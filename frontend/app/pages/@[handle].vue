<script setup lang="js">
 const loading = ref(false)
 const { user } = useAuth()
 const player = computed(() => user.value) //going to need to load the actual player
</script>

<template>
  <article class="flex w-full flex-col px-24">
    <BackButton/>
    <div class="w-full bg-elevated rounded-t-xl px-8 py-4">
      <div class="flex gap-x-4 items-center">
        <UAvatar :src="player.avatar" :ui="{ root: 'ring-3 ring-elevated size-20'}"/>
        <div class="flex flex-col">
          <h2 class="text-3xl text-elevated">{{ player.display_name }}</h2>
          <div>@{{ player.handle }}</div>
        </div>
      </div>
    </div>
    <div class="flex w-full h-screen bg-accented/30 rounded-b-xl">

    </div>
  </article>
</template>

<style scoped>

</style>
