<script setup lang="ts">
defineProps<{
  target?: string
}>()
</script>

<template>
  <nuxt-link v-if="target" :to="`#${target}`">
    <ski-icon icon="link-45deg" />
  </nuxt-link>
</template>

<style lang="scss" scoped>
.anchor {
  color: grey;
}
</style>
