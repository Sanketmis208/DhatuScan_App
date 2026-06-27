// src/server.js
// HTTP server entry point.
//
// Loads environment variables, creates the Express app, and starts listening.
// Prisma connectivity is verified before binding the port so the process
// exits (and lets the process manager restart it) if the DB is unreachable.

import 'dotenv/config';
import { createApp } from './app.js';
import prisma from './config/database.js';

const PORT = process.env.PORT ?? 3000;

async function start() {
  // Verify database connectivity on startup.
  try {
    await prisma.$connect();
    console.log('✅  Database connected');
  } catch (err) {
    console.error('❌  Failed to connect to the database:', err.message);
    process.exit(1);
  }

  const app = createApp();

  const server = app.listen(PORT, () => {
    console.log(`🚀  DhatuScan API listening on http://localhost:${PORT}`);
    console.log(`   Environment : ${process.env.NODE_ENV ?? 'development'}`);
  });

  // ── Graceful shutdown ──────────────────────────────────────────────────
  const shutdown = async (signal) => {
    console.log(`\n🛑  Received ${signal} — shutting down gracefully...`);
    server.close(async () => {
      await prisma.$disconnect();
      console.log('   Database disconnected. Goodbye! 👋');
      process.exit(0);
    });
  };

  process.on('SIGINT',  () => shutdown('SIGINT'));
  process.on('SIGTERM', () => shutdown('SIGTERM'));
}

start();
