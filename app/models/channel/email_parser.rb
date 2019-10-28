# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

# encoding: utf-8

class Channel::EmailParser
  PROZESS_TIME_MAX = 180
  EMAIL_REGEX = /.+@.+/.freeze
  RECIPIENT_FIELDS = %w[to cc delivered-to x-original-to envelope-to].freeze
  SENDER_FIELDS = %w[from reply-to return-path sender].freeze
  EXCESSIVE_LINKS_MSG = 'This message cannot be displayed because it contains over 5,000 links. Download the raw message below and open it via an Email client if you still wish to view it.'.freeze

=begin

  parser = Channel::EmailParser.new
  mail = parser.parse(msg_as_string)

  mail = {
    from:              'Some Name <some@example.com>',
    from_email:        'some@example.com',
    from_local:        'some',
    from_domain:       'example.com',
    from_display_name: 'Some Name',
    message_id:        'some_message_id@example.com',
    to:                'Some System <system@example.com>',
    cc:                'Somebody <somebody@example.com>',
    subject:           'some message subject',
    body:              'some message body',
    content_type:      'text/html', # text/plain
    date:              Time.zone.now,
    attachments:       [
      {
        data:        'binary of attachment',
        filename:    'file_name_of_attachment.txt',
        preferences: {
          'content-alternative' => true,
          'Mime-Type'           => 'text/plain',
          'Charset:             => 'iso-8859-1',
        },
      },
    ],

    # ignore email header
    x-zammad-ignore: 'false',

    # customer headers
    x-zammad-customer-login:     '',
    x-zammad-customer-email:     '',
    x-zammad-customer-firstname: '',
    x-zammad-customer-lastname:  '',

    # ticket headers (for new tickets)
    x-zammad-ticket-group:    'some_group',
    x-zammad-ticket-state:    'some_state',
    x-zammad-ticket-priority: 'some_priority',
    x-zammad-ticket-owner:    'some_owner_login',

    # ticket headers (for existing tickets)
    x-zammad-ticket-followup-group:    'some_group',
    x-zammad-ticket-followup-state:    'some_state',
    x-zammad-ticket-followup-priority: 'some_priority',
    x-zammad-ticket-followup-owner:    'some_owner_login',

    # article headers
    x-zammad-article-internal: false,
    x-zammad-article-type:     'agent',
    x-zammad-article-sender:   'customer',

    # all other email headers
    some-header: 'some_value',
  }

=end

  def parse(msg)
    msg = msg.force_encoding('binary')
    # mail 2.6 and earlier accepted non-conforming mails that lacked the correct CRLF seperators,
    # mail 2.7 and above require CRLF so we force it on using binary_unsafe_to_crlf
    msg = Mail::Utilities.binary_unsafe_to_crlf(msg)
    mail = Mail.new(msg)

    headers = message_header_hash(mail)
    body = message_body_hash(mail)
    message_attributes = [
      { mail_instance: mail },
      headers,
      body,
      self.class.sender_attributes(headers),
    ]
    message_attributes.reduce({}.with_indifferent_access, &:merge)
  end

=begin

  parser = Channel::EmailParser.new
  ticket, article, user, mail = parser.process(channel, email_raw_string)

returns

  [ticket, article, user, mail]

do not raise an exception - e. g. if used by scheduler

  parser = Channel::EmailParser.new
  ticket, article, user, mail = parser.process(channel, email_raw_string, false)

returns

  [ticket, article, user, mail] || false

=end

  def process(channel, msg, exception = true)

    Timeout.timeout(PROZESS_TIME_MAX) do
      _process(channel, msg)
    end
  rescue => e
    # store unprocessable email for bug reporting
    filename = archive_mail('unprocessable_mail', msg)

    message = "ERROR: Can't process email, you will find it for bug reporting under #{filename}, please create an issue at https://github.com/zammad/zammad/issues"

    p message # rubocop:disable Rails/Output
    p 'ERROR: ' + e.inspect # rubocop:disable Rails/Output
    Rails.logger.error message
    Rails.logger.error e

    return false if exception == false

    raise e.inspect + "\n" + e.backtrace.join("\n")
  end

  def _process(channel, msg)

    # parse email
    mail = parse(msg)

    Rails.logger.info "Process email with msgid '#{mail[:message_id]}'"

    # run postmaster pre filter
    UserInfo.current_user_id = 1
    filters = {}
    Setting.where(area: 'Postmaster::PreFilter').order(:name).each do |setting|
      filters[setting.name] = Setting.get(setting.name).constantize
    end
    filters.each do |key, backend|
      Rails.logger.debug { "run postmaster pre filter #{key}: #{backend}" }
      begin
        backend.run(channel, mail)
      rescue => e
        Rails.logger.error "can't run postmaster pre filter #{key}: #{backend}"
        Rails.logger.error e.inspect
        raise e
      end
    end

    # check ignore header
    if mail['x-zammad-ignore'.to_sym] == 'true' || mail['x-zammad-ignore'.to_sym] == true
      Rails.logger.info "ignored email with msgid '#{mail[:message_id]}' from '#{mail[:from]}' because of x-zammad-ignore header"
      return
    end

    # set interface handle
    original_interface_handle = ApplicationHandleInfo.current

    ticket       = nil
    article      = nil
    session_user = nil

    # use transaction
    Transaction.execute(interface_handle: "#{original_interface_handle}.postmaster") do

      # get sender user
      session_user_id = mail['x-zammad-session-user-id'.to_sym]
      if !session_user_id
        raise 'No x-zammad-session-user-id, no sender set!'
      end

      session_user = User.lookup(id: session_user_id)
      if !session_user
        raise "No user found for x-zammad-session-user-id: #{session_user_id}!"
      end

      # set current user
      UserInfo.current_user_id = session_user.id

      # get ticket# based on email headers
      if mail['x-zammad-ticket-id'.to_sym]
        ticket = Ticket.find_by(id: mail['x-zammad-ticket-id'.to_sym])
      end
      if mail['x-zammad-ticket-number'.to_sym]
        ticket = Ticket.find_by(number: mail['x-zammad-ticket-number'.to_sym])
      end

      # set ticket state to open if not new
      if ticket
        set_attributes_by_x_headers(ticket, 'ticket', mail, 'followup')

        # save changes set by x-zammad-ticket-followup-* headers
        ticket.save! if ticket.has_changes_to_save?

        # set ticket to open again or keep create state
        if !mail['x-zammad-ticket-followup-state'.to_sym] && !mail['x-zammad-ticket-followup-state_id'.to_sym]
          new_state = Ticket::State.find_by(default_create: true)
          if ticket.state_id != new_state.id && !mail['x-zammad-out-of-office'.to_sym]
            ticket.state = Ticket::State.find_by(default_follow_up: true)
            ticket.save!
          end
        end
      end

      # create new ticket
      if !ticket

        preferences = {}
        if channel[:id]
          preferences = {
            channel_id: channel[:id]
          }
        end

        # get default group where ticket is created
        group = nil
        if channel[:group_id]
          group = Group.lookup(id: channel[:group_id])
        end
        if group.blank? || group.active == false
          group = Group.where(active: true).order(id: :asc).first
        end
        if group.blank?
          group = Group.first
        end
        title = mail[:subject]
        if title.blank?
          title = '-'
        end
        ticket = Ticket.new(
          group_id:    group.id,
          title:       title,
          preferences: preferences,
        )
        set_attributes_by_x_headers(ticket, 'ticket', mail)

        # create ticket
        ticket.save!

      end

      # apply tags to ticket
      if mail['x-zammad-ticket-tags'.to_sym].present?
        mail['x-zammad-ticket-tags'.to_sym].each do |tag|
          ticket.tag_add(tag)
        end
      end

      # set attributes
      ticket.with_lock do
        article = Ticket::Article.new(
          ticket_id:    ticket.id,
          type_id:      Ticket::Article::Type.find_by(name: 'email').id,
          sender_id:    Ticket::Article::Sender.find_by(name: 'Customer').id,
          content_type: mail[:content_type],
          body:         mail[:body],
          from:         mail[:from],
          reply_to:     mail[:"reply-to"],
          to:           mail[:to],
          cc:           mail[:cc],
          subject:      mail[:subject],
          message_id:   mail[:message_id],
          internal:     false,
        )

        # x-headers lookup
        set_attributes_by_x_headers(article, 'article', mail)

        # create article
        article.save!

        # store mail plain
        article.save_as_raw(msg)

        # store attachments
        mail[:attachments]&.each do |attachment|
          filename = attachment[:filename].force_encoding('utf-8')
          if !filename.force_encoding('UTF-8').valid_encoding?
            filename = filename.utf8_encode(fallback: :read_as_sanitized_binary)
          end
          Store.add(
            object:      'Ticket::Article',
            o_id:        article.id,
            data:        attachment[:data],
            filename:    filename,
            preferences: attachment[:preferences]
          )
        end
      end
    end

    ticket.reload
    article.reload
    session_user.reload

    # run postmaster post filter
    filters = {}
    Setting.where(area: 'Postmaster::PostFilter').order(:name).each do |setting|
      filters[setting.name] = Setting.get(setting.name).constantize
    end
    filters.each_value do |backend|
      Rails.logger.debug { "run postmaster post filter #{backend}" }
      begin
        backend.run(channel, mail, ticket, article, session_user)
      rescue => e
        Rails.logger.error "can't run postmaster post filter #{backend}"
        Rails.logger.error e.inspect
      end
    end

    # return new objects
    [ticket, article, session_user, mail]
  end

  def self.check_attributes_by_x_headers(header_name, value)
    class_name = nil
    attribute = nil
    # skip check attributes if it is tags
    return true if header_name == 'x-zammad-ticket-tags'

    if header_name =~ /^x-zammad-(.+?)-(followup-|)(.*)$/i
      class_name = $1
      attribute = $3
    end
    return true if !class_name

    if class_name.casecmp('article').zero?
      class_name = 'Ticket::Article'
    end
    return true if !attribute

    key_short = attribute[ attribute.length - 3, attribute.length ]
    return true if key_short != '_id'

    class_object = class_name.to_classname.constantize
    return if !class_object

    class_instance = class_object.new

    return false if !class_instance.association_id_validation(attribute, value)

    true
  end

  def self.sender_attributes(from)
    if from.is_a?(HashWithIndifferentAccess)
      from = SENDER_FIELDS.map { |f| from[f] }.compact
                          .map(&:to_utf8).reject(&:blank?)
                          .partition { |address| address.match?(EMAIL_REGEX) }
                          .flatten.first
    end

    data = {}.with_indifferent_access
    return data if from.blank?

    from = from.gsub('<>', '').strip
    mail_address = begin
                     Mail::AddressList.new(from).addresses
                                      .select { |a| a.address.present? }
                                      .partition { |a| a.address.match?(EMAIL_REGEX) }
                                      .flatten.first
                   rescue Mail::Field::ParseError => e
                     STDOUT.puts e
                   end

    if mail_address&.address.present?
      data[:from_email]        = mail_address.address
      data[:from_local]        = mail_address.local
      data[:from_domain]       = mail_address.domain
      data[:from_display_name] = mail_address.display_name || mail_address.comments&.first
    elsif from =~ /^(.+?)<((.+?)@(.+?))>/
      data[:from_email]        = $2
      data[:from_local]        = $3
      data[:from_domain]       = $4
      data[:from_display_name] = $1
    else
      data[:from_email]        = from
      data[:from_local]        = from
      data[:from_domain]       = from
      data[:from_display_name] = from
    end

    # do extra decoding because we needed to use field.value
    data[:from_display_name] =
      Mail::Field.new('X-From', data[:from_display_name].to_utf8)
                 .to_s
                 .delete('"')
                 .strip
                 .gsub(/(^'|'$)/, '')

    data
  end

  def set_attributes_by_x_headers(item_object, header_name, mail, suffix = false)

    # loop all x-zammad-header-* headers
    item_object.attributes.each_key do |key|

      # ignore read only attributes
      next if key == 'updated_by_id'
      next if key == 'created_by_id'

      # check if id exists
      key_short = key[ key.length - 3, key.length ]
      if key_short == '_id'
        key_short = key[ 0, key.length - 3 ]
        header = "x-zammad-#{header_name}-#{key_short}"
        if suffix
          header = "x-zammad-#{header_name}-#{suffix}-#{key_short}"
        end

        # only set value on _id if value/reference lookup exists
        if mail[header.to_sym]

          Rails.logger.info "set_attributes_by_x_headers header #{header} found #{mail[header.to_sym]}"
          item_object.class.reflect_on_all_associations.map do |assoc|

            next if assoc.name.to_s != key_short

            Rails.logger.info "set_attributes_by_x_headers found #{assoc.class_name} lookup for '#{mail[header.to_sym]}'"
            item = assoc.class_name.constantize
            assoc_object = nil
            if item.new.respond_to?(:name)
              assoc_object = item.lookup(name: mail[header.to_sym])
            end
            if !assoc_object && item.new.respond_to?(:login)
              assoc_object = item.lookup(login: mail[header.to_sym])
            end
            if !assoc_object && item.new.respond_to?(:email)
              assoc_object = item.lookup(email: mail[header.to_sym])
            end

            if assoc_object.blank?

              # no assoc exists, remove header
              mail.delete(header.to_sym)
              next
            end

            Rails.logger.info "set_attributes_by_x_headers assign #{item_object.class} #{key}=#{assoc_object.id}"

            item_object[key] = assoc_object.id

          end
        end
      end

      # check if attribute exists
      header = "x-zammad-#{header_name}-#{key}"
      if suffix
        header = "x-zammad-#{header_name}-#{suffix}-#{key}"
      end
      if mail[header.to_sym]
        Rails.logger.info "set_attributes_by_x_headers header #{header} found. Assign #{key}=#{mail[header.to_sym]}"
        item_object[key] = mail[header.to_sym]
      end
    end
  end

=begin

process unprocessable_mails (tmp/unprocessable_mail/*.eml) again

  Channel::EmailParser.process_unprocessable_mails

=end

  def self.process_unprocessable_mails(params = {})
    path = Rails.root.join('tmp', 'unprocessable_mail')
    files = []
    Dir.glob("#{path}/*.eml") do |entry|
      ticket, _article, _user, _mail = Channel::EmailParser.new.process(params, IO.binread(entry))
      next if ticket.blank?

      files.push entry
      File.delete(entry)
    end
    files
  end

=begin

  process oversized emails by:
  1. Archiving the oversized mail as tmp/oversized_mail/md5.eml
  2. Reply with a postmaster message to inform the sender

=end

  def process_oversized_mail(channel, msg)
    archive_mail('oversized_mail', msg)
    postmaster_response(channel, msg)
  end

  private

  def message_header_hash(mail)
    imported_fields = mail.header.fields.map do |f|
      begin
        value = f.to_utf8
        if value.blank?
          value = f.decoded.to_utf8
        end
      # fields that cannot be cleanly parsed fallback to the empty string
      rescue Mail::Field::IncompleteParseError
        value = ''
      rescue
        value = f.decoded.to_utf8(fallback: :read_as_sanitized_binary)
      end
      [f.name.downcase, value]
    end.to_h

    # imported_fields = mail.header.fields.map { |f| [f.name.downcase, f.to_utf8] }.to_h
    raw_fields = mail.header.fields.map { |f| ["raw-#{f.name.downcase}", f] }.to_h
    custom_fields = {}.tap do |h|
      h.replace(imported_fields.slice(*RECIPIENT_FIELDS)
                               .transform_values { |v| v.match?(EMAIL_REGEX) ? v : '' })

      h['x-any-recipient'] = h.values.select(&:present?).join(', ')
      h['message_id']      = imported_fields['message-id']
      h['subject']         = imported_fields['subject']
      begin
        h['date'] = Time.zone.parse(mail.date.to_s) || imported_fields['date']
      rescue
        h['date'] = nil
      end
    end

    [imported_fields, raw_fields, custom_fields].reduce({}.with_indifferent_access, &:merge)
  end

  def message_body_hash(mail)
    message = [mail.html_part, mail.text_part, mail].find { |m| m&.body.present? }

    if message.present? && (message.mime_type.nil? || message.mime_type.match?(%r{^text/(plain|html)$}))
      content_type = message.mime_type || 'text/plain'
      body = body_text(message, strict_html: content_type.eql?('text/html'))
    end

    content_type = 'text/plain' if body.blank?

    {
      attachments:  collect_attachments(mail),
      content_type: content_type || 'text/plain',
      body:         body.presence || 'no visible content'
    }.with_indifferent_access
  end

  def body_text(message, **options)
    body_text = begin
                  message.body.to_s
                rescue Mail::UnknownEncodingType # see test/data/mail/mail043.box / issue #348
                  message.body.raw_source
                end

    body_text = body_text.utf8_encode(from: message.charset, fallback: :read_as_sanitized_binary)
    body_text = Mail::Utilities.to_lf(body_text)

    # plaintext body requires no processing
    return body_text if !options[:strict_html]

    # Issue #2390 - emails with >5k HTML links should be rejected
    return EXCESSIVE_LINKS_MSG if body_text.scan(/<a[[:space:]]/i).count >= 5_000

    body_text.html2html_strict
  end

  def collect_attachments(mail)
    attachments = []

    # Add non-plaintext body as an attachment
    if mail.html_part&.body.present? ||
       (!mail.multipart? && mail.mime_type.present? && mail.mime_type != 'text/plain')
      message = mail.html_part || mail

      filename = message.filename.presence ||
                 (message.mime_type.eql?('text/html') ? 'message.html' : '-no name-')

      headers_store = {
        'content-alternative' => true,
        'original-format'     => message.mime_type.eql?('text/html'),
        'Mime-Type'           => message.mime_type,
        'Charset'             => message.charset,
      }.reject { |_, v| v.blank? }

      attachments.push({ data:        body_text(message),
                         filename:    filename,
                         preferences: headers_store })
    end

    mail.parts.each do |part|

      new_attachments = get_attachments(part, attachments, mail).flatten.compact
      attachments.push(*new_attachments)
    rescue => e # Protect process to work with spam emails (see test/fixtures/mail15.box)
      raise e if (fail_count ||= 0).positive?

      (fail_count += 1) && retry

    end

    attachments
  end

  def get_attachments(file, attachments, mail)
    return file.parts.map { |p| get_attachments(p, attachments, mail) } if file.parts.any?
    return [] if [mail.text_part&.body&.encoded, mail.html_part&.body&.encoded].include?(file.body.encoded)

    # get file preferences
    headers_store = {}
    file.header.fields.each do |field|

      # full line, encode, ready for storage
      value = field.to_utf8
      if value.blank?
        value = field.raw_value
      end
      headers_store[field.name.to_s] = value
    rescue
      headers_store[field.name.to_s] = field.raw_value
    end

    # cleanup content id, <> will be added automatically later
    if headers_store['Content-ID']
      headers_store['Content-ID'].gsub!(/^</, '')
      headers_store['Content-ID'].gsub!(/>$/, '')
    end

    # get filename from content-disposition

    # workaround for: NoMethodError: undefined method `filename' for #<Mail::UnstructuredField:0x007ff109e80678>
    begin
      filename = file.header[:content_disposition].try(:filename)
    rescue
      begin
        if file.header[:content_disposition].to_s =~ /(filename|name)(\*{0,1})="(.+?)"/i
          filename = $3
        elsif file.header[:content_disposition].to_s =~ /(filename|name)(\*{0,1})='(.+?)'/i
          filename = $3
        elsif file.header[:content_disposition].to_s =~ /(filename|name)(\*{0,1})=(.+?);/i
          filename = $3
        end
      rescue
        Rails.logger.debug { 'Unable to get filename' }
      end
    end

    begin
      if file.header[:content_disposition].to_s =~ /(filename|name)(\*{0,1})="(.+?)"/i
        filename = $3
      elsif file.header[:content_disposition].to_s =~ /(filename|name)(\*{0,1})='(.+?)'/i
        filename = $3
      elsif file.header[:content_disposition].to_s =~ /(filename|name)(\*{0,1})=(.+?);/i
        filename = $3
      end
    rescue
      Rails.logger.debug { 'Unable to get filename' }
    end

    # as fallback, use raw values
    if filename.blank?
      if headers_store['Content-Disposition'].to_s =~ /(filename|name)(\*{0,1})="(.+?)"/i
        filename = $3
      elsif headers_store['Content-Disposition'].to_s =~ /(filename|name)(\*{0,1})='(.+?)'/i
        filename = $3
      elsif headers_store['Content-Disposition'].to_s =~ /(filename|name)(\*{0,1})=(.+?);/i
        filename = $3
      end
    end

    # for some broken sm mail clients (X-MimeOLE: Produced By Microsoft Exchange V6.5)
    filename ||= file.header[:content_location].to_s.force_encoding('utf-8')

    # generate file name based on content-id
    if filename.blank? && headers_store['Content-ID'].present?
      if headers_store['Content-ID'] =~ /(.+?)@.+?/i
        filename = $1
      end
    end

    # generate file name based on content type
    if filename.blank? && headers_store['Content-Type'].present? && headers_store['Content-Type'].match?(%r{^message/rfc822}i)
      begin
        parser = Channel::EmailParser.new
        mail_local = parser.parse(file.body.to_s)
        filename = if mail_local[:subject].present?
                     "#{mail_local[:subject]}.eml"
                   elsif headers_store['Content-Description'].present?
                     "#{headers_store['Content-Description']}.eml".to_s.force_encoding('utf-8')
                   else
                     'Mail.eml'
                   end
      rescue
        filename = 'Mail.eml'
      end
    end

    # e. g. Content-Type: video/quicktime; name="Video.MOV";
    if filename.blank?
      ['(filename|name)(\*{0,1})="(.+?)"(;|$)', '(filename|name)(\*{0,1})=\'(.+?)\'(;|$)', '(filename|name)(\*{0,1})=(.+?)(;|$)'].each do |regexp|
        if headers_store['Content-Type'] =~ /#{regexp}/i
          filename = $3
          break
        end
      end
    end

    # workaround for mail gem - decode filenames
    # https://github.com/zammad/zammad/issues/928
    if filename.present?
      filename = Mail::Encodings.value_decode(filename)
    end

    if !filename.force_encoding('UTF-8').valid_encoding?
      filename = filename.utf8_encode(fallback: :read_as_sanitized_binary)
    end

    # e. g. Content-Type: video/quicktime
    if filename.blank?
      map = {
        'message/delivery-status': %w[txt delivery-status],
        'text/plain':              %w[txt document],
        'text/html':               %w[html document],
        'video/quicktime':         %w[mov video],
        'image/jpeg':              %w[jpg image],
        'image/jpg':               %w[jpg image],
        'image/png':               %w[png image],
        'image/gif':               %w[gif image],
      }
      map.each do |type, ext|
        next if !headers_store['Content-Type'].match?(/^#{Regexp.quote(type)}/i)

        filename = if headers_store['Content-Description'].present?
                     "#{headers_store['Content-Description']}.#{ext[0]}".to_s.force_encoding('utf-8')
                   else
                     "#{ext[1]}.#{ext[0]}"
                   end
        break
      end
    end

    # set fallback filename
    if filename.blank?
      filename = 'file'
    end

    # create uniq filename
    local_filename = ''
    local_extention = ''
    if filename =~ /^(.*?)\.(.+?)$/
      local_filename = $1
      local_extention = $2
    end
    1.upto(1000) do |i|
      filename_exists = false
      attachments.each do |attachment|
        if attachment[:filename] == filename
          filename_exists = true
        end
      end
      break if filename_exists == false

      filename = if local_extention.present?
                   "#{local_filename}#{i}.#{local_extention}"
                 else
                   "#{local_filename}#{i}"
                 end
    end

    # get mime type
    if file.header[:content_type]&.string
      headers_store['Mime-Type'] = file.header[:content_type].string
    end

    # get charset
    if file.header&.charset
      headers_store['Charset'] = file.header.charset
    end

    # remove not needed header
    headers_store.delete('Content-Transfer-Encoding')
    headers_store.delete('Content-Disposition')

    attach = {
      data:        file.body.to_s,
      filename:    filename,
      preferences: headers_store,
    }

    [attach]
  end

  # Archive the given message as tmp/folder/md5.eml
  def archive_mail(folder, msg)
    path = Rails.root.join('tmp', folder)
    FileUtils.mkpath path

    # MD5 hash the msg and save it as "md5.eml"
    md5 = Digest::MD5.hexdigest(msg)
    file_path = Rails.root.join('tmp', folder, "#{md5}.eml")

    File.open(file_path, 'wb') do |file|
      file.write msg
    end

    file_path
  end

  # Auto reply as the postmaster to oversized emails with:
  # [undeliverable] Message too large
  def postmaster_response(channel, msg)
    begin
      reply_mail = compose_postmaster_reply(msg)
    rescue NotificationFactory::FileNotFoundError => e
      Rails.logger.error 'No valid postmaster email_oversized template found. Skipping postmaster reply. ' + e.inspect
      return
    end

    Rails.logger.error "Send mail too large postmaster message to: #{reply_mail[:to]}"
    reply_mail[:from] = EmailAddress.find_by(channel: channel).email
    channel.deliver(reply_mail)
  rescue => e
    Rails.logger.error "Error during sending of postmaster oversized email auto-reply: #{e.inspect}\n#{e.backtrace}"
  end

  # Compose a "Message too large" reply to the given message
  def compose_postmaster_reply(raw_incoming_mail, locale = nil)
    parsed_incoming_mail = Channel::EmailParser.new.parse(raw_incoming_mail)

    # construct a dummy mail object
    mail = OpenStruct.new
    mail.from_display_name = parsed_incoming_mail[:from_display_name]
    mail.subject = parsed_incoming_mail[:subject]
    mail.msg_size = format('%.2f', raw_incoming_mail.size.to_f / 1024 / 1024)

    reply = NotificationFactory::Mailer.template(
      template:   'email_oversized',
      locale:     locale,
      format:     'txt',
      objects:    {
        mail: mail,
      },
      raw:        true, # will not add application template
      standalone: true, # default: false - will send header & footer
    )

    reply.merge(
      to:            parsed_incoming_mail[:from_email],
      body:          reply[:body].gsub(/\n/, "\r\n"),
      content_type:  'text/plain',
      References:    parsed_incoming_mail[:message_id],
      'In-Reply-To': parsed_incoming_mail[:message_id],
    )
  end
end

module Mail

  # workaround to get content of no parseable headers - in most cases with non 7 bit ascii signs
  class Field
    def raw_value
      begin
        value = @raw_value.try(:utf8_encode)
      rescue
        value = @raw_value.utf8_encode(fallback: :read_as_sanitized_binary)
      end
      return value if value.blank?

      value.sub(/^.+?:(\s|)/, '')
    end
  end

  # issue#348 - IMAP mail fetching stops because of broken spam email (e. g. broken Content-Transfer-Encoding value see test/fixtures/mail43.box)
  # https://github.com/zammad/zammad/issues/348
  class Body
    def decoded
      if !Encodings.defined?(encoding)
        #raise UnknownEncodingType, "Don't know how to decode #{encoding}, please call #encoded and decode it yourself."
        Rails.logger.info "UnknownEncodingType: Don't know how to decode #{encoding}!"
        raw_source
      else
        Encodings.get_encoding(encoding).decode(raw_source)
      end
    end
  end

end
