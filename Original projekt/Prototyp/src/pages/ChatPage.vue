<template>

  <!-- HLAVNÁ STRÁNKA CHATU -->
  <q-page class="chat-page">

    <!-- KOMPONENT ZOBRAZUJÚCI SPRÁVY -->
    <ChatMessages ref="chatMessagesRef" :messages="messages" />

  </q-page>

</template>



<script lang="ts" setup>
import ChatMessages from 'components/ChatMessages.vue'
import { inject, type Ref, shallowRef } from 'vue'

/* ROZHRANIE PRE SPRÁVY */
interface Message {
  id: number
  user: string
  text: string
}

/* INJEKCIA SPRÁV Z PARENT KOMPONENTU */
const messages = inject<Ref<Message[]>>('messages')!
if (!messages) throw new Error('messages not provided!')

/* REFERENCIA NA CHATMESSAGE KOMPONENT PRE MOŽNÚ MANIPULÁCIU ZVONKU */
const chatMessagesRef = shallowRef<InstanceType<typeof ChatMessages>>()

/* SPRÍSTUPNENIE REFERENCIE PRE RODIČOVSKÝ KOMPONENT */
defineExpose({ chatMessagesRef })

</script>



<style>

/* HLAVNÝ ŠTÝL CHAT STRÁNKY */
.chat-page {
  background-color: #1E1E1E;
  height: 100%;
  display: flex;
  flex-direction: column;
}

</style>
