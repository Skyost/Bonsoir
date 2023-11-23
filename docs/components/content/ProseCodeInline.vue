<template>
  <code class="prose-code">
    <slot />
  </code>
</template>

<style scoped lang="scss">
@import 'assets/colors';

.prose-code {
  background: $light;
  padding: 2px 4px;
}
</style>
