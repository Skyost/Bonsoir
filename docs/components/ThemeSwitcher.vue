<script setup lang="ts">
const theme = useTheme()

const name = computed(() => theme.value === 'light' ? 'bi:moon-stars-fill' : 'bi:sun-fill')
const toggleTheme = () => {
  theme.value = theme.value === 'light' ? 'dark' : 'light'
}
</script>

<template>
  <icon
    :name="name"
    @click="toggleTheme"
  />
</template>
