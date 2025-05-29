class Api::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    user = User.new(user_params)

    if user.save
      render json: { success: true, user: user.slice(:id, :name, :username, :email) }, status: :created
    else
      render json: { success: false, error: user.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:name, :username, :email, :password, :password_confirmation)
  end
end
