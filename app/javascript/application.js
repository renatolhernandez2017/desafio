import { createApp } from 'vue'
import App from './App.vue'

document.addEventListener('DOMContentLoaded', () => {
  const appElement = document.getElementById('app')
  if (appElement) {
    createApp(App).mount(appElement)
  }
})
