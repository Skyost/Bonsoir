<script setup lang="ts">
import { siteMeta } from '~/meta'

const theme = useTheme()
</script>

<template>
  <ski-navbar class="navbar" :class="`navbar-${theme}`" :color="theme">
    <ski-navbar-collapse id="page-navbar-collapse">
      <template #brand>
        <ski-navbar-brand class="brand" to="/">
          <img class="logo" src="/images/hand.svg" alt="Logo">
          Bonsoir
        </ski-navbar-brand>
        <div class="d-block d-lg-none p-3">
          <theme-switcher />
        </div>
      </template>
      <ski-navbar-items class="me-auto">
        <ski-navbar-item to="/" :active="$route.path === '/'">
          <ski-icon icon="house-door-fill" /> Home
        </ski-navbar-item>
        <ski-navbar-item to="/docs" :active="$route.path.startsWith('/docs')">
          <ski-icon icon="file-text-fill" /> Docs
        </ski-navbar-item>
      </ski-navbar-items>
      <ski-navbar-items>
        <ski-navbar-item class="d-none d-lg-block" href="#">
          <theme-switcher />
        </ski-navbar-item>
        <ski-navbar-item :href="`https://github.com/${siteMeta.github}`">
          <ski-icon icon="github" /> Github
        </ski-navbar-item>
      </ski-navbar-items>
    </ski-navbar-collapse>
  </ski-navbar>
</template>

<style lang="scss" scoped>
@import 'assets/colors';
@import 'assets/wave';

.navbar {
  &.navbar-dark {
    background-color: $body-dark !important;

    .brand:before {
      filter: hue-rotate(225deg);
    }
  }

  .brand {
    font-family: Handlee, cursive;
    padding-top: 0.4em;
    font-size: 1.5em;
    position: relative;

    .logo {
      height: 1em;
      vertical-align: sub;
    }

    &:before {
      position: absolute;
      top: 0.62em;
      left: 0;
      content: '';
      height: 1em;
      width: 1em;
      background-image: url('/images/waves.svg');
      background-repeat: no-repeat;
    }

    &:hover .logo {
      @include wave-animation();
    }
  }
}
</style>
