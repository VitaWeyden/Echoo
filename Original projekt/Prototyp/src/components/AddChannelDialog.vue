<template>
  <!-- Dialog pre vytvorenie nového kanála -->
  <q-dialog
    :model-value="visible"
    @update:model-value="$emit('update:visible', $event)"
    maximized
    transition-show="slide-up"
    transition-hide="slide-down"
  >
    <!-- Hlavný obsah karty -->
    <q-card style="background-color: #2d4a6b; color: white; display: flex; flex-direction: column; height: 100%;">
      <!-- Header s názvom a tlačidlom zatvoriť -->
      <q-card-section class="row items-center q-pb-none" style="flex: 0 0 auto;">
        <div class="text-h6">Create New Channel</div>
        <q-space />
        <q-btn icon="close" flat round dense @click="closeDialog" />
      </q-card-section>

      <!-- Sekcia s formulárom -->
      <q-card-section class="q-pa-md" style="flex: 1 1 auto; overflow-y: auto;">
        <!-- Názov kanála -->
        <div class="q-mb-md">
          <label class="text-weight-medium q-mb-xs block">Channel Name</label>
          <q-input
            v-model="channelName"
            filled
            dense
            placeholder="Enter channel name"
            bg-color="rgba(255, 255, 255, 0.1)"
            color="white"
            dark
            :rules="[val => !!val || 'Channel name is required']"
          >
            <template v-slot:prepend>
              <q-icon name="tag" color="white" />
            </template>
          </q-input>
        </div>

        <!-- Viditeľnosť kanála -->
        <div class="q-mb-md">
          <label class="text-weight-medium q-mb-xs block">Visibility</label>
          <q-select
            v-model="visibility"
            :options="visibilityOptions"
            filled
            dense
            bg-color="rgba(255, 255, 255, 0.1)"
            color="white"
            dark
            emit-value
            map-options
          >
            <template v-slot:prepend>
              <q-icon :name="visibility === 'private' ? 'lock' : 'public'" color="white" />
            </template>
          </q-select>
        </div>

        <!-- Výber členov na pozvanie -->
        <div class="q-mb-md">
          <label class="text-weight-medium q-mb-xs block">Invite Members (Optional)</label>
          <q-select
            v-model="invitedMembers"
            :options="availableMembers"
            filled
            dense
            multiple
            use-chips
            bg-color="rgba(255, 255, 255, 0.1)"
            color="white"
            dark
            placeholder="Select members to invite"
          >
            <template v-slot:prepend>
              <q-icon name="people" color="white" />
            </template>
          </q-select>
        </div>

        <!-- Nastavenia notifikácií -->
        <div class="q-mb-md">
          <label class="text-weight-medium q-mb-xs block">Notification Settings</label>
          <q-option-group
            v-model="notificationLevel"
            :options="notificationOptions"
            color="primary"
            dark
            inline
          />
        </div>
      </q-card-section>

      <!-- Akcie v spodnej časti -->
      <q-card-actions align="right" class="q-px-md q-pb-md sticky-footer" style="flex: 0 0 auto;">
        <q-btn
          flat
          label="Cancel"
          color="white"
          @click="closeDialog"
          class="cancel-btn"
        />
        <q-btn
          unelevated
          label="Create Channel"
          color="primary"
          @click="createChannel"
          :disable="!channelName"
          class="create-btn"
        />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>



<script lang="ts" setup>
import { ref, watch } from 'vue'

// Stav formulára
const channelName = ref('')
const visibility = ref<'private' | 'public'>('public')
const description = ref('')
const invitedMembers = ref<string[]>([])
const notificationLevel = ref('all')

// Možnosti viditeľnosti
const visibilityOptions = [
  { label: 'Public', value: 'public', icon: 'public' },
  { label: 'Private', value: 'private', icon: 'lock' }
]

// Dostupní členovia
const availableMembers = ref([
  'John Doe',
  'Jane Smith',
  'Bob Johnson',
  'Alice Williams',
  'Charlie Brown'
])

// Možnosti notifikácií
const notificationOptions = [
  { label: 'All Messages', value: 'all' },
  { label: 'Mentions Only', value: 'mentions' },
  { label: 'Muted', value: 'muted' }
]

// Emits: udalosti, ktoré komponent vysiela
const emit = defineEmits<{
  'update:visible': [value: boolean]
  'create': [data: ChannelData]
}>()

// Props: vstupné vlastnosti komponentu
defineProps<{
  visible: boolean
  existingChannels?: string[]
}>()

// Typ dát kanála
interface ChannelData {
  name: string
  visibility: 'private' | 'public'
  description: string
  invitedMembers: string[]
  notificationLevel: string
}

// Zatvorenie dialógu a reset formulára
function closeDialog() {
  emit('update:visible', false)
  resetForm()
}

// Vytvorenie kanála a emit udalosti
function createChannel() {
  const channelData: ChannelData = {
    name: channelName.value,
    visibility: visibility.value,
    description: description.value,
    invitedMembers: invitedMembers.value,
    notificationLevel: notificationLevel.value
  }

  emit('create', channelData)
  closeDialog()
}

// Reset všetkých polí formulára
function resetForm() {
  channelName.value = ''
  visibility.value = 'public'
  description.value = ''
  invitedMembers.value = []
  notificationLevel.value = 'all'
}

// Reset formulára pri zmene emit (alebo zatvorení)
watch(() => emit, () => {
  resetForm()
})
</script>



<style scoped>
.block {
  display: block; /* zaberá celú šírku a zalomí riadok */
}

/* Pozadie spodnej časti dialogu */
.sticky-footer {
  background-color: #2d4a6b;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

/* Tlačidlo Zrušiť – základný štýl */
.cancel-btn {
  background-color: rgba(255, 255, 255, 0.1);
  border-radius: 6px;
}

/* Hover efekt tlačidla Zrušiť */
.cancel-btn:hover {
  background-color: rgba(255, 255, 255, 0.2);
}

/* Tlačidlo Vytvoriť – základná farba */
.create-btn {
  background-color: #4CAF50;
  color: white;
  border-radius: 6px;
  font-weight: bold;
}

/* Hover efekt tlačidla Vytvoriť */
.create-btn:hover {
  background-color: #45a049;
}

/* Zakázané tlačidlo Vytvoriť */
.create-btn:disabled {
  background-color: rgba(76, 175, 80, 0.5);
}
</style>
