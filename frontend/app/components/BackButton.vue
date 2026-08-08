<script setup lang="js">
  const router = useRouter()

  const onBack = () => {
    router.go(-1)
  }
</script>

<template>
  <NuxtLink @click="onBack" class="cursor-pointer w-full gap-x-2 text-info text-2xl flex items-center mb-4">
    <UIcon name="lucide:arrow-left"/>
    <span>Back</span>
  </NuxtLink>
</template>

<style scoped>

</style>
