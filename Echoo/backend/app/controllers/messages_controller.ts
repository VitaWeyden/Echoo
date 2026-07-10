// import type { HttpContext } from '@adonisjs/core/http'
import Message from '#models/message'
import Channel from '#models/channel'
import User from '#models/user'
import MessageMention from '#models/message_mention'
import { DateTime } from 'luxon'

export default class MessagesController {
  // Pomocná funkcia na extrakciu mentions
  private async extractMentions(content: string) {
    // Načítame všetkých používateľov pre porovnanie prezývok
    const allUsers = await User.all()
    const mentionedUserIds: number[] = []

    // Regex pre @ mentions - zachytí aj viacrozmerné mená
    // Hľadáme @username alebo @"user name" alebo @'user name'
    const mentionRegex = /@(?:"([^"]+)"|'([^']+)'|(\S+))/g

    let match
    while ((match = mentionRegex.exec(content)) !== null) {
      // match[1] = text v úvodzovkách ", match[2] = text v úvodzovkách ', match[3] = jedno slovo
      const mentionText = (match[1] || match[2] || match[3] || '').toLowerCase()

      // Porovnáme prezývku s menami všetkých používateľov
      const user = allUsers.find((u) => u.nickName.toLowerCase() === mentionText)
      if (user && !mentionedUserIds.includes(user.id)) {
        mentionedUserIds.push(user.id)
      }
    }

    return mentionedUserIds
  }

  public async index({ params, request }: { params: { id: number }; request: any }) {
    const channelId = params.id
    const before = request.input('before')
    const limit = Number(request.input('limit', 30))

    // Základný dotaz na správy vrátane autora a mentions
    let query = Message.query()
      .where('channel_id', channelId)
      .preload('sender')
      .preload('mentions')
      .orderBy('id', 'desc')
      .limit(limit)

    if (before) {
      // Stránkovanie starších správ podľa ID
      query = query.where('id', '<', Number(before))
    }

    const messages = await query

    // Preformátovanie do shape očakávaného frontendom
    const result = messages.map((msg) => ({
      id: msg.id,
      userId: msg.senderId,
      user: msg.sender.nickName,
      text: msg.content,
      mentionedUserIds: msg.mentions.map((m) => m.mentionedUserId),
      isCommand: msg.isCommand,
    }))

    return result
  }

  public async store({ auth, params, request }: any) {
    const channelId = Number(params.id)
    const { content } = request.only(['content'])

    // Overíme, že je prihlásený používateľ
    const senderId = auth?.user?.id
    if (!senderId) throw new Error('Používateľ nie je autentifikovaný')

    // Overíme, že kanál existuje
    const channel = await Channel.findOrFail(channelId)

    // Uložíme text správy bez pingu/command flagov
    const message = await Message.create({
      channelId,
      senderId,
      content,
      hasPing: false,
    })

    await message.load('sender')

    // Extrahovanie a uloženie mentions
    const mentionedUserIds = await this.extractMentions(content)

    if (mentionedUserIds.length > 0) {
      // Pre každé mention vytvoríme záznam v message_mentions
      for (const userId of mentionedUserIds) {
        await MessageMention.create({
          messageId: message.id,
          mentionedUserId: userId,
        })
      }

      message.hasPing = true
      await message.save()
    }

    // Aktualizujeme last_active_at kanála
    channel.lastActiveAt = DateTime.now()
    await channel.save()

    return {
      id: message.id,
      userId: senderId,
      user: message.sender.nickName,
      text: message.content,
      mentionedUserIds: mentionedUserIds,
    }
  }
}
