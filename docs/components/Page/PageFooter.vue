<script setup lang="ts">
import { siteMeta } from '~/meta'
</script>

<template>
  <footer>
    <ski-container class="pt-4 pb-4 text-center" fluid>
      <p>
        <a :href="`https://github.com/${siteMeta.github}`">Github</a>
        &#128900; <a :href="`https://pub.dev/packages/${siteMeta.pubDev}`">pub.dev</a>
        &#128900; <a :href="`https://paypal.me/${siteMeta.paypal}`">Donate</a>
      </p>
      <p>
        <small>
          Copyright &copy; 2023, <a href="https://skyost.eu">Skyost</a>.
          Revision <current-commit-sha />.
        </small>
      </p>
      <ul class="icons">
        <li>
          <a href="https://vuejs.org">
            <img class="icon" src="/icons/vue.svg" alt="Vue.js">
          </a>
        </li>
        <li>
          <a href="https://nuxt.com">
            <img class="icon" src="/icons/nuxt.svg" alt="Nuxt">
          </a>
        </li>
        <li>
          <a href="https://flutter.dev">
            <img class="icon" src="/icons/flutter.svg" alt="Flutter">
          </a>
        </li>
      </ul>
    </ski-container>
  </footer>
</template>

<style lang="scss" scoped>
.icons {
  padding-left: 0;
  margin-bottom: 0;

  li {
    display: inline-block;
    margin: 0 0.25em;

    .icon {
      height: 12px;
    }
  }
}
</style>
