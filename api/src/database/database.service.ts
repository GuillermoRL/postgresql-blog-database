import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import { Pool, QueryResult, PoolClient, QueryResultRow } from 'pg'

@Injectable()
export class DatabaseService implements OnModuleInit, OnModuleDestroy {
  private pool: Pool

  constructor(private configService: ConfigService) {}

  async onModuleInit(): Promise<void> {
    this.pool = new Pool({
      host: this.configService.get<string>('database.host'),
      port: this.configService.get<number>('database.port'),
      database: this.configService.get<string>('database.database'),
      user: this.configService.get<string>('database.user'),
      password: this.configService.get<string>('database.password'),
      max: this.configService.get<number>('database.max'),
      idleTimeoutMillis: this.configService.get<number>('database.idleTimeoutMillis'),
      connectionTimeoutMillis: this.configService.get<number>('database.connectionTimeoutMillis'),
    })

    try {
      const client = await this.pool.connect()
      console.log('Database connected successfully')
      client.release()
    } catch (error) {
      console.error('Database connection failed: ', error.message)
      throw error
    }
  }

  async onModuleDestroy() {
    await this.pool.end()
    console.log('Database connection pool closed')
  }

  async query<T extends QueryResultRow = any>(
    text: string,
    params?: any[],
  ): Promise<QueryResult<T>> {
    const start = Date.now()
    try {
      const result = await this.pool.query<T>(text, params)
      const duration = Date.now() - start
      console.log('Executed query', {
        text: text.substring(0, 50) + '...',
        duration,
        rows: result.rowCount,
      })
      return result
    } catch (error) {
      console.error('Query error', {
        text: text.substring(0, 50) + '...',
        error: error.message,
      })
      throw error
    }
  }

  async getClient(): Promise<PoolClient> {
    return this.pool.connect()
  }
}
