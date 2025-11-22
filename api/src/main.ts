import { NestFactory } from '@nestjs/core'
import { AppModule } from './app.module'
import { ValidationPipe } from '@nestjs/common'
import { HttpExceptionFilter } from './common/filters/exception.filter'

async function bootstrap() {
  const app = await NestFactory.create(AppModule)

  // Global validation
  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
      whitelist: true,
      forbidNonWhitelisted: true,
    }),
  )

  // Global error handling
  app.useGlobalFilters(new HttpExceptionFilter())

  // CORS
  app.enableCors()

  // API prefix
  app.setGlobalPrefix('api/v1')

  const port = process.env.PORT || 3000
  await app.listen(port)
  console.log('Newsletter API running on port ', port)
}

bootstrap()
