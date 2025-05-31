require "rails_helper"

RSpec.describe Api::MessagesController, type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:message) { create(:message, user: user) }

  before do
    # Simula usuário autenticado em todas as requisições
    allow_any_instance_of(Api::MessagesController).to receive(:current_user).and_return(user)
  end

  describe "GET /api/messages" do
    it "returns all messages" do
      get "/api/messages"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end

    it "filters by search query if present" do
      get "/api/messages", params: {query: message.content}

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.first["content"]).to eq(message.content)
    end
  end

  describe "POST /api/messages" do
    it "creates and broadcasts a message" do
      expect {
        post "/api/messages", params: {message: {content: "Hello!", room: "geral"}}
      }.to change(Message, :count).by(1)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["content"]).to eq("Hello!")
    end
  end

  describe "PUT /api/messages/:id" do
    it "updates the message if it belongs to current_user" do
      put "/api/messages/#{message.id}", params: {content: "Updated", room: "geral"}

      expect(response).to have_http_status(:ok)
      expect(message.reload.content).to eq("Updated")
    end

    it "returns unauthorized if user is not the owner" do
      other_message = create(:message, user: other_user)

      put "/api/messages/#{other_message.id}", params: {content: "Hacked", room: "geral"}

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /api/messages/:id" do
    it "deletes the message if user is the owner" do
      delete "/api/messages/#{message.id}"

      expect(response).to have_http_status(:no_content)
      expect(Message.exists?(message.id)).to be false
    end

    it "returns unauthorized if user is not the owner" do
      other_message = create(:message, user: other_user)

      delete "/api/messages/#{other_message.id}"

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
