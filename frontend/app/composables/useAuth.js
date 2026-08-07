export const useAuth = () => {
  const user = useState('auth:user', () => null)
  const pending = useState('auth:pending', () => false)
  const initialized = useState('auth:initialized', () => false)
  const api = useApi()

  const fetchUser = async () => {
    pending.value = true
    try {
      const resp = await api.get('/me')
      user.value = resp.data
    } catch {
      user.value = null
    } finally {
      pending.value = false
      initialized.value = true
    }
  }

  const logout = async () => {
    //TODO: wtf do I do API side here
    user.value = null
  }

  return {
    user,
    pending,
    initialized,
    isLoggedIn: computed(() => !!user.value),
    fetchUser,
    logout
  }
}
