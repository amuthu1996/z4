class Sessions::Event::ChatSessionNotice < Sessions::Event::ChatBase

  def run
    return super if super
    return if !check_chat_session_exists

    chat_session = current_chat_session
    return if !chat_session
    return if !@payload['data']['message']

    message = {
      event: 'chat_session_notice',
      data:  {
        session_id: chat_session.session_id,
        message:    @payload['data']['message'],
      },
    }
    chat_session.send_to_recipients(message, @client_id)

    nil
  end

end
