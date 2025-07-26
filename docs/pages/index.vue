<script setup lang="ts">
import { codeToHtml } from 'shiki'

const theme = useTheme()

const background = computed(() => theme.value === 'light' ? 'white' : 'dark')
const button = computed(() => theme.value === 'light' ? 'dark' : 'light')

const demoCode = `BonsoirService service = BonsoirService(
  name: 'My wonderful service',
  type: '_wonderful-service._tcp',
  port: 3030,
);

BonsoirBroadcast broadcast = BonsoirBroadcast(service: service);
await broadcast.initialize();
await broadcast.start();`

onMounted(async () => {
  const shikiContainer = document.getElementById('demo-code')
  if (shikiContainer) {
    const html = await codeToHtml(
      demoCode,
      {
        lang: 'dart',
        themes: {
          light: 'min-light',
          dark: 'github-dark',
        },
      },
    )
    shikiContainer.classList.add('shiki-container')
    shikiContainer.innerHTML = html
    shikiContainer.classList.remove('opacity-0')
  }
})

usePageHead()
useShikiCopy()
</script>

<template>
  <div>
    <bonsoir-header />
    <div :class="`bg-${background}`">
      <b-container>
        <b-row class="pt-5">
          <b-col
            sm="12"
            md="6"
            class="d-flex align-items-center"
          >
            <div>
              <p>
                Bonsoir is a Flutter Zeroconf library that allows you to discover network services and to broadcast your own.
                It's based on <a href="https://developer.android.com/training/connect-devices-wirelessly/nsd">Android NSD</a>
                and on Apple's popular framework <a href="https://developer.apple.com/documentation/foundation/bonjour">Bonjour</a>.
              </p>
              <p>
                In fact, <q>Bonsoir</q> can be translated into <q>Good evening</q> (and <q>Bonjour</q> into
                <q>Good morning</q> or <q>Good afternoon</q> depending on the current moment of the day).
              </p>
              <p>
                You can use Bonsoir on Android, iOS, macOS, Windows and Linux.
              </p>
            </div>
          </b-col>
          <b-col
            sm="12"
            md="6"
          >
            <div
              id="demo-code"
              class="opacity-0"
            />
          </b-col>
        </b-row>
        <div class="text-center pt-5 pb-5">
          <b-button
            to="/docs"
            size="lg"
            class="ps-5 pe-5"
            :variant="button"
          >
            <icon name="bi:code-slash" /> Get started
          </b-button>
        </div>
      </b-container>
    </div>
  </div>
</template>

<style lang="scss" scoped>
#demo-code {
  transition: opacity 0.5s;
}
</style>
