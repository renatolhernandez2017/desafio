class Api::SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    user = User.find_by(email: params[:email])

    if user&.valid_password?(params[:password])
      session[:user_id] = user.id
      render json: {success: true, user: user.slice(:id, :name, :username, :email)}
    else
      render json: {success: false, error: "Email ou senha inválidos"}, status: :unauthorized
    end
  end

  def destroy
    session.delete(:user_id)
    render json: {success: true}
  end
end
