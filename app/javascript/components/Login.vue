<template>
  <form @submit.prevent="submitLogin">
    <div class="">
      <h2 class="text-center">Entrar</h2>

      <div class="mb-3 mt-3">
        <input id="login" v-model="login" placeholder="Email" class="form-control" required />
      </div>

      <div class="mb-3 mt-3">
        <input id="password" type="password" v-model="password" placeholder="Senha" class="form-control" required />
      </div>

      <button type="submit" class="btn btn-primary">Entrar</button>
      <p v-if="error" class="text-danger m-2">{{ error }}</p>

      <p v-if="typeof error === 'string' && error.includes('bloqueada')" class="text-warning m-2">
        <a :href="`/unlock/${unlockToken}`">Clique aqui para desbloquear sua conta</a>
      </p>
    </div>
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
            const token = data.token
            localStorage.setItem('chat_token', token)
            this.$emit('login-success', data.user)
          } else {
            this.error = data.error || 'Erro ao logar'
          }
        } catch (e) {
          this.error = 'Erro de conexão';
        }
      },
    },
  };
</script>
