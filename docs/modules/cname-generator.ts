import { dirname } from 'path'
import fs from 'fs'
import { createResolver, defineNuxtModule } from '@nuxt/kit'
import * as logger from '../utils/logger'

export interface ModuleOptions {
  hostname: string
}

const name = 'generate-cname'
export default defineNuxtModule<ModuleOptions>({
  meta: {
    name,
    version: '0.0.1',
    configKey: 'cname',
    compatibility: { nuxt: '^3.0.0' }
  },
  defaults: {
    hostname: 'localhost:3000'
  },
  setup: (options, nuxt) => {
    const resolver = createResolver(import.meta.url)
    const filePath = resolver.resolve(nuxt.options.srcDir, 'node_modules/.cache/cname/CNAME')
    const fileDirectory = dirname(filePath)
    if (!fs.existsSync(fileDirectory)) {
      fs.mkdirSync(fileDirectory, { recursive: true })
    }
    nuxt.options.nitro.publicAssets = nuxt.options.nitro.publicAssets || []
    nuxt.options.nitro.publicAssets.push({
      baseURL: '/',
      dir: dirname(filePath)
    })
    const { host } = new URL(options.hostname)
    fs.writeFileSync(filePath, host)
    logger.success(name, `Generated CNAME for ${host}.`)
  }
})
