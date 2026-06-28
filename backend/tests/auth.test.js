// tests/auth.test.js
// Integration tests for Google Sign-In authentication flow

import { jest } from '@jest/globals';

const mockPrisma = {
  user: {
    findUnique: jest.fn(),
    create:     jest.fn(),
    update:     jest.fn(),
  },
};

jest.unstable_mockModule('../src/config/database.js', () => ({
  default: mockPrisma,
}));

const { createApp }  = await import('../src/app.js');
const supertest      = (await import('supertest')).default;
const { USER_EMAIL, sampleUser } = await import('./helpers/fixtures.js');

const app     = createApp();
const request = supertest(app);

function resetMocks() {
  mockPrisma.user.findUnique.mockReset();
  mockPrisma.user.create.mockReset();
  mockPrisma.user.update.mockReset();
}

describe('Authentication via Google Sign-In', () => {
  beforeEach(resetMocks);

  describe('POST /api/auth/signup', () => {
    test('successfully registers a new user', async () => {
      mockPrisma.user.findUnique.mockResolvedValue(null);
      mockPrisma.user.create.mockResolvedValue(sampleUser);

      const res = await request
        .post('/api/auth/signup')
        .send({ idToken: 'mock-id-token' })
        .expect(201);

      expect(res.body).toMatchObject({
        isNewUser: true,
        userId:    sampleUser.id,
      });
      expect(typeof res.body.token).toBe('string');
      expect(mockPrisma.user.create).toHaveBeenCalledTimes(1);
    });

    test('returns 400 when user email already exists', async () => {
      mockPrisma.user.findUnique.mockResolvedValue(sampleUser);

      const res = await request
        .post('/api/auth/signup')
        .send({ idToken: 'mock-id-token' })
        .expect(400);

      expect(res.body.code).toBe('ALREADY_EXISTS');
      expect(res.body.message).toContain('already have an account');
    });

    test('returns 400 when idToken is missing', async () => {
      const res = await request
        .post('/api/auth/signup')
        .send({})
        .expect(400);

      expect(res.body.message).toBe('Validation failed');
    });
  });

  describe('POST /api/auth/login', () => {
    test('successfully logs in an existing user', async () => {
      mockPrisma.user.findUnique.mockResolvedValue(sampleUser);

      const res = await request
        .post('/api/auth/login')
        .send({ idToken: 'mock-id-token' })
        .expect(200);

      expect(res.body).toMatchObject({
        isNewUser: false,
        userId:    sampleUser.id,
      });
      expect(typeof res.body.token).toBe('string');
      expect(mockPrisma.user.create).not.toHaveBeenCalled();
    });

    test('returns 404 when user profile does not exist', async () => {
      mockPrisma.user.findUnique.mockResolvedValue(null);

      const res = await request
        .post('/api/auth/login')
        .send({ idToken: 'mock-id-token' })
        .expect(404);

      expect(res.body.code).toBe('NOT_FOUND');
      expect(res.body.message).toContain('Account not found');
    });

    test('returns 400 when idToken is missing', async () => {
      const res = await request
        .post('/api/auth/login')
        .send({})
        .expect(400);

      expect(res.body.message).toBe('Validation failed');
    });
  });
});
