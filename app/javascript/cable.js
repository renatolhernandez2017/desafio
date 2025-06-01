import { createConsumer } from "@rails/actioncable"

export function createChatConsumer() {
  const token = localStorage.getItem("chat_token")
  return createConsumer(`ws://localhost:3000/cable?token=${token}`)
}
