<script setup lang="ts">
const theme = useTheme()
useUpdateTheme()
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

<style lang="scss">
@import 'assets/colors';

html {
  background-color: $light;
}
</style>
