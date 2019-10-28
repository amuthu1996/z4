class SettingSendNoAutoResponseRegExp < ActiveRecord::Migration[5.0]
  def up

    # return if it's a new setup
    return if !Setting.find_by(name: 'system_init_done')

    # improved domain name matching
    return if !Setting.find_by(name: 'send_no_auto_response_reg_exp')

    Setting.set('send_no_auto_response_reg_exp', '(mailer-daemon|postmaster|abuse|root|noreply|noreply.+?|no-reply|no-reply.+?)@.+?')
  end

end
