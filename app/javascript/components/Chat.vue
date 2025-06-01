<template>
  <div class="mx-5">
    <h2>Chat</h2>

    <div class="filters my-4">
      <div class="input-group">
        <input v-model="searchQuery" @keyup.enter="fetchMessages" class="form-control" placeholder="Buscar por mensagem ou autor" />
        <button @click="fetchMessages" class="btn btn-success">Buscar</button>
      </div>
    </div>

    <div class="card card-body">
      <div v-for="(msg, index) in messages" :key="msg.id" class="container-fluid">
        <div :class="['d-flex mb-3 align-items-center', msg.user === currentUser ? 'justify-content-start' : 'justify-content-end']">
          <div class="me-2">
            <span class="material-symbols-outlined img-size">account_circle</span>
          </div>

          <div>
            <div class="d-flex gap-2 align-items-center mb-1">
              <strong class="text-black">{{ msg.user }}</strong>
              <small class="text-black opacity-50">{{ msg.formatted_time }}</small>
            </div>

            <div class="p-2 rounded-3 bg-primary" style="max-width: 250px;">
              <template v-if="editIndex === index">
                <input v-model="editContent" class="form-control form-control-sm" />

                <div class="mt-2">
                  <button class="btn btn-sm btn-success me-2" @click="updateMessage(index, msg.id)">
                    Salvar
                  </button>

                  <button class="btn btn-sm btn-secondary" @click="cancelEditing">
                    Cancelar
                  </button>
                </div>
              </template>

              <template v-else>
                <p class="mb-0 text-white">{{ msg.content }}</p>
              </template>
            </div>

            <small class="text-muted">entregue</small>
          </div>

          <div class="mt-1">
            <button class="no-border no-border-disabled" :disabled="msg.user !== currentUser"
              :class="{ 'opacity-50 cursor-not-allowed': msg.user !== currentUser }"
              @click="msg.user === currentUser && startEditing(index, msg.content)"
              title="Editar mensagem"
            >
              <span class="material-symbols-outlined font-size">edit</span>
            </button>

            <button class="no-border no-border-disabled" :disabled="msg.user !== currentUser"
              :class="{ 'opacity-50 cursor-not-allowed': msg.user !== currentUser }"
              @click="msg.user === currentUser && deleteMessage(msg.id)"
              title="Excluir mensagem"
            >
              <span class="material-symbols-outlined font-size">delete</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <div class="input-group my-4">
      <input v-model="newMessage" @keyup.enter="sendMessage" class="form-control" placeholder="Digite sua mensagem" />
      <button @click="sendMessage" class="btn btn-success">Enviar</button>
    </div>
  </div>
</template>

<style scoped>
  .text-xs {
    font-size: 0.75rem; /* 12px */
  }

  .no-border {
    display: inline-block;
    border: transparent;
    background: transparent;
    padding: 2px;
  }

  .no-border-disabled:disabled {
    border: none !important;
    box-shadow: none !important;
    outline: none !important;
    background-color: transparent !important;
  }

  .font-size {
    font-size: 22px;
  }
</style>

<script setup>
  import { ref, onMounted } from 'vue'
  import axios from 'axios'
  import { createChatConsumer } from './cable'

  const currentUser = ref(localStorage.getItem('chat_user_name') || '')
  const messages = ref([])
  const newMessage = ref('')
  const editIndex = ref(null)
  const editContent = ref('')
  const searchQuery = ref('')
  let channel = null

  function formatTime(datetime) {
    return new Date(datetime).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit', second: '2-digit' })
  }

  async function fetchMessages() {
    const token = localStorage.getItem('chat_token')
    const params = new URLSearchParams()

    if (searchQuery.value) params.append('query', searchQuery.value)

    try {
      const response = await axios.get(`/api/messages?${params.toString()}`, {
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
    const token = localStorage.getItem('chat_token')
    const username = localStorage.getItem('chat_user_name')

    if (!token || !username) {
      console.error('Token ou usuário ausente.')
      return
    }

    const cable = createChatConsumer()

    fetchMessages()

    channel = cable.subscriptions.create(
      { channel: 'ChatChannel', room: 'geral' },
      {
        connected() {
          console.log('Conectado ao canal WebSocket')
        },
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
        },
        disconnected() {
          console.log('Desconectado do canal')
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
