<script setup lang="ts">
import { siteMeta } from '~/meta'
</script>

<template>
  <ski-navbar color="light">
    <ski-navbar-collapse id="page-navbar-collapse">
      <template #brand>
        <ski-navbar-brand class="brand" to="/">
          <img class="logo" src="/logo.svg" alt="Logo">
          Bonsoir
        </ski-navbar-brand>
      </template>
      <ski-navbar-items class="me-auto">
        <ski-navbar-item to="/" :active="$route.path === '/'">
          <ski-icon icon="house-door-fill" /> Home
        </ski-navbar-item>
        <ski-navbar-item to="/docs/" :active="$route.path.startsWith('/docs/')">
          <ski-icon icon="file-text-fill" /> Docs
        </ski-navbar-item>
      </ski-navbar-items>
      <ski-navbar-items>
        <ski-navbar-item :href="`https://github.com/${siteMeta.github}`">
          <ski-icon icon="github" /> Github
        </ski-navbar-item>
      </ski-navbar-items>
    </ski-navbar-collapse>
  </ski-navbar>
</template>

<style lang="scss" scoped>
@import 'assets/wave';

.brand {
  font-family: Handlee, cursive;
  padding-top: 0.4em;
  font-size: 1.5em;

  .logo {
    height: 1em;
    vertical-align: sub;
  }

  &:hover .logo {
    @include wave-animation();
  }
}
</style>
