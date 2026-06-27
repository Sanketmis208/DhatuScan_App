// src/routes/assessment.routes.js
// POST /api/assessment/submit            — save a completed assessment (Bearer)
// GET  /api/assessment/history/:userId   — list assessments for a user (Bearer)
// GET  /api/assessment/:id              — fetch single assessment (Bearer)

import { Router } from 'express';
import { z } from 'zod';
import { verifyJWT } from '../middleware/auth.js';
import { validate } from '../middleware/validate.js';
import {
  submitAssessment,
  getAssessmentHistory,
  getAssessment,
} from '../controllers/assessment.controller.js';

const router = Router();

// All assessment routes require a valid JWT.
router.use(verifyJWT);

// ── Zod schema for assessment submission ──────────────────────────────────────

// Per-Dhatu VK result shape (matches DhatuVKResult Dart model).
const dhatuVkResultSchema = z.object({
  dhatu: z.string(),
  vriddhiScore: z.number().int().min(0),
  kshayaScore: z.number().int().min(0),
  vriddhiMax: z.number().int().positive(),
  kshayaMax: z.number().int().positive(),
  vriddhiPercent: z.number().min(0).max(100),
  kshayaPercent: z.number().min(0).max(100),
  vriddhiStatus: z.string(),
  kshayaStatus: z.string(),
  dominant: z.enum(['Vriddhi', 'Kshaya', 'Balanced']),
});

// SarataResult shape (matches SarataResult Dart model).
const sarataResultSchema = z.object({
  scores: z.record(z.number()),        // { dhatu -> percentage }
  totalScore: z.number().min(0),
  healthIndex: z.number().min(0).max(100),
  healthGrade: z.enum(['Poor', 'Fair', 'Good', 'Excellent']),
  dominantSara: z.string(),
  secondarySara: z.string(),
  weakestSara: z.string(),
});

const submitAssessmentSchema = z.object({
  vkResults: z.array(dhatuVkResultSchema).length(7),
  sarataResult: sarataResultSchema,
  healthIndex: z.number().min(0).max(100),
  healthGrade: z.enum(['Poor', 'Fair', 'Good', 'Excellent']),
  balanceStatus: z.string(),
  dominantSara: z.string(),
  secondarySara: z.string(),
  weakestSara: z.string(),
  predominantKshaya: z.string(),
  predominantVriddhi: z.string(),
  assessmentDate: z.string().optional(), // ISO 8601 string
});

/**
 * POST /api/assessment/submit
 * Persist a completed assessment.
 */
router.post('/submit', validate(submitAssessmentSchema), submitAssessment);

/**
 * GET /api/assessment/history/:userId
 * List all past assessments for a user, newest first.
 *
 * NOTE: This route MUST be registered before /assessment/:id to prevent
 * "history" being matched as an :id parameter.
 */
router.get('/history/:userId', getAssessmentHistory);

/**
 * GET /api/assessment/:id
 * Fetch a single assessment by UUID.
 */
router.get('/:id', getAssessment);

export default router;
