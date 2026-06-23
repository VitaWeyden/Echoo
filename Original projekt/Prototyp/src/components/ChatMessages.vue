<template>

  <!-- HLAVNÁ SEKCIA PRE ZOBRAZENIE SPRÁV -->
  <div ref="messagesContainer" class="chat-messages">

    <!-- INFINITE SCROLL -->
    <q-infinite-scroll
    :offset="100"
    @load="loadMore"
    reverse
    spinner-color="white"
    >

      <!-- CYKLUS PRE ZOBRAZENIE KAŽDEJ SPRÁVY -->
      <div
      v-for="msg in localMessages"
      :key="msg.id"
      class="q-mb-md"
      >

        <!-- MENO POUŽÍVATEĽA -->
        <div class="text-bold">{{ msg.user }}</div>

        <!-- OBSAH SPRÁVY (S KONTROLOU NA PING) -->
        <div
        class="message-content q-pa-sm q-mt-xs"
        :class="{ 'ping-message': msg.isPing }"
        >

          <!-- FORMÁTOVANIE TEXTU (ZVÝRAZNENIE @USERNAME) -->
          <span v-html="formatMessage(msg.text, msg.isPing)"></span>
        </div>

      </div>
    </q-infinite-scroll>
  </div>

</template>



<script lang="ts" setup>
import { ref, watch, nextTick, onMounted } from 'vue'

/* ROZHRANIE PRE SPRÁVU */
interface Message {
  id: number
  user: string
  text: string
  isPing?: boolean
}

/* ÚDAJE PRICHÁDZAJÚCE Z NADRADENEJ KOMPONENTY */
const props = defineProps<{ messages: Message[] }>()

/* LOKÁLNE POLE SPRÁV (KÓPIA PRE VNÚTORNÚ PRÁCU) */
const localMessages = ref<Message[]>([])

/* REFERENCIA NA KONTAJNER, KDE SA ZOBRAZUJÚ SPRÁVY */
const messagesContainer = ref<HTMLElement | null>(null)

/* FUNKCIA NA SCROLLOVANIE NA SPODOK KONVERZÁCIE */
function scrollToBottom() {
  const el = messagesContainer.value
  if (el) {
    setTimeout(() => {
      el.scrollTop = el.scrollHeight
    }, 0)
  }
}

/* FUNKCIA NA FORMÁTOVANIE SPRÁVY (PING) */
function formatMessage(text: string, isPing?: boolean): string {
  if (!isPing) return text;
  return text.replace(/(@\w+)/g, '<span class="ping-highlight">$1</span>');
}

/* FUNKCIA NAČÍTAVAJÚCA STARŠIE SPRÁVY PRI SCROLLOVANÍ HORE */
function loadMore(index: number, done: (stop?: boolean) => void) {
  const el = messagesContainer.value
  const prevScrollHeight = el ? el.scrollHeight : 0

  setTimeout(() => {
    const older: Message[] = Array.from({ length: 10 }, (_, i) => ({
      id: Date.now() + Math.floor(Math.random() * 100000) + i,
      user: `User ${Math.ceil(Math.random() * 5)}`,
      text: `Older message ${i + 1}`
    }))

    // Pridá staršie správy na začiatok
    localMessages.value = [...older, ...localMessages.value]

    // Udrží pozíciu scrolovania po načítaní
    void nextTick().then(() => {
      if (el) el.scrollTop = el.scrollHeight - prevScrollHeight
      done()
    })
  }, 450)
}

/* SLEDUJE ZMENY V PROPS.MESSAGES A AKTUALIZUJE LOKÁLNE SPRÁVY */
watch(
  () => props.messages,
  (newVal) => {
    localMessages.value = [...newVal]
    scrollToBottom()
  },
  { immediate: true, deep: true }
)

/* SLEDUJE ZMENY V DĹŽKE LOKÁLNYCH SPRÁV A SCROLLUJE NA SPODOK */
watch(
  () => localMessages.value.length,
  async () => {
    await nextTick()
    scrollToBottom()
  }
)

/* PO NAČÍTANÍ KOMPONENTU SA AUTOMATICKY SCROLUJE NA SPODOK */
onMounted(() => {
  scrollToBottom()
})

</script>



<style>

/* ZVÝRAZNENIE POUŽÍVATEĽA V PING SPRÁVE */
.ping-highlight {
  color: #00aff4 !important;
  font-weight: 700;
}

/* HLAVNÝ KONTAJNER PRE SPRÁVY */
.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  padding-bottom: 100px;
}

/* ŠTÝL JEDNOTLIVÝCH SPRÁV */
.message-content {
  border-radius: 8px;
  background-color: #2d2d2d;
  color: white;
}

/* ŠTÝL PRE PING SPRÁVU (ZVÝRAZNENÉ SPRÁVY) */
.ping-message {
  background-color: rgba(88, 101, 242, 0.15) !important;
  border: 2px solid #5865f2;
  font-weight: 600;
}

</style>
