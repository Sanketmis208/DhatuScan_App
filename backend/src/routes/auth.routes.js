// src/routes/auth.routes.js
// Express routes for Google OAuth authentication

import { Router } from 'express';
import { z } from 'zod';
import { validate } from '../middleware/validate.js';
import { login, signUp } from '../controllers/auth.controller.js';

const router = Router();

// Zod schema: requires a valid Google ID token string
const googleAuthSchema = z.object({
  idToken: z.string({ required_error: 'idToken is required' }),
});

/**
 * POST /api/auth/signup
 * Register a user via Google OAuth, return JWT + isNewUser.
 */
router.post('/signup', validate(googleAuthSchema), signUp);

/**
 * POST /api/auth/login
 * Authenticate a user via Google OAuth, return JWT + isNewUser.
 */
router.post('/login', validate(googleAuthSchema), login);

export default router;
