// src/routes/auth.routes.js
// POST /api/auth/check-user
//
// No auth middleware — this is the endpoint that issues a JWT.

import { Router } from 'express';
import { z } from 'zod';
import { validate } from '../middleware/validate.js';
import { checkUser } from '../controllers/auth.controller.js';

const router = Router();

// Zod schema: phone is exactly 10 digits; firebaseUid / firebaseIdToken optional.
const checkUserSchema = z.object({
  phone: z
    .string({ required_error: 'phone is required' })
    .regex(/^\d{10}$/, 'phone must be exactly 10 digits'),
  firebaseUid: z.string().optional(),
  firebaseIdToken: z.string().optional(),
});

/**
 * POST /api/auth/check-user
 * Upsert user by phone, return JWT + isNewUser.
 */
router.post('/check-user', validate(checkUserSchema), checkUser);

export default router;
