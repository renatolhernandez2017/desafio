class Api::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    user = User.new(user_params)

    if user.save
      token = Rails.application.message_verifier(:user).generate(user.id)
      UserMailer.welcome(user).deliver_now
      session[:user_id] = user.id
      render json: {success: true, token: token, user: user.slice(:id, :name, :username, :email)}, status: :created
    else
      render json: {success: false, error: user.errors.full_messages.join(", ")}, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:name, :username, :email, :password, :password_confirmation)
  end
end
