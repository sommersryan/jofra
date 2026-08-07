import {useAuth} from "~/composables/useAuth.js";

export default defineNuxtPlugin(async () => {
  const { fetchUser, initialized } = useAuth()
  if (!initialized.value) {
    await fetchUser()
  }
})
