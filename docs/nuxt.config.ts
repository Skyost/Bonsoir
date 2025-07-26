import StylelintPlugin from 'vite-plugin-stylelint'
import eslintPlugin from '@nabla/vite-plugin-eslint'
import { siteMeta } from './meta'

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({

  modules: [
    '@nuxt/eslint',
    'nuxt-cname-generator',
    '~/modules/commit-sha-file-generator',
    '@bootstrap-vue-next/nuxt',
    '@nuxtjs/google-fonts',
    'nuxt-link-checker',
    '@nuxtjs/sitemap',
    '@nuxtjs/robots',
    '@nuxt/icon',
  ],

  ssr: true,

  app: {
    head: {
      htmlAttrs: {
        lang: 'en',
      },
      meta: [
        { name: 'description', content: siteMeta.description },
        { name: 'theme-color', content: '#343a40' },
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
      ],
    },
  },

  css: [
    '~/assets/app.scss',
  ],

  site: {
    url: siteMeta.url,
    name: siteMeta.title,
    trailingSlash: false,
  },

  content: {
    markdown: {
      anchorLinks: false,
    },
  },

  compatibilityDate: '2025-07-01',

  vite: {
    plugins: [
      StylelintPlugin(),
      eslintPlugin(),
    ],
    css: {
      preprocessorOptions: {
        scss: {
          api: 'modern-compiler',
          silenceDeprecations: [
            'mixed-decls',
            'color-functions',
            'global-builtin',
            'import',
          ],
        },
      },
    },
  },

  cname: {
    host: siteMeta.url,
  },

  commitShaFileGenerator: {
    directory: 'node_modules/.commit-sha-file-generator/',
  },

  eslint: {
    config: {
      stylistic: true,
    },
  },

  googleFonts: {
    display: 'swap',
    families: {
      Raleway: true,
      Handlee: true,
    },
  },

  icon: {
    provider: 'iconify',
    class: 'vue-icon',
  },

  linkChecker: {
    failOnError: false,
    excludeLinks: [
      '/pdf/**',
    ],
    skipInspections: [
      'link-text',
      'no-uppercase-chars',
    ],
  },

  linkChecker: {
    failOnError: false,
  },
})
