<template>

  <!-- ZOBRAZENIE INDIKÁTORA PÍSANIA SPRÁVY -->
  <div class="typing-status-fixed" :style="typingStatusStyle">
    User 1 is typing...
  </div>

</template>



<script lang="ts" setup>

/* PRIJÍMANÉ PROPS, ŠTÝL PRE POZÍCIU */
defineProps<{
  typingStatusStyle: Record<string, string | number>
}>()

</script>



<style scoped>

/* HLAVNÝ ŠTÝL */
.typing-status-fixed {
  background: transparent;
}

</style>
