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
    'nuxt-cname-generator',
    '~/modules/commit-sha-file-generator',
    'skimple-components/nuxt',
    '@nuxt/content',
    '@nuxtjs/google-fonts',
    'nuxt-link-checker',
    '@nuxtjs/sitemap',
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
    trailingSlash: false
  },

  linkChecker: {
    failOnError: false
  },

  cname: {
    host: siteMeta.url
  },

  runtimeConfig: {
    public: {
      url: siteMeta.url
    }
  }
})
