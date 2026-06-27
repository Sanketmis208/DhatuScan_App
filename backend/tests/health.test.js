// tests/health.test.js
// Tests for the /health endpoint and 404 handling.

import { jest } from '@jest/globals';

jest.unstable_mockModule('../src/config/database.js', () => ({
  default: {
    user:       { findUnique: jest.fn(), create: jest.fn(), update: jest.fn() },
    assessment: { findUnique: jest.fn(), findMany: jest.fn(), create: jest.fn() },
  },
}));

jest.unstable_mockModule('../src/config/firebase.js', () => ({
  getFirebaseApp:      jest.fn(),
  verifyFirebaseToken: jest.fn(),
}));

const { createApp } = await import('../src/app.js');
const supertest     = (await import('supertest')).default;

const app     = createApp();
const request = supertest(app);

describe('GET /health', () => {
  test('returns 200 with status ok', async () => {
    const res = await request.get('/health').expect(200);
    expect(res.body.status).toBe('ok');
    expect(res.body.service).toBeDefined();
  });
});

describe('Unknown routes', () => {
  test('returns 404 for an unrecognised route', async () => {
    const res = await request.get('/api/does-not-exist').expect(404);
    expect(res.body.message).toBe('Route not found');
  });

  test('returns 404 for a POST to a non-existent route', async () => {
    const res = await request.post('/api/mystery').send({}).expect(404);
    expect(res.body.message).toBe('Route not found');
  });
});
