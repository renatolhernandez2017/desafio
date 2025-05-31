<template>
  <div class="min-vh-100 bg-light d-flex flex-column justify-content-center align-items-center">
    <div v-if="!user" class="row w-100 justify-content-center align-items-center">
      <div class="col-12 col-sm-8 col-md-5 col-lg-4">
        <div class="shadow-lg p-4 bg-white rounded">
          <Login v-if="!showSignup" @login-success="handleLogin" />
          <Signup v-else @signup-success="handleSignup" />

          <button class="btn btn-dark w-100 mt-3" @click="toggleForm">
            {{ showSignup ? 'Já tem conta? Login' : 'Não tem conta? Cadastre-se' }}
          </button>
        </div>
      </div>
    </div>

    <div v-else class="row w-100 flex-grow-1 min-vh-80">
      <div class="col-12 col-md-3 col-lg-2 bg-dark text-white py-4">
        <div class="d-flex justify-content-between align-items-center">
          <div class="d-flex align-items-center gap-3">
            <div class="me-2">
              <span class="material-symbols-outlined img-size">account_circle</span>
            </div>

            <div class="fw-bold">{{ user.name || 'Usuário' }}</div>
          </div>

          <div v-if="user">
            <button type="button" @click="logout" class="btn btn-danger">Sair</button>
          </div>
        </div>
      </div>

      <div class="col-12 col-md-9 col-lg-10 bg-white p-4">
        <Chat :user="user" />
      </div>
    </div>
  </div>
</template>

<style>
  .img-size {
    font-size: 50px;
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
      const appDiv = document.getElementById('app');
      if (appDiv && appDiv.dataset.user) {
        try {
          this.user = JSON.parse(appDiv.dataset.user);
        } catch (e) {
          console.error('Erro ao parsear user data:', e);
        }
      } else {
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
      },
      async logout() {
        try {
          const res = await fetch('/api/logout', {
            method: 'DELETE',
            headers: {
              'Accept': 'application/json'
            }
          });

          const data = await res.json();

          if (data.success) {
            localStorage.removeItem('user');
            this.user = null;
            this.showSignup = false;
          } else {
            console.error('Erro no logout:', data.error || 'desconhecido');
          }
        } catch (e) {
          console.error('Erro ao deslogar:', e);
        }
      }
    }
  };
</script>
