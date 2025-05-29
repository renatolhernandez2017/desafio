class MessagesController < ApplicationController
  before_action :authorize_user, only: %i[update destroy]

  def authorize_user
    @message = Message.find(params[:id])
    head :forbidden unless @message.user == current_user
  end
end
