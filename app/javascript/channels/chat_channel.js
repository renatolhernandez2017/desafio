import consumer from "./consumer"

const token = localStorage.getItem('chat_token')

const subscription = consumer.subscriptions.create(
  { channel: "ChatChannel", room: "geral", token: token },
  {
    connected() {
    },

    disconnected() {
    },

    received(data) {
    }
  }
)

// Mantenha a referência da subscription para evitar garbage collection
window.chatSubscription = subscription