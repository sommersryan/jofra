<script setup lang="ts">
const loginMenuOpen = ref(false)
const runtimeConfig = useRuntimeConfig()

const onLogin = () => {
  window.location.href = `http://127.0.0.1:4000/oauth/login?handle=${loginHandle.value}`
}

const loginHandle = ref(null)

const { user, isLoggedIn } = useAuth()
</script>

<template>
  <div v-if="isLoggedIn">
    {{user.handle}}
  </div>
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
