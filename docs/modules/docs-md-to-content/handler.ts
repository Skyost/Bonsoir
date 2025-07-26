import { storageKey, filename } from './common.ts'

export default defineEventHandler(async () => {
  const json = await useStorage(`assets:${storageKey}`).getItem(filename)
  if (!json) {
    throw createError({ status: 404 })
  }
  return json
})
