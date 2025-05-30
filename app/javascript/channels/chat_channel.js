import consumer from "./consumer"

// Certifique-se de que o arquivo consumer.js está exportando corretamente o consumer
// e que o servidor ActionCable está rodando e acessível.

const subscription = consumer.subscriptions.create(
  { channel: "ChatChannel", room: "geral" },
  {
    connected() {
    },

    disconnected() {
    },

    received(data) {
      // Aqui você pode chamar uma função para adicionar no chat, etc
    }
  }
)

// Mantenha a referência da subscription para evitar garbage collection
window.chatSubscription = subscription