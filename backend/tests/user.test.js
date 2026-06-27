// tests/user.test.js
// Integration tests for user profile routes.
//
// Tests:
//   POST /api/user/profile
//     ✓ 200 — saves profile
//     ✓ 401 — no token
//     ✓ 401 — invalid token
//     ✓ 404 — user not found in DB (P2025)
//
//   GET /api/user/profile/:id
//     ✓ 200 — returns user
//     ✓ 401 — no token
//     ✓ 404 — user not found

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

jest.unstable_mockModule('../src/config/firebase.js', () => ({
  getFirebaseApp:      jest.fn(),
  verifyFirebaseToken: jest.fn(),
}));

const { createApp }  = await import('../src/app.js');
const supertest      = (await import('supertest')).default;
const { sampleUser, validToken, invalidToken, USER_ID } =
  await import('./helpers/fixtures.js');

const app     = createApp();
const request = supertest(app);

const AUTH = { Authorization: `Bearer ${validToken}` };

function resetMocks() {
  mockPrisma.user.findUnique.mockReset();
  mockPrisma.user.create.mockReset();
  mockPrisma.user.update.mockReset();
}

// ── POST /api/user/profile ────────────────────────────────────────────────────

describe('POST /api/user/profile', () => {
  beforeEach(resetMocks);

  test('200 — saves profile and returns updated user', async () => {
    mockPrisma.user.update.mockResolvedValue(sampleUser);

    const res = await request
      .post('/api/user/profile')
      .set(AUTH)
      .send({
        name:             'Arjun Sharma',
        age:              34,
        gender:           'Male',
        height:           175,
        weight:           70,
        physicalActivity: 'Moderate',
      })
      .expect(200);

    expect(res.body.user).toBeDefined();
    expect(res.body.user.name).toBe('Arjun Sharma');
    expect(mockPrisma.user.update).toHaveBeenCalledTimes(1);

    // isProfileComplete must be set to true in the Prisma call.
    const updateArgs = mockPrisma.user.update.mock.calls[0][0];
    expect(updateArgs.data.isProfileComplete).toBe(true);
  });

  test('401 — returns 401 when no Authorization header', async () => {
    const res = await request
      .post('/api/user/profile')
      .send({ name: 'Test' })
      .expect(401);

    expect(res.body.message).toMatch(/no token/i);
  });

  test('401 — returns 401 for invalid token', async () => {
    const res = await request
      .post('/api/user/profile')
      .set('Authorization', invalidToken)
      .send({ name: 'Test' })
      .expect(401);

    expect(res.body.message).toBeDefined();
  });

  test('404 — returns 404 when user record not found (P2025)', async () => {
    const p2025 = Object.assign(new Error('Not found'), { code: 'P2025' });
    mockPrisma.user.update.mockRejectedValue(p2025);

    const res = await request
      .post('/api/user/profile')
      .set(AUTH)
      .send({ name: 'Ghost' })
      .expect(404);

    expect(res.body.message).toBe('User not found');
  });

  test('400 — returns 400 for invalid gender enum', async () => {
    const res = await request
      .post('/api/user/profile')
      .set(AUTH)
      .send({ gender: 'InvalidGender' })
      .expect(400);

    expect(res.body.message).toBe('Validation failed');
  });

  test('400 — returns 400 for negative height', async () => {
    const res = await request
      .post('/api/user/profile')
      .set(AUTH)
      .send({ height: -10 })
      .expect(400);

    expect(res.body.message).toBe('Validation failed');
  });
});

// ── GET /api/user/profile/:id ─────────────────────────────────────────────────

describe('GET /api/user/profile/:id', () => {
  beforeEach(resetMocks);

  test('200 — returns user profile', async () => {
    mockPrisma.user.findUnique.mockResolvedValue(sampleUser);

    const res = await request
      .get(`/api/user/profile/${USER_ID}`)
      .set(AUTH)
      .expect(200);

    expect(res.body.user).toBeDefined();
    expect(res.body.user.id).toBe(USER_ID);
  });

  test('401 — returns 401 when no token', async () => {
    await request
      .get(`/api/user/profile/${USER_ID}`)
      .expect(401);
  });

  test('404 — returns 404 when user not found', async () => {
    mockPrisma.user.findUnique.mockResolvedValue(null);

    const res = await request
      .get('/api/user/profile/nonexistent-id')
      .set(AUTH)
      .expect(404);

    expect(res.body.message).toBe('User not found');
  });

  test('500 — returns 500 on unexpected Prisma error', async () => {
    mockPrisma.user.findUnique.mockRejectedValue(new Error('Unexpected DB error'));

    const res = await request
      .get(`/api/user/profile/${USER_ID}`)
      .set(AUTH)
      .expect(500);

    expect(res.body.message).toBe('Internal server error');
  });
});
