<script setup lang="ts">
  const items = computed(() => [
    {
      label: 'Matches',
      icon: 'grommet-icons:scorecard'
    },
    {
      label: 'Players',
      icon: 'maki:cricket'
    }
  ])
</script>

<template>
  <div class="flex w-full justify-center">
    <UNavigationMenu
      :items="items"
      class="text-xl"
      color="primary"
      highlight
      highlight-color="primary"
    />
  </div>
</template>

<style scoped>

</style>
