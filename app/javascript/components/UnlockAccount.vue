<template>
  <div class="container mt-5 text-center">
    <h2>Desbloqueando conta...</h2>
    <p v-if="success" class="text-success">Redirecionando para login...</p>
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
        const res = await fetch(`/api/unlock/${token}`);
        const data = await res.json();

        if (data.success) {
          this.success = true;

          setTimeout(() => {
            this.$router.push({ name: 'Login', query: { unlocked: 'true' } });
          }, 1500);
        } else {
          this.error = data.error || 'Erro ao desbloquear conta';
        }
      } catch (e) {
        this.error = 'Erro de conexão';
      }
    }
  };
</script>
