<script setup>
  const runtimeConfig = useRuntimeConfig()


</script>

<template>
  <div class="flex w-full justify-center">
    {{runtimeConfig.public}}
  </div>
</template>
