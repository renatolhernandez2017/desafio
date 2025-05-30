class Api::SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    user = User.find_by(email: params[:email])

    if user&.locked?
      render json: {success: false, unlock_token: user.unlock_token, error: "Conta bloqueada."}, status: :unauthorized
      return
    end

    if user&.valid_password?(params[:password])
      token = Rails.application.message_verifier(:user).generate(user.id)
      user.reset_failed_attempts!
      session[:user_id] = user.id
      render json: {success: true, token: token, user: user.slice(:id, :name, :username, :email)}
    else
      user&.increment_failed_attempts!
      render json: {success: false, error: "Email ou senha inválidos"}, status: :unauthorized
    end
  end

  def destroy
    session.delete(:user_id)
    render json: {success: true}
  end

  def unlock
    user = User.find_by(unlock_token: params[:token])

    if user&.locked?
      user.unlock_account!
      render json: {success: true, message: "Sua conta foi desbloqueada com sucesso!"}
    else
      render json: {error: "Token inválido ou conta já desbloqueada."}, status: :unprocessable_entity
    end
  end
end
