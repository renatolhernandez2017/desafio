<template>
  <div class="app-container">
    <div v-if="!user" class="auth-container">
      <div class="form-card">
        <Login v-if="!showSignup" @login-success="handleLogin" />
        <Signup v-else @signup-success="handleSignup" />
        <button class="toggle-btn" @click="toggleForm">
          {{ showSignup ? 'Já tem conta? Login' : 'Não tem conta? Cadastre-se' }}
        </button>
      </div>
    </div>

    <div v-else class="chat-container">
      <Chat :user="user" />
    </div>
  </div>
</template>

<style scoped>
  .app-container {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: white;
  }

  .auth-container {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .form-card {
    background: #fff;
    padding: 2rem 2.5rem;
    border-radius: 16px;
    box-shadow: 0 4px 24px rgba(0,0,0,0.08);
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .toggle-btn {
    margin-top: 1.5rem;
    background: #4f8cff;
    color: #fff;
    border: none;
    border-radius: 8px;
    padding: 0.75rem 1.5rem;
    font-size: 1rem;
    cursor: pointer;
    transition: background 0.2s;
  }

  .toggle-btn:hover {
    background: #2563eb;
  }

  .chat-container {
    width: 100%;
    max-width: 800px;
    min-height: 600px;
    background: #fff;
    border-radius: 16px;
    box-shadow: 0 4px 24px rgba(0,0,0,0.08);
    padding: 2rem;
    display: flex;
    flex-direction: column;
  }
</style>

<script>
  import Login from './components/Login.vue';
  import Signup from './components/Signup.vue';
  import Chat from './components/Chat.vue';

  export default {
    components: { Login, Signup, Chat },
    data() {
      return {
        user: null,
        showSignup: false,
      };
    },
    created() {
      const storedUser = localStorage.getItem('user');
      if (storedUser) {
        this.user = JSON.parse(storedUser);
      }

      const appDiv = document.getElementById('app');
      if (appDiv && appDiv.dataset.user) {
        try {
          this.user = JSON.parse(appDiv.dataset.user);
        } catch (e) {
          console.error('Erro ao parsear user data:', e);
        }
      } else {
        // Se não vier do servidor, tenta localStorage
        const storedUser = localStorage.getItem('user');
        if (storedUser) {
          this.user = JSON.parse(storedUser);
        }
      }
    },
    methods: {
      toggleForm() {
        this.showSignup = !this.showSignup;
      },
      handleLogin(user) {
        localStorage.setItem('user', JSON.stringify(user));
        this.user = user;
      },
      handleSignup(user) {
        localStorage.setItem('user', JSON.stringify(user));
        this.user = user;
        this.showSignup = false;
      }
    }
  };
</script>
