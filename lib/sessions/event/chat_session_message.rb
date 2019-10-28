class Sessions::Event::ChatSessionMessage < Sessions::Event::ChatBase

  def run
    return super if super
    return if !check_chat_session_exists

    chat_session = current_chat_session

    user_id = nil
    if @session
      user_id = @session['id']
    end
    chat_message = Chat::Message.create(
      chat_session_id: chat_session.id,
      content:         @payload['data']['content'],
      created_by_id:   user_id,
    )
    message = {
      event: 'chat_session_message',
      data:  {
        session_id: chat_session.session_id,
        message:    chat_message,
      },
    }

    # send to participents
    chat_session.send_to_recipients(message, @client_id)

    # send chat_session_init to agent
    {
      event: 'chat_session_message',
      data:  {
        session_id:   chat_session.session_id,
        message:      chat_message,
        self_written: true,
      },
    }

  end

end
