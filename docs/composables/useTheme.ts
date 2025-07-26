export const useTheme = () => useState('theme', () => 'light')

export const useUpdateTheme = () => {
  const theme = useTheme()

  const getTheme = (mediaQuery: MediaQueryList | MediaQueryListEvent): 'dark' | 'light' => mediaQuery.matches ? 'dark' : 'light'
  const themeUpdate = (event: MediaQueryListEvent) => {
    theme.value = getTheme(event)
  }

  onMounted(() => {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    if ('addEventListener' in mediaQuery) {
      mediaQuery.addEventListener('change', themeUpdate)
    }
    else {
      // @ts-expect-error deprecated API
      mediaQuery.addListener(themeUpdate)
    }
    theme.value = getTheme(mediaQuery)
  })
  onUnmounted(() => {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    if ('removeEventListener' in mediaQuery) {
      mediaQuery.removeEventListener('change', themeUpdate)
    }
    else {
      // @ts-expect-error deprecated API
      mediaQuery.removeListener(themeUpdate)
    }
  })
  return theme
}
