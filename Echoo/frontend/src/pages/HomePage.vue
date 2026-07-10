<template>
  <div class="homepage-container">

    <div class="welcome-card">

      <!-- Sekcia loga – zobrazuje sa iba na väčších obrazovkách -->
      <div class="logo-section">
        <img
          v-if="!$q.screen.lt.md"
          src="/pictures/logo_transparent.png"
          alt="Echoo Logo"
          class="logo"
        />
      </div>

      <!-- Textová sekcia s nadpisom a podnadpisom -->
      <div class="text-section">
        <h1 class="welcome-title">Welcome to <span>Echoo</span></h1>

        <!-- Krátka inštrukcia pre používateľa -->
        <p class="welcome-subtitle">
          Select a channel from the sidebar to start chatting or create your own channel!
        </p>
      </div>

      <!-- Join Command Input -->
      <div class="join-command-section">
        <div class="command-label">
          <span>Join a channel</span>
        </div>

        <q-input
          v-model="joinCommand"
          class="join-input"
          dense
          outlined
          dark
          bg-color="grey-9"
          @keydown.enter="handleJoinCommand"
        >
        </q-input>

        <div class="command-hint">
          You can use: <strong>/join channelName</strong> or <strong>/join channelName [private]</strong>
        </div>
      </div>

    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, inject, getCurrentInstance } from 'vue'
import { useQuasar } from 'quasar'
import { useChannelCommands } from 'src/composables/useChannelCommands'
import { useRouter } from 'vue-router'
import type { Ref } from 'vue'
import type { UserChannel, Message } from '@/types'

const $q = useQuasar()
const instance = getCurrentInstance()
const socket = instance!.appContext.config.globalProperties.$socket
const router = useRouter()

// Inject potrebných dát z ChatLayout
const privateChannels = inject<Ref<UserChannel[]>>('privateChannels', ref([]))
const publicChannels = inject<Ref<UserChannel[]>>('publicChannels', ref([]))
const currentChannelId = inject<Ref<number | null>>('currentChannelId', ref(null))
const currentChannelName = inject<Ref<string>>('currentChannelName', ref(''))
const activeChannelPath = inject<Ref<string>>('activeChannelPath', ref(''))
const messages = inject<Ref<Message[]>>('messages', ref([]))
const currentUserId = inject<Ref<number | null>>('currentUserId', ref(null))

// Dummy handleChannelLeft pre composable (nepoužíva sa tu)
const handleChannelLeft = () => {}

// Channel Commands Composable
const { handleCommand } = useChannelCommands(
  privateChannels,
  publicChannels,
  currentChannelId,
  currentChannelName,
  activeChannelPath,
  messages,
  currentUserId,
  handleChannelLeft,
  $q,
  router,
  socket
)

const joinCommand = ref('')

// Validácia, či príkaz začína s /join
const isValidJoinCommand = computed(() => {
  const trimmed = joinCommand.value.trim()
  return trimmed.startsWith('/join ') && trimmed.length > 6
})

async function handleJoinCommand() {
  const cmd = joinCommand.value.trim()

  // Kontrola, či príkaz začína s /join
  if (!cmd.startsWith('/join')) {
    $q.notify({
      type: 'warning',
      message: 'Only /join commands are allowed here!'
    })
    return
  }

  // Kontrola, či je formát správny
  if (!isValidJoinCommand.value) {
    $q.notify({
      type: 'warning',
      message: 'Usage: /join channelName [private]'
    })
    return
  }

  // Spustenie príkazu
  await handleCommand(cmd)

  // Vymazanie inputu po úspešnom príkaze
  joinCommand.value = ''
}
</script>

<style scoped>
/* Hlavný kontajner – centrovanie celého obsahu */
.homepage-container {
  min-height: 90vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #1E1E1E;
  padding: 2rem;
}

/* Uvítacia karta so skleneným (glass) efektom */
.welcome-card {
  max-width: 800px;
  width: 100%;
  text-align: center;
  padding: 3rem 2rem;
  border-radius: 20px;

  /* Polopriehľadné pozadie a rozmazanie */
  background: rgba(30, 41, 59, 0.85);
  backdrop-filter: blur(12px);

  /* Tieň pre vizuálnu hĺbku */
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5);

  animation: fadeInUp 1s ease-out;
  border: 1px solid rgba(255,255,255,0.1);
}

/* Logo aplikácie */
.logo {
  height: 120px;
  border-radius: 15px;
}

/* Sekcia textu */
.text-section {
  margin-bottom: 2rem;
  animation: fadeIn 1s ease-out 0.2s both;
}

/* Hlavný nadpis */
.welcome-title {
  font-size: 3rem;
  font-weight: 800;
  margin-bottom: 1rem;
  color: #ffffff;
}

/* Farebný prechod pre časť textu */
.welcome-title span {
  background: linear-gradient(180deg,
    #b97a9a, #816b91, #4e74a3, #5988c0);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

/* Podnadpis */
.welcome-subtitle {
  font-size: 1.2rem;
  color: #cbd5e1;
  line-height: 1.6;
}

/* JOIN COMMAND SECTION */
.join-command-section {
  margin-top: 2rem;
  padding: 1.5rem;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  animation: fadeIn 1s ease-out 0.4s both;
}

.command-label {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-bottom: 1rem;
  color: #cbd5e1;
  font-weight: 600;
  font-size: 0.95rem;
}

.join-input {
  width: 100%;
  margin-bottom: 0.5rem;
}

.join-input :deep(.q-field__control) {
  border-radius: 8px;
}

.command-hint {
  font-size: 0.85rem;
  color: #94a3b8;
  margin-top: 0.75rem;
}

.command-hint code {
  background: rgba(255, 255, 255, 0.1);
  padding: 2px 8px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  color: #5865f2;
  margin: 0 4px;
}

/* Jemná fade-in animácia */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Animácia smerom nahor */
@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(40px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Responzívne úpravy pre menšie zariadenia */
@media (max-width: 768px) {
  .welcome-title { font-size: 2rem; }
  .welcome-subtitle { font-size: 1rem; }
  .logo { height: 100px; }
  .join-command-section { padding: 1rem; }
  .command-hint { font-size: 0.75rem; }
}
</style>
