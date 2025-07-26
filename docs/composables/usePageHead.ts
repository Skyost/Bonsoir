import { siteMeta } from '~/meta'

/**
 * Configurable parameters for `usePageHead`.
 */
export interface PageHead {
  /**
   * The page title.
   */
  title?: string
  /**
   * The page description.
   */
  description?: string
  /**
   * The OpenGraph image.
   */
  openGraphImage?: string
  /**
   * The Twitter card to use.
   */
  twitterCard?: 'summary' | 'summary_large_image' | 'app' | 'player'
  /**
   * The Twitter image.
   */
  twitterImage?: string
}

/**
 * Adds the specified tags to the page head.
 * @param pageHead The parameters to use.
 */
export const usePageHead = (pageHead: PageHead = {}) => {
  const head: PageHead = { ...pageHead }
  if (head.title) {
    head.title = `${head.title} | ${siteMeta.title}`
  }
  else {
    head.title = siteMeta.title
  }
  head.description ??= siteMeta.description
  head.openGraphImage ??= `${siteMeta.url}/images/social/open-graph.png`
  head.twitterCard ??= 'summary'
  head.twitterImage ??= `${siteMeta.url}/images/social/twitter.png`
  const route = useRoute()
  const currentAddress = `${siteMeta.url}${route.path}`
  useSeoMeta({
    title: head.title,
    description: head.description,
    ogTitle: head.title,
    ogDescription: head.description,
    ogType: 'website',
    ogSiteName: siteMeta.title,
    ogUrl: currentAddress,
    ogImage: head.openGraphImage,
    ogLocale: 'en',
    twitterCard: head.twitterCard,
    twitterTitle: head.title,
    twitterDescription: head.description,
    twitterSite: '@Skyost',
    twitterCreator: '@Skyost',
    twitterImage: head.twitterImage,
  })
  useHead({
    meta: [
      {
        name: 'twitter:url',
        content: currentAddress,
      },
    ],
    link: [
      {
        rel: 'canonical',
        href: currentAddress,
      },
    ],
  })
}
