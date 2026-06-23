<template>
  <!-- Hlavný header s paddingom -->
  <q-header elevated class="row items-center justify-between q-px-lg q-py-sm text-white">

    <!-- Ľavá časť: Logo / menu + názov kanála -->
    <div class="row items-center no-wrap" style="flex: 1; min-width: 0;">
      <!-- Tlačidlo menu na mobilných obrazovkách -->
      <q-btn
        v-if="$q.screen.lt.md"
        dense flat round icon="menu" class="q-mr-sm"
        @click="$emit('update:drawerOpen', !drawerOpen)"
      />

      <!-- Logo na desktop -->
      <img
        v-if="!$q.screen.lt.md"
        src="/pictures/logo.jpg"
        alt="Logo"
        class="rounded-borders"
        style="height: 40px;"
      />

      <!-- Názov aktuálneho kanála na mobile -->
      <div
        v-if="currentChannel && $q.screen.lt.md"
        class="text-bold current-channel"
      >
        {{ currentChannel }}
      </div>
    </div>

    <!-- Stredná časť: názov kanála na desktop -->
    <div
      v-if="currentChannel && !$q.screen.lt.md"
      class="text-bold current-channel centered"
    >
      {{ currentChannel }}
    </div>

    <!-- Pravá časť: členovia, status, nastavenia, info -->
    <div class="row items-center justify-end q-gutter-sm no-wrap" style="flex: 0 0 auto;">
      <MembersMenu v-if="currentChannel" :current-channel="currentChannel" />
      <UserStatus />
      <SettingsMenu />
      <InfoBox />
    </div>
  </q-header>
</template>



<script lang="ts" setup>
import { useQuasar } from 'quasar'
import SettingsMenu from './SettingsMenu.vue'
import InfoBox from './InfoBox.vue'
import UserStatus from './UserStatus.vue'
import MembersMenu from './MembersMenu.vue'

// Props: vstupné vlastnosti komponentu
defineProps<{
  drawerOpen: boolean // povinná vlastnosť
  currentChannel?: string // nepovinná vlastnosť
}>()

// Emits: udalosti, ktoré komponent vysiela
defineEmits<{
  'update:drawerOpen': [value: boolean]
}>()


const $q = useQuasar()
</script>



<style scoped>
/* Hlavný header */
.q-header {
  background-color: #283C55;
  height: 60px;
  z-index: 2000; /* poradie prekrytia elementov */
}

/* Zaoblené rohy pre logo */
.rounded-borders {
  border-radius: 8px;
}

/* Aktuálny kanál – text */
.current-channel {
  font-size: 1.25rem;
  font-weight: 700;
  color: white;
  white-space: nowrap; /* prevents text from wrapping to a new line */
  overflow: hidden; /* hides text that goes beyond the element's width */
  text-overflow: ellipsis; /* adds "..." at the end of the truncated text */
}

/* Centrálne zobrazenie textu */
.centered {
  position: absolute; /* takes the element out of normal flow and positions it absolutely */
  left: 50%; /* moves the element’s left edge to the horizontal center of its parent */
  transform: translateX(-50%); /* shifts it left by half of its own width to truly center it */
}

/* Flex elementy sa nezalamujú */
.no-wrap {
  flex-wrap: nowrap !important;
}
</style>
