<script setup lang="ts">
const theme = useUpdateTheme()
</script>

<template>
  <div>
    <Html :data-bs-theme="theme" />
    <nuxt-loading-indicator :color="theme === 'light' ? 'black' : 'white'" />
    <page-navbar />
    <slot />
    <page-footer />
  </div>
</template>
