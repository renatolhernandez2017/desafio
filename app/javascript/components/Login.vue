<template>
  <div class="p-4">
    <h2 class="text-xl font-bold mb-4">Login</h2>
    <form>
      <input type="email" placeholder="Email" class="block mb-2 border p-2 w-full" />
      <input type="password" placeholder="Senha" class="block mb-2 border p-2 w-full" />
      <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded">Entrar</button>
    </form>
  </div>
</template>

<script>
export default {
  name: 'Login',
}
</script>
