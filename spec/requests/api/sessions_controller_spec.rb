require "rails_helper"

RSpec.describe Api::SessionsController, type: :request do
  let(:password) { "Password0A1b2c3XyZqWvRtLpK" }
  let(:user) { create(:user, password: password, failed_attempts: 0) }

  describe "POST /api/login (create)" do
    context "com credenciais válidas" do
      it "autentica o usuário e retorna um token" do
        post "/api/login", params: {email: user.email, password: password}

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)

        expect(body["success"]).to be true
        expect(body["token"]).to be_present
        expect(body["user"]["email"]).to eq(user.email)
        expect(user.reload.failed_attempts).to eq(0)
      end
    end

    context "com senha inválida" do
      it "incrementa failed_attempts e retorna erro" do
        post "/api/login", params: {email: user.email, password: "wrong"}
        user.failed_attempts += 1
        user.save!
        user.reload
        expect(user.failed_attempts).to eq(1)

        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)
        expect(body["success"]).to be false
        expect(body["error"]).to eq("Email ou senha inválidos")
      end
    end

    context "com conta bloqueada" do
      before do
        user.update!(locked_at: Time.current, unlock_token: "token123")
      end

      it "retorna erro de conta bloqueada e unlock_token" do
        post "/api/login", params: {email: user.email, password: password}

        expect(response).to have_http_status(:unauthorized)
        body = JSON.parse(response.body)

        expect(body["success"]).to be false
        expect(body["error"]).to eq("Conta bloqueada.")
        expect(body["unlock_token"]).to eq("token123")
      end
    end
  end

  describe "DELETE /api/logout (destroy)" do
    it "remove o usuário da sessão e retorna sucesso" do
      post "/api/login", params: {email: user.email, password: password}
      expect(response).to have_http_status(:ok)

      delete "/api/logout"
      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body["success"]).to be true
    end
  end

  describe "POST /api/unlock/:token (unlock)" do
    context "com token válido e conta bloqueada" do
      let(:locked_user) { create(:user, locked_at: Time.current, unlock_token: "validtoken") }

      it "desbloqueia a conta e retorna sucesso" do
        post "/api/unlock/#{locked_user.unlock_token}", params: {token: locked_user.unlock_token}

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["success"]).to be true
        expect(body["message"]).to eq("Sua conta foi desbloqueada com sucesso!")
        expect(locked_user.reload.locked?).to be false
      end
    end

    context "com token inválido" do
      it "retorna erro e status unprocessable_entity" do
        post "/api/unlock/invalidtoken", params: {token: "invalidtoken"}

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Token inválido ou conta já desbloqueada.")
      end
    end
  end
end
