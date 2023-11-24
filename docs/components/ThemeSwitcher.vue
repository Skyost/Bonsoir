<script setup lang="ts">
const theme = useTheme()

const icon = computed(() => theme.value === 'light' ? 'moon-stars-fill' : 'sun-fill')
const toggleTheme = () => {
  theme.value = theme.value === 'light' ? 'dark' : 'light'
}
</script>

<template>
  <ski-icon :icon="icon" @click="toggleTheme" />
</template>
