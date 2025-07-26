import { storageKey, filename } from './common.ts'

export default defineEventHandler(async () => {
  return await useStorage(`assets:${storageKey}`).getItem(filename)
})
