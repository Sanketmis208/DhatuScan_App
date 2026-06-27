// src/controllers/assessment.controller.js
// POST /api/assessment/submit           — persist a completed assessment
// GET  /api/assessment/history/:userId  — list all assessments for a user
// GET  /api/assessment/:id              — fetch single assessment by UUID

import prisma from '../config/database.js';

// ── POST /api/assessment/submit ───────────────────────────────────────────────
/**
 * Persist a completed assessment for the authenticated user.
 *
 * Body (validated by Zod):
 *   { vkResults, sarataResult, healthIndex, healthGrade, balanceStatus,
 *     dominantSara, secondarySara, weakestSara,
 *     predominantKshaya, predominantVriddhi,
 *     assessmentDate? }
 *
 * Response: 201 { assessmentId: string }
 */
export async function submitAssessment(req, res, next) {
  try {
    const userId = req.userId; // set by verifyJWT

    const {
      vkResults,
      sarataResult,
      healthIndex,
      healthGrade,
      balanceStatus,
      dominantSara,
      secondarySara,
      weakestSara,
      predominantKshaya,
      predominantVriddhi,
      assessmentDate,
    } = req.body;

    // Verify the user exists before creating the assessment.
    const userExists = await prisma.user.findUnique({
      where: { id: userId },
      select: { id: true },
    });
    if (!userExists) {
      return res.status(404).json({ message: 'User not found' });
    }

    const assessment = await prisma.assessment.create({
      data: {
        userId,
        vkResults,      // stored as JSON
        sarataResult,   // stored as JSON
        healthIndex,
        healthGrade,
        balanceStatus,
        dominantSara,
        secondarySara,
        weakestSara,
        predominantKshaya,
        predominantVriddhi,
        assessmentDate: assessmentDate ? new Date(assessmentDate) : undefined,
      },
    });

    return res.status(201).json({ assessmentId: assessment.id });
  } catch (err) {
    next(err);
  }
}

// ── GET /api/assessment/history/:userId ───────────────────────────────────────
/**
 * Return all assessments for the given user, sorted newest first.
 *
 * Response: 200 { assessments: Assessment[] }
 */
export async function getAssessmentHistory(req, res, next) {
  try {
    const { userId } = req.params;

    const assessments = await prisma.assessment.findMany({
      where: { userId },
      orderBy: { assessmentDate: 'desc' },
    });

    return res.status(200).json({ assessments });
  } catch (err) {
    next(err);
  }
}

// ── GET /api/assessment/:id ───────────────────────────────────────────────────
/**
 * Fetch a single assessment by UUID.
 *
 * Response: 200 { assessment: Assessment }  |  404 { message: 'Not found' }
 */
export async function getAssessment(req, res, next) {
  try {
    const { id } = req.params;

    const assessment = await prisma.assessment.findUnique({ where: { id } });

    if (!assessment) {
      return res.status(404).json({ message: 'Assessment not found' });
    }

    return res.status(200).json({ assessment });
  } catch (err) {
    next(err);
  }
}
