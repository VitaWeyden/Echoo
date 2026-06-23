import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  // AUTH a root route-on
  {
    path: '/',
    component: () => import('layouts/AuthLayout.vue'),
    children: [
      { path: '', component: () => import('pages/AuthPage.vue') }
    ]
  },

  // CHAT
  {
    path: '/chat',
    component: () => import('layouts/ChatLayout.vue'),
    children: [
      { path: '', redirect: '/chat/private1' },
      { path: ':id', component: () => import('pages/ChatPage.vue') },
    ]
  },

  // 404 fallback
  {
    path: '/:catchAll(.*)*',
    component: () => import('pages/ErrorNotFound.vue')
  }
]

export default routes
