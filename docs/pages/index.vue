<script setup lang="ts">
import { siteMeta } from '~/meta'
const theme = useTheme()

const background = computed(() => theme.value === 'light' ? 'white' : 'dark')
const button = computed(() => theme.value === 'light' ? 'dark' : 'light')
</script>

<template>
  <div>
    <page-head :title="siteMeta.title" title-suffix="" />
    <bonsoir-header />
    <div :class="`bg-${background}`">
      <ski-container>
        <ski-columns class="pt-5">
          <ski-column
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
          </ski-column>
          <ski-column
            sm="12"
            md="6"
          >
            <shikiji-code
              code="
BonsoirService service = BonsoirService(
  name: 'My wonderful service',
  type: '_wonderful-service._tcp',
  port: 3030,
);

BonsoirBroadcast broadcast = BonsoirBroadcast(service: service);
await broadcast.initialize();
await broadcast.start();
"
            />
          </ski-column>
        </ski-columns>
        <div class="text-center pt-5 pb-5">
          <ski-button to="/docs" class="btn-lg ps-5 pe-5" :variant="button">
            <ski-icon icon="code-slash" /> Get started
          </ski-button>
        </div>
      </ski-container>
    </div>
  </div>
</template>
