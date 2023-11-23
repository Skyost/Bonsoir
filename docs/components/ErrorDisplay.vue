<script setup lang="ts">
const props = defineProps<{ error: any }>()

const errorCode = computed(() => {
  if (/^-?\d+$/.test(props.error.toString())) {
    return parseInt(props.error.toString())
  }
  if (Object.prototype.hasOwnProperty.call(props.error, 'statusCode')) {
    return parseInt(props.error.statusCode)
  }
  return null
})

const title = computed(() => {
  if (errorCode.value === 404) {
    return 'Page not found !'
  }
  if (errorCode.value) {
    return `Error ${errorCode.value}`
  }
  return 'Error'
})
</script>

<template>
  <div>
    <h1 v-text="title" />
    <p>
      You can keep browsing this website by going on <a href="javascript:history.back()">the previous page</a>
      or by going on <nuxt-link to="/">the home page</nuxt-link>.
      <span v-if="errorCode === 404">
        If you think something should be here,
        feel free to <a href="https://skyost.eu/fr/#contact">contact me</a> to report it.
      </span>
    </p>
  </div>
</template>
