<script setup lang="ts">
import { siteMeta } from '~/meta'

const theme = useTheme()
const background = computed(() => theme.value === 'light' ? 'white' : 'dark')

usePageHead({
  title: 'Documentation',
})

const { data, status, error } = await useFetch<{ body: string }>('/_api/docs/')
const onLinkClick = (event: MouseEvent) => {
  if (event.target?.tagName === 'A' && event.target.href && (event.target.href.startsWith('/') || event.target.href.startsWith(siteMeta.url))) {
    event.preventDefault()
    useRouter().push(new URL(event.target.href).pathname)
  }
}

useShikiCopy()
</script>

<template>
  <b-container
    class="content-container"
    fluid
  >
    <div
      class="content"
      :class="`bg-${background}`"
    >
      <div v-if="status === 'pending'">
        <spinner />
      </div>
      <div v-else-if="data">
        <div
          @click="onLinkClick"
          v-html="data.body"
        />
      </div>
      <div v-else>
        <error-display :error="error" />
      </div>
    </div>
  </b-container>
</template>

<style lang="scss" scoped>
@import 'assets/bootstrap-mixins';
@import 'assets/anchor';

.content-container {
  padding: 30px 0;

  .content {
    margin-left: 15%;
    margin-right: 15%;
    padding: 30px;

    :deep(h1) {
      counter-increment: headline-1;
      counter-reset: headline-2 headline-3;
      padding-bottom: 0.25rem;
      margin-top: 2rem;
      margin-bottom: 1rem;
      border-bottom: 1px solid rgb(black, 0.2);

      &.theme-dark {
        border-bottom: 1px solid rgb(white, 0.2);
      }

      &:first-child {
        margin-top: 0;
      }

      .title {
        @include title-anchor;
      }

      &::before {
        content: counter(headline-1, upper-roman) ' - ';
      }
    }

    :deep(h2) {
      counter-increment: headline-2;
      counter-reset: headline-3;

      .title {
        @include title-anchor;
      }

      &::before {
        content: counter(headline-2) '. ';
      }
    }

    :deep(h3) {
      counter-increment: headline-3;
      font-size: 1.5rem;

      .title {
        @include title-anchor;
      }

      &::before {
        content: counter(headline-3, lower-alpha) '. ';
      }
    }

    @include media-breakpoint-down(lg) {
      margin-left: 10%;
      margin-right: 10%;
    }

    @include media-breakpoint-down(md) {
      margin-left: 0;
      margin-right: 0;
    }
  }

  @include media-breakpoint-down(lg) {
    padding-top: 0;
  }
}
</style>
