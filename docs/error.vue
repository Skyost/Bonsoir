<script setup lang="ts">
import type { NuxtError } from '#app'

const props = defineProps<{ error: NuxtError }>()

const title = computed(() => {
  let result = 'Error'
  if ((Object.hasOwnProperty.call(props.error, 'statusCode'))) {
    result += ` ${props.error.statusCode}`
  }
  return result
})

// onMounted(() => console.error(props.error))
</script>

<template>
  <nuxt-layout>
    <page-head :title="title" />
    <div class="bg-white">
      <ski-container class="pt-5 pb-5">
        <error-display :error="error" />
      </ski-container>
    </div>
  </nuxt-layout>
</template>
