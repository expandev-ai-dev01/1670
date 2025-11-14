import { Request, Response } from 'express';

export const notFoundMiddleware = (req: Request, res: Response): void => {
  res.status(404).json({
    success: false,
    error: {
      code: 404,
      message: `Not Found - The requested resource '${req.originalUrl}' does not exist.`,
    },
    timestamp: new Date().toISOString(),
  });
};
