import * as bootstrapCollapse from 'bootstrap/js/dist/collapse'

export default defineNuxtPlugin((nuxtApp) => {
  nuxtApp.provide('bootstrap', {
    ...bootstrapCollapse
  })
})
