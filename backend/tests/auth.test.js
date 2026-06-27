// tests/auth.test.js
// Integration tests for POST /api/auth/check-user
//
// Tests:
//   ✓ Happy path — new user (201 with token + isNewUser=true)
//   ✓ Happy path — existing user (200 with token + isNewUser=false)
//   ✓ 400 — missing phone
//   ✓ 400 — phone too short
//   ✓ 400 — phone contains non-digits
//   ✓ 500 — Prisma throws unexpectedly

import { jest } from '@jest/globals';

// ── Mock Prisma BEFORE importing app ─────────────────────────────────────────
const mockPrisma = {
  user: {
    findUnique: jest.fn(),
    create:     jest.fn(),
    update:     jest.fn(),
  },
  assessment: {
    findUnique: jest.fn(),
    findMany:   jest.fn(),
    create:     jest.fn(),
  },
};

jest.unstable_mockModule('../src/config/database.js', () => ({
  default: mockPrisma,
}));

// Mock Firebase so no real token verification happens.
jest.unstable_mockModule('../src/config/firebase.js', () => ({
  getFirebaseApp:      jest.fn(),
  verifyFirebaseToken: jest.fn().mockResolvedValue({ uid: 'firebase-uid' }),
}));

// Dynamic imports AFTER mocks are set up.
const { createApp }  = await import('../src/app.js');
const supertest      = (await import('supertest')).default;
const { USER_PHONE, sampleUser } = await import('./helpers/fixtures.js');

const app     = createApp();
const request = supertest(app);

// ── Helpers ───────────────────────────────────────────────────────────────────

function resetMocks() {
  mockPrisma.user.findUnique.mockReset();
  mockPrisma.user.create.mockReset();
  mockPrisma.user.update.mockReset();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

describe('POST /api/auth/check-user', () => {
  beforeEach(resetMocks);

  // ── Happy path: new user ──────────────────────────────────────────────────
  test('creates a new user and returns token + isNewUser=true', async () => {
    mockPrisma.user.findUnique.mockResolvedValue(null); // not found → new user
    mockPrisma.user.create.mockResolvedValue({ ...sampleUser, isProfileComplete: false });

    const res = await request
      .post('/api/auth/check-user')
      .send({ phone: USER_PHONE })
      .expect(200);

    expect(res.body).toMatchObject({
      isNewUser: true,
      userId:    sampleUser.id,
    });
    expect(typeof res.body.token).toBe('string');
    expect(res.body.token.length).toBeGreaterThan(10);
    expect(mockPrisma.user.create).toHaveBeenCalledTimes(1);
  });

  // ── Happy path: existing user ─────────────────────────────────────────────
  test('finds existing user and returns token + isNewUser=false', async () => {
    mockPrisma.user.findUnique.mockResolvedValue(sampleUser);

    const res = await request
      .post('/api/auth/check-user')
      .send({ phone: USER_PHONE })
      .expect(200);

    expect(res.body.isNewUser).toBe(false);
    expect(res.body.userId).toBe(sampleUser.id);
    expect(mockPrisma.user.create).not.toHaveBeenCalled();
  });

  // ── Validation: missing phone ──────────────────────────────────────────────
  test('returns 400 when phone is missing', async () => {
    const res = await request
      .post('/api/auth/check-user')
      .send({})
      .expect(400);

    expect(res.body.message).toBe('Validation failed');
    expect(Array.isArray(res.body.errors)).toBe(true);
  });

  // ── Validation: phone too short ────────────────────────────────────────────
  test('returns 400 when phone is fewer than 10 digits', async () => {
    const res = await request
      .post('/api/auth/check-user')
      .send({ phone: '98765' })
      .expect(400);

    expect(res.body.message).toBe('Validation failed');
  });

  // ── Validation: phone too long ─────────────────────────────────────────────
  test('returns 400 when phone is more than 10 digits', async () => {
    const res = await request
      .post('/api/auth/check-user')
      .send({ phone: '98765432101' })
      .expect(400);

    expect(res.body.message).toBe('Validation failed');
  });

  // ── Validation: non-digit characters ─────────────────────────────────────
  test('returns 400 when phone contains non-digit characters', async () => {
    const res = await request
      .post('/api/auth/check-user')
      .send({ phone: '987654321a' })
      .expect(400);

    expect(res.body.message).toBe('Validation failed');
  });

  // ── Error: Prisma throws ───────────────────────────────────────────────────
  test('returns 500 when Prisma throws unexpectedly', async () => {
    mockPrisma.user.findUnique.mockRejectedValue(new Error('DB connection lost'));

    const res = await request
      .post('/api/auth/check-user')
      .send({ phone: USER_PHONE })
      .expect(500);

    expect(res.body.message).toBe('Internal server error');
  });
});
