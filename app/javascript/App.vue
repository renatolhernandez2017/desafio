<template>
  <div>
    <Login v-if="!user" />
    <MessageChannel v-else :user="user" />
  </div>
</template>

<script setup>
import Login from './components/Login.vue'
import MessageChannel from './components/MessageChannel.vue'

const props = defineProps({
  user: Object
})
</script>
