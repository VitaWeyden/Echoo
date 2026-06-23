<template>
  <!-- Tlačidlo s ikonou informácií -->
  <q-btn flat round dense icon="info" class="text-white info-btn">
    <!-- Tooltip po prejdení kurzorom -->
    <q-tooltip v-if="$q.screen.gt.sm" anchor="top middle" self="bottom middle">
      Commands
    </q-tooltip>

    <!-- Menu s príkazmi (otvorí sa po kliknutí, nezatvára sa automaticky) -->
    <q-menu :auto-close="false" anchor="bottom middle" self="top middle" transition-show="jump-down" transition-hide="jump-up">
      <div class="info-box-container" @click.stop>
        <div class="info-title">Commands</div>
        <div class="info-line">/join channelName [private]</div>
        <div class="info-line">/join channelName</div>
        <div class="info-line">/invite nickName</div>
        <div class="info-line">/revoke nickName</div>
        <div class="info-line">/kick nickName</div>
        <div class="info-line">/quit</div>
        <div class="info-line">/cancel</div>
        <div class="info-line">/list</div>
      </div>
    </q-menu>
  </q-btn>
</template>



<style scoped>
/* Štýl tlačidla s ikonou */
.q-btn {
  background-color: transparent;
  width: 36px;
  height: 36px;
  min-width: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Štýl menu (transparentné pozadie) */
.q-menu {
  background: transparent;
  min-width: 220px;
}

/* Kontajner s príkazmi */
.info-box-container {
  background: #355070;
  color: white;
  padding: 10px;
}

/* Každý riadok s príkazom */
.info-line {
  padding: 4px 0;
  font-size: 0.95rem;
}

/* Infobox Header štýl (Commands title) */
.info-title {
  font-weight: bold;
  font-size: 1.05rem;
  text-transform: uppercase;
  border-bottom: 1px solid rgba(255, 255, 255, 0.3);
  margin-bottom: 6px;
  padding-bottom: 4px;
  text-align: center;
  letter-spacing: 0.5px;
}

</style>
