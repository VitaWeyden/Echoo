import { Server } from 'socket.io'
import server from '@adonisjs/core/services/server'
import Message from '#models/message'
import MessageMention from '#models/message_mention'
import User from '#models/user'
import CommandLog from '#models/command_log'
import { DateTime } from 'luxon'

class Ws {
  io: Server | undefined
  private booted = false

  boot() {
    if (this.booted) return
    this.booted = true

    // Any additional origins to allow beyond localhost and private networks
    // - e.g. a public cloud VM's IP. Same mechanism as backend/config/cors.ts;
    // duplicated here because Socket.IO's CORS check is entirely separate
    // from AdonisJS's own HTTP CORS middleware. See TROUBLESHOOTING.md #16.
    const extraAllowedOrigins = (process.env.ALLOWED_ORIGINS ?? '')
      .split(',')
      .map((o) => o.trim())
      .filter(Boolean)

    // Inicializácia Socket.IO servera s vlastným CORS callbackom
    this.io = new Server(server.getNodeServer(), {
      cors: {
        // Rovnaké nastavenie ako pri HTTP CORS, len bez callbacku
        origin: (origin, callback) => {
          if (!origin) return callback(null, true)

          if (extraAllowedOrigins.includes(origin)) {
            return callback(null, true)
          }

          try {
            const url = new URL(origin)
            const hostname = url.hostname

            // Localhost
            if (hostname === 'localhost' || hostname === '127.0.0.1' || hostname === '::1') {
              return callback(null, true)
            }

            // Súkromné siete (RFC 1918)
            if (
              /^10\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.test(hostname) ||
              /^172\.(1[6-9]|2\d|3[01])\.\d{1,3}\.\d{1,3}$/.test(hostname) ||
              /^192\.168\.\d{1,3}\.\d{1,3}$/.test(hostname)
            ) {
              return callback(null, true)
            }

            console.log('[WS] Rejected origin:', origin)
            callback(new Error('Not allowed by CORS'))
          } catch (err) {
            console.error('[WS] Error parsing origin:', origin, err)
            callback(new Error('Invalid origin'))
          }
        },
        credentials: true,
        methods: ['GET', 'POST'],
      },
    })

    this.io.on('connection', (socket) => {
      // console.log(`[WS] New client: ${socket.id}`)

      socket.on('join', (room: string) => {
        socket.join(room)
        // console.log(`[WS] Joined room: ${room}`)
      })

      socket.on('leave', (room: string) => {
        socket.leave(room)
        // console.log(`[WS] Left room: ${room}`)
      })

      // Používateľ sa pripája do svojej osobnej miestnosti pre notifikácie o pozvánkach
      socket.on('join_user_room', (userId: number) => {
        const userRoom = `user_${userId}`
        socket.join(userRoom)
        // console.log(`[WS] User ${userId} joined personal room: ${userRoom}`)
      })

      socket.on('typing', (data: { channelId: number; user: string }) => {
        const room = `channel_${data.channelId}`
        // console.log('TYPING EVENT:', data, ' -> broadcasting to ', room)

        // Odošli správu každému inému v miestnosti okrem odosielateľa
        socket.to(room).emit('user_typing', { user: data.user, channelId: data.channelId })

        // Voliteľné: automaticky zastav po 5 sekundách, ak nepríde nové písanie
        setTimeout(() => {
          socket.to(room).emit('user_stop_typing', { user: data.user })
        }, 5000)
      })

      socket.on('stop_typing', (data: { channelId: number; user: string }) => {
        const room = `channel_${data.channelId}`
        // Odošli informáciu o zastavení písania s menom používateľa
        socket.to(room).emit('user_stop_typing', { user: data.user })
      })

      socket.on('typing_content', (data: { channelId: number; user: string; content: string }) => {
        const room = `channel_${data.channelId}`
        // console.log('[WS] Typing content from', data.user, ':', data.content)

        // Odošli obsah všetkým ostatným v miestnosti
        socket.to(room).emit('user_typing_content', {
          user: data.user,
          channelId: data.channelId,
          content: data.content,
        })
      })

      socket.on('message', async (data) => {
        const { channelId, userId, text } = data

        try {
          // Extrahuj mentions z textu (podporuje úvodzovky)
          const mentionedNicknames = this.extractMentions(text)
          let mentionedUserIds: number[] = []

          if (mentionedNicknames.length > 0) {
            const mentionedUsers = await User.query().whereIn('nickName', mentionedNicknames) // nájdi všetkých mentionovaných

            // Odstráň duplikáty a seba samého
            mentionedUserIds = [
              ...new Set(mentionedUsers.filter((u) => u.id !== userId).map((u) => u.id)),
            ]
          }

          // Ulož správu s príznakom ping
          const message = await Message.create({
            channelId,
            senderId: userId,
            content: text,
            hasPing: mentionedUserIds.length > 0,
            // hasCommand: false,
            sentAt: DateTime.now(),
          })

          // Ulož všetky mentions do MessageMention
          if (mentionedUserIds.length > 0) {
            const mentions = mentionedUserIds.map((mentionedUserId) => ({
              messageId: message.id,
              mentionedUserId,
            }))
            await MessageMention.createMany(mentions)
          }

          await message.load('sender')

          // Payload pre klientov s menom a ping flagom
          const messagePayload = {
            id: message.id,
            text: message.content,
            userId: message.senderId,
            user:
              message.sender.nickName || `${message.sender.firstName} ${message.sender.lastName}`,
            channelId,
            sentAt: message.sentAt,
            isPing: mentionedUserIds.length > 0,
            mentionedUserIds,
          }

          // Rozpošli správu všetkým v miestnosti channel_X
          this.io?.to(`channel_${channelId}`).emit('newMessage', messagePayload)

          // console.log(`[WS] Message sent`, {
          //   content: message.content,
          //   mentions: mentionedNicknames,
          //   mentionedUserIds,
          //   isPing: messagePayload.isPing,
          // })
        } catch (error) {
          console.error('[WS] Sending error:', error)
          socket.emit('error', { message: 'Message cannot be sent' })
        }
      })

      // Príkaz (napr. /kick, /ban, /join, ...), ktorý používateľ zadal do chatu.
      // Vždy sa zaloguje do command_logs (audit trail) a voliteľne sa zobrazí
      // ako systémová správa v chate všetkým členom kanála.
      socket.on(
        'command',
        async (data: {
          channelId: number
          userId: number
          command: string
          args?: string
          success?: boolean
          resultText?: string
          showInChat?: boolean
        }) => {
          const { channelId, userId, command, args, success = true, resultText, showInChat = true } = data

          try {
            // 1) Audit log - vždy sa uloží, nezávisle od toho, či zlyhal alebo nie
            await CommandLog.create({
              channelId,
              userId,
              command,
              args: args || null,
              success,
            })

            // 2) Voliteľne systémová správa viditeľná pre všetkých v kanáli
            if (showInChat && resultText) {
              const message = await Message.create({
                channelId,
                senderId: userId,
                content: resultText,
                hasPing: false,
                isCommand: true,
                sentAt: DateTime.now(),
              })

              await message.load('sender')

              const messagePayload = {
                id: message.id,
                text: message.content,
                userId: message.senderId,
                user: message.sender.nickName,
                channelId,
                sentAt: message.sentAt,
                isPing: false,
                isCommand: true,
                mentionedUserIds: [],
              }

              this.io?.to(`channel_${channelId}`).emit('newMessage', messagePayload)
            }
          } catch (error) {
            console.error('[WS] Command logging error:', error)
          }
        }
      )

      // socket.on('disconnect', () => {
      //   console.log(`[WS] Client disconnected: ${socket.id}`)
      // })
    })

    console.log('[WS] WebSocket server is running')
  }

  // Odošli notifikáciu o pozvánke konkrétnemu používateľovi
  sendInviteNotification(userId: number, inviteData: any) {
    const userRoom = `user_${userId}`
    // console.log(`[WS] Sending invite notification to user ${userId} in room ${userRoom}`)
    this.io?.to(userRoom).emit('new_invite', inviteData)
  }

  // Notifikuj používateľa o aktualizácii kanála (po prijatí pozvánky)
  sendChannelUpdate(userId: number, channelData: any) {
    const userRoom = `user_${userId}`
    // console.log(`[WS] Sending channel update to user ${userId}`)
    this.io?.to(userRoom).emit('channel_joined', channelData)
  }

  // Notifikuj všetkých používateľov v kanáli, že bol zmazaný
  sendChannelDeleted(channelId: number, channelName: string, deletedBy: number) {
    const channelRoom = `channel_${channelId}`
    // console.log(`[WS] Sending channel deleted notification to channel ${channelId}`)
    this.io?.to(channelRoom).emit('channel_deleted', {
      channelId,
      channelName,
      deletedBy,
    })
  }

  // Notifikuj používateľa, že bol vyhodený z kanála
  sendUserKicked(userId: number, channelId: number, channelName: string) {
    const userRoom = `user_${userId}`
    // console.log(`[WS] Sending user kicked notification to user ${userId}`)
    this.io?.to(userRoom).emit('user_kicked', {
      userId,
      channelId,
      channelName,
    })
  }

  // Notifikuj používateľa, že bol zabanovaný v kanáli
  sendUserBanned(userId: number, channelId: number, channelName: string) {
    const userRoom = `user_${userId}`
    console.log(`[WS] Sending user banned notification to user ${userId}`)
    this.io?.to(userRoom).emit('user_banned', {
      userId,
      channelId,
      channelName,
    })
  }

  // Odošli zmenu statusu používateľa všetkým
  broadcastUserStatus(userId: number, status: string) {
    this.io?.emit('user_status_changed', { userId, status })
  }

  // Vylepšená funkcia na extrakciu všetkých @nickname zo správy
  // Podporuje aj @"user name" a @'user name' formát
  private extractMentions(text: string): string[] {
    // Regex pre @"user name", @'user name' alebo @username
    const mentionRegex = /@(?:"([^"]+)"|'([^']+)'|(\S+))/g
    const matches = text.matchAll(mentionRegex)
    const mentions: string[] = []

    for (const match of matches) {
      // match[1] = text v úvodzovkách ", match[2] = text v úvodzovkách ', match[3] = jedno slovo
      const mention = match[1] || match[2] || match[3]
      if (mention) {
        mentions.push(mention)
      }
    }

    return mentions
  }
}

export default new Ws()
