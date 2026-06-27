// src/config/firebase.js
// Firebase Admin SDK initialisation.
//
// The service-account key is loaded from the file path referenced by
// GOOGLE_APPLICATION_CREDENTIALS (set in .env).  During testing the
// credential is omitted so the SDK initialises in a "no-credential" mode
// that still allows token verification against the Firebase emulator.

import admin from 'firebase-admin';
import { readFileSync, existsSync } from 'fs';

let firebaseApp;

/**
 * Initialise (or return the already-initialised) Firebase Admin app.
 *
 * Calling this function multiple times is safe — subsequent calls return
 * the existing app instance.
 */
export function getFirebaseApp() {
  if (firebaseApp) return firebaseApp;

  // If running in test/CI without a real service account, initialise with
  // no credentials so we can still call verifyIdToken against the emulator.
  if (process.env.NODE_ENV === 'test' || process.env.FIREBASE_SKIP_INIT) {
    try {
      firebaseApp = admin.app();
    } catch {
      firebaseApp = admin.initializeApp({ projectId: 'dhatuscan-test' });
    }
    return firebaseApp;
  }

  const credPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;

  if (credPath && existsSync(credPath)) {
    const serviceAccount = JSON.parse(readFileSync(credPath, 'utf8'));
    try {
      firebaseApp = admin.app();
    } catch {
      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    }
  } else {
    // Fall back to application-default credentials (GCP environments).
    try {
      firebaseApp = admin.app();
    } catch {
      firebaseApp = admin.initializeApp();
    }
  }

  return firebaseApp;
}

/**
 * Verify a Firebase ID token and return the decoded payload.
 * Throws if the token is invalid or expired.
 *
 * @param {string} idToken
 * @returns {Promise<admin.auth.DecodedIdToken>}
 */
export async function verifyFirebaseToken(idToken) {
  const app = getFirebaseApp();
  return admin.auth(app).verifyIdToken(idToken);
}

// Initialise eagerly (non-blocking) so the SDK warms up.
getFirebaseApp();
