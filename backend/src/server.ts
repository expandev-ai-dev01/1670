import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import 'dotenv/config';

import { config } from '@/config';
import { errorMiddleware } from '@/middleware/errorMiddleware';
import { notFoundMiddleware } from '@/middleware/notFoundMiddleware';
import apiRoutes from '@/routes';
import { logger } from '@/utils/logger';

const app: Application = express();

// Security & Core Middleware
app.use(helmet());
app.use(cors(config.api.cors));
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Logging
app.use(morgan('combined', { stream: { write: (message) => logger.info(message.trim()) } }));

// Health check endpoint (does not require versioning)
app.get('/health', (_req: Request, res: Response) => {
  res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// API Routes - All routes are versioned and prefixed with /api
app.use('/api', apiRoutes);

// 404 Not Found Handler
app.use(notFoundMiddleware);

// Centralized Error Handling Middleware
app.use(errorMiddleware);

const server = app.listen(config.api.port, () => {
  logger.info(`Server running on port ${config.api.port} in ${config.nodeEnv} mode`);
});

// Graceful Shutdown
const signals = ['SIGTERM', 'SIGINT'];

function gracefulShutdown(signal: string) {
  process.on(signal, () => {
    logger.info(`${signal} received, closing server gracefully.`);
    server.close(() => {
      logger.info('Server closed.');
      // Add any cleanup logic here (e.g., close DB connection)
      process.exit(0);
    });
  });
}

signals.forEach((signal) => {
  gracefulShutdown(signal);
});

export default app;
