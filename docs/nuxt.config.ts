import StylelintPlugin from 'vite-plugin-stylelint'
import eslintPlugin from 'vite-plugin-eslint'
import { siteMeta } from './meta'

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  ssr: true,

  app: {
    head: {
      htmlAttrs: {
        lang: 'en'
      },
      meta: [
        { name: 'description', content: siteMeta.description },
        { name: 'theme-color', content: '#343a40' }
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }
      ]
    }
  },

  css: [
    '~/assets/app.scss'
  ],

  vite: {
    plugins: [
      StylelintPlugin(),
      eslintPlugin()
    ]
  },

  modules: [
    '~/modules/generate-cname',
    '~/modules/generate-commit-sha-file',
    'skimple-components/nuxt',
    '@nuxt/content',
    '@nuxtjs/google-fonts',
    'nuxt-link-checker',
    'nuxt-simple-sitemap',
    'nuxt-simple-robots'
  ],

  googleFonts: {
    display: 'swap',
    families: {
      Raleway: true,
      Handlee: true
    }
  },

  skimpleComponents: {
    bootstrapCss: false,
    bootstrapJs: false
  },

  content: {
    contentHead: false,
    markdown: {
      anchorLinks: false
    }
  },

  site: {
    url: siteMeta.url,
    name: siteMeta.title,
    trailingSlash: true
  },

  linkChecker: {
    failOnError: false
  },

  cname: {
    hostname: siteMeta.url
  }
})
