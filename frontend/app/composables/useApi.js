function buildHeaders(extra) {
  const forwarded = import.meta.server ? useRequestHeaders(['cookie']) : undefined
  return {
    ...forwarded,
    ...extra
  }
}

export const useApi = () => {
  const config = useRuntimeConfig()
  const baseURL = `${config.public.apiBaseUrl}/api`

  const request = (url, opts = {}) => {
    return $fetch(url, {
      baseURL,
      credentials: 'include',
      ...opts,
      headers: buildHeaders(opts.headers)
    })
  }

  return {
    get: (url, opts = {}) =>
      request(url, { ...opts, method: 'GET' }),

    post: (url, body, opts = {}) =>
      request(url, { ...opts, method: 'POST', body }),

    put: (url, body, opts = {}) =>
      request(url, { ...opts, method: 'PUT', body }),

    patch: (url, body, opts = {}) =>
      request(url, { ...opts, method: 'PATCH', body }),

    delete: (url, opts = {}) =>
      request(url, { ...opts, method: 'DELETE' })
  }
}
