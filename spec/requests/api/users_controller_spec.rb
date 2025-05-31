require "rails_helper"

RSpec.describe Api::UsersController, type: :request do
  describe "POST /api/users (create)" do
    let(:valid_params) do
      {
        name: "Test User",
        username: "Testuser",
        email: "test@gmail.com",
        password: "Password0A1b2c3XyZqWvRtLpK",
        password_confirmation: "Password0A1b2c3XyZqWvRtLpK"
      }
    end

    context "com parâmetros válidos" do
      it "cria um novo usuário e retorna token" do
        expect {
          post "/api/users", params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)

        body = JSON.parse(response.body)
        expect(body["success"]).to be true
        expect(body["token"]).to be_present
        expect(body["user"]["email"]).to eq("test@gmail.com")
      end
    end

    context "com parâmetros inválidos" do
      it "não cria o usuário e retorna erro" do
        invalid_params = valid_params.merge(email: "")

        expect {
          post "/api/users", params: invalid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)

        body = JSON.parse(response.body)
        expect(body["success"]).to be false
        expect(body["error"]).to include("Email")
      end
    end
  end
end
