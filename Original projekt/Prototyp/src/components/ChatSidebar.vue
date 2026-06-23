<template>

  <!-- SIDEBAR -->
  <q-drawer
  :model-value="drawerOpen"
  @update:model-value="$emit('update:drawerOpen', $event)"
  show-if-above
  side="left"
  bordered
  bg-color="#355070"
  class="sidebar"
  >
    <!-- CHANNELS & Add Channel -->
    <div class="sidebar-title-wrapper q-pa-md row items-center justify-between">
      <div class="text-bold sidebar-title">CHANNELS</div>
      <q-btn flat dense round icon="add" color="white" @click="showAddChannelDialog = true" class="add-channel-btn" size="sm">
        <!-- Tooltip (zobrazí sa pri prechode myšou) -->
        <q-tooltip v-if="$q.screen.gt.sm" anchor="top middle" self="bottom middle">
          Add Channel
        </q-tooltip>
      </q-btn>
    </div>

    <!-- SCROLLOVATEĽNÁ OBLASŤ SIDEBARU -->
    <div class="sidebar-scrollable">

      <div class="sidebar-divider"></div>

      <!-- SEKCIÁ PRE POZVÁNKY -->
      <div class="q-pa-sm sidebar-subtitle">Invites</div>

      <div class="channel-list">
        <div class="channel-wrapper">
          <q-item
          clickable
          @click="openInviteDialog"
          class="sidebar-item active-invite"
          >
            <q-item-section>Channel</q-item-section>
            <div class="invite-badge"></div>
          </q-item>
        </div>
      </div>

      <div class="sidebar-divider"></div>

      <!-- SÚKROMNÉ KANÁLY -->
      <div class="q-pa-sm sidebar-subtitle">Private Channels</div>

      <div class="channel-list">
        <div v-for="ch in privateChannels" :key="ch.name" class="channel-wrapper">
          <q-item
          clickable
          @click="selectChannel(ch)"
          :class="['sidebar-item', { 'active-channel': ch.path === activeChannelPath }]"
          >
            <q-item-section>{{ ch.name }}</q-item-section>
          </q-item>
          <ManageChannelMenu v-if="ch.path === activeChannelPath" />
        </div>
      </div>

      <div class="sidebar-divider"></div>

      <!-- VEREJNÉ KANÁLY -->
      <div class="q-pa-sm sidebar-subtitle">Public Channels</div>

      <div class="channel-list">
        <div v-for="ch in publicChannels" :key="ch.name" class="channel-wrapper">
          <q-item
          clickable
          @click="selectChannel(ch)"
          :class="['sidebar-item', { 'active-channel': ch.path === activeChannelPath }]">
            <q-item-section>{{ ch.name }}</q-item-section>
          </q-item>
          <ManageChannelMenu v-if="ch.path === activeChannelPath" />
        </div>
      </div>

      <!-- PRÁZDNA MEDZERA POD ZOZNAMOM (ABY LOGOUT NEPREKRYL OBSAH) -->
      <div style="height: 80px;"></div>

    </div>

    <!-- LOGOUT BUTTON -->
    <div class="logout-wrapper">
      <q-btn
      flat
      color="red"
      icon="logout"
      label="Log Out"
      class="logout-btn"
      @click="$emit('logout')"
      />
    </div>

    <!-- DIALÓG NA PRIDANIE NOVÉHO KANÁLU -->
    <AddChannelDialog
    v-model:visible="showAddChannelDialog"
    :existing-channels="allChannelNames"
    @create="handleCreateChannel"
    />

    <!-- INVITE DIALOG -->
    <q-dialog v-model="inviteDialog" persistent>
      <q-card style="width: 300px; background-color: #355070; color: white;">
        <q-card-section class="text-h6 text-center q-pt-md">
          Join Channel?
        </q-card-section>
        <q-card-section class="q-pt-none text-center">
          You have been invited to <strong>{{ invitedChannel.name }}</strong>
        </q-card-section>
        <q-card-actions align="center">
          <q-btn flat label="Join" color="white" @click="joinChannel" />
          <q-btn flat label="Cancel" color="white" @click="inviteDialog = false" />
        </q-card-actions>
      </q-card>
    </q-dialog>

  </q-drawer>

</template>



<script lang="ts" setup>
import { ref, computed } from 'vue'
import ManageChannelMenu from './ManageChannelMenu.vue'
import AddChannelDialog from './AddChannelDialog.vue'


/* ROZHRANIA PRE DÁTA O KANÁLOCH */
interface Channel {
  name: string
  path: string
}

interface ChannelData {
  name: string
  visibility: 'private' | 'public'
  description: string
  invitedMembers: string[]
  notificationLevel: string
}

/* PROPS - ÚDAJE ZO ZVYŠKU APLIKÁCIE */
const props = defineProps<{
  drawerOpen: boolean
  privateChannels: Channel[]
  publicChannels: Channel[]
}>()

/* UDALOSTI, KTORÉ KOMPONENT VYSIELA */
const emit = defineEmits<{
  'update:drawerOpen': [value: boolean]
  'goToChannel': [channel: Channel]
  'logout': []
  'createChannel': [data: ChannelData]
}>()

/* AKTUÁLNE VYBRANÝ KANÁL */
const activeChannelPath = ref<string>('')

/* OVLÁDANIE ZOBRAZENIA DIALÓGU NA PRIDANIE KANÁLU */
const showAddChannelDialog = ref(false)

/* ZOZNAM VŠETKÝCH NÁZVOV KANÁLOV (PRE VALIDÁCIU NOVÉHO) */
const allChannelNames = computed(() => {
  return [...props.privateChannels, ...props.publicChannels].map(ch => ch.name)
})

/* LOGIKA PRE POZVÁNKY */
const inviteDialog = ref(false)
const inviteAccepted = ref(false)
const invitedChannel: Channel = { name: 'Channel', path: '/chat/invite-channel' }

/* FUNKCIA NA VÝBER KANÁLU */
function selectChannel(ch: Channel) {
  activeChannelPath.value = ch.path
  emit('goToChannel', ch)
}

/* FUNKCIA NA VYTVORENIE NOVÉHO KANÁLU */
function handleCreateChannel(data: ChannelData) {
  console.log('Creating channel:', data)
  emit('createChannel', data)
}

/* OTVORENIE DIALÓGU PRI KLIKNUTÍ NA INVITE */
function openInviteDialog() {
  if (!inviteAccepted.value) {
    inviteDialog.value = true
  } else {
    selectChannel(invitedChannel)
  }
}

/* POTVRDENIE POZVÁNKY (JOIN CHANNEL) */
function joinChannel() {
  inviteAccepted.value = true
  inviteDialog.value = false
  selectChannel(invitedChannel)
}

</script>



<style>

/* HLAVNÝ ŠTÝL SIDEBARU */
.sidebar {
  background-color: #355070 !important;
  border-right: 1px solid #283C55;
  box-shadow: none !important;
  display: flex;
  flex-direction: column;
}

/* HLAVIČKA SIDEBARU (CHANNELS + + BUTTON) */
.sidebar-title-wrapper {
  display: flex;
  align-items: center;
  justify-content: space-between;
  z-index: 10;
  background-color: #355070;
  flex-shrink: 0;
}

/* SCROLLOVATEĽNÁ ČASŤ PRE ZOZNAM KANÁLOV */
.sidebar-scrollable {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
  padding-bottom: 80px;
}

/* CUSTOM SCROLLBAR */
.sidebar-scrollable::-webkit-scrollbar {
  width: 8px;
}

.sidebar-scrollable::-webkit-scrollbar-track {
  background: rgba(0, 0, 0, 0.1);
}

.sidebar-scrollable::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 4px;
}

.sidebar-scrollable::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.3);
}

/* ŠTÝL TLAČIDLA NA PRIDANIE KANÁLU */
.add-channel-btn {
  min-width: 32px !important;
  min-height: 32px !important;
  padding: 4px !important;
  transition: background-color 0.2s ease;
}

.add-channel-btn:hover {
  background-color: rgba(255, 255, 255, 0.1) !important;
}

.add-channel-btn .q-icon {
  font-size: 20px;
}

/* NADPISY SEKCIÍ */
.sidebar-title {
  color: #FFFFFF;
}

/* ZOZNAM KANÁLOV */
.channel-list {
  display: flex;
  flex-direction: column;
}

.channel-wrapper {
  display: flex;
  flex-direction: column;
}

/* ŠTÝL PRE POLOŽKY KANÁLOV */
.sidebar-item {
  color: #FFFFFF;
  transition: background-color 0.2s ease, font-weight 0.2s ease;
  position: relative;
}

.sidebar-item:hover {
  background-color: rgba(255, 255, 255, 0.1);
}

/* AKTÍVNY KANÁL */
.active-channel {
  background-color: rgba(255, 255, 255, 0.25);
  font-weight: bold;
  border-left: 3px solid #FFFFFF;
}

/* AKTÍVNA POZVÁNKA */
.active-invite {
  font-weight: bold;
}

/* MALÝ BADGE PRE NOVÉ POZVÁNKY */
.invite-badge {
  width: 10px;
  height: 10px;
  background-color: red;
  border-radius: 50%;
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
}

/* ROZDEĽOVACIA ČIARA MEDZI SEKCIAMI */
.sidebar-divider {
  height: 1px;
  background-color: rgba(255,255,255,0.3);
  margin: 8px 0;
}

.sidebar-subtitle {
  color: #FFFFFF;
  font-weight: bold;
  margin-top: 8px;
  margin-bottom: 4px;
  font-size: 0.85rem;
}

/* KONTAJNER PRE LOGOUT TLAČIDLO */
.logout-wrapper {
  position: fixed;
  bottom: 0;
  left: 0;
  width: 300px;
  padding: 0 20px 20px 20px;
  background: linear-gradient(to top, #355070 80%, transparent);
  padding-top: 20px;
  z-index: 1000;
}

/* ŠTÝL TLAČIDLA ODHLÁSENIA */
.logout-btn {
  width: 100%;
  background-color: rgba(255, 0, 0, 0.15);
  font-weight: bold;
  text-transform: none;
  border-radius: 8px;
  transition: background-color 0.2s ease;
}

.logout-btn:hover {
  background-color: rgba(255, 0, 0, 0.3);
}
</style>
