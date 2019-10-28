class ExternalCredential::Twitter

  def self.app_verify(params)
    register_webhook(params)
  end

  def self.request_account_to_link(credentials = {}, app_required = true)
    external_credential = ExternalCredential.find_by(name: 'twitter')
    raise Exceptions::UnprocessableEntity, 'No twitter app configured!' if !external_credential && app_required

    if external_credential
      if credentials[:consumer_key].blank?
        credentials[:consumer_key] = external_credential.credentials['consumer_key']
      end
      if credentials[:consumer_secret].blank?
        credentials[:consumer_secret] = external_credential.credentials['consumer_secret']
      end
    end

    raise Exceptions::UnprocessableEntity, 'No consumer_key param!' if credentials[:consumer_key].blank?
    raise Exceptions::UnprocessableEntity, 'No consumer_secret param!' if credentials[:consumer_secret].blank?

    consumer = OAuth::Consumer.new(
      credentials[:consumer_key],
      credentials[:consumer_secret], {
        site: 'https://api.twitter.com'
      }
    )
    begin
      request_token = consumer.get_request_token(oauth_callback: ExternalCredential.callback_url('twitter'))
    rescue => e
      if e.message == '403 Forbidden'
        raise "#{e.message}, maybe credentials wrong or callback_url for application wrong configured."
      end

      raise e
    end

    {
      request_token: request_token,
      authorize_url: request_token.authorize_url,
    }
  end

  def self.link_account(request_token, params)
    external_credential = ExternalCredential.find_by(name: 'twitter')
    raise Exceptions::UnprocessableEntity, 'No twitter app configured!' if !external_credential
    raise Exceptions::UnprocessableEntity, 'No request_token for session found!' if !request_token
    raise Exceptions::UnprocessableEntity, 'Invalid oauth_token given!' if request_token.params[:oauth_token] != params[:oauth_token]

    access_token = request_token.get_access_token(oauth_verifier: params[:oauth_verifier])
    client = TwitterSync.new(
      consumer_key:        external_credential.credentials[:consumer_key],
      consumer_secret:     external_credential.credentials[:consumer_secret],
      access_token:        access_token.token,
      access_token_secret: access_token.secret,
    )
    client_user = client.who_am_i
    client_user_id = client_user.id

    # check if account already exists
    Channel.where(area: 'Twitter::Account').each do |channel|
      next if !channel.options
      next if !channel.options['user']
      next if !channel.options['user']['id']
      next if channel.options['user']['id'] != client_user_id && channel.options['user']['screen_name'] != client_user.screen_name

      channel.options['user']['id'] = client_user_id
      channel.options['user']['screen_name'] = client_user.screen_name
      channel.options['user']['name'] = client_user.name

      # update access_token
      channel.options['auth']['external_credential_id'] = external_credential.id
      channel.options['auth']['oauth_token'] = access_token.token
      channel.options['auth']['oauth_token_secret'] = access_token.secret
      channel.save!

      subscribe_webhook(
        channel:             channel,
        client:              client,
        external_credential: external_credential,
      )

      return channel
    end

    # create channel
    channel = Channel.create!(
      area:          'Twitter::Account',
      options:       {
        adapter: 'twitter',
        user:    {
          id:          client_user_id,
          screen_name: client_user.screen_name,
          name:        client_user.name,
        },
        auth:    {
          external_credential_id: external_credential.id,
          oauth_token:            access_token.token,
          oauth_token_secret:     access_token.secret,
        },
        sync:    {
          limit:           20,
          search:          [],
          mentions:        {},
          direct_messages: {},
          track_retweets:  false
        }
      },
      active:        true,
      created_by_id: 1,
      updated_by_id: 1,
    )

    subscribe_webhook(
      channel:             channel,
      client:              client,
      external_credential: external_credential,
    )

    channel
  end

  def self.webhook_url
    "#{Setting.get('http_type')}://#{Setting.get('fqdn')}#{Rails.configuration.api_path}/channels_twitter_webhook"
  end

  def self.register_webhook(params)
    request_account_to_link(params, false)

    raise Exceptions::UnprocessableEntity, 'No consumer_key param!' if params[:consumer_key].blank?
    raise Exceptions::UnprocessableEntity, 'No consumer_secret param!' if params[:consumer_secret].blank?
    raise Exceptions::UnprocessableEntity, 'No oauth_token param!' if params[:oauth_token].blank?
    raise Exceptions::UnprocessableEntity, 'No oauth_token_secret param!' if params[:oauth_token_secret].blank?

    return if params[:env].blank?

    env_name = params[:env]

    client = TwitterSync.new(
      consumer_key:        params[:consumer_key],
      consumer_secret:     params[:consumer_secret],
      access_token:        params[:oauth_token],
      access_token_secret: params[:oauth_token_secret],
    )

    # needed for verify callback
    Cache.write('external_credential_twitter', {
                  consumer_key:        params[:consumer_key],
                  consumer_secret:     params[:consumer_secret],
                  access_token:        params[:oauth_token],
                  access_token_secret: params[:oauth_token_secret],
                })

    # verify if webhook is already registered
    begin
      webhooks = client.webhooks_by_env_name(env_name)
    rescue
      begin
        webhooks = client.webhooks
        raise "Unable to get list of webooks. You use the wrong 'Dev environment label', only #{webhooks.inspect} available."
      rescue => e
        raise "Unable to get list of webooks. Maybe you do not have an Twitter developer approval right now or you use the wrong 'Dev environment label': #{e.message}"
      end
    end
    webhook_id = nil
    webhook_valid = nil
    webhooks.each do |webhook|
      next if webhook[:url] != webhook_url

      webhook_id = webhook[:id]
      webhook_valid = webhook[:valid]
    end

    # if webhook is already registered
    # - in case if webhook is invalid, just send a new verification request
    # - in case if webhook is valid return
    if webhook_id
      if webhook_valid == false
        client.webhook_request_verification(webhook_id, env_name, webhook_url)
      end
      params[:webhook_id] = webhook_id
      return params
    end

    # delete already registered webhooks
    webhooks.each do |webhook|
      client.webhook_delete(webhook[:id], env_name)
    end

    # register new webhook
    response = client.webhook_register(env_name, webhook_url)

    params[:webhook_id] = response[:id]
    params
  end

  def self.subscribe_webhook(channel:, client:, external_credential:)
    env_name = external_credential.credentials[:env]
    webhook_id = external_credential.credentials[:webhook_id]

    Rails.logger.debug { "Starting Twitter subscription for webhook_id #{webhook_id} and Channel #{channel.id}" }
    client.webhook_subscribe(env_name)

    channel.options['subscribed_to_webhook_id'] = webhook_id
    channel.save!

    true
  end

end
