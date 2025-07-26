<template>
  <nuxt-layout>
    <nuxt-page />
  </nuxt-layout>
</template>

<style lang="scss">
@import 'assets/colors';

.shiki-container {
  position: relative;
  margin-bottom: 1rem;

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

  &[data-filename] {
    margin-top: 1.75em;

    &::before {
      position: absolute;
      content: '> ' attr(data-filename);
      font-size: 0.75em;
      top: 0;
      left: 0;
      transform: translateY(-100%);
      font-family: var(--bs-font-monospace), monospace;
      color: gray;
    }
  }

  pre {
    padding: 10px;

    &.shiki {
      margin-bottom: 0;
    }
  }

  code {
    counter-reset: step;
    counter-increment: step 0;
  }

  code .line::before {
    content: counter(step);
    counter-increment: step;
    width: 1rem;
    margin-right: 1.5rem;
    display: inline-block;
    text-align: right;
    color: rgba(#738A94, 0.4)
  }

  &[data-line-count="0"], &[data-line-count="1"] code .line::before {
    display: none;
  }
}

html[data-bs-theme='light'] {
  .shiki-container {
    background-color: $light;

    .shiki, .shiki span {
      background-color: $light !important;
    }
  }
}

html[data-bs-theme='dark'] {
  .shiki-container {
    background-color: $body-dark;

    .shiki, .shiki span {
      color: var(--shiki-dark) !important;
      background-color: $body-dark !important;
      font-style: var(--shiki-dark-font-style) !important;
      font-weight: var(--shiki-dark-font-weight) !important;
      text-decoration: var(--shiki-dark-text-decoration) !important;
    }

    .copy-icon {
      color: $light;
    }
  }
}
</style>
