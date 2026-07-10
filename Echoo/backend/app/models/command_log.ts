import { BaseModel, column, belongsTo } from '@adonisjs/lucid/orm'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'
import { DateTime } from 'luxon'
import Channel from './channel.js'
import User from './user.js'

export default class CommandLog extends BaseModel {
  @column({ isPrimary: true }) declare id: number
  @column() declare channelId: number
  @column() declare userId: number
  @column() declare command: string
  @column() declare args: string | null
  @column() declare success: boolean
  @column.dateTime({ autoCreate: true }) declare createdAt: DateTime

  @belongsTo(() => Channel, { foreignKey: 'channelId' })
  declare channel: BelongsTo<typeof Channel>

  @belongsTo(() => User, { foreignKey: 'userId' })
  declare user: BelongsTo<typeof User>
}
