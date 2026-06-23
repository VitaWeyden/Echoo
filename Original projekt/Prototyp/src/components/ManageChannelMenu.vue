<template>
  <!-- Hlavný obal pre menu -->
  <div class="manage-wrapper">
    <!-- Tlačidlo na otvorenie menu správy kanála -->
    <q-btn
      flat
      dense
      label="Manage Channel"
      color="white"
      @click.stop="menu = !menu"
      class="manage-btn"
    />

    <!-- Rozbaľovacie menu so zoznamom akcií -->
    <q-menu
      v-model="menu"
      anchor="bottom left"
      self="top left"
      :offset="[0, 4]"
    >
      <!-- Zoznam akcií v menu -->
      <q-list style="min-width: 200px; background-color: #2d4a6b; color: white;">

        <!-- Pridať používateľa -->
        <q-item clickable v-ripple @click="addUser">
          <q-item-section avatar>
            <q-icon name="person_add" color="white" />
          </q-item-section>
          <q-item-section>
            <q-item-label>Add User</q-item-label>
          </q-item-section>
        </q-item>

        <q-separator dark />

        <!-- Vyhodiť používateľa -->
        <q-item clickable v-ripple @click="kickUser">
          <q-item-section avatar>
            <q-icon name="sports_martial_arts" color="white" />
          </q-item-section>
          <q-item-section>
            <q-item-label>Kick User</q-item-label>
          </q-item-section>
        </q-item>

        <q-separator dark />

        <!-- Zablokovať používateľa -->
        <q-item clickable v-ripple @click="banUser">
          <q-item-section avatar>
            <q-icon name="no_accounts" color="white" />
          </q-item-section>
          <q-item-section>
            <q-item-label>Ban User</q-item-label>
          </q-item-section>
        </q-item>

        <q-separator dark />

        <!-- Spravovať oprávnenia -->
        <q-item clickable v-ripple @click="managePermissions">
          <q-item-section avatar>
            <q-icon name="security" color="white" />
          </q-item-section>
          <q-item-section>
            <q-item-label>Manage Permissions</q-item-label>
          </q-item-section>
        </q-item>

        <q-separator dark />

        <!-- Spravovať notifikácie -->
        <q-item clickable v-ripple @click="manageNotifications">
          <q-item-section avatar>
            <q-icon name="notifications" color="white" />
          </q-item-section>
          <q-item-section>
            <q-item-label>Manage Notifications</q-item-label>
          </q-item-section>
        </q-item>

        <q-separator dark />

        <!-- Zrušiť kanál -->
        <q-item clickable v-ripple @click="terminateChannel">
            <q-item-section avatar>
              <q-icon name="highlight_off" color="white" />
            </q-item-section>
            <q-item-section>
              <q-item-label>Terminate Channel</q-item-label>
            </q-item-section>
          </q-item>

          <q-separator dark />

          <!-- Opustiť kanál -->
          <q-item clickable v-ripple @click="leaveChannel">
            <q-item-section avatar>
              <q-icon name="exit_to_app" color="white" />
            </q-item-section>
            <q-item-section>
              <q-item-label>Leave Channel</q-item-label>
            </q-item-section>
          </q-item>
      </q-list>
    </q-menu>
  </div>
</template>



<script lang="ts" setup>
import { ref } from 'vue'

// Premenná, ktorá určuje, či je menu otvorené
const menu = ref(false)

// Funkcia na pridanie používateľa
function addUser() {
  menu.value = false
  console.log('Add user clicked')
}

// Funkcia na vyhodenie používateľa
function kickUser() {
  menu.value = false
  console.log('Remove user clicked')
}

// Funkcia na zablokovanie používateľa
function banUser() {
  menu.value = false
  console.log('Remove user clicked')
}

// Funkcia na správu oprávnení
function managePermissions() {
  menu.value = false
  console.log('Manage permissions clicked')
}

// Funkcia na správu notifikácií
function manageNotifications() {
  menu.value = false
  console.log('Manage notifications clicked')
}

// Funkcia na vymazanie kanála
function terminateChannel() {
  menu.value = false
  console.log('Terminate channel clicked')
}

// Funkcia na opustenie kanála
function leaveChannel() {
  menu.value = false
  console.log('Leave channel clicked')
}
</script>



<style scoped>
/* Obal pre menu */
.manage-wrapper {
  width: 100%;
  padding: 4px 8px;
  z-index: 1000;
}

/* Štýl tlačidla Manage Channel */
.manage-btn {
  width: 100%;
  text-align: center;
  font-size: 0.85rem;
  font-weight: 500;
  color: white !important;
  background-color: rgba(255, 255, 255, 0.05) !important;
  border-radius: 6px;
  padding: 6px 12px;
}

/* Efekt pri prechode myšou cez tlačidlo */
.manage-btn:hover {
  background-color: rgba(255, 255, 255, 0.15) !important;
}

/* Položky v menu */
.q-list .q-item {
  padding: 10px 16px;
}

/* Zvýraznenie položky pri prechode kurzorom */
.q-list .q-item:hover {
  background-color: rgba(255, 255, 255, 0.1);
}
</style>
