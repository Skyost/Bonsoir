<script setup lang="ts">
const theme = useTheme()
</script>

<template>
  <code class="prose-code" :class="`theme-${theme}`">
    <slot />
  </code>
</template>

<style scoped lang="scss">
@import 'assets/colors';

.prose-code {
  padding: 2px 4px;

  &.theme-dark {
    background-color: $body-dark;
  }

  &.theme-light {
    background-color: $light;
  }
}
</style>
