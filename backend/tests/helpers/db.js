// tests/helpers/db.js
// Shared Prisma mock used by all test suites.
//
// We use jest.unstable_mockModule to intercept the ../config/database.js
// import BEFORE any controller imports it. Each test file that needs the mock
// imports this helper first (via jest setup or explicit import).

import { jest } from '@jest/globals';

// ── Prisma mock factory ───────────────────────────────────────────────────────
// Returns a fresh mock object with all methods needed by the controllers.
export function makePrismaMock() {
  return {
    user: {
      findUnique: jest.fn(),
      findFirst:  jest.fn(),
      create:     jest.fn(),
      update:     jest.fn(),
      upsert:     jest.fn(),
      delete:     jest.fn(),
    },
    assessment: {
      findUnique: jest.fn(),
      findMany:   jest.fn(),
      create:     jest.fn(),
      delete:     jest.fn(),
    },
    $connect:    jest.fn().mockResolvedValue(undefined),
    $disconnect: jest.fn().mockResolvedValue(undefined),
  };
}
