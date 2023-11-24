<script setup lang="ts">
defineProps<{ id?: string }>()

const theme = useTheme()
</script>

<template>
  <h1 :id="id" :class="`theme-${theme}`">
    <span class="title">
      <slot />
      <anchor class="anchor" :target="id" />
    </span>
  </h1>
</template>

<style lang="scss" scoped>
@import 'assets/anchor';

h1 {
  counter-increment: headline-1;
  counter-reset: headline-2 headline-3;
  padding-bottom: 0.25rem;
  margin-top: 2rem;
  margin-bottom: 1rem;
  border-bottom: 1px solid rgba(black, 0.2);

  &.theme-dark {
    border-bottom: 1px solid rgba(white, 0.2);
  }

  &:first-child {
    margin-top: 0;
  }

  .title {
    @include title-anchor();
  }

  &:before {
    content: counter(headline-1, upper-roman) ' - ';
  }
}
</style>
