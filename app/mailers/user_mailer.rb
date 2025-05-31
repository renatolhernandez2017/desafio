class UserMailer < ApplicationMailer
  default from: "no-reply@meusite.com"

  def welcome(user)
    @user = user

    mail(to: @user.email, subject: "Seja bem-vindo!") do |format|
      format.html
      format.text
    end
  end
end
