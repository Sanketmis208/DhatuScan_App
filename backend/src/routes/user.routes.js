// src/routes/user.routes.js
// POST /api/user/profile     — save/update user profile (Bearer)
// GET  /api/user/profile/:id — fetch profile by UUID (Bearer)

import { Router } from 'express';
import { z } from 'zod';
import { verifyJWT } from '../middleware/auth.js';
import { validate } from '../middleware/validate.js';
import { saveProfile, getProfile } from '../controllers/user.controller.js';

const router = Router();

// All user routes require a valid JWT.
router.use(verifyJWT);

// Zod schema for profile update — all fields optional except phone
// (phone is already on the user record from check-user).
const saveProfileSchema = z.object({
  name: z.string().min(1).optional(),
  dateOfBirth: z.string().datetime({ offset: true }).optional().or(
    z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional()
  ),
  age: z.number().int().min(0).max(150).optional(),
  gender: z.enum(['Male', 'Female', 'Other']).optional(),
  address: z.string().optional(),
  height: z.number().positive().optional(),   // cm
  weight: z.number().positive().optional(),   // kg
  bmi: z.number().positive().optional(),
  bp: z.string().optional(),                  // e.g. "120/80"
  pulseRate: z.number().int().positive().optional(),
  medicalHistory: z.string().optional(),
  occupation: z.string().optional(),
  physicalActivity: z
    .enum(['Sedentary', 'Light', 'Moderate', 'Active', 'Very Active'])
    .optional(),
  sleepDuration: z.string().optional(),
  appetitePattern: z.enum(['Poor', 'Moderate', 'Good', 'Excessive']).optional(),
  waterIntake: z.string().optional(),
});

/**
 * POST /api/user/profile
 * Create or update the authenticated user's profile.
 */
router.post('/profile', validate(saveProfileSchema), saveProfile);

/**
 * GET /api/user/profile/:id
 * Fetch a user profile by UUID.
 */
router.get('/profile/:id', getProfile);

export default router;
