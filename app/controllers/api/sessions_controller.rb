class Api::SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    user = User.find_by(email: params[:email])

    if user&.locked?
      render json: { success: false, error: "Conta bloqueada. Verifique seu email para desbloquear." }, status: :unauthorized
      return
    end

    if user&.valid_password?(params[:password])
      user.reset_failed_attempts!
      session[:user_id] = user.id
      render json: {success: true, user: user.slice(:id, :name, :username, :email)}
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

    if user
      user.unlock_account!
      render json: { success: true, message: "Conta desbloqueada com sucesso. Você pode fazer login." }
    else
      render json: { success: false, error: "Token inválido ou expirado." }, status: :unprocessable_entity
    end
  end
end
