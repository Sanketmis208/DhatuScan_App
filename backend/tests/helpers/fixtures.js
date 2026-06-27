// tests/helpers/fixtures.js
// Shared test fixtures used across all test suites.

import { signToken } from '../../src/utils/jwt.js';

// ── Users ────────────────────────────────────────────────────────────────────

export const USER_ID   = 'user-uuid-1234';
export const USER_PHONE = '9876543210';

export const sampleUser = {
  id:               USER_ID,
  firebaseUid:      'firebase-uid-abc',
  phone:            USER_PHONE,
  name:             'Arjun Sharma',
  dateOfBirth:      new Date('1990-06-15'),
  age:              34,
  gender:           'Male',
  address:          '12 MG Road, Bengaluru',
  height:           175,
  weight:           70,
  bmi:              22.9,
  bp:               '120/80',
  pulseRate:        72,
  medicalHistory:   null,
  occupation:       'Engineer',
  physicalActivity: 'Moderate',
  sleepDuration:    '7–8 hrs',
  appetitePattern:  'Good',
  waterIntake:      '2–3 L',
  isProfileComplete: true,
  createdAt:        new Date('2024-01-01'),
  updatedAt:        new Date('2024-01-01'),
};

/** A valid JWT for sampleUser — signed with the test secret. */
export const validToken = signToken(USER_ID);

/** A clearly invalid JWT string. */
export const invalidToken = 'Bearer obviously.not.valid';

// ── Assessment ───────────────────────────────────────────────────────────────

export const ASSESSMENT_ID = 'assessment-uuid-5678';

export const sampleVKResults = [
  'Rasa','Rakta','Mamsa','Meda','Asthi','Majja','Shukra',
].map((dhatu) => ({
  dhatu,
  vriddhiScore:   0,
  kshayaScore:    0,
  vriddhiMax:     21,
  kshayaMax:      18,
  vriddhiPercent: 0,
  kshayaPercent:  0,
  vriddhiStatus:  'No Significant Change',
  kshayaStatus:   'No Significant Change',
  dominant:       'Balanced',
}));

export const sampleSarataResult = {
  scores:        { Rasa: 80, Rakta: 60, Mamsa: 70, Meda: 55, Asthi: 65, Majja: 75, Shukra: 80, Satva: 90 },
  totalScore:    90,
  healthIndex:   71.4,
  healthGrade:   'Good',
  dominantSara:  'Rasa',
  secondarySara: 'Shukra',
  weakestSara:   'Meda',
};

export const sampleAssessmentPayload = {
  vkResults:          sampleVKResults,
  sarataResult:       sampleSarataResult,
  healthIndex:        71.4,
  healthGrade:        'Good',
  balanceStatus:      'Sama Dhatu (Well Balanced)',
  dominantSara:       'Rasa',
  secondarySara:      'Shukra',
  weakestSara:        'Meda',
  predominantKshaya:  'Rasa',
  predominantVriddhi: 'Rakta',
};

export const sampleAssessment = {
  id:                ASSESSMENT_ID,
  userId:            USER_ID,
  assessmentDate:    new Date('2024-06-01'),
  ...sampleAssessmentPayload,
  createdAt:         new Date('2024-06-01'),
};
