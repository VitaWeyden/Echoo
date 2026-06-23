<template>

  <!-- HLAVNÝ CHAT LAYOUT (ZÁKLADNÁ ŠTRUKTÚRA STRÁNKY) -->
  <q-layout view="hHh Lpr lFf" class="bg-dark text-white">

    <!-- HEADER -->
    <Header
    v-model:drawer-open="drawerOpen"
    :current-channel="currentChannelName"
    />

    <!-- SIDEBAR -->
    <Sidebar
    v-model:drawer-open="drawerOpen"
    :private-channels="privateChannels"
    :public-channels="publicChannels"
    @go-to-channel="goToChannel"
    @logout="handleLogout"
    @create-channel="handleCreateChannel"
    />

    <!-- MAIN CONTENT -->
    <q-page-container class="chat-bg">
      <router-view />
    </q-page-container>

    <!-- TYPING STATUS -->
    <TypingStatus
    v-if="isTyping"
    :typing-status-style="typingStatusStyle"
    />

    <!-- FOOTER -->
    <ChatFooter
    v-model:new-message="newMessage"
    :footer-style="footerStyle"
    @enter-press="onEnterPress"
    />

    <!-- NOTIFICATION POPUP -->
    <NotificationPopUp
    :visible="showNotification"
    sender="User 1"
    message="Message sent!"
    logo="/pictures/logo.jpg"
    />

  </q-layout>

</template>



<script lang="ts" setup>
import { ref, computed, watch, provide, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useQuasar } from 'quasar'
import NotificationPopUp from 'components/NotificationPopUp.vue'
import Header from 'components/ChatHeader.vue'
import Sidebar from 'components/ChatSidebar.vue'
import ChatFooter from 'components/ChatFooter.vue'
import TypingStatus from 'components/TypingStatus.vue'

/* NASTAVENIE MENA KOMPONENTU */
defineOptions({ name: 'ChatLayout' })

/* ROZHRANIA PRE TYPY DÁT */
interface ChannelData {
  name: string
  visibility: 'private' | 'public'
  description: string
  invitedMembers: string[]
  notificationLevel: string
}

/* ROZHRANIE PRE SPRÁVY */
interface Message {
  id: number
  user: string
  text: string
  isPing?: boolean
}

/* ZÁKLADNÉ INŠTANCIE */
const router = useRouter()
const route = useRoute()
const $q = useQuasar()

/* REAKTÍVNE DÁTA PRE SPRÁVY */
const messages = ref<Message[]>([])

/* STAVY A PREMENNÉ */
const drawerOpen = ref($q.screen.gt.sm)
const newMessage = ref('')
const isTyping = ref(false)
const showNotification = ref(false)
const currentChannelName = ref('')

/* ZOZNAMY KANÁLOV */
const privateChannels = ref([
  { name: '#private-1 (Admin)', path: '/chat/private1' },
  { name: '#private-2', path: '/chat/private2' }
])
const publicChannels = ref([
  { name: '#public-1 (Admin)', path: '/chat/public1' },
  { name: '#public-2', path: '/chat/public2' },
  { name: '#public-3', path: '/chat/public3' }
])

/* ŠTÝL PRE FOOTER – POZÍCIA DOLNÉHO PANELU */
const footerStyle = computed(() => ({
  left: $q.screen.lt.md ? '0' : '300px',
  right: '0',
  bottom: '0',
  position: 'fixed' as const
}))

/* ŠTÝL PRE STATUS PÍSANIA – NAD FOOTEROM */
const typingStatusStyle = computed(() => ({
  position: 'fixed' as const,
  left: $q.screen.lt.md ? '0' : '300px',
  bottom: '80px',
  right: '0',
  padding: '4px 16px',
  color: 'white',
  fontStyle: 'italic',
  zIndex: 2150
}))

/* FUNKCIA NA VYTVORENIE ZAČIATOČNÝCH SPRÁV (10) */
function createInitialMessages(): Message[] {
  return [
    {
      id: Date.now() + 1,
      user: 'User 1',
      text: `INITIAL MESSAGE`,
    },
    {
      id: Date.now() + 2,
      user: 'User 2',
      text: `INITIAL MESSAGE`,
    },
    {
      id: Date.now() + 3,
      user: 'User 3',
      text: `@username AAAAAAAAAAAAAAA`,
      isPing: true,
    },
    {
      id: Date.now() + 4,
      user: 'User 4',
      text: `INITIAL MESSAGE`,
    },
    {
      id: Date.now() + 5,
      user: 'User 5',
      text: `@username BBBBBBBBBBBBBB`,
      isPing: true,
    },
    {
      id: Date.now() + 6,
      user: 'User 6',
      text: `INITIAL MESSAGE`,
    },
    {
      id: Date.now() + 7,
      user: 'User 6',
      text: `INITIAL MESSAGE`,
    },
    {
      id: Date.now() + 8,
      user: 'User 6',
      text: `INITIAL MESSAGE`,
    },
    {
      id: Date.now() + 9,
      user: 'User 6',
      text: `INITIAL MESSAGE`,
    },
    {
      id: Date.now() + 10,
      user: 'User 6',
      text: `INITIAL MESSAGE`,
    },
  ]
}

/* FUNKCIA NA ZMENU KANÁLU */
function goToChannel(ch: { name: string; path: string }) {
  currentChannelName.value = ch.name
  messages.value = createInitialMessages()
  void router.push(ch.path)
}

/* FUNKCIA NA ODHLÁSENIE UŽÍVATEĽA */
function handleLogout() {
  localStorage.removeItem('userToken')
  void router.push('/')
}

/* FUNKCIA NA VYTVORENIE NOVÉHO KANÁLU */
function handleCreateChannel(data: ChannelData) {
  // Formátovanie channel name
  const formattedName = data.name.startsWith('#') ? data.name : `#${data.name}`

  // Kontrola, či názov kanála už existuje v oboch kategóriách
  const allChannels = [...privateChannels.value, ...publicChannels.value]
  const nameExists = allChannels.some(ch => ch.name.toLowerCase() === formattedName.toLowerCase())

  if (nameExists) {
    $q.notify({
      type: 'negative',
      message: `Channel "${formattedName}" already exists!`,
      position: 'top',
      timeout: 2500
    })
    return
  }

  // Generovanie pathu pre nový channel
  const channelPath = `/chat/${data.visibility}-${data.name.toLowerCase().replace(/\s+/g, '-')}`

  const newChannel = {
    name: formattedName,
    path: channelPath
  }

  // Pridanie do kategórie na základe visibility
  if (data.visibility === 'private') {
    privateChannels.value.push(newChannel)
  } else {
    publicChannels.value.push(newChannel)
  }

  // Zobraziť oznámenie o úspechu
  $q.notify({
    type: 'positive',
    message: `Channel "${newChannel.name}" created successfully!`,
    position: 'top',
    timeout: 2000
  })

  // Navigácia do nového channela
  currentChannelName.value = newChannel.name
  void router.push(channelPath)
}

/* FUNKCIA NA ODOSLANIE SPRÁVY */
async function onEnterPress(e: KeyboardEvent) {
  if (e.key === 'Enter' && newMessage.value.trim() !== '') {
    e.preventDefault()

    const newMsg: Message = {
      id: Date.now(),
      user: 'You',
      text: newMessage.value.trim()
    }

    messages.value.push(newMsg)

    // Reset input
    newMessage.value = ''

    // Notification
    showNotification.value = true
    setTimeout(() => { showNotification.value = false }, 2500)

    // Scrolling
    await nextTick()
    const chatMessagesEl = document.querySelector('.chat-messages')
    if (chatMessagesEl) {
      chatMessagesEl.scrollTop = chatMessagesEl.scrollHeight
    }
  }
}

/* LOGIKA PRE DETEKCIU PÍSANIA SPRÁV */
let typingTimeout: NodeJS.Timeout | null = null
watch(newMessage, (value) => {
  if (value !== '') {
    isTyping.value = true
    if (typingTimeout) clearTimeout(typingTimeout)
    typingTimeout = setTimeout(() => {
      isTyping.value = false
    }, 1000)
  } else {
    isTyping.value = false
  }
})

/* AUTOMATICKÉ SCROLLOVANIE PO ZMENE KANÁLU */
watch(currentChannelName, async () => {
  await nextTick()
  const chatMessagesEl = document.querySelector('.chat-messages')
  if (chatMessagesEl) {
    chatMessagesEl.scrollTop = chatMessagesEl.scrollHeight
  }
})

/* WATCH PRE SIDEBAR */
watch(
  () => $q.screen.name,
  (newSize, oldSize) => {
    // Ak zmením malý view na velký view
    if ((oldSize === 'xs' || oldSize === 'sm') && (newSize === 'md' || newSize === 'lg' || newSize === 'xl')) {
      // Zatváram sidebar manuálne
      drawerOpen.value = false

      // Po krátkom čakaní ho opäť otvoríme, aby Quasar mohol znovu zostaviť layout
      setTimeout(() => {
        drawerOpen.value = true
      }, 150)
    }
  }
)

/* SLEDOVANIE ROUTE: KEĎ SA MENÍ KANÁL ALEBO VSTÚPIME PRIAMO CEZ ROUTE */
watch(
  () => route.path,
  (newPath) => {
    // Nájdi channel podľa path
    const allChannels = [...privateChannels.value, ...publicChannels.value]
    const found = allChannels.find(ch => ch.path === newPath)

    if (found) {
      currentChannelName.value = found.name
      messages.value = createInitialMessages()
    } else {
      // Ak route neexistuje v našom zozname
      currentChannelName.value = ''
      messages.value = []
    }
  },
  { immediate: true }   //spustí sa aj pri prvom načítaní
)

/* SPRÁVY DOSTUPNÉ PRE VŠETKY DIEŤA KOMPONENTY */
provide('messages', messages)

</script>



<style>

/* HLAVNÝ šTÝL */
.chat-bg {
  background-color: #1E1E1E;
}

</style>
