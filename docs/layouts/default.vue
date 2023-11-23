<template>
  <div>
    <page-navbar />
    <div class="page-content">
      <slot />
    </div>
    <page-footer />
  </div>
</template>

<style lang="scss" scoped>
@import 'assets/colors';

.page-content {
  background-color: $light;
}
</style>
