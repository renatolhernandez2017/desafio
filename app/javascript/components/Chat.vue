<template>
  <div>
    <h2>Chat</h2>

    <div v-for="(msg, index) in messages" :key="msg.id">
      <p>
        <strong>{{ msg.user }}:</strong>

        <template v-if="editIndex === index">
          <input v-model="editContent" />
          <button @click="updateMessage(index, msg.id)">Salvar</button>
          <button @click="cancelEditing">Cancelar</button>
        </template>

        <template v-else>
          {{ msg.content }}
          <span style="font-size: 0.8em; color: gray">({{ msg.formatted_time }})</span>

          <button @click="startEditing(index, msg.content)" :disabled="msg.user !== currentUser">
            Editar
          </button>

          <button @click="deleteMessage(msg.id)" :disabled="msg.user !== currentUser">
            Excluir
          </button>
        </template>
      </p>
    </div>

    <input v-model="newMessage" @keyup.enter="sendMessage" placeholder="Digite sua mensagem" />
    <button @click="sendMessage">Enviar</button>
  </div>
</template>

<script setup>
  import { ref, onMounted } from 'vue'
  import axios from 'axios'
  import cable from './cable'

  const currentUser = ref(localStorage.getItem('chat_user_name') || '')
  const messages = ref([])
  const newMessage = ref('')
  const editIndex = ref(null)
  const editContent = ref('')
  let channel = null

  function formatTime(datetime) {
    return new Date(datetime).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit', second: '2-digit' })
  }

  async function fetchMessages() {
    const token = localStorage.getItem('chat_token')

    try {
      const response = await axios.get('/api/messages', {
        headers: {
          Authorization: `Bearer ${token}`
        }
      })

      messages.value = response.data
        .map(msg => ({
          id: msg.id,
          content: msg.content,
          created_at: msg.created_at,
          formatted_time: formatTime(msg.created_at),
          user: msg.user.name
        }))
    } catch (error) {
      console.error('Erro ao buscar mensagens:', error)
    }
  }

  onMounted(() => {
    fetchMessages()

    channel = cable.subscriptions.create(
      { channel: 'ChatChannel', room: 'geral' },
      {
        received(data) {
          const index = messages.value.findIndex(m => m.id === data.id)

          const message = {
            id: data.id,
            content: data.content,
            created_at: data.created_at,
            formatted_time: formatTime(data.created_at),
            user: typeof data.user === 'object' ? data.user.name : data.user
          }

          if (index !== -1) {
            messages.value[index] = message
          } else {
            messages.value.unshift(message)
          }
        }
      }
    )
  })

  function startEditing(index, content) {
    editIndex.value = index
    editContent.value = content
  }

  function cancelEditing() {
    editIndex.value = null
    editContent.value = ''
  }

  async function updateMessage(index, id) {
    const token = localStorage.getItem('chat_token')
    try {
      await axios.put(`/api/messages/${id}`, {
        content: editContent.value,
        room: 'geral'
      }, {
        headers: { Authorization: `Bearer ${token}` }
      })

      cancelEditing()

    } catch (err) {
      console.error('Erro ao atualizar:', err)
    }
  }

  async function deleteMessage(id) {
    const token = localStorage.getItem('chat_token')
    try {
      await axios.delete(`/api/messages/${id}`, {
        headers: { Authorization: `Bearer ${token}` }
      })
      messages.value = messages.value.filter(m => m.id !== id)
    } catch (err) {
      console.error('Erro ao excluir:', err)
    }
  }

  async function sendMessage() {
    const token = localStorage.getItem('chat_token')

    if (newMessage.value.trim() !== '') {
      try {
        await axios.post('/api/messages', {
          message: { content: newMessage.value, room: 'geral' }
        }, {
          headers: { Authorization: `Bearer ${token}` }
        })
        newMessage.value = ''
      } catch (error) {
        console.error('Erro ao enviar mensagem', error)
      }
    }
  }
</script>
