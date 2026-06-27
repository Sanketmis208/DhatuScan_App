// tests/assessment.test.js
// Integration tests for assessment routes.
//
// Tests:
//   POST /api/assessment/submit
//     ✓ 201 — saves assessment, returns assessmentId
//     ✓ 401 — no token
//     ✓ 400 — missing required fields
//     ✓ 400 — vkResults has wrong length (not 7)
//     ✓ 400 — invalid healthGrade enum
//     ✓ 404 — user not found
//
//   GET /api/assessment/history/:userId
//     ✓ 200 — returns list (possibly empty)
//     ✓ 401 — no token
//
//   GET /api/assessment/:id
//     ✓ 200 — returns assessment
//     ✓ 401 — no token
//     ✓ 404 — not found

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

const { createApp } = await import('../src/app.js');
const supertest     = (await import('supertest')).default;
const {
  sampleUser,
  sampleAssessment,
  sampleAssessmentPayload,
  validToken,
  USER_ID,
  ASSESSMENT_ID,
} = await import('./helpers/fixtures.js');

const app     = createApp();
const request = supertest(app);
const AUTH    = { Authorization: `Bearer ${validToken}` };

function resetMocks() {
  mockPrisma.user.findUnique.mockReset();
  mockPrisma.assessment.findUnique.mockReset();
  mockPrisma.assessment.findMany.mockReset();
  mockPrisma.assessment.create.mockReset();
}

// ── POST /api/assessment/submit ───────────────────────────────────────────────

describe('POST /api/assessment/submit', () => {
  beforeEach(() => {
    resetMocks();
    // Default: user exists
    mockPrisma.user.findUnique.mockResolvedValue({ id: USER_ID });
  });

  test('201 — saves assessment and returns assessmentId', async () => {
    mockPrisma.assessment.create.mockResolvedValue(sampleAssessment);

    const res = await request
      .post('/api/assessment/submit')
      .set(AUTH)
      .send(sampleAssessmentPayload)
      .expect(201);

    expect(res.body.assessmentId).toBe(ASSESSMENT_ID);
    expect(mockPrisma.assessment.create).toHaveBeenCalledTimes(1);

    // Verify userId is set from JWT (not body).
    const createArgs = mockPrisma.assessment.create.mock.calls[0][0];
    expect(createArgs.data.userId).toBe(USER_ID);
  });

  test('401 — returns 401 with no Authorization header', async () => {
    await request
      .post('/api/assessment/submit')
      .send(sampleAssessmentPayload)
      .expect(401);
  });

  test('400 — returns 400 when vkResults is missing', async () => {
    const { vkResults, ...payload } = sampleAssessmentPayload;
    const res = await request
      .post('/api/assessment/submit')
      .set(AUTH)
      .send(payload)
      .expect(400);

    expect(res.body.message).toBe('Validation failed');
  });

  test('400 — returns 400 when vkResults has fewer than 7 entries', async () => {
    const res = await request
      .post('/api/assessment/submit')
      .set(AUTH)
      .send({ ...sampleAssessmentPayload, vkResults: sampleAssessmentPayload.vkResults.slice(0, 3) })
      .expect(400);

    expect(res.body.message).toBe('Validation failed');
  });

  test('400 — returns 400 for invalid healthGrade enum', async () => {
    const res = await request
      .post('/api/assessment/submit')
      .set(AUTH)
      .send({ ...sampleAssessmentPayload, healthGrade: 'Outstanding' })
      .expect(400);

    expect(res.body.message).toBe('Validation failed');
  });

  test('404 — returns 404 when user does not exist', async () => {
    mockPrisma.user.findUnique.mockResolvedValue(null); // user not found

    const res = await request
      .post('/api/assessment/submit')
      .set(AUTH)
      .send(sampleAssessmentPayload)
      .expect(404);

    expect(res.body.message).toBe('User not found');
  });

  test('500 — returns 500 on unexpected Prisma error', async () => {
    mockPrisma.assessment.create.mockRejectedValue(new Error('DB exploded'));

    const res = await request
      .post('/api/assessment/submit')
      .set(AUTH)
      .send(sampleAssessmentPayload)
      .expect(500);

    expect(res.body.message).toBe('Internal server error');
  });
});

// ── GET /api/assessment/history/:userId ───────────────────────────────────────

describe('GET /api/assessment/history/:userId', () => {
  beforeEach(resetMocks);

  test('200 — returns list of assessments (non-empty)', async () => {
    mockPrisma.assessment.findMany.mockResolvedValue([sampleAssessment]);

    const res = await request
      .get(`/api/assessment/history/${USER_ID}`)
      .set(AUTH)
      .expect(200);

    expect(Array.isArray(res.body.assessments)).toBe(true);
    expect(res.body.assessments).toHaveLength(1);
    expect(res.body.assessments[0].id).toBe(ASSESSMENT_ID);
  });

  test('200 — returns empty array when user has no assessments', async () => {
    mockPrisma.assessment.findMany.mockResolvedValue([]);

    const res = await request
      .get(`/api/assessment/history/${USER_ID}`)
      .set(AUTH)
      .expect(200);

    expect(res.body.assessments).toHaveLength(0);
  });

  test('401 — returns 401 with no Authorization header', async () => {
    await request
      .get(`/api/assessment/history/${USER_ID}`)
      .expect(401);
  });

  test('500 — returns 500 on Prisma error', async () => {
    mockPrisma.assessment.findMany.mockRejectedValue(new Error('Connection timeout'));

    const res = await request
      .get(`/api/assessment/history/${USER_ID}`)
      .set(AUTH)
      .expect(500);

    expect(res.body.message).toBe('Internal server error');
  });
});

// ── GET /api/assessment/:id ───────────────────────────────────────────────────

describe('GET /api/assessment/:id', () => {
  beforeEach(resetMocks);

  test('200 — returns single assessment', async () => {
    mockPrisma.assessment.findUnique.mockResolvedValue(sampleAssessment);

    const res = await request
      .get(`/api/assessment/${ASSESSMENT_ID}`)
      .set(AUTH)
      .expect(200);

    expect(res.body.assessment).toBeDefined();
    expect(res.body.assessment.id).toBe(ASSESSMENT_ID);
    expect(res.body.assessment.healthGrade).toBe('Good');
  });

  test('401 — returns 401 with no token', async () => {
    await request
      .get(`/api/assessment/${ASSESSMENT_ID}`)
      .expect(401);
  });

  test('404 — returns 404 when assessment not found', async () => {
    mockPrisma.assessment.findUnique.mockResolvedValue(null);

    const res = await request
      .get('/api/assessment/nonexistent-uuid')
      .set(AUTH)
      .expect(404);

    expect(res.body.message).toBe('Assessment not found');
  });

  test('500 — returns 500 on Prisma error', async () => {
    mockPrisma.assessment.findUnique.mockRejectedValue(new Error('Unexpected'));

    const res = await request
      .get(`/api/assessment/${ASSESSMENT_ID}`)
      .set(AUTH)
      .expect(500);

    expect(res.body.message).toBe('Internal server error');
  });
});
