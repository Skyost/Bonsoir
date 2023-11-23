<script setup lang="ts">
const props = withDefaults(
  defineProps<{
    code: string,
    language?: string
  }>(),
  {
    language: 'dart'
  }
)

import { getHighlighter } from 'shikiji'

const shiki = await getHighlighter({
  themes: ['min-light']
})

// @ts-ignore
await shiki.loadLanguage(props.language)

const code = computed(() => props.code.trim().replace(/\r\n/g, '\n'))
const content = ref<HTMLDivElement>()
onMounted(() => {
  content.value!.innerHTML = shiki.codeToHtml(
    code.value,
    // @ts-ignore
    {
      theme: 'min-light',
      lang: props.language
    }
  )
  const lineCount = code.value.split(/\r\n|\r|\n/).length
  if (lineCount === 0 || lineCount === 1) {
    content.value!.classList.add('no-linecount')
  }
})

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
  <div class="shikiji-code">
    <div ref="content" />
    <ski-icon class="copy-icon" icon="copy" title="Copy code" @click="copy" />
  </div>
</template>

<style lang="scss" scoped>
@import 'assets/colors';

.shikiji-code {
  position: relative;
  background-color: $light !important;

  :deep(pre) {
    padding: 10px;
  }

  :deep(pre.shiki) {
    margin-bottom: 0;
  }

  :deep(.shiki),
  :deep(.shiki span) {
    background-color: $light !important;
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

  .no-linecount :deep(code .line:before) {
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
