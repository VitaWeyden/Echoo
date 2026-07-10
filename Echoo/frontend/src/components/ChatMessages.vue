<template>
  <div ref="messagesContainer" class="chat-messages">
    <!-- Infinite scroll pre načítavanie starších správ -->
    <q-infinite-scroll
      :offset="250"
      :disable="isLoadingOlder || !hasMoreMessages || isInitializing"
      @load="onLoad"
      reverse
    >
      <!-- Načítavacia animácia -->
      <template v-slot:loading>
        <div class="row justify-center q-my-md">
          <q-spinner-dots color="white" size="40px" />
        </div>
      </template>

      <!-- Načítavacia animácia hore (v reverse režime) -->
      <div v-if="isLoadingOlder" class="row justify-center q-my-md">
        <q-spinner-dots color="white" size="40px" />
      </div>

      <!-- Zoznam správ -->
      <div v-for="msg in localMessages" :key="msg.id" class="q-mb-md message-wrapper">
        <!-- Systémová správa (výsledok príkazu, napr. /kick, /ban, /join...) -->
        <div v-if="msg.isCommand" class="row justify-center">
          <div class="command-message q-px-md q-py-xs">
            {{ msg.text }}
          </div>
        </div>

        <!-- Bežná chatová správa -->
        <div
          v-else
          class="message-container"
          :class="{ 'my-message': currentUserId === msg.userId }"
        >
          <!-- Meno odosielateľa -->
          <div class="text-bold message-author">
            {{ msg.user }}
          </div>
          <!-- Obsah správy -->
          <div
            class="message-content q-pa-sm q-mt-xs"
            :class="{ 'ping-message': isPingedMessage(msg) }"
          >
            <span v-html="formatMessage(msg.text)"></span>
          </div>
        </div>
      </div>

      <!-- Element na spodku pre scrollovanie -->
      <div ref="bottomElement"></div>
    </q-infinite-scroll>
  </div>
</template>

<script lang="ts" setup>
import { nextTick, ref, watch, onMounted, inject, type Ref } from 'vue'
import type { Message } from '@/types';
import API_URL from '../config/api';

// Injektované hodnoty z rodiča
const currentUserId = inject<number>('currentUserId')
const currentChannelId = inject<Ref<number | null>>('currentChannelId')

// Props z rodiča
const props = defineProps<{ messages: Message[] }>()

// Lokálne stavy pre infinite scroll, cache a zistenie pingu
const isLoadingOlder = ref(false) // Či sa práve načítavajú staršie správy
const hasMoreMessages = ref(true) // Či sú k dispozícii ďalšie staršie správy
const localMessages = ref<Message[]>([]) // Lokálny zoznam správ
const messagesContainer = ref<HTMLElement | null>(null) // Ref na kontajner správ
const bottomElement = ref<HTMLElement | null>(null) // Ref na spodný element
const userScrolledUp = ref(false) // Či používateľ scrolloval hore
const oldestMessageId = ref<number | null>(null) // ID najstaršej správy (pre načítanie ďalších)
const lastLoadTime = ref<number>(0) // Čas posledného načítania (rate limiting)
const isInitializing = ref(false) // Či prebieha inicializácia (blokuje infinite scroll)
const channelMembers = ref<Array<{ id: number, nickName: string, role: string }>>([]) // Členovia kanála

// Načítaj členov kanála z API (pre validáciu mentions)
async function loadChannelMembers() {
  if (!currentChannelId?.value) return

  try {
    const token = localStorage.getItem('auth_token')
    const res = await fetch(`${API_URL}/channels/${currentChannelId.value}/members`, {
      headers: { Authorization: `Bearer ${token}` }
    })

    if (res.ok) {
      channelMembers.value = await res.json()
      console.log('[ChatMessages] Loaded', channelMembers.value.length, 'channel members')
    }
  } catch (err) {
    console.error('[ChatMessages] Failed to load members:', err)
  }
}

// Pre fallback pingu si vytiahneme nick uložený v localStorage
function getCurrentUserNickname(): string | null {
  const savedUser = localStorage.getItem('user')
  if (!savedUser) return null
  try {
    const user = JSON.parse(savedUser)
    return user.nickName || null
  } catch {
    return null
  }
}

// Extrahuj všetky mentions zo správy (case-sensitive)
function extractMentions(text: string): string[] {
  // Regex na vyhľadanie všetkých mentions v texte (aj s úvodzovkami aj bez)
  const mentionRegex = /@(?:"([^"]+)"|'([^']+)'|(\S+))/g
  const matches = text.matchAll(mentionRegex)
  const mentions: string[] = []

  // Prejdi všetky nájdené mentions a pridaj ich do poľa (bez zavináča a úvodzoviek)
  for (const match of matches) {
    // Vyber meno z prvej neprázdnej skupiny (dvojité úvodzovky, jednoduché úvodzovky alebo bez úvodzoviek)
    const mention = match[1] || match[2] || match[3]
    if (mention) {
      mentions.push(mention)
    }
  }

  return mentions
}

// Načítavanie starších správ pri scrollnutí hore (reverse infinite scroll)
async function onLoad(index: number, done: (stop?: boolean) => void) {
  const now = Date.now()

  // Blokuj načítanie, ak ešte prebieha inicializácia (napr. po prepnutí kanála)
  if (isInitializing.value) {
    done()
    return
  }

  // Rate limiting: povolí načítanie max. raz za sekundu
  if (now - lastLoadTime.value < 1000) {
    done()
    return
  }

  // Ak nie je vybraný kanál, ukonči načítanie
  if (!currentChannelId?.value) {
    done(true)
    return
  }

  // Ak už prebieha načítavanie, nič nerob
  if (isLoadingOlder.value) {
    done()
    return
  }

  isLoadingOlder.value = true // Označ, že prebieha načítavanie
  lastLoadTime.value = now // Ulož čas posledného načítania

  const token = localStorage.getItem('auth_token')
  const beforeId = oldestMessageId.value ?? ''
  const url = `${API_URL}/channels/${currentChannelId.value}/messages?before=${beforeId}&limit=20`

  try {
    // Načítaj správy z API
    const response = await fetch(url, {
      headers: { Authorization: `Bearer ${token}` }
    })

    if (!response.ok) {
      // Ak API vráti chybu, ukonči načítanie
      console.error('[INFINITE SCROLL] Failed to fetch messages:', response.status)
      hasMoreMessages.value = false
      done(true)
      return
    }

    const newMessages: Message[] = await response.json()

    // Ak už nie sú žiadne ďalšie správy, nastav flag a ukonči
    if (newMessages.length === 0) {
      hasMoreMessages.value = false
      done(true)
      return
    }

    // API vracia správy od najnovšej po najstaršiu, preto ich otočíme
    const sortedMessages = [...newMessages].reverse()
    // Odstráň duplicity (už načítané správy)
    const existingIds = new Set(localMessages.value.map(m => m.id))
    const uniqueNewMessages = sortedMessages.filter(m => !existingIds.has(m.id))

    if (uniqueNewMessages.length > 0) {
      // Pridaj nové staršie správy na začiatok zoznamu
      localMessages.value = [...uniqueNewMessages, ...localMessages.value]
      const allIds = localMessages.value.map(m => m.id)
      oldestMessageId.value = Math.min(...allIds) // Aktualizuj najstaršiu správu
    }

    // Ak bolo načítaných menej ako 20 správ, už nie sú ďalšie
    if (newMessages.length < 20) {
      hasMoreMessages.value = false
    }

    setTimeout(() => {
      done()
    }, 300)

  } catch (err) {
    // Ak nastane chyba pri fetchi, nastav flag a ukonči
    console.error("[INFINITE SCROLL] Fetch error:", err)
    hasMoreMessages.value = false
    done(true)
  } finally {
    // Po krátkej pauze zruš loading stav
    setTimeout(() => {
      isLoadingOlder.value = false
    }, 200)
  }
}

// Naformátuj text správy – zvýrazni len mentions, ktoré patria členom kanála
function formatMessage(text: string): string {
  const MENTION_PLACEHOLDER = '___MENTION___'
  const mentions: Array<{ original: string; display: string }> = []

  // Set členov kanála pre validáciu (case-sensitive)
  const memberNicknames = new Set(
    channelMembers.value.map(m => m.nickName)
  )

  // Nahraď mentions placeholdermi (aby sme neescapovali HTML)
  const textWithPlaceholders = text.replace(
    /@(?:"([^"]+)"|'([^']+)'|(\S+))/g,
    (match, quoted1, quoted2, single) => {
      const mentionText = quoted1 || quoted2 || single

      // Zvýrazni len ak je validný člen kanála (case-sensitive)
      const isValidMention = memberNicknames.has(mentionText)

      const display = isValidMention
        ? `<span class="ping-highlight">@${mentionText}</span>`
        : `@${mentionText}`

      mentions.push({
        original: match,
        display
      })
      return `${MENTION_PLACEHOLDER}${mentions.length - 1}${MENTION_PLACEHOLDER}`
    }
  )

  // Escapuj HTML znaky (okrem placeholderov)
  const escaped = textWithPlaceholders
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')

  // Nahraď placeholdery skutočným HTML
  let result = escaped
  mentions.forEach((mention, index) => {
    result = result.replace(
      `${MENTION_PLACEHOLDER}${index}${MENTION_PLACEHOLDER}`,
      mention.display
    )
  })

  return result
}

// Zistí, či daná správa pinguje prihláseného používateľa
function isPingedMessage(msg: Message): boolean {
  // Vlastné správy sa nepingujú
  if (msg.userId === currentUserId) return false

  // Kontrola cez mentionedUserIds z backendu
  if (msg.mentionedUserIds && msg.mentionedUserIds.length > 0) {
    if (msg.mentionedUserIds.includes(currentUserId as number)) return true
  }

  // Fallback: kontrola cez nickname (spätná kompatibilita, case-sensitive)
  const currentNickname = getCurrentUserNickname()
  if (!currentNickname) return false
  const mentions = extractMentions(msg.text)
  return mentions.includes(currentNickname)
}

// Pomocník pre zistenie, či je scroll pri spodku
function isAtBottom(): boolean {
  const el = messagesContainer.value
  if (!el) return true
  const threshold = 100
  return el.scrollHeight - el.scrollTop - el.clientHeight <= threshold
}

// Jemný scroll na spodok (používa sa po nových správach)
function scrollToBottom() {
  const el = bottomElement.value
  if (!el) return
  el.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

// Ukladá, že používateľ sa posunul vyššie a nechce auto-scroll
function handleScroll() {
  userScrolledUp.value = !isAtBottom()
}

// Sleduj prichádzajúce správy; rozlišuje novú várku vs. prepnutie kanála
watch(
  () => props.messages,
  async (newVal) => {
    const wasBottom = isAtBottom()

    if (newVal.length > 0) {
      const currentIds = new Set(localMessages.value.map(m => m.id))
      const isChannelChange = newVal.length > 0 && newVal.every(m => !currentIds.has(m.id))

      if (isChannelChange) {
        // Zmena kanála - reinicializuj všetko
        console.log('[ChatMessages] Channel change detected')

        // Aktivuj inicializáciu - blokuj infinite scroll
        isInitializing.value = true

        localMessages.value = [...newVal]
        hasMoreMessages.value = true
        isLoadingOlder.value = false
        userScrolledUp.value = false

        // Nastav oldestMessageId pre načítanie starších správ
        if (newVal.length > 0) {
          const allIds = newVal.map(m => m.id)
          oldestMessageId.value = Math.min(...allIds)
          console.log('[ChatMessages] oldestMessageId set to:', oldestMessageId.value, 'from', allIds.length, 'messages')
        }

        await nextTick()

        // Scrollni na spodok, potom povoľ infinite scroll
        setTimeout(() => {
          scrollToBottom()

          setTimeout(() => {
            isInitializing.value = false
            console.log('[ChatMessages] Initialization complete, infinite scroll enabled')
          }, 500)
        }, 150)

      } else {
        // Pridaj nové správy (nie zmena kanála)
        const existingIds = new Set(localMessages.value.map(m => m.id))
        const uniqueNewMessages = newVal.filter(m => !existingIds.has(m.id))

        if (uniqueNewMessages.length > 0) {
          console.log('[ChatMessages] Adding', uniqueNewMessages.length, 'new messages')
          localMessages.value = [...localMessages.value, ...uniqueNewMessages]

          // Aktualizuj oldestMessageId
          const allIds = localMessages.value.map(m => m.id)
          if (allIds.length > 0) {
            const newOldest = Math.min(...allIds)
            if (oldestMessageId.value === null || newOldest < oldestMessageId.value) {
              oldestMessageId.value = newOldest
              console.log('[ChatMessages] Updated oldestMessageId to:', oldestMessageId.value)
            }
          }
        }

        await nextTick()

        // Scrollni na spodok len ak bol používateľ už dolu
        if (wasBottom || !userScrolledUp.value) {
          setTimeout(scrollToBottom, 100)
        }
      }
    }
  },
  { immediate: true, deep: true }
)

// Pri zmene kanála resetuje stav a znovu načíta členov
watch(
  () => currentChannelId?.value,
  () => {
    console.log('[ChatMessages] Channel ID changed, resetting state')
    hasMoreMessages.value = true
    oldestMessageId.value = null
    localMessages.value = []
    userScrolledUp.value = false
    lastLoadTime.value = 0
    isInitializing.value = true
    channelMembers.value = []

    void loadChannelMembers()

    void nextTick(() => {
      setTimeout(scrollToBottom, 300)
    })
  }
)

// Pri mount-e nastaví listener, načíta členov a scrollne na spodok
onMounted(() => {
  // Pridaj scroll listener
  const el = messagesContainer.value
  if (el) {
    el.addEventListener('scroll', handleScroll)
  }

  // Načítaj členov kanála
  void loadChannelMembers()

  // Scrollni na spodok
  void nextTick(() => {
    setTimeout(scrollToBottom, 500)
  })
})
</script>

<style scoped>
.command-message {
  background-color: rgba(255, 255, 255, 0.06);
  color: #b0b0b0;
  font-size: 0.85rem;
  font-style: italic;
  border-radius: 12px;
  text-align: center;
  max-width: 80%;
}

/* Zvýraznenie mention (modré) */
.message-content :deep(.ping-highlight) {
  color: #00aff4 !important;
  font-weight: 700;
  background-color: rgba(0, 175, 244, 0.15);
  padding: 2px 4px;
  border-radius: 3px;
}

/* Kontajner správ */
.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  margin-top: 80px;
  display: flex;
  flex-direction: column;
}

/* Wrapper pre každú správu */
.message-wrapper {
  max-width: 100%;
  width: 100%;
  overflow: hidden;
}

/* Kontajner správy (autor + obsah) */
.message-container {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  width: 100%;
  margin-bottom: 8px;
}

/* Meno autora pre vlastné správy (svetlo modrá) */
.my-message .message-author {
  color: #c6dfff;
  font-weight: 700;
}

/* Meno autora */
.message-author {
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* Obsah správy */
.message-content {
  border-radius: 12px;
  background-color: #2d2d2d;
  color: white;
  width: 100%;

  /* Text wrapping */
  word-wrap: break-word;
  overflow-wrap: break-word;
  word-break: break-word;
  white-space: pre-wrap;

  min-width: 0;
  overflow-wrap: anywhere;
  hyphens: auto;

  box-sizing: border-box;
}

/* Obsah vlastnej správy (modro-šedé pozadie) */
.my-message .message-content {
  background: #2b3137 !important;
  color: white;
}

/* Správa ktorá pingla používateľa (fialový border) */
.ping-message {
  background-color: rgba(88, 101, 242, 0.15) !important;
  border: 2px solid #5865f2;
  font-weight: 600;
}
</style>
