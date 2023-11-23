<script setup lang="ts">
import { siteMeta } from '~/meta'
</script>

<template>
  <header class="bonsoir-header">
    <div class="title">
      <div class="logo">
        <img src="/images/hand.svg" alt="Hand" class="hand">
      </div>
      <h1>{{ siteMeta.title }}</h1>
    </div>
  </header>
</template>

<style scoped lang="scss">
@import "assets/wave";

.bonsoir-header {
  position: relative;
  min-height: 400px;

  .title {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);

    h1 {
      font-family: Handlee, cursive;
      font-size: 5rem;
    }

    .logo {
      position: relative;
      height: 220px;
      text-align: center;

      .hand {
        @include wave-animation();
      }

      &:before {
        animation: fade-in-animation;
        animation-delay: 1s;
        animation-duration: 1s;
        animation-iteration-count: 1;
        animation-fill-mode: forwards;
        opacity: 0;
        position: absolute;
        content: '';
        height: 100%;
        width: 100%;
        background-image: url('/images/waves.svg');
        background-repeat: no-repeat;
      }
    }
  }
}

@keyframes fade-in-animation {
  0% {
    opacity: 0;
  }
  100% {
    opacity: 1;
  }
}
</style>
