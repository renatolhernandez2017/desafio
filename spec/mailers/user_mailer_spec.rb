# spec/mailers/user_mailer_spec.rb
require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "#welcome" do
    let(:user) { create(:user, email: "test@example.com", name: "Test User") }
    let(:mail) { UserMailer.welcome(user) }

    it "envia para o email correto" do
      expect(mail.to).to eq([user.email])
    end

    it "usa o remetente padrão" do
      expect(mail.from).to eq(["no-reply@meusite.com"])
    end

    it "tem o assunto correto" do
      expect(mail.subject).to eq("Seja bem-vindo!")
    end

    it "renderiza o corpo em HTML e texto" do
      expect(mail.body.encoded).to include(user.name).or include(user.email)
      expect(mail.content_type).to match(/multipart\/alternative/)
    end
  end
end
