// src/controllers/user.controller.js
// POST /api/user/profile  — create or update user profile
// GET  /api/user/profile/:id — fetch user profile by UUID

import prisma from '../config/database.js';

// ── POST /api/user/profile ────────────────────────────────────────────────────
/**
 * Create or update the profile for the authenticated user.
 *
 * The JWT middleware sets req.userId, which is used as the record key.
 * Accepts all UserModel fields; marks isProfileComplete = true.
 *
 * Response: 200 { user: User }
 */
export async function saveProfile(req, res, next) {
  try {
    const userId = req.userId; // set by verifyJWT

    const {
      name,
      phone,
      dateOfBirth,
      age,
      gender,
      address,
      height,
      weight,
      bmi,
      bp,
      pulseRate,
      medicalHistory,
      occupation,
      physicalActivity,
      sleepDuration,
      appetitePattern,
      waterIntake,
    } = req.body;

    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        name: name ?? undefined,
        phone: phone ?? undefined,
        dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : undefined,
        age: age ?? undefined,
        gender: gender ?? undefined,
        address: address ?? undefined,
        height: height ?? undefined,
        weight: weight ?? undefined,
        bmi: bmi ?? undefined,
        bp: bp ?? undefined,
        pulseRate: pulseRate ?? undefined,
        medicalHistory: medicalHistory ?? undefined,
        occupation: occupation ?? undefined,
        physicalActivity: physicalActivity ?? undefined,
        sleepDuration: sleepDuration ?? undefined,
        appetitePattern: appetitePattern ?? undefined,
        waterIntake: waterIntake ?? undefined,
        isProfileComplete: true,
      },
    });

    return res.status(200).json({ user });
  } catch (err) {
    // P2025: Record not found (userId from JWT doesn't exist in DB)
    if (err.code === 'P2025') {
      return res.status(404).json({ message: 'User not found' });
    }
    next(err);
  }
}

// ── GET /api/user/profile/:id ─────────────────────────────────────────────────
/**
 * Fetch a user profile by UUID.
 * The caller must be authenticated (verifyJWT attached by router).
 *
 * Response: 200 { user: User }  |  404 { message: 'User not found' }
 */
export async function getProfile(req, res, next) {
  try {
    const { id } = req.params;

    const user = await prisma.user.findUnique({ where: { id } });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    return res.status(200).json({ user });
  } catch (err) {
    next(err);
  }
}
