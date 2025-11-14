import { Request, Response, NextFunction } from 'express';
import { logger } from '@/utils/logger';

interface AppError extends Error {
  statusCode?: number;
  isOperational?: boolean;
}

export const errorMiddleware = (
  err: AppError,
  req: Request,
  res: Response,
  _next: NextFunction
): void => {
  const statusCode = err.statusCode || 500;
  const message = err.isOperational ? err.message : 'An unexpected error occurred on the server.';

  logger.error(
    `[${req.method}] ${req.path} >> StatusCode:: ${statusCode}, Message:: ${err.message}`,
    {
      stack: err.stack,
    }
  );

  res.status(statusCode).json({
    success: false,
    error: {
      code: statusCode,
      message: message,
    },
    timestamp: new Date().toISOString(),
  });
};
