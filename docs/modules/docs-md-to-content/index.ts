import * as fs from 'fs'
import { addPrerenderRoutes, addServerHandler, createResolver, defineNuxtModule, useLogger } from '@nuxt/kit'
import { marked } from 'marked'
import { storageKey, filename } from './common.ts'
import { siteMeta } from '~/meta.ts'
import markedShiki from 'marked-shiki'
import { codeToHtml } from 'shiki'
import GithubSlugger from 'github-slugger'

/**
 * The module name.
 */
const name = 'docs-md-to-content'

/**
 * The logger instance.
 */
const logger = useLogger(name)

export default defineNuxtModule({
  meta: {
    name: 'docs-md-to-content',
    version: '0.0.1',
    compatibility: { nuxt: '^3.0.0' },
  },
  setup: async (_, nuxt) => {
    const resolver = createResolver(import.meta.url)

    // Read docs.md file.
    const docsFilePath = resolver.resolve(nuxt.options.srcDir, 'content', 'docs.md')
    if (!fs.existsSync(docsFilePath)) {
      logger.fatal(`${docsFilePath} not found.`)
      return
    }

    // Render into HTML.
    const slugger = new GithubSlugger()
    const renderedMarkdown = await marked
      .use({
        renderer: {
          heading({ tokens, depth }) {
            const text = this.parser.parseInline(tokens)
            const id = slugger.slug(text)
            return `<h${depth} id="${id}"><span class="title">${text}<a class="anchor-link" href="#${id}">#</a></span></h${depth}>`
          },
          code({ text, lang, escaped }) {
            console.log(text, lang, escaped)
            return `<code class="language-${lang}">${escaped ? text : text.replace(/\n/g, '<br>')}</code>`
          },
        },
      })
      .use(markedShiki({
        async highlight(code, lang, props) {
          const regex = /^\[([\w.-/]+)\]$/
          let filename
          for (const prop of props) {
            if (regex.test(prop)) {
              filename = prop.replace(regex, '$1')
              break
            }
          }
          const html = await codeToHtml(
            code,
            {
              lang,
              themes: {
                light: 'min-light',
                dark: 'github-dark',
              },
            },
          )
          const lineCount = code.split(/\r\n|\r|\n/).length
          return `<div class="shiki-container" data-line-count="${lineCount}"${filename ? ' data-filename="' + filename + '"' : ''}>${html}</div>`
        },
      }))
      .parse(fs.readFileSync(docsFilePath, { encoding: 'utf8' }))
    const destinationDirectoryPath = resolver.resolve(nuxt.options.srcDir, 'node_modules', `.${name}`)
    const destinationFilePath = resolver.resolve(destinationDirectoryPath, filename)
    fs.mkdirSync(destinationDirectoryPath, { recursive: true })
    fs.writeFileSync(destinationFilePath, JSON.stringify({ body: renderedMarkdown.replaceAll(siteMeta.url, '') }))

    // Update Nitro config.
    nuxt.options.nitro.publicAssets = nuxt.options.nitro.publicAssets || []
    nuxt.options.nitro.publicAssets.push({
      baseURL: '/_api/docs/',
      dir: destinationDirectoryPath,
      fallthrough: true,
    })
    nuxt.options.nitro.serverAssets = nuxt.options.nitro.serverAssets || []
    nuxt.options.nitro.serverAssets.push({
      baseName: storageKey,
      dir: destinationDirectoryPath,
    })
    addServerHandler({
      route: `/_api/docs`,
      handler: resolver.resolve(`./handler.ts`),
    })
    addPrerenderRoutes('/')
    logger.success(`Pointing "/_api/docs/" to "${destinationDirectoryPath}".`)
  },
})
