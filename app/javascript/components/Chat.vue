<template>
  <div>
    <h2>Chat</h2>
    <div v-for="(msg, index) in messages" :key="index">
      <p>
        <strong>{{ msg.user }}:</strong>
        {{ msg.content }}
        <span style="font-size: 0.8em; color: gray">({{ msg.created_at }})</span>
      </p>
    </div>

    <input
      v-model="newMessage"
      @keyup.enter="sendMessage"
      placeholder="Digite sua mensagem"
    />
    <button @click="sendMessage">Enviar</button>
  </div>
</template>

<script setup>
  import { ref, onMounted } from 'vue'
  import cable from './cable'

  const messages = ref([])
  const newMessage = ref('')
  let channel = null

  onMounted(() => {
    channel = cable.subscriptions.create(
      { channel: 'ChatChannel', room: 'geral' },
      {
        received(data) {
          messages.value.push(data)
        }
      }
    )
  })

  function sendMessage() {
    if (newMessage.value.trim() !== '') {
      channel.send({ content: newMessage.value })
      newMessage.value = ''
    }
  }
</script>
