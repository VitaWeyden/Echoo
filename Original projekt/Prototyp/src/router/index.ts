import { route } from 'quasar/wrappers'
import {
  createMemoryHistory,
  createRouter,
  createWebHistory,
  createWebHashHistory
} from 'vue-router'
import routes from './routes'

/*
 * This file creates the router instance for your app.
 * Changes to the router mode or base path should be done in quasar.config.js
 */

export default route(function (/* { store, ssrContext } */) {
  const createHistory = process.env.SERVER
    ? createMemoryHistory
    : process.env.VUE_ROUTER_MODE === 'history'
      ? createWebHistory
      : createWebHashHistory

  const Router = createRouter({
    scrollBehavior: () => ({ left: 0, top: 0 }),
    routes,

    // Important: use Quasar config for base path
    history: createHistory(process.env.VUE_ROUTER_BASE)
  })

  return Router
})
