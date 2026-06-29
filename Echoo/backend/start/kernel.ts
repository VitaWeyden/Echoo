import router from '@adonisjs/core/services/router'
import server from '@adonisjs/core/services/server'
import app from '@adonisjs/core/services/app'
import { startCronJobs } from './cron.js'

server.errorHandler(() => import('#exceptions/handler'))

server.use([
  () => import('#middleware/container_bindings_middleware'),
  () => import('#middleware/force_json_response_middleware'),
  () => import('@adonisjs/cors/cors_middleware'),
])

router.use([
  () => import('@adonisjs/core/bodyparser_middleware'),
  () => import('@adonisjs/auth/initialize_auth_middleware'),
])

export const middleware = router.named({
  auth: () => import('#middleware/auth_middleware'),
})

// Only start cron and WebSocket when running as a web server, not during ace commands
if (app.getEnvironment() === 'web') {
  startCronJobs()

  app.ready(() => {
    import('#services/ws').then(({ default: Ws }) => {
      Ws.boot()
    })
  })
}
