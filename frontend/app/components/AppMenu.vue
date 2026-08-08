<script setup lang="ts">
  const items = computed(() => [
    {
      label: 'Matches',
      icon: 'grommet-icons:scorecard',
      class: 'text-2xl',
      to: '/matches'
    },
    {
      label: 'Players',
      icon: 'maki:cricket',
      class: 'text-2xl',
      to: '/players'
    }
  ])
</script>

<template>
  <div class="flex w-full justify-center">
    <UNavigationMenu
      :items="items"
      color="primary"
      highlight
      highlight-color="primary"
    />
  </div>
</template>

<style scoped>

</style>
