<script setup lang="ts">
import { siteMeta } from '~/meta'

const { data: commitSha } = await useFetch('/_api/latest-commit.json')
</script>

<template>
  <span v-if="commitSha">
    <a :href="`https://github.com/${siteMeta.github}/commit/${commitSha.long}`">&#35;{{ commitSha.short }}</a>
  </span>
</template>
