require "rails_helper"

RSpec.describe ChatChannel, type: :channel do
  let(:room) { "geral" }
  let(:user) { create(:user) }

  before do
    stub_connection current_user: user
    subscribe(room: room)
  end

  it "subscribes to a stream" do
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("chat_#{room}")
  end

  describe "#receive" do
    let(:message) { create(:message, content: "Olá mundo", user: user) }

    it "broadcasts the message to the stream" do
      expect {
        perform :receive, {
          "content" => message.content,
          "user" => {
            "id" => message.user.id,
            "email" => message.user.email,
            "name" => message.user.name,
            "username" => message.user.username
          },
          "created_at" => message.created_at.strftime("%H:%M:%S")
        }
      }.to have_broadcasted_to("chat_#{room}").with(
        hash_including(
          "content" => message.content,
          "user" => hash_including(
            "id" => message.user.id,
            "email" => message.user.email,
            "name" => message.user.name,
            "username" => message.user.username
          )
        )
      )
    end
  end
end
