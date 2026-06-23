<template>
  <div class="user-status">
    <!-- Tlačidlo zobrazujúce aktuálny status používateľa -->
    <q-btn flat round dense icon="person" :color="statusColor" @click="cycleStatus">
      <!-- Tooltip (zobrazí sa pri prechode myšou) -->
      <q-tooltip v-if="$q.screen.gt.sm" anchor="top middle" self="bottom middle">
        {{currentStatus.toUpperCase()}}
      </q-tooltip>
    </q-btn>
  </div>
</template>



<script lang="ts" setup>
import { ref, computed } from 'vue'

// Typ statusu - definuje tri možné hodnoty
type Status = 'online' | 'dnd' | 'offline'

// Aktuálny status používateľa (reaktívna hodnota)
const currentStatus = ref<Status>('online')

// Určenie farby podľa aktuálneho statusu
const statusColor = computed(() => {
  switch (currentStatus.value) {
    case 'online':
      return 'green'
    case 'dnd':
      return 'yellow'
    case 'offline':
      return 'red'
    default:
      return 'gray' // pre prípad, že currentStatus má neočakávanú hodnotu
  }
})

// Po kliknutí na ikonu sa cyklicky mení status: online → dnd → offline → online
function cycleStatus() {
  if (currentStatus.value === 'online') currentStatus.value = 'dnd'
  else if (currentStatus.value === 'dnd') currentStatus.value = 'offline'
  else currentStatus.value = 'online'
}
</script>



<style scoped>
/* Vycentruje ikonu do stredu kontajnera */
.user-status {
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
