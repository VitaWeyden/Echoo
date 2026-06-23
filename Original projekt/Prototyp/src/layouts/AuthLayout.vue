<template>
  <!-- Hlavné rozloženie aplikácie pomocou Quasar Layout systému -->
  <q-layout view="hHh lpR fFf">
    <!-- 
      view="hHh lpR fFf" určuje správanie headeru, footeru a page containeru:
      - hHh: header je pevný hore (fixed)
      - lpR: left panel (drawer) je "reveal" — zobrazuje sa nad obsahom
      - fFf: footer je pevný dole (fixed)
    -->

    <!-- Kontajner pre obsah jednotlivých strán -->
    <q-page-container>
      <!-- router-view = miesto, kde sa načítavajú komponenty podľa aktuálnej cesty (route) -->
      <router-view />
    </q-page-container>

  </q-layout>
</template>