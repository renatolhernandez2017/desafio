require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) { create(:user) }
  let(:verifier) { Rails.application.message_verifier(:user) }
  let(:token) { verifier.generate(user.id) }

  context "with valid token" do
    it "successfully connects and sets current_user" do
      connect "/cable?token=#{token}"

      expect(connection.current_user).to eq(user)
    end
  end

  context "with invalid token" do
    it "rejects connection" do
      expect {
        connect "/cable?token=invalidtoken"
      }.to raise_error(ActionCable::Connection::Authorization::UnauthorizedError)
    end
  end

  context "with missing token" do
    it "rejects connection" do
      expect {
        connect "/cable"
      }.to raise_error(ActionCable::Connection::Authorization::UnauthorizedError)
    end
  end
end
