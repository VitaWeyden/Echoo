<template>
  <!-- Kontajner pre tlačidlo odhlásenia -->
  <div class="logout-container">
    <!-- Tlačidlo na odhlásenie -->
    <q-btn
      flat
      color="red"
      icon="logout"
      label="Log Out"
      class="logout-btn"
      @click="onLogout"
    />
  </div>
</template>



<script lang="ts" setup>
// Definícia udalosti 'logout', ktorú komponent vysiela po kliknutí
const emit = defineEmits<{ logout: [] }>()

// Funkcia na odhlásenie používateľa
function onLogout() {
  emit('logout')
}
</script>



<style scoped>
/* Umiestnenie kontajnera s tlačidlom v ľavom dolnom rohu */
.logout-container {
  position: fixed;
  bottom: 10px;
  left: 20px;
  z-index: 2200;
}

/* Štýl tlačidla odhlásenia */
.logout-btn {
  font-weight: bold;
  text-transform: none;
  background-color: rgba(255, 0, 0, 0.15);
  border-radius: 10px;
  transition: background-color 0.2s ease;
}

/* Efekt pri prechode kurzorom na tlačidlo */
.logout-btn:hover {
  background-color: rgba(255, 0, 0, 0.3);
}
</style>
