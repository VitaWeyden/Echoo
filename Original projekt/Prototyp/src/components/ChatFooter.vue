<template>

  <!-- FOOTER SEKCIA -->
  <footer
  class="chat-footer row items-center q-pa-sm"
  :style="footerStyle"
  >

    <!-- VSTUPNÉ (INPUT) POLE PRE PÍSANIE NOVEJ SPRÁVY -->
    <q-input
    :model-value="newMessage"
    @update:model-value="$emit('update:newMessage', $event)"
    placeholder="Start writing..."
    class="col chat-input"
    dense
    outlined
    borderless
    @keydown="$emit('enterPress', $event)"
    />

  </footer>

</template>



<script lang="ts" setup>

/* ÚDAJE PRICHÁDZAJÚCE Z NAHRADENEJ KOMPONENTY */
defineProps<{
  newMessage: string
  footerStyle: Record<string, string | number>
}>()

/* DEFINOVANIE UDALOSTÍ, KTORÉ KOMPONENT VYSIELA SPÄť */
defineEmits<{
  'update:newMessage': [value: string | number | null]
  'enterPress': [event: KeyboardEvent]
}>()

</script>



<style>

/* HLAVNÝ šTÝL FOOTERA */
.chat-footer {
  z-index: 2100;
  background-color: #1E1E1E;
  height: 80px;
  display: flex;
  align-items: center;
  padding: 0 16px;
}

/* šTÝL PRE TEXTOVÉ POLE */
.chat-input {
  border-radius: 15px;
  background-color: white;
  padding: 6px 12px;
}
</style>
