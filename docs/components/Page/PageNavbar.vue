<script setup lang="ts">
import { siteMeta } from '~/meta'

const theme = useTheme()
</script>

<template>
  <b-navbar
    v-b-color-mode="theme"
    class="navbar"
    :data-bs-theme="theme"
    toggleable="lg"
  >
    <b-navbar-brand
      class="brand"
      to="/"
    >
      <img
        class="logo"
        src="/images/hand.svg"
        alt="Logo"
      >
      Bonsoir
    </b-navbar-brand>
    <div class="d-block d-lg-none p-3">
      <theme-switcher />
    </div>
    <b-navbar-toggle target="page-navbar-collapse" />
    <b-collapse
      id="page-navbar-collapse"
      is-nav
    >
      <b-navbar-nav class="me-auto">
        <b-nav-item
          to="/"
          :active="$route.path === '/'"
        >
          <icon name="bi:house-door-fill" /> Home
        </b-nav-item>
        <b-nav-item
          to="/docs"
          :active="$route.path.startsWith('/docs')"
        >
          <icon name="bi:file-text-fill" /> Docs
        </b-nav-item>
      </b-navbar-nav>
      <b-navbar-nav>
        <b-nav-item class="d-none d-lg-block">
          <theme-switcher />
        </b-nav-item>
        <b-navbar-nav>
          <b-nav-item :href="`https://github.com/${siteMeta.github}`">
            <icon name="bi:github" /> Github
          </b-nav-item>
        </b-navbar-nav>
      </b-navbar-nav>
    </b-collapse>
  </b-navbar>
</template>

<style lang="scss" scoped>
@import 'assets/bootstrap-mixins';
@import 'assets/colors';
@import 'assets/wave';

.navbar {
  &.navbar-dark {
    background-color: $body-dark !important;

    .brand::before {
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

    &::before {
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
      @include wave-animation;
    }

    @include media-breakpoint-down(lg) {
      margin-right: 0;
    }
  }
}
</style>
