import { execSync } from 'child_process'
import fs from 'fs'
import path from 'path'
import { addServerHandler, createResolver, defineNuxtModule, useLogger } from '@nuxt/kit'
import { storageKey, filename } from './common.ts'

/**
 * Options for the commit SHA file generator module.
 */
export interface ModuleOptions {
  /**
   * The file target URL.
   */
  targetUrl: string

  /**
   * The directory.
   */
  directory: string
}

/**
 * The name of the commit SHA file generator module.
 */
export const name = 'commit-sha-file-generator'

/**
 * The logger instance.
 */
const logger = useLogger(name)

/**
 * Nuxt module to generate a file containing the latest commit hash information.
 */
export default defineNuxtModule<ModuleOptions>({
  meta: {
    name,
    version: '0.0.1',
    configKey: 'commitShaFileGenerator',
    compatibility: { nuxt: '^3.0.0' },
  },
  defaults: {
    targetUrl: '/_api/',
    directory: `node_modules/.${name}/`,
  },
  setup: (options, nuxt) => {
    const resolver = createResolver(import.meta.url)
    const srcDir = nuxt.options.srcDir

    // Retrieve commit hash information.
    const long = execSync('git rev-parse HEAD', { cwd: srcDir }).toString().trim()
    const short = execSync('git rev-parse --short HEAD', { cwd: srcDir }).toString().trim()

    // Merge with other data.
    const directoryPath = resolver.resolve(srcDir, options.directory)
    const filePath = resolver.resolve(directoryPath, filename)

    // Write commit information to file.
    fs.mkdirSync(directoryPath, { recursive: true })
    fs.writeFileSync(filePath, JSON.stringify({ long, short }))
    logger.success(`Wrote latest commit info for ${long} in ${filePath}.`)

    logger.info('Registering it to Nitro...')
    nuxt.options.nitro.publicAssets = nuxt.options.nitro.publicAssets || []
    nuxt.options.nitro.publicAssets.push({
      baseURL: options.targetUrl,
      dir: directoryPath,
      fallthrough: true,
    })
    nuxt.options.nitro.serverAssets = nuxt.options.nitro.serverAssets || []
    nuxt.options.nitro.serverAssets.push({
      baseName: storageKey,
      dir: directoryPath,
    })
    addServerHandler({
      route: `${options.targetUrl}${path.parse(filePath).base}`,
      handler: resolver.resolve(`./handler.ts`),
    })
    logger.success(`Done : "${options.targetUrl}" mapped to "${filePath}".`)
  },
})
