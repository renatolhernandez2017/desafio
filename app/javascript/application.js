import { createApp } from 'vue'
import App from './App.vue'

const el = document.getElementById('app')
const user = el.dataset.user ? JSON.parse(el.dataset.user) : null

createApp(App, { user }).mount('#app')
import "./channels"
