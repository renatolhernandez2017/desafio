<template>
  <div class="container mt-5 text-center">
    <h2>Desbloquear conta</h2>
    <p v-if="success" class="text-success">Conta desbloqueada! Você pode <router-link to="/">fazer login</router-link>.</p>
    <p v-if="error" class="text-danger">{{ error }}</p>
  </div>
</template>

<script>
  export default {
    data() {
      return {
        success: false,
        error: null,
      };
    },
    async mounted() {
      const token = this.$route.params.token;
      try {
        const res = await fetch(`/unlock/${token}`);
        const data = await res.json();
        if (data.success) {
          this.success = true;
        } else {
          this.error = data.error || 'Erro ao desbloquear conta';
        }
      } catch (e) {
        this.error = 'Erro de conexão';
      }
    }
  };
</script>
