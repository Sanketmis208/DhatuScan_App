// src/app.js
// Express application factory.
//
// Registers:
//   - JSON body parser
//   - CORS
//   - All API route files under /api
//   - 404 catch-all
//   - Global error handler (500)
//
// Exported as a factory function so integration tests can spin up the app
// without starting an HTTP server.

import express from 'express';
import cors from 'cors';
import authRoutes       from './routes/auth.routes.js';
import userRoutes       from './routes/user.routes.js';
import assessmentRoutes from './routes/assessment.routes.js';

/**
 * Create and configure the Express application.
 *
 * @returns {import('express').Application}
 */
export function createApp() {
  const app = express();

  // ── Core middleware ─────────────────────────────────────────────────────
  app.use(cors());
  app.use(express.json({ limit: '5mb' })); // assessment payloads can be large
  app.use(express.urlencoded({ extended: true }));

  // ── Health check ────────────────────────────────────────────────────────
  app.get('/health', (_req, res) => {
    res.status(200).json({ status: 'ok', service: 'DhatuScan API', version: '1.0.0' });
  });

  // ── API routes ──────────────────────────────────────────────────────────
  app.use('/api/auth',       authRoutes);
  app.use('/api/user',       userRoutes);
  app.use('/api/assessment', assessmentRoutes);

  // ── 404 handler ─────────────────────────────────────────────────────────
  app.use((_req, res) => {
    res.status(404).json({ message: 'Route not found' });
  });

  // ── Global error handler ────────────────────────────────────────────────
  // eslint-disable-next-line no-unused-vars
  app.use((err, _req, res, _next) => {
    console.error('[DhatuScan API Error]', err);

    // Don't leak stack traces in production.
    const isDev = process.env.NODE_ENV === 'development';

    return res.status(500).json({
      message: 'Internal server error',
      ...(isDev && { detail: err.message, stack: err.stack }),
    });
  });

  return app;
}
