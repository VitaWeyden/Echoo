import axios from 'axios'
import type { Ref } from 'vue'
import type { UserChannel, AppUser, KickResponse, Channel, ChannelResponse, Message } from '@/types'
import type { QVueGlobals } from 'quasar'
import type { Router } from 'vue-router'
import type io from 'socket.io-client'
import API_URL from '../config/api'

// const API_URL = 'http://localhost:3333'

export function useChannelCommands(
  privateChannels: Ref<UserChannel[]>,
  publicChannels: Ref<UserChannel[]>,
  currentChannelId: Ref<number | null>,
  currentChannelName: Ref<string>,
  activeChannelPath: Ref<string>,
  messages: Ref<Message[]>, // ak máš typ Message, nech je to messages: Ref<Message[]>
  currentUserId: Ref<number | null>,
  handleChannelLeft: (channelId: number) => void,
  $q: QVueGlobals,
  router: Router,
  socket?: ReturnType<typeof io>
) {

  // Prezývka aktuálne prihláseného používateľa (pre systémové správy typu "X kicked Y")
  function getCurrentNickName(): string {
    try {
      const saved = localStorage.getItem('user')
      if (!saved) return 'Someone'
      const parsed = JSON.parse(saved) as { nickName?: string }
      return parsed.nickName || 'Someone'
    } catch {
      return 'Someone'
    }
  }

  // Zaloguje vykonaný príkaz na backend (audit trail v command_logs)
  // a voliteľne ho zobrazí ako systémovú správu všetkým v kanáli.
  function logCommand(
    channelId: number | null,
    command: string,
    args: string,
    options: { success?: boolean; resultText?: string; showInChat?: boolean } = {}
  ) {
    if (!socket || !channelId || !currentUserId.value) return

    socket.emit('command', {
      channelId,
      userId: currentUserId.value,
      command,
      args,
      success: options.success ?? true,
      resultText: options.resultText,
      showInChat: options.showInChat ?? true,
    })
  }

  // Command handlers - upravené na používanie existujúcich endpointov
  async function handleCancelCommand() {
    if (!currentChannelId.value) {
      $q.notify({ type: 'negative', message: 'You are not in any channel!' })
      return
    }

    const channelId = currentChannelId.value
    const allChannels = [...privateChannels.value, ...publicChannels.value]
    const channel = allChannels.find(ch => ch.id === channelId)

    if (!channel) {
      $q.notify({ type: 'negative', message: 'Channel not found!' })
      return
    }

    const token = localStorage.getItem('auth_token')
    const isAdmin = channel.role === 'admin'

    try {
      if (isAdmin) {
        // Zaloguj ešte pred zmazaním kanála (FK cascade by inak zmazal aj samotný log/správu)
        logCommand(channelId, '/cancel', '', {
          resultText: `🗑️ ${getCurrentNickName()} deleted the channel "${channel.name}"`
        })

        // Admin vymaže celý kanál
        await axios.delete(`${API_URL}/channels/${channelId}`, {
          headers: { Authorization: `Bearer ${token}` }
        })

        privateChannels.value = privateChannels.value.filter(c => c.id !== channelId)
        publicChannels.value = publicChannels.value.filter(c => c.id !== channelId)

        $q.notify({
          type: 'positive',
          message: `Channel "${channel.name}" deleted.`
        })
      } else {
        // Bežný používateľ opustí kanál - používame existujúci endpoint
        await axios.delete(`${API_URL}/channels/${channelId}/leave`, {
          headers: { Authorization: `Bearer ${token}` }
        })

        handleChannelLeft(channelId)

        logCommand(channelId, '/cancel', '', {
          resultText: `👋 ${getCurrentNickName()} left the channel "${channel.name}"`
        })

        $q.notify({
          type: 'positive',
          message: `You left channel "${channel.name}".`
        })
      }

      currentChannelId.value = null
      currentChannelName.value = ''
      messages.value = []
      activeChannelPath.value = ''

      void router.push('/')
    } catch (err) {
      console.error(err)
      $q.notify({
        type: 'negative',
        message: 'Failed to cancel channel!'
      })
    }
  }

  async function handleKickCommand(parts: string[]) {
    if (!currentChannelId.value) {
      $q.notify({ type: 'negative', message: 'You are not in any channel!' })
      return
    }

    const channelId = currentChannelId.value
    const targetName = parts.slice(1).join(' ')

    if (!targetName) {
      $q.notify({ type: 'negative', message: 'Usage: /kick nickName' })
      return
    }

    const allChannels = [...privateChannels.value, ...publicChannels.value]
    const channel = allChannels.find(c => c.id === channelId)

    if (!channel) {
      $q.notify({ type: 'negative', message: 'Channel not found!' })
      return
    }

    try {
      const token = localStorage.getItem('auth_token')

      // Pýtame sa len členov aktuálneho kanála
      const membersRes = await axios.get<{ id: number, nickName: string, role: string }[]>(
        `${API_URL}/channels/${channelId}/members`,
        { headers: { Authorization: `Bearer ${token}` } }
      )

      const targetUser = membersRes.data.find(
        m => m.nickName.toLowerCase() === targetName.toLowerCase()
      )

      if (!targetUser) {
        $q.notify({ type: 'negative', message: 'User not found in this channel!' })
        return
      }

      let endpoint = ''

      if (channel.role === 'admin') { // Admin → BAN
      endpoint = `${API_URL}/channels/${channelId}/ban/${targetUser.id}`
      const res = await axios.delete<KickResponse>(endpoint, { headers: { Authorization: `Bearer ${token}` } })
      logCommand(channelId, '/kick', targetName, {
        resultText: `🔨 ${getCurrentNickName()} banned ${targetName} from the channel`
      })
      $q.notify({ type: 'positive', message: res.data.message || `User "${targetName}" has been banned` })

      } else { // Member → KICK
      endpoint = `${API_URL}/channels/${channelId}/kick/${targetUser.id}`
      const res = await axios.delete<KickResponse>(endpoint, { headers: { Authorization: `Bearer ${token}` } })
      logCommand(channelId, '/kick', targetName, {
        resultText: `👢 ${getCurrentNickName()} kicked ${targetName} from the channel`
      })
      $q.notify({ type: 'positive', message: res.data.message })
      }

    /*
      if (channel.role === 'admin') {
        // Admin → BAN
        endpoint = `${API_URL}/channels/${channelId}/ban/${targetUser.id}`
      } else {
        // Member → KICK
        endpoint = `${API_URL}/channels/${channelId}/kick/${targetUser.id}`
      }

      await axios.delete(endpoint, {
        headers: { Authorization: `Bearer ${token}` }
      })

      $q.notify({
        type: 'positive',
        message:
          channel.role === 'admin'
            ? `User "${targetName}" has been banned`
            : `User "${targetName}" has been kicked`
      })
      */

    } catch (err) {
      console.error(err)
      $q.notify({ type: 'negative', message: 'Failed to kick user!' })
    }
  }

  async function handleInviteCommand(parts: string[]) {
    if (!currentChannelId.value) {
      $q.notify({ type: 'negative', message: 'You are not in any channel!' })
      return
    }

    const channelId = currentChannelId.value
    const targetName = parts.slice(1).join(' ')

    if (!targetName) {
      $q.notify({ type: 'negative', message: 'Usage: /invite nickName' })
      return
    }

    const allChannels = [...privateChannels.value, ...publicChannels.value]
    const channel = allChannels.find(c => c.id === channelId)

    if (!channel) {
      $q.notify({ type: 'negative', message: 'Channel not found!' })
      return
    }

    const isPrivate = channel.type === 'private'
    const isAdmin = channel.role === 'admin'

    if (isPrivate && !isAdmin) {
      $q.notify({ type: 'negative', message: 'Only admin can invite in private channels!' })
      return
    }

    try {
      const token = localStorage.getItem('auth_token')
      const users = await axios.get<AppUser[]>(
        `${API_URL}/users`,
        { headers: { Authorization: `Bearer ${token}` } }
      )

      const targetUser = users.data.find(
        u => u.nickName.toLowerCase() === targetName.toLowerCase()
      )

      if (!targetUser) {
        $q.notify({ type: 'negative', message: 'User not found!' })
        return
      }

      // Pozývanie používateľa pomocou existujúceho endpointu
      await axios.post(
        `${API_URL}/channels/${channelId}/invite`,
        { userId: targetUser.id },
        { headers: { Authorization: `Bearer ${token}` } }
      )

      logCommand(channelId, '/invite', targetName, {
        resultText: `✉️ ${getCurrentNickName()} invited ${targetName} to the channel`
      })

      $q.notify({
        type: 'positive',
        message: `Invite sent to "${targetName}"`
      })
    } catch (err) {
      console.error(err)
      $q.notify({ type: 'negative', message: 'Failed to invite user!' })
    }
  }

  async function handleBanCommand(parts: string[]) {
    if (!currentChannelId.value) {
      $q.notify({ type: 'negative', message: 'You are not in any channel!' })
      return
    }

    const channelId = currentChannelId.value
    const targetName = parts.slice(1).join(' ')  // Podpora viacslovných mien

    if (!targetName) {
      $q.notify({ type: 'negative', message: 'Usage: /ban nickName' })
      return
    }

    const allChannels = [...privateChannels.value, ...publicChannels.value]
    const channel = allChannels.find(c => c.id === channelId)

    if (!channel) {
      $q.notify({ type: 'negative', message: 'Channel not found!' })
      return
    }

    const isAdmin = channel.role === 'admin'

    if (!isAdmin) {
      $q.notify({ type: 'negative', message: 'Only admin can ban users!' })
      return
    }

    try {
      const token = localStorage.getItem('auth_token')

      // Pýtame sa len členov aktuálneho kanála
      const membersRes = await axios.get<{ id: number, nickName: string, role: string }[]>(
        `${API_URL}/channels/${channelId}/members`,
        { headers: { Authorization: `Bearer ${token}` } }
      )

      const targetUser = membersRes.data.find(
        m => m.nickName.toLowerCase() === targetName.toLowerCase()
      )

      if (!targetUser) {
        $q.notify({ type: 'negative', message: 'User not found in this channel!' })
        return
      }

      // Ban používateľa pomocou existujúceho endpointu
      await axios.delete(
        `${API_URL}/channels/${channelId}/ban/${targetUser.id}`,
        { headers: { Authorization: `Bearer ${token}` } }
      )

      logCommand(channelId, '/ban', targetName, {
        resultText: `🔨 ${getCurrentNickName()} banned ${targetName} from the channel`
      })

      $q.notify({ type: 'positive', message: `${targetName} banned from channel` })
    } catch (err) {
      console.error(err)
      $q.notify({ type: 'negative', message: 'Failed to ban user!' })
    }
  }

  async function handleListCommand() {
    if (!currentChannelId.value) {
      return $q.notify({ type: 'negative', message: 'You are not in any channel!' })
    }

    try {
      const token = localStorage.getItem('auth_token')

      const res = await axios.get(
        `${API_URL}/channels/${currentChannelId.value}/members`,
        { headers: { Authorization: `Bearer ${token}` } }
      )

      const members = res.data as { id: number, nickName: string, role: string }[]

      if (!members.length) {
        return $q.notify({ type: 'info', message: 'This channel has no members.' })
      }

      const formatted = members
        .map(m => `• ${m.nickName} (${m.role})`)
        .join('<br>')

      logCommand(currentChannelId.value, '/list', '', { showInChat: false })

      $q.notify({
        message: `Members:<br>${formatted}`,
        html: true,
        color: 'blue',
        textColor: 'white',
        timeout: 0
      })

    } catch (err) {
      console.error(err)
      return $q.notify({ type: 'negative', message: 'Failed to load members!' })
    }
  }

  async function handleQuitCommand() {
    if (!currentChannelId.value) {
      $q.notify({
        type: 'negative',
        message: 'You are not in any channel!'
      })
      return
    }

    const channelId = currentChannelId.value
    const allChannels = [...privateChannels.value, ...publicChannels.value]
    const channel = allChannels.find(ch => ch.id === channelId)

    if (!channel) {
      $q.notify({
        type: 'negative',
        message: 'Channel not found!'
      })
      return
    }

    // Kontrola, či je používateľ admin
    if (channel.role !== 'admin') {
      $q.notify({
        type: 'negative',
        message: 'You cannot use this command, you are not the admin!'
      })
      return
    }

    const token = localStorage.getItem('auth_token')

    try {
      // Zaloguj ešte pred zmazaním kanála (FK cascade by inak zmazal aj samotný log/správu)
      logCommand(channelId, '/quit', '', {
        resultText: `🗑️ ${getCurrentNickName()} deleted the channel "${channel.name}"`
      })

      // Vymazanie kanála
      await axios.delete(`${API_URL}/channels/${channelId}`, {
        headers: { Authorization: `Bearer ${token}` }
      })

      // Odstránenie z frontendu
      privateChannels.value = privateChannels.value.filter(c => c.id !== channelId)
      publicChannels.value = publicChannels.value.filter(c => c.id !== channelId)

      $q.notify({
        type: 'positive',
        message: `Channel "${channel.name}" deleted.`
      })

      // Reset UI
      currentChannelId.value = null
      currentChannelName.value = ''
      messages.value = []
      activeChannelPath.value = ''

      void router.push('/')

    } catch (err) {
      console.error(err)
      $q.notify({
        type: 'negative',
        message: 'Failed to delete channel!'
      })
    }
  }

  async function handleRevokeCommand(parts: string[]) {
    if (!currentChannelId.value) {
      return $q.notify({ type: 'negative', message: 'You are not in any channel!' })
    }

    const channelId = currentChannelId.value
    const targetName = parts.slice(1).join(' ')  // Podpora viacslovných mien

    if (!targetName) {
      return $q.notify({ type: 'negative', message: 'Usage: /revoke nickName' })
    }

    const allChannels = [...privateChannels.value, ...publicChannels.value]
    const channel = allChannels.find(c => c.id === channelId)

    if (!channel) {
      return $q.notify({ type: 'negative', message: 'Channel not found!' })
    }

    const isAdmin = channel.role === 'admin'

    if (!isAdmin) {
      return $q.notify({ type: 'negative', message: 'Only admin can revoke users!' })
    }

    try {
      const token = localStorage.getItem('auth_token')

      // Pýtame sa len členov aktuálneho kanála
      const membersRes = await axios.get<{ id: number, nickName: string, role: string }[]>(
        `${API_URL}/channels/${channelId}/members`,
        { headers: { Authorization: `Bearer ${token}` } }
      )

      const targetUser = membersRes.data.find(
        m => m.nickName.toLowerCase() === targetName.toLowerCase()
      )

      if (!targetUser) {
        return $q.notify({ type: 'negative', message: 'User not found in this channel!' })
      }

      await axios.delete(
        `${API_URL}/channels/${channelId}/ban/${targetUser.id}`,
        { headers: { Authorization: `Bearer ${token}` } }
      )

      logCommand(channelId, '/revoke', targetName, {
        resultText: `🚫 ${getCurrentNickName()} revoked ${targetName} from the channel`
      })

      $q.notify({ type: 'positive', message: `${targetName} removed from channel` })

    } catch (err) {
      console.error(err)
      $q.notify({ type: 'negative', message: 'Failed to revoke user!' })
    }
  }

  async function handleJoinCommand(parts: string[]) {
    const isPrivate = parts.includes('[private]')

    const nameParts = parts.slice(1).filter(p => p !== '[private]')
    const channelName = nameParts.join(' ')

    if (!channelName) {
      return $q.notify({ type: 'negative', message: 'Channel name is required!' })
    }

    try {
      const token = localStorage.getItem('auth_token')
      if (!token || !currentUserId.value) throw new Error('Not authenticated')

      // Načítame všetky kanály globálne
      const allChannelsRes = await axios.get(`${API_URL}/channels`)
      const allChannels = allChannelsRes.data as Channel[]

      const existingChannelGlobal = allChannels.find(
        c => c.name.toLowerCase() === channelName.toLowerCase() &&
            c.type === (isPrivate ? 'private' : 'public')
      )

      let channelId: number

      if (existingChannelGlobal) {
        // Ochrana privátneho kanála
        if (isPrivate) {
          $q.notify({
            type: 'negative',
            message: `Private channel "${channelName}" already exists. You can only join via invite.`
          })
          return
        }

        // Pripojenie k existujúcemu kanálu (len public)
        const joinResponse = await axios.post<UserChannel | { error: string }>(
          `${API_URL}/user_channel`,
          {
            channelId: existingChannelGlobal.id,
            userId: currentUserId.value,
            role: 'member',
            notificationSettings: 'all'
          },
          { headers: { Authorization: `Bearer ${token}` } }
        )

        // Kontrola: nie si zabanovaný?
        if ('error' in joinResponse.data) {
          $q.notify({
            type: 'negative',
            message: joinResponse.data.error
          })
          return // Zastavíme proces
        }

        channelId = existingChannelGlobal.id

        const newLocalChannel: UserChannel = {
          id: channelId,
          name: existingChannelGlobal.name,
          path: `/chat/${channelId}`,
          type: existingChannelGlobal.type,
          role: isPrivate ? 'admin' : 'member'
        }

        let alreadyJoined = false

        if (existingChannelGlobal.type === 'private') {
          if (!privateChannels.value.some(c => c.id === channelId)) {
            privateChannels.value.push(newLocalChannel)
          } else {
            alreadyJoined = true
          }
        } else {
          if (!publicChannels.value.some(c => c.id === channelId)) {
            publicChannels.value.push(newLocalChannel)
          } else {
            alreadyJoined = true
          }
        }

        if (!alreadyJoined) {
          logCommand(channelId, '/join', channelName, {
            resultText: `🚪 ${getCurrentNickName()} joined the channel "${channelName}"`
          })
        }

        $q.notify({
          type: alreadyJoined ? 'info' : 'positive',
          message: alreadyJoined
            ? `You are already a member of "${channelName}"`
            : `Joined channel "${channelName}"`
        })

      } else {
        // Vytvorenie
        const res = await axios.post<ChannelResponse>(
          `${API_URL}/channels`,
          {
            name: channelName,
            type: isPrivate ? 'private' : 'public',
            invitedMembers: [],
            notificationSettings: 'all'
          },
          { headers: { Authorization: `Bearer ${token}` } }
        )

        channelId = res.data.id

        const userChannelRes = await axios.post<UserChannel>(
          `${API_URL}/user_channel`,
          {
            channelId,
            userId: currentUserId.value,
            role: 'admin', // podľa backendu je vytvárajúci vždy admin
            notificationSettings: 'all'
          },
          { headers: { Authorization: `Bearer ${token}` } }
        )

        const newChannel: UserChannel = {
          id: channelId,
          name: channelName,
          path: `/chat/${channelId}`,
          type: isPrivate ? 'private' : 'public',
          role: userChannelRes.data.role
        }

        if (isPrivate) privateChannels.value.push(newChannel)
        else publicChannels.value.push(newChannel)

        logCommand(channelId, '/join', channelName, {
          resultText: `✨ ${getCurrentNickName()} created the channel "${channelName}"`
        })

        $q.notify({
          type: 'positive',
          message: `Channel "${channelName}" created!`
        })
      }

      currentChannelName.value = channelName
      currentChannelId.value = channelId

      void router.push(`/chat/${channelId}`)

    } catch (err) {
      console.error(err)
      $q.notify({
        type: 'negative',
        message: 'Failed to join or create channel!'
      })
    }
  }

  async function handleCommand(cmd: string) {
    const parts = cmd.trim().split(' ')
    const command = parts[0]

    if (command === '/cancel') {
      await handleCancelCommand()
    } else if (command === '/kick') {
      await handleKickCommand(parts)
    } else if (command === '/invite') {
      await handleInviteCommand(parts)
    } else if (command === '/ban') {
      await handleBanCommand(parts)
    } else if (command === '/quit') {
      await handleQuitCommand()
    } else if (command === '/join') {
      await handleJoinCommand(parts)
    } else if (command === '/revoke') {
      await handleRevokeCommand(parts)
    } else if (command === '/list') {
      await handleListCommand()
    } else {
      logCommand(currentChannelId.value, command ?? 'unknown', parts.slice(1).join(' '), {
        success: false,
        showInChat: false
      })
      $q.notify({ type: 'warning', message: 'Unknown command' })
    }
  }

  return { handleCommand }
}
