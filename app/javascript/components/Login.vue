<template>
  <form @submit.prevent="submitLogin" class="login-form">
    <input v-model="login" placeholder="Email" required />
    <input type="password" v-model="password" placeholder="Senha" required />
    <button type="submit">Entrar</button>
    <p v-if="error" class="error">{{ error }}</p>
  </form>
</template>

<script>
  export default {
    data() {
      return {
        login: '',
        password: '',
        error: null
      };
    },
    methods: {
      async submitLogin() {
        this.error = null;
        try {
          const res = await fetch('/api/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              email: this.login,
              password: this.password
            }),
          });
          const data = await res.json();

          if (data.success) {
            // Salva os dados do usuário no localStorage
            localStorage.setItem('user', JSON.stringify(data.user));

            // Redireciona para o chat
            this.$router.push('/chat');
          } else {
            this.error = data.error || 'Erro ao logar';
          }
        } catch (e) {
          this.error = 'Erro de conexão';
        }
      },
    },
  };
</script>

<style scoped>
  .error {
    color: red;
  }
</style>
