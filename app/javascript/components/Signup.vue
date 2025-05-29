<template>
  <form @submit.prevent="submitSignup" class="signup-form">
    <input v-model="name" placeholder="Nome" required minlength="3" maxlength="255" />
    <input v-model="username" placeholder="Username" required minlength="5" maxlength="50" pattern="^[a-zA-Z0-9-_]+$" />
    <input v-model="email" type="email" placeholder="Email" required />
    <input v-model="password" type="password" placeholder="Senha" required minlength="20" maxlength="100" />
    <input v-model="passwordConfirmation" type="password" placeholder="Confirme a senha" required />
    <button type="submit">Cadastrar</button>
    <p v-if="error" class="error">{{ error }}</p>
  </form>
</template>

<script>
export default {
  data() {
    return {
      name: '',
      username: '',
      email: '',
      password: '',
      passwordConfirmation: '',
      error: null,
    };
  },
  methods: {
    async submitSignup() {
      this.error = null;
      if (this.password !== this.passwordConfirmation) {
        this.error = 'As senhas não conferem';
        return;
      }
      try {
        const res = await fetch('/api/users', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            name: this.name,
            username: this.username,
            email: this.email,
            password: this.password,
            password_confirmation: this.passwordConfirmation
          }),
        });
        const data = await res.json();
        if (data.success) {
          // Cadastro ok, pode fazer login automático ou avisar usuário
          this.$emit('signup-success', data.user);
        } else {
          this.error = data.error || 'Erro ao cadastrar';
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
