<script setup lang="ts">
import type { NuxtError } from '#app'

const props = defineProps<{ error: NuxtError }>()

watch (props.error, () => {
  let title = 'Error'
  if ((Object.hasOwnProperty.call(props.error, 'statusCode'))) {
    title += ` ${props.error.statusCode}`
  }
  usePageHead({
    title: title,
  })
})
// onMounted(() => console.error(props.error))
</script>

<template>
  <nuxt-layout>
    <div class="bg-white">
      <b-container class="pt-5 pb-5">
        <error-display :error="error" />
        {{ error }}
      </b-container>
    </div>
  </nuxt-layout>
</template>
