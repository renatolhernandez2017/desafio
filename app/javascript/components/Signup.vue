<template>
  <form @submit.prevent="submitSignup">
    <h2 class="text-center">Cadastrar</h2>

    <div class="mb-3 mt-3">
      <input v-model="name" placeholder="Nome" class="form-control" required minlength="3" maxlength="255" />
    </div>

    <div class="mb-3 mt-3">
      <input v-model="username" placeholder="Username" class="form-control" required minlength="5" maxlength="50" pattern="^[a-zA-Z0-9-_]+$" />
    </div>

    <div class="mb-3 mt-3">
      <input v-model="email" type="email" placeholder="Email" class="form-control" required />
    </div>

    <div class="mb-3 mt-3">
      <input v-model="password" type="password" placeholder="Senha" class="form-control" required minlength="20" maxlength="100" />
    </div>

    <div class="mb-3 mt-3">
      <input v-model="passwordConfirmation" type="password" placeholder="Confirme a senha" class="form-control" required />
    </div>

    <button type="submit" class="btn btn-primary">Cadastrar</button>
    <p v-if="error" class="text-danger m-2">{{ error }}</p>
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
            const token = data.token
            localStorage.setItem('chat_token', token)
            localStorage.setItem('chat_user_name', data.user.name)

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
