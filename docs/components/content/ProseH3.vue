<script setup lang="ts">
defineProps<{ id?: string }>()
</script>

<template>
  <h3 :id="id">
    <span class="title">
      <slot />
      <anchor class="anchor" :target="id" />
    </span>
  </h3>
</template>

<style lang="scss" scoped>
@import 'assets/anchor';

h3 {
  counter-increment: headline-3;
  font-size: 1.5rem;

  .title {
    @include title-anchor();
  }

  &::before {
    content: counter(headline-3, lower-alpha) '. ';
  }
}
</style>
