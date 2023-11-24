<script setup lang="ts">
const theme = useTheme()

const props = withDefaults(
  defineProps<{
    code: string,
    language?: string
    filename?: string
  }>(),
  {
    language: 'dart',
    filename: undefined
  }
)

import { getHighlighter } from 'shikiji'

const shiki = await getHighlighter({
  themes: ['min-light', 'github-dark']
})

// @ts-ignore
await shiki.loadLanguage(props.language)

const code = computed(() => props.code.trim().replace(/\r\n/g, '\n'))

const codeHtml = computed(() => shiki.codeToHtml(
  code.value,
  // @ts-ignore
  {
    themes: {
      light: 'min-light',
      dark: 'github-dark'
    },
    lang: props.language
  }
))

const lineCount = computed(() => code.value.split(/\r\n|\r|\n/).length)

const content = ref<HTMLDivElement>()
const copy = () => {
  if (window.clipboardData && window.clipboardData.setData) {
    return window.clipboardData.setData('Text', code.value)
  } else if (document.queryCommandSupported && document.queryCommandSupported('copy')) {
    const textarea = document.createElement('textarea')
    textarea.textContent = code.value
    textarea.style.position = 'fixed'
    content.value!.appendChild(textarea)
    textarea.select()
    try {
      return document.execCommand('copy')
    } catch (ex) {
      // eslint-disable-next-line no-console
      console.warn('Copy to clipboard failed.', ex)
      return prompt('Copy to clipboard: Ctrl+C, Enter', code.value)
    } finally {
      content.value!.removeChild(textarea)
    }
  }
}
</script>

<template>
  <div class="shikiji-code" :class="[`theme-${theme}`, {'has-filename': filename}]">
    <span v-if="filename" class="filename">
      <ski-icon class="icon" icon="chevron-right" /> {{ filename }}
    </span>
    <div ref="content" :class="{'no-line-count': lineCount === 0 || lineCount === 1}" v-html="codeHtml" />
    <ski-icon class="copy-icon" icon="copy" title="Copy code" @click="copy" />
  </div>
</template>

<style lang="scss" scoped>
@import 'assets/colors';

.shikiji-code {
  position: relative;

  &.has-filename {
    margin-top: 1.75em;

    .filename {
      position: absolute;
      font-size: 0.75em;
      top: 0;
      left: 0;
      transform: translateY(-100%);
      font-family: var(--bs-font-monospace);
      color: gray;

      .icon {
        vertical-align: middle;
      }
    }
  }

  :deep(pre) {
    padding: 10px;
  }

  :deep(pre.shiki) {
    margin-bottom: 0;
  }

  &.theme-light {
    background-color: $light;

    :deep(.shiki),
    :deep(.shiki span) {
      background-color: $light !important;
    }
  }

  &.theme-dark {
    background-color: $body-dark;

    :deep(.shiki),
    :deep(.shiki span) {
      background-color: $body-dark !important;
      color: var(--shiki-dark) !important;
      font-style: var(--shiki-dark-font-style) !important;
      font-weight: var(--shiki-dark-font-weight) !important;
      text-decoration: var(--shiki-dark-text-decoration) !important;
    }

    .copy-icon {
      color: $light;
    }
  }

  :deep(code) {
    counter-reset: step;
    counter-increment: step 0;
  }

  :deep(code .line:before) {
    content: counter(step);
    counter-increment: step;
    width: 1rem;
    margin-right: 1.5rem;
    display: inline-block;
    text-align: right;
    color: rgba(#738A94, 0.4)
  }

  .no-line-count :deep(code .line:before) {
    display: none;
  }

  .copy-icon {
    position: absolute;
    top: 10px;
    right: 10px;
    font-size: 1em;
    opacity: 0.5;
    transition: opacity 0.2s;
    cursor: pointer;
    color: $dark;

    &:hover {
      opacity: 1;
    }
  }
}
</style>
