require "rails_helper"

RSpec.describe Message, type: :model do
  describe "associações" do
    it { should belong_to(:user) }
  end

  describe "validações" do
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:content).is_at_most(1000) }
  end

  describe ".search_full_text" do
    let!(:user1) { create(:user, name: "Alice") }
    let!(:user2) { create(:user, name: "Bob") }

    let!(:msg1) { create(:message, content: "Olá, tudo bem?", user: user1) }
    let!(:msg2) { create(:message, content: "Vamos ao parque", user: user2) }
    let!(:msg3) { create(:message, content: "Nada a ver", user: user2) }

    it "encontra mensagens pelo conteúdo" do
      expect(Message.search_full_text("parque")).to include(msg2)
      expect(Message.search_full_text("parque")).not_to include(msg1, msg3)
    end

    it "encontra mensagens pelo nome do usuário associado" do
      expect(Message.search_full_text("Alice")).to include(msg1)
      expect(Message.search_full_text("Alice")).not_to include(msg2, msg3)
    end

    it "ignora acentos e permite prefixo" do
      expect(Message.search_full_text("tud")).to include(msg1)
      expect(Message.search_full_text("bem")).to include(msg1)
    end
  end
end
