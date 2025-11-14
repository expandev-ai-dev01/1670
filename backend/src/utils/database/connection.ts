import sql from 'mssql';
import { config } from '@/config';
import { logger } from '@/utils/logger';

const sqlConfig: sql.config = {
  server: config.database.server,
  port: config.database.port,
  user: config.database.user,
  password: config.database.password,
  database: config.database.database,
  options: {
    ...config.database.options,
    connectionTimeout: 30000,
    pool: {
      max: 10,
      min: 0,
      idleTimeoutMillis: 30000,
    },
  },
};

let pool: sql.ConnectionPool;

export const getPool = async (): Promise<sql.ConnectionPool> => {
  if (pool && pool.connected) {
    return pool;
  }
  try {
    pool = await new sql.ConnectionPool(sqlConfig).connect();
    logger.info('SQL Server connection pool established.');

    pool.on('error', (err) => {
      logger.error('SQL Server pool error', err);
    });

    return pool;
  } catch (err) {
    logger.error('Database connection failed:', err);
    throw err;
  }
};
