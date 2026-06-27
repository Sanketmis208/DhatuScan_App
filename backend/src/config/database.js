// src/config/database.js
// Prisma client singleton — shared across the entire application.
// Instantiated once and re-exported so connection pooling works correctly.

import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis;

/**
 * Re-use an existing PrismaClient in development (hot-reload safe).
 * In production a fresh instance is created per process start.
 */
const prisma =
  globalForPrisma.__prisma ??
  new PrismaClient({
    log:
      process.env.NODE_ENV === 'development'
        ? ['query', 'warn', 'error']
        : ['warn', 'error'],
  });

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.__prisma = prisma;
}

export default prisma;
