// src/utils/jwt.js
// JWT sign / verify helpers.
//
// signToken(userId)  — creates a signed JWT with 7-day expiry.
// verifyToken(token) — verifies and returns the decoded payload,
//                      or throws if invalid / expired.

import jwt from 'jsonwebtoken';

const SECRET = process.env.JWT_SECRET;
const EXPIRES_IN = process.env.JWT_EXPIRES_IN ?? '7d';

if (!SECRET && process.env.NODE_ENV !== 'test') {
  throw new Error(
    'JWT_SECRET environment variable is not set. ' +
      'Copy .env.example to .env and set a strong secret.'
  );
}

// Use a deterministic test secret so tests never fail because of a missing env var.
const _secret = SECRET ?? 'test-jwt-secret-do-not-use-in-production';

/**
 * Sign a JWT for the given userId.
 *
 * @param {string} userId  — backend UUID of the user
 * @returns {string}       — signed JWT string
 */
export function signToken(userId) {
  return jwt.sign({ userId }, _secret, { expiresIn: EXPIRES_IN });
}

/**
 * Verify a JWT and return the decoded payload.
 * Throws `JsonWebTokenError` or `TokenExpiredError` on failure.
 *
 * @param {string} token
 * @returns {{ userId: string, iat: number, exp: number }}
 */
export function verifyToken(token) {
  return jwt.verify(token, _secret);
}
