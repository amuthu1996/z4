class Sessions::Event::ChatSessionInit < Sessions::Event::ChatBase

  def run
    return super if super
    return if !check_chat_exists

    # geo ip lookup
    geo_ip = nil
    if @remote_ip
      geo_ip = Service::GeoIp.location(@remote_ip)
    end

    # dns lookup
    dns_name = nil
    if @remote_ip
      begin
        dns = Resolv::DNS.new
        dns.timeouts = 3
        result = dns.getname @remote_ip
        if result
          dns_name = result.to_s
        end
      rescue => e
        Rails.logger.error e
      end
    end

    # create chat session
    chat_session = Chat::Session.create(
      chat_id:     @payload['data']['chat_id'],
      name:        '',
      state:       'waiting',
      preferences: {
        url:          @payload['data']['url'],
        participants: [@client_id],
        remote_ip:    @remote_ip,
        geo_ip:       geo_ip,
        dns_name:     dns_name,
      },
    )

    # send broadcast to agents
    Chat.broadcast_agent_state_update

    # return new session
    {
      event: 'chat_session_queue',
      data:  {
        state:      'queue',
        position:   Chat.waiting_chat_count,
        session_id: chat_session.session_id,
      },
    }
  end

end
