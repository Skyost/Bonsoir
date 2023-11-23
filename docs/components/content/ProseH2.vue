<script setup lang="ts">
defineProps<{ id?: string }>()
</script>

<template>
  <h2 :id="id">
    <span class="title">
      <slot />
      <anchor class="anchor" :target="id" />
    </span>
  </h2>
</template>

<style lang="scss" scoped>
@import 'assets/anchor';

h2 {
  counter-increment: headline-2;
  counter-reset: headline-3;

  .title {
    @include title-anchor();
  }

  &::before {
    content: counter(headline-2) '. ';
  }
}
</style>
