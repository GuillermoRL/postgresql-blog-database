import { ExceptionFilter, Catch, ArgumentsHost, HttpException, HttpStatus } from '@nestjs/common'
import { Response } from 'express'

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp()
    const response = ctx.getResponse<Response>()

    let status = HttpStatus.INTERNAL_SERVER_ERROR
    let message = 'Internal server error'
    let error = 'Error'

    if (exception instanceof HttpException) {
      status = exception.getStatus()
      const exceptionResponse = exception.getResponse()
      message =
        typeof exceptionResponse === 'string'
          ? exceptionResponse
          : (exceptionResponse as any).message
      error = exception.name
    } else if (exception instanceof Error) {
      message = exception.message
      error = exception.name

      if (exception.message.includes('relation') && exception.message.includes('does not exist')) {
        status = HttpStatus.SERVICE_UNAVAILABLE
        message = 'Database schema not initialized. Run migrations'
      }
    }

    response.status(status).json({
      success: false,
      error: {
        type: error,
        message,
        statusCode: status,
        timestamp: new Date().toISOString(),
      },
    })
  }
}
