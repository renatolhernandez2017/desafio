class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, only: %i[update destroy]

  def index
    @messages = Message.includes(:user).order(:created_at)
  end

  private

  def authorize_user
    @message = Message.find(params[:id])
    head :forbidden unless @message.user == current_user
  end
end
