<script setup lang="ts">
  const api = useApi()

  const user = await api.get('/me')

  console.log(user)
</script>

<template>
  hello
</template>

<style scoped>

</style>
