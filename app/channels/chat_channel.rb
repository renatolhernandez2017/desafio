class ChatChannel < ApplicationCable::Channel
  def subscribed
    # O cliente se inscreve em um canal nomeado, como "chat_geral"
    stream_from "chat_#{params[:room]}"
  end

  def unsubscribed
    # Cleanup quando o cliente se desconecta (opcional)
  end

  def receive(data)
    # Recebe mensagens do cliente e repassa para todos no canal

    ActionCable.server.broadcast(
      "chat_#{params[:room]}",
      {
        content: data["content"],
        user: data["user"],
        created_at: Time.now.strftime("%H:%M:%S")
      }
    )
  end
end
