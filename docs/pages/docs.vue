<script setup lang="ts">
const theme = useTheme()

const background = computed(() => theme.value === 'light' ? 'white' : 'dark')
</script>

<template>
  <ski-container class="content-container" fluid>
    <page-head title="Documentation" />
    <div class="content" :class="`bg-${background}`">
      <content-doc path="/docs">
        <template #not-found>
          <error-display :error="404" />
        </template>
      </content-doc>
    </div>
  </ski-container>
</template>

<style lang="scss" scoped>
@import 'assets/bootstrap-mixins';

.content-container {
  padding: 30px 0;

  .content {
    margin-left: 15%;
    margin-right: 15%;
    padding: 30px;

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
