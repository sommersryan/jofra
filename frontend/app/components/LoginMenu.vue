<script setup lang="ts">
const loginMenuOpen = ref(false)

const onLogin = () => {
  window.location.href = `http://127.0.0.1:4000/oauth/login?handle=${loginHandle.value}`
}

const loginHandle = ref(null)

const accountMenuItems = computed(() => [
  {
    label: 'Profile',
    icon: 'gg:profile',
    to: `/@${user.value.handle}`
  },
  {
    label: 'Logout',
    icon: 'material-symbols:logout'
  }
])

const { user, isLoggedIn } = useAuth()

console.log(user)
</script>

<template>
  <UDropdownMenu :items="accountMenuItems" v-if="isLoggedIn" :ui="{ content: 'w-48'}">
    <div class="flex items-center gap-x-2 cursor-pointer hover:bg-info-100 transition-colors duration-200 dark:hover:bg-info-950 bg-elevated p-3 h-12 rounded-xl">
      <UAvatar :src="user.avatar" size="md" class=""/>
      <span class="text-md">@{{ user.handle }}</span>
    </div>
  </UDropdownMenu>
  <UPopover v-model:open="loginMenuOpen" v-else>
    <UButton variant="ghost" icon="fa6-brands:square-bluesky">
      Login
    </UButton>
    <template #content>
      <UForm class="flex w-full p-4" @submit="onLogin">
        <UFormField label="Bluesky handle">
          <div class="flex items-center gap-x-2">
            <UInput
              v-model="loginHandle"
              icon="lucide:at-sign"
              placeholder="dril.bsky.social"/>
            <UButton icon="lucide:arrow-right"/>
          </div>
        </UFormField>
      </UForm>
    </template>
  </UPopover>
</template>

<style scoped>

</style>
