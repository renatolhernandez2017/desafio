<template>
  <form @submit.prevent="submitLogin">
    <div class="d-flex justify-content-center mb-5">
      <img src="/images/logo.png" alt="Logo" class="img-fluid col-5 col-sm-5 col-md-4 col-lg-3 col-xl-2" />
    </div>

    <h2 class="text-center">Login</h2>

    <div class="mb-3 mt-3">
      <input id="login" v-model="login" placeholder="Email" class="form-control" required />
    </div>

    <div class="mb-3 mt-3">
      <input id="password" type="password" v-model="password" placeholder="Senha" class="form-control" required />
    </div>

    <button type="submit" class="btn btn-primary">Entrar</button>

    <p v-if="error && !isAccountBlocked" class="alert alert-danger mt-2">{{ error }}</p>
    <p v-if="successMessage" class="alert alert-success mt-2">{{ successMessage }}</p>
    <p v-if="errorMessage" class="alert alert-danger mt-2">{{ errorMessage }}</p>

    <p v-if="isAccountBlocked && unlockToken" class="alert alert-danger mt-2">
      {{ error }}
      <br />
      <a href="#" @click.prevent="unlockAccount">Clique aqui para desbloquear sua conta</a>
    </p>
  </form>
</template>

<script>
  export default {
    data() {
      return {
        login: '',
        password: '',
        error: null,
        successMessage: '',
        errorMessage: '',
        unlockToken: null,
        isAccountBlocked: false
      };
    },
    methods: {
      async submitLogin() {
        this.error = null;
        this.successMessage = '';
        this.errorMessage = '';
        this.isAccountBlocked = false;

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
            const token = data.token;
            localStorage.setItem('chat_token', token);
            localStorage.setItem('chat_user_name', data.user.name);

            this.$emit('login-success', data.user);
            this.$router.push('/chat');
          } else {
            if (data.error?.includes('bloqueada')) {
              this.isAccountBlocked = true;
              this.unlockToken = data.unlock_token;
              this.error = data.error;
            } else {
              this.error = data.error || 'Erro ao logar';
            }
          }
        } catch (e) {
          this.error = 'Erro de conexão';
        }
      },
      async unlockAccount() {
        try {
          const response = await fetch(`/api/unlock/${this.unlockToken}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
          });

          const data = await response.json();

          if (data.success) {
            this.successMessage = data.message || 'Conta desbloqueada com sucesso!';
            this.errorMessage = '';
            this.error = '';
            this.isAccountBlocked = false;
            this.unlockToken = null;
          } else {
            this.errorMessage = data.error || 'Falha ao desbloquear conta.';
            this.successMessage = '';
          }
        } catch(e) {
          this.errorMessage = 'Erro de conexão.';
          this.successMessage = '';
        }
      }
    },
  };
</script>
