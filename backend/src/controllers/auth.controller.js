// src/controllers/auth.controller.js
// POST /api/auth/check-user
//
// Business logic:
//   1. Optionally verify a Firebase ID token if firebaseUid is provided.
//   2. Upsert a User record keyed by phone number.
//   3. Sign a JWT and return { token, userId, isNewUser }.

import prisma from '../config/database.js';
import { signToken } from '../utils/jwt.js';
import { verifyFirebaseToken } from '../config/firebase.js';

/**
 * POST /api/auth/check-user
 *
 * Body (validated by Zod before this handler is called):
 *   { phone: string, firebaseUid?: string, firebaseIdToken?: string }
 *
 * Response:
 *   200 { token: string, userId: string, isNewUser: boolean, user: User }
 */
export async function checkUser(req, res, next) {
  try {
    const { phone, firebaseUid, firebaseIdToken } = req.body;

    // ── Optional Firebase token verification ──────────────────────────────
    let resolvedFirebaseUid = firebaseUid ?? null;

    if (firebaseIdToken) {
      try {
        const decoded = await verifyFirebaseToken(firebaseIdToken);
        resolvedFirebaseUid = decoded.uid;
      } catch (err) {
        // If token verification fails, reject the request outright.
        return res.status(401).json({
          message: 'Invalid Firebase ID token',
          detail: err.message,
        });
      }
    }

    // ── Upsert user by phone ──────────────────────────────────────────────
    // We use findFirst + create/update instead of upsert so we can correctly
    // distinguish isNewUser from the result.
    let user = await prisma.user.findUnique({ where: { phone } });
    let isNewUser = false;

    if (!user) {
      user = await prisma.user.create({
        data: {
          phone,
          firebaseUid: resolvedFirebaseUid,
        },
      });
      isNewUser = true;
    } else if (resolvedFirebaseUid && user.firebaseUid !== resolvedFirebaseUid) {
      // Update firebaseUid if it has changed (e.g. re-registration).
      user = await prisma.user.update({
        where: { id: user.id },
        data: { firebaseUid: resolvedFirebaseUid },
      });
    }

    // ── Sign JWT ──────────────────────────────────────────────────────────
    const token = signToken(user.id);

    return res.status(200).json({
      token,
      userId: user.id,
      isNewUser,
      user,
    });
  } catch (err) {
    next(err);
  }
}
