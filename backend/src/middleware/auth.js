// src/middleware/auth.js
// JWT Bearer-token authentication middleware.
//
// Usage:
//   router.get('/protected', verifyJWT, handler)
//
// On success:  sets req.userId and calls next().
// On failure:  responds 401 with { message: '...' }.

import { verifyToken } from '../utils/jwt.js';

/**
 * Express middleware that validates the Authorization: Bearer <token> header.
 *
 * @param {import('express').Request}  req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
export function verifyJWT(req, res, next) {
  const header = req.headers['authorization'];

  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'No token provided' });
  }

  const token = header.slice(7); // strip "Bearer "

  try {
    const payload = verifyToken(token);
    req.userId = payload.userId;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Token has expired' });
    }
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
}
