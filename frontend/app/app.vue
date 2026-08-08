<script setup>
import LoginMenu from "~/components/LoginMenu.vue";

useHead({
  meta: [
    { name: 'viewport', content: 'width=device-width, initial-scale=1' }
  ],
  link: [
    { rel: 'icon', href: '/favicon.ico' }
  ],
  htmlAttrs: {
    lang: 'en'
  }
})

const title = 'Jofra'
const description = ''

useSeoMeta({
  title,
  description,
  ogTitle: title,
  ogDescription: description,
  ogImage: 'https://ui.nuxt.com/assets/templates/nuxt/starter-light.png',
  twitterCard: 'summary_large_image'
})
</script>

<template>
  <UApp>
    <UHeader>
      <template #left>
        <div class="text-5xl font-bold">
          jofra
        </div>
        <UIcon name="boxicons:cricket-ball" class="size-10"/>
      </template>
      <AppMenu/>
      <template #right>
        <div class="flex gap-x-4">
          <LoginMenu/>
          <UColorModeButton/>
        </div>
      </template>
    </UHeader>

    <UMain class="flex w-full text-center p-8">
      <NuxtPage />
    </UMain>

    <USeparator icon="i-arcticons-cricket" />

    <UFooter>
      <template #left>
        <p class="text-sm dark:text-accent text-primary">
          by @phylan
        </p>
      </template>

      <template #right>
        <UButton
          to="https://github.com/nuxt-ui-templates/starter"
          target="_blank"
          icon="i-simple-icons-github"
          aria-label="GitHub"
          class="text-primary dark:text-accent"
          variant="ghost"
        />
      </template>
    </UFooter>
  </UApp>
</template>
