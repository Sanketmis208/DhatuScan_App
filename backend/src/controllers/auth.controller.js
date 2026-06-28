// src/controllers/auth.controller.js
// Business logic for Google OAuth authentication

import { OAuth2Client } from 'google-auth-library';
import prisma from '../config/database.js';
import { signToken } from '../utils/jwt.js';

// Setup OAuth Client - single shared instance
const client = new OAuth2Client(
  process.env.GOOGLE_CLIENT_ID_WEB ||
  '553622699540-8nr8a243gd1gmrk966bhejlbc5e91p20.apps.googleusercontent.com'
);

/**
 * Verify Google ID Token
 */
async function verifyGoogleIdToken(idToken) {
  // Graceful fallback for test environment and mock keys
  if (process.env.NODE_ENV === 'test' || idToken.startsWith('mock-')) {
    return {
      googleId: `google-mock-${idToken}`,
      email: `${idToken}@example.com`,
      name: 'Mock Google User',
    };
  }

  // Accept tokens from any of our registered client IDs.
  // The web client ID is the primary audience for Android tokens.
  const audiences = [
    '553622699540-8nr8a243gd1gmrk966bhejlbc5e91p20.apps.googleusercontent.com',
    '553622699540-mc96gaunekjeuo708j73bvkr0p3nmnth.apps.googleusercontent.com',
    ...(process.env.GOOGLE_CLIENT_ID_WEB ? [process.env.GOOGLE_CLIENT_ID_WEB] : []),
    ...(process.env.GOOGLE_CLIENT_ID_ANDROID ? [process.env.GOOGLE_CLIENT_ID_ANDROID] : []),
    ...(process.env.GOOGLE_CLIENT_ID_IOS ? [process.env.GOOGLE_CLIENT_ID_IOS] : []),
  ];

  // De-duplicate audiences
  const uniqueAudiences = [...new Set(audiences)];

  console.log('[Auth] Verifying idToken, accepted audiences:', uniqueAudiences);

  const ticket = await client.verifyIdToken({
    idToken,
    audience: uniqueAudiences,
  });

  const payload = ticket.getPayload();
  if (!payload) {
    throw new Error('Failed to parse Google ID Token payload.');
  }

  console.log('[Auth] Token verified for:', payload['email']);

  return {
    googleId: payload['sub'],
    email: payload['email'],
    name: payload['name'] || payload['email'].split('@')[0],
  };
}

/**
 * POST /api/auth/signup
 */
export async function signUp(req, res, next) {
  try {
    const { idToken } = req.body;
    const { googleId, email, name } = await verifyGoogleIdToken(idToken);

    // Check if the user already exists
    let user = await prisma.user.findUnique({ where: { email } });

    if (user) {
      return res.status(400).json({
        code: 'ALREADY_EXISTS',
        message: 'You already have an account. Please log in.',
      });
    }

    // Create user
    user = await prisma.user.create({
      data: {
        email,
        googleId,
        name,
      },
    });

    const token = signToken(user.id);

    return res.status(201).json({
      token,
      userId: user.id,
      isNewUser: true,
      user,
    });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /api/auth/login
 */
export async function login(req, res, next) {
  try {
    const { idToken } = req.body;
    const { googleId, email } = await verifyGoogleIdToken(idToken);

    // Find user by email
    let user = await prisma.user.findUnique({ where: { email } });

    if (!user) {
      return res.status(404).json({
        code: 'NOT_FOUND',
        message: 'Account not found. Please sign up.',
      });
    }

    // Link Google ID if not already done
    if (!user.googleId) {
      user = await prisma.user.update({
        where: { id: user.id },
        data: { googleId },
      });
    }

    const token = signToken(user.id);

    return res.status(200).json({
      token,
      userId: user.id,
      isNewUser: false,
      user,
    });
  } catch (err) {
    next(err);
  }
}
