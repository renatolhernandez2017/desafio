import { createConsumer } from "@rails/actioncable"

const token = localStorage.getItem("chat_token") // ou outro local seguro

export default createConsumer(`ws://localhost:3000/cable?token=${token}`) // ou wss:// se estiver em produção/https
