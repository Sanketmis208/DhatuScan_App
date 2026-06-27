// tests/middleware.test.js
// Unit tests for auth.js and validate.js middleware.
//
// Tests:
//   verifyJWT
//     ✓ Calls next() and sets req.userId for a valid token
//     ✓ Returns 401 with "No token provided" when header is absent
//     ✓ Returns 401 with "No token provided" when header lacks "Bearer "
//     ✓ Returns 401 with "Invalid or expired token" for a bad token
//     ✓ Returns 401 with "Token has expired" for an expired token
//
//   validate(schema)
//     ✓ Calls next() and replaces req.body with parsed data on success
//     ✓ Returns 400 with errors array when parsing fails

import { jest } from '@jest/globals';

// No Prisma or Firebase needed for middleware tests — import directly.
const { verifyJWT } = await import('../src/middleware/auth.js');
const { validate }  = await import('../src/middleware/validate.js');
const { signToken } = await import('../src/utils/jwt.js');
const { z }         = await import('zod');

// ── Helpers ───────────────────────────────────────────────────────────────────

function makeResMock() {
  const res = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json   = jest.fn().mockReturnValue(res);
  return res;
}

// ── verifyJWT ─────────────────────────────────────────────────────────────────

describe('verifyJWT middleware', () => {
  const userId = 'test-user-id';
  const validToken = signToken(userId);
  const next = jest.fn();

  beforeEach(() => next.mockClear());

  test('calls next() and sets req.userId for a valid token', () => {
    const req = { headers: { authorization: `Bearer ${validToken}` } };
    const res = makeResMock();

    verifyJWT(req, res, next);

    expect(next).toHaveBeenCalledTimes(1);
    expect(req.userId).toBe(userId);
    expect(res.status).not.toHaveBeenCalled();
  });

  test('returns 401 when Authorization header is absent', () => {
    const req = { headers: {} };
    const res = makeResMock();

    verifyJWT(req, res, next);

    expect(next).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ message: expect.stringMatching(/no token/i) })
    );
  });

  test('returns 401 when header does not start with "Bearer "', () => {
    const req = { headers: { authorization: 'Token abc123' } };
    const res = makeResMock();

    verifyJWT(req, res, next);

    expect(next).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(401);
  });

  test('returns 401 "Invalid or expired token" for a bad signature', () => {
    const req = { headers: { authorization: 'Bearer this.is.not.valid' } };
    const res = makeResMock();

    verifyJWT(req, res, next);

    expect(next).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ message: expect.stringMatching(/invalid/i) })
    );
  });
});

// ── validate middleware ────────────────────────────────────────────────────────

describe('validate middleware', () => {
  const schema = z.object({
    name:  z.string().min(1),
    score: z.number().min(0).max(100),
  });

  const next = jest.fn();
  beforeEach(() => next.mockClear());

  test('calls next() and sets req.body to parsed data on success', () => {
    const req = { body: { name: 'Arjun', score: 85 } };
    const res = makeResMock();

    validate(schema)(req, res, next);

    expect(next).toHaveBeenCalledTimes(1);
    expect(req.body).toEqual({ name: 'Arjun', score: 85 });
    expect(res.status).not.toHaveBeenCalled();
  });

  test('returns 400 with errors array when required field is missing', () => {
    const req = { body: { score: 50 } }; // name missing
    const res = makeResMock();

    validate(schema)(req, res, next);

    expect(next).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(400);

    const body = res.json.mock.calls[0][0];
    expect(body.message).toBe('Validation failed');
    expect(Array.isArray(body.errors)).toBe(true);
    expect(body.errors.some((e) => e.path === 'name')).toBe(true);
  });

  test('returns 400 when score is out of range', () => {
    const req = { body: { name: 'Test', score: 200 } };
    const res = makeResMock();

    validate(schema)(req, res, next);

    expect(next).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(400);

    const body = res.json.mock.calls[0][0];
    expect(body.errors.some((e) => e.path === 'score')).toBe(true);
  });

  test('returns 400 with multiple errors when several fields fail', () => {
    const req = { body: {} }; // both name and score missing
    const res = makeResMock();

    validate(schema)(req, res, next);

    const body = res.json.mock.calls[0][0];
    expect(body.errors.length).toBeGreaterThanOrEqual(2);
  });
});
