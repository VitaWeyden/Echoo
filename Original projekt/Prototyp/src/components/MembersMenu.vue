<template>
  <div>
    <!-- Tlačidlo na zobrazenie zoznamu členov -->
    <q-btn dense flat round icon="people" class="text-white" @click="showMembers = true">
      <!-- Tooltip (zobrazí sa pri prechode myšou) -->
      <q-tooltip v-if="$q.screen.gt.sm" anchor="top middle" self="bottom middle">
        List Members
      </q-tooltip>
    </q-btn>

    <!-- Dialógové okno so zoznamom členov -->
    <q-dialog v-model="showMembers" persistent>
      <q-card
        style="width: 360px; max-height: 420px; background-color: #355070; color: white;"
      >
        <!-- Nadpis dialógu -->
        <q-card-section class="text-h6 text-center q-pt-md">
          Members of {{ currentChannel }}
        </q-card-section>

        <q-separator color="white" />

        <!-- Scrollovateľný zoznam členov -->
        <q-scroll-area style="height: 300px;">
          <div class="q-pa-md">
            <div class="column q-gutter-sm">
              <q-btn
                v-for="member in members"
                :key="member"
                flat
                rounded
                color="white"
                text-color="#283C55"
                @click="onMemberClick(member)"
                class="member-btn"
                align="left"
              >
                {{ member }}
              </q-btn>
            </div>
          </div>
        </q-scroll-area>

        <q-separator color="white" />

        <!-- Tlačidlo na zatvorenie dialógu -->
        <q-card-actions align="center" class="q-pb-sm">
          <q-btn flat label="Close" color="white" @click="showMembers = false" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>



<script lang="ts" setup>
import { ref } from 'vue'

// Stav určujúci, či je dialóg otvorený
const showMembers = ref(false)

// Statický zoznam členov (ukážkové dáta)
const members = [
  'Sophia Martinez', 'Liam Chen', 'Emma Rodriguez', 'Noah Williams', 'Olivia Johnson',
  'Ethan Brown', 'Ava Davis', 'Mason Garcia', 'Isabella Miller', 'Lucas Anderson',
  'Mia Thompson', 'Aiden Wilson', 'Charlotte Moore', 'Jackson Taylor', 'Amelia Thomas',
  'Logan Hernandez', 'Harper Lee', 'Sebastian White', 'Evelyn Harris', 'Alexander Clark'
]

// Vstupný parameter s názvom aktuálneho kanála
defineProps<{
  currentChannel?: string
}>()

// Funkcia pri kliknutí na člena, možná doimplementácia - kick/ban user na kliknutie
function onMemberClick(member: string) {
  console.log('Clicked member:', member)
}
</script>



<style scoped>
/* Štýl tlačidiel so zoznamom členov */
.member-btn {
  width: 100%;
  justify-content: flex-start;
}
</style>
