class Api::MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_message, only: %i[update destroy]

  def index
    messages = if params[:query].present?
      Message.search_full_text(params[:query]).includes(:user).reorder(created_at: :desc)
    else
      Message.includes(:user).order(created_at: :desc)
    end

    render json: messages.map { |message|
      {
        id: message.id,
        content: message.content,
        created_at: message.created_at,
        user: {name: message.user.name}
      }
    }
  end

  def create
    room = params[:message][:room]

    message = Message.create!(
      content: params[:message][:content],
      user: current_user
    )

    if message.present?
      ActionCable.server.broadcast(
        "chat_#{room}",
        {
          id: message.id,
          content: message.content,
          user: current_user.name,
          created_at: message.created_at
        }
      )

      render json: message
    else
      head :unauthorized
    end
  end

  def update
    if @message.user == current_user
      @message.update!(content: params[:content])
      room = params[:room]

      ActionCable.server.broadcast(
        "chat_#{room}",
        {
          id: @message.id,
          content: @message.content,
          created_at: @message.created_at,
          user: @message.user.name
        }
      )

      render json: {content: @message.content}
    else
      head :unauthorized
    end
  end

  def destroy
    if @message.user == current_user
      @message.destroy
      head :no_content
    else
      head :unauthorized
    end
  end

  private

  def set_message
    @message = Message.find(params[:id])
  end
end
