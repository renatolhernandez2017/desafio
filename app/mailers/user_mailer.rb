class UserMailer < ApplicationMailer
  default from: "no-reply@meusite.com"

  def welcome(user)
    @user = user

    mail(to: @user.email, subject: "Seja bem-vindo!") do |format|
      format.html
      format.text
    end
  end

  def unlock_account(user, unlock_token)
    @user = user
    @unlock_token = unlock_token
    @root_url = root_url

    mail(to: @user.email, subject: "Segue instruções para desbloqueadar sua conta!") do |format|
      format.html
      format.text
    end
  end
end
