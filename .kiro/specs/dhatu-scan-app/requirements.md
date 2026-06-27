# Requirements Document

## Introduction

DhatuScan is a bilingual (English + Hindi) mobile application built with Flutter and Dart that provides Ayurvedic health assessments based on the 7 Dhatus (bodily tissues) of Ayurveda. The app guides users through two assessment sections — Dhatu Vriddhi-Kshaya (imbalance scoring) and Dhatu Sarata (quality scoring) — and delivers personalized diet, lifestyle, and medicine recommendations for each affected Dhatu. The backend is built with Node.js, Express, Prisma, and PostgreSQL; authentication uses Firebase Phone OTP; and state management in Flutter uses the Provider pattern.

---

## Glossary

- **App**: The DhatuScan Flutter mobile application
- **Backend**: The Node.js + Express + Prisma + PostgreSQL server
- **User**: An authenticated individual using the App
- **Dhatu**: One of the 7 Ayurvedic bodily tissues: Rasa, Rakta, Mamsa, Meda, Asthi, Majja, Shukra
- **Vriddhi**: Excess/increase condition of a Dhatu
- **Kshaya**: Deficiency/decrease condition of a Dhatu
- **Sarata**: Quality or excellence condition of a Dhatu
- **Satva**: The eighth quality assessed only in Section 2 (mental resilience)
- **VK_Score**: The numeric score (0–3) assigned to each Vriddhi or Kshaya question response (No=0, Mild=1, Moderate=2, Severe=3)
- **VK_Percent**: The percentage score for a Dhatu's Vriddhi or Kshaya dimension, computed as (score / maxScore) * 100
- **Health_Index**: The Section 2 overall score computed as (totalSarataScore / 126) * 100
- **Balance_Status**: Enum: Sama (0 affected Dhatus), Mild (1–2 affected), Moderate (3–4 affected), Severe (5–7 affected)
- **Assessment**: A single complete evaluation comprising both Section 1 and Section 2
- **JWT**: JSON Web Token used for authenticated API requests
- **OTP**: One-Time Password delivered via Firebase Phone Authentication
- **BMI**: Body Mass Index, computed as weight(kg) / (height(m))²
- **Pathya_Aahar**: Recommended diet for a Dhatu condition
- **Apathya_Aahar**: Diet to avoid for a Dhatu condition
- **Pathya_Vihara**: Recommended lifestyle for a Dhatu condition
- **Apathya_Vihara**: Lifestyle to avoid for a Dhatu condition
- **Aushadha**: Recommended Ayurvedic medicine for a Dhatu condition
- **Recommendation_Table**: The hardcoded lookup table of 14 conditions (7 Dhatus × Vriddhi/Kshaya), each containing Pathya_Aahar, Apathya_Aahar, Pathya_Vihara, Apathya_Vihara, and Aushadha
- **SharedPreferences**: Local key-value storage on the device used for persisting assessment progress
- **Provider**: The Flutter state management library used throughout the App
- **Pinput**: The Flutter package used for rendering the 6-digit OTP input field
- **Shimmer**: Loading placeholder animation shown while data is being fetched
- **Lottie**: Animation library used for splash and transition animations

---

## Requirements

---

### Requirement 1: Splash Screen

**User Story:** As a user, I want to see a branded splash screen when I open the app, so that the app loads gracefully and routes me to the correct screen based on my login state.

#### Acceptance Criteria

1. WHEN the App is launched, THE App SHALL display a splash screen with a dark green gradient background, the DhatuScan logo from `assets/images/dhatu_logo.png`, and the app name rendered using the Poppins font.
2. WHEN the splash screen is displayed, THE App SHALL show the splash screen for exactly 2.5 seconds before navigating away.
3. WHEN the 2.5-second duration elapses and the User has an active authenticated session, THE App SHALL navigate the User directly to the Dashboard screen.
4. WHEN the 2.5-second duration elapses and the User does not have an active authenticated session, THE App SHALL navigate the User to the Landing screen.
5. WHEN a Lottie animation asset is available, THE App SHALL play the Lottie animation on the splash screen during the 2.5-second display period.

---

### Requirement 2: Landing Screen

**User Story:** As a new or returning user, I want to see a welcoming landing screen, so that I can choose to begin a new assessment or log into my existing account.

#### Acceptance Criteria

1. THE App SHALL display the DhatuScan logo, an app subtitle, a "Begin Assessment" button, and an "I already have account" button on the Landing screen.
2. WHEN the User taps the "Begin Assessment" button, THE App SHALL navigate to the Phone Input screen.
3. WHEN the User taps the "I already have account" button, THE App SHALL navigate to the Phone Input screen.
4. THE App SHALL render the Landing screen using the primary color `#1A5C5A` for headings and the accent color `#E8A838` for interactive button elements.
5. THE App SHALL render heading text using the Poppins font and body or subtitle text using the Lato font.

---

### Requirement 3: Phone Number Input

**User Story:** As a user, I want to enter my mobile number with a country prefix, so that I can receive a Firebase OTP to authenticate.

#### Acceptance Criteria

1. THE App SHALL display a phone number input field with a fixed `+91` country code prefix and accept exactly 10 numeric digits.
2. WHEN the User enters fewer than 10 digits and taps "Send OTP", THE App SHALL display an inline validation error message without navigating away.
3. WHEN the User enters exactly 10 digits and taps "Send OTP", THE App SHALL call the Firebase Phone Authentication API with the full phone number (`+91` + 10 digits).
4. WHEN the Firebase Phone Authentication API call succeeds, THE App SHALL navigate to the OTP Verification screen and pass the verification ID.
5. IF the Firebase Phone Authentication API call fails, THEN THE App SHALL display a toast notification with a descriptive error message.
6. WHEN the App calls Firebase Phone Authentication, THE App SHALL also call `POST /api/auth/check-user` on the Backend with the phone number to determine whether the User is new or returning, and store the result in the Provider state.

---

### Requirement 4: OTP Verification

**User Story:** As a user, I want to verify my identity with a 6-digit OTP, so that I can securely access my account.

#### Acceptance Criteria

1. THE App SHALL display a 6-digit OTP input rendered using the Pinput widget on the OTP Verification screen.
2. THE App SHALL display a 60-second countdown timer that begins immediately when the OTP Verification screen is shown.
3. WHEN the countdown timer reaches zero, THE App SHALL enable a "Resend OTP" button.
4. WHILE the countdown timer is running, THE App SHALL disable the "Resend OTP" button.
5. WHEN the User taps "Resend OTP" after the timer has reached zero, THE App SHALL restart the 60-second countdown and call the Firebase Phone Authentication API again.
6. WHEN the User enters all 6 digits of the OTP and taps "Verify", THE App SHALL call the Firebase credential verification method with the stored verification ID and the entered OTP.
7. WHEN Firebase OTP verification succeeds and the Backend indicates the User is new, THE App SHALL navigate to the Personal Details Form screen.
8. WHEN Firebase OTP verification succeeds and the Backend indicates the User is returning, THE App SHALL navigate to the Dashboard screen.
9. IF Firebase OTP verification fails due to an incorrect OTP, THEN THE App SHALL display an inline error message on the OTP input field and allow the User to re-enter.
10. IF Firebase OTP verification fails due to OTP expiry, THEN THE App SHALL display a toast notification prompting the User to resend the OTP.

---

### Requirement 5: Personal Details Form

**User Story:** As a new user, I want to enter my personal and health details, so that the app can personalize my assessment and track my health profile.

#### Acceptance Criteria

1. THE App SHALL display the Personal Details Form with the following fields: Full Name, Date of Birth (with a date picker), Age (auto-computed from Date of Birth), Gender (Male/Female/Other), Height (cm), Weight (kg), BMI (auto-computed and read-only), Blood Pressure (systolic/diastolic), Pulse rate, Medical History (multi-select or free text), Occupation, Physical Activity level, Sleep duration, Appetite level, Daily Water Intake, and Menstrual Regularity (displayed only when Gender is Female).
2. WHEN the User selects a Date of Birth, THE App SHALL automatically compute and display the User's Age in the Age field.
3. WHEN the User enters both Height and Weight, THE App SHALL automatically compute BMI as `weight / (height_in_metres)²` and display the result rounded to one decimal place in the BMI field.
4. WHEN the User taps "Submit" with any required field left empty, THE App SHALL highlight each empty required field with a validation error message.
5. WHEN all required fields are valid and the User taps "Submit", THE App SHALL call `POST /api/user/profile` on the Backend with the form data and the Firebase UID as the user identifier.
6. WHEN the Backend responds with a success status to `POST /api/user/profile`, THE App SHALL store the returned user profile and JWT in the Provider state and navigate to the Dashboard screen.
7. IF the Backend responds with an error to `POST /api/user/profile`, THEN THE App SHALL display a toast notification with the error message and keep the User on the Personal Details Form screen.

---

### Requirement 6: Dashboard

**User Story:** As a returning user, I want to see a personalized dashboard, so that I can review my health summary and start a new assessment.

#### Acceptance Criteria

1. WHEN the Dashboard screen loads, THE App SHALL call `GET /api/user/profile/:id` and `GET /api/assessment/history/:userId` with the stored JWT and display a Shimmer loading placeholder until the responses are received.
2. WHEN profile and assessment history data is loaded, THE App SHALL display: a greeting with the User's name, a health score card showing the latest Health_Index and Balance_Status, quick action buttons, and a list of past assessments.
3. WHEN the assessment history list is empty, THE App SHALL display a descriptive empty state message prompting the User to start their first assessment.
4. THE App SHALL display a "Start Assessment" button prominently on the Dashboard.
5. WHEN the User taps "Start Assessment", THE App SHALL navigate to the Assessment Home screen.
6. WHEN the User taps a past assessment item in the list, THE App SHALL navigate to the Result screen for that assessment, passing the assessment ID.
7. IF the `GET /api/user/profile/:id` call fails due to an expired JWT, THEN THE App SHALL clear the stored JWT, clear the Provider state, and navigate the User to the Landing screen.

---

### Requirement 7: Assessment Home

**User Story:** As a user, I want to see an overview of the two assessment sections before starting, so that I understand the scope and time commitment.

#### Acceptance Criteria

1. THE App SHALL display two section cards on the Assessment Home screen: one for "Section 1: Dhatu Vriddhi-Kshaya Assessment" and one for "Section 2: Dhatu Sarata Assessment".
2. THE App SHALL display an estimated time of 20–30 minutes for completing both sections on the Assessment Home screen.
3. WHEN the User taps "Start" on a section card, THE App SHALL navigate to that section's question screen.
4. WHEN Section 1 has been completed in a prior incomplete session, THE App SHALL display a visual indicator on the Section 1 card showing it is completed.
5. THE App SHALL allow the User to navigate back to the Dashboard from the Assessment Home screen without losing persisted progress.

---

### Requirement 8: Section 1 — Dhatu Vriddhi-Kshaya Assessment

**User Story:** As a user, I want to answer questions about symptoms of excess and deficiency for each Dhatu, so that the app can identify Dhatu imbalances.

#### Acceptance Criteria

1. THE App SHALL present Section 1 questions grouped by Dhatu in the following order: Rasa, Rakta, Mamsa, Meda, Asthi, Majja, Shukra, with each Dhatu group further divided into Vriddhi subsection and Kshaya subsection.
2. THE App SHALL display each question with a 4-point response scale: No (0), Mild (1), Moderate (2), Severe (3), rendered as selectable options.
3. THE App SHALL display each question in both English and Hindi using bilingual text, with Hindi rendered using the Noto Sans Devanagari font.
4. THE App SHALL display the following question counts per Dhatu: Rasa Vriddhi 7 questions (max 21 pts), Rasa Kshaya 6 questions (max 18 pts), Rakta Vriddhi 12 questions (max 36 pts), Rakta Kshaya 4 questions (max 12 pts), Mamsa Vriddhi 5 questions (max 15 pts), Mamsa Kshaya 3 questions (max 9 pts), Meda Vriddhi 5 questions (max 15 pts), Meda Kshaya 3 questions (max 9 pts), Asthi Vriddhi 2 questions (max 6 pts), Asthi Kshaya 4 questions (max 12 pts), Majja Vriddhi 3 questions (max 9 pts), Majja Kshaya 3 questions (max 9 pts), Shukra Vriddhi 2 questions (max 6 pts), Shukra Kshaya 5 questions (max 15 pts).
5. WHEN the User's Gender is not Male, THE App SHALL hide all Shukra Kshaya questions that specifically reference ejaculation, semen, or penile/testicular symptoms, and SHALL NOT include those questions' scores in the Shukra Kshaya maximum points calculation.
6. THE App SHALL display a progress indicator showing the number of answered questions out of the total questions in the current Dhatu subsection.
7. WHEN the User answers all questions in a subsection and taps "Next", THE App SHALL advance to the next subsection or Dhatu group.
8. WHEN the User taps "Previous", THE App SHALL navigate to the prior subsection without clearing already-entered answers.
9. WHEN any answer is recorded, THE App SHALL serialize the current Section 1 state (all answered VK_Scores and current position) to SharedPreferences as a JSON string.
10. WHEN the User opens Section 1 and a persisted Section 1 state exists in SharedPreferences, THE App SHALL restore all previous answers and resume from the last unanswered question.
11. WHEN the User completes all Section 1 questions and taps "Finish Section 1", THE App SHALL compute VK_Percent for each Dhatu dimension, determine the imbalance status per Dhatu, compute Balance_Status, and navigate to the Section 2 screen (or Assessment Home if Section 2 is not yet started).

---

### Requirement 9: Section 1 Score Calculation

**User Story:** As a system, I need to compute accurate Vriddhi-Kshaya scores so that each Dhatu's imbalance status is correctly determined.

#### Acceptance Criteria

1. THE App SHALL compute VK_Percent for each Dhatu Vriddhi dimension as `(sum of Vriddhi VK_Scores / Vriddhi max points) * 100`, rounded to one decimal place.
2. THE App SHALL compute VK_Percent for each Dhatu Kshaya dimension as `(sum of Kshaya VK_Scores / Kshaya max points) * 100`, rounded to one decimal place.
3. THE App SHALL assign an imbalance status to each Dhatu dimension using the following thresholds: 0–39% = "No Significant Change", 40–59% = "Mild", 60–79% = "Moderate", ≥80% = "Severe".
4. THE App SHALL count the number of Dhatu dimensions with a status of Mild, Moderate, or Severe as the "affected count".
5. THE App SHALL assign Balance_Status as follows: affected count = 0 → Sama, 1–2 → Mild, 3–4 → Moderate, 5–7 → Severe.
6. WHEN the User's Gender excludes certain Shukra Kshaya questions, THE App SHALL adjust the Shukra Kshaya max points to reflect only the applicable questions and use the adjusted max in the VK_Percent calculation.

---

### Requirement 10: Section 2 — Dhatu Sarata Assessment

**User Story:** As a user, I want to answer quality-indicator questions about each Dhatu, so that the app can compute my overall Dhatu health index.

#### Acceptance Criteria

1. THE App SHALL present Section 2 questions grouped by the following Sara categories with their maximum points: Rasa Sara (max 26 pts), Rakta Sara (max 9 pts), Mamsa Sara (max 14 pts), Meda Sara (max 21 pts), Asthi Sara (max 10 pts), Majja Sara (max 11 pts), Shukra Sara (max 20 pts), Satva Sara (max 15 pts).
2. THE App SHALL render Section 2 questions as multi-select checkboxes where each selected checkbox contributes its defined point value to the Sara category total.
3. THE App SHALL display each question in both English and Hindi using bilingual text, with Hindi rendered using the Noto Sans Devanagari font.
4. THE App SHALL display a progress indicator showing the number of answered question groups out of 8 Sara categories.
5. WHEN any checkbox selection changes, THE App SHALL serialize the current Section 2 state to SharedPreferences as a JSON string.
6. WHEN the User opens Section 2 and a persisted Section 2 state exists in SharedPreferences, THE App SHALL restore all previous checkbox selections and resume from the last unanswered Sara category.
7. WHEN the User completes all Section 2 Sara categories and taps "Finish Section 2", THE App SHALL compute the Health_Index as `(totalSarataScore / 126) * 100`, assign a Health_Index grade, and proceed to the Result screen.
8. THE App SHALL assign Health_Index grades as follows: 0–40% = "Poor", 41–60% = "Fair", 61–80% = "Good", 81–100% = "Excellent".

---

### Requirement 11: Assessment Submission

**User Story:** As a user, I want my completed assessment to be saved to the server, so that I can review past assessments from any device.

#### Acceptance Criteria

1. WHEN both Section 1 and Section 2 are completed, THE App SHALL call `POST /api/assessment/submit` on the Backend with the User's ID, all VK_Scores, all Sarata scores, the computed VK_Percents, the computed Balance_Status, and the computed Health_Index.
2. WHEN the Backend responds with success to `POST /api/assessment/submit`, THE App SHALL clear the Section 1 and Section 2 progress data from SharedPreferences and navigate to the Result screen with the returned assessment ID.
3. IF the Backend responds with an error to `POST /api/assessment/submit`, THEN THE App SHALL display a toast notification with the error message, retain the assessment data in SharedPreferences, and allow the User to retry submission.
4. THE App SHALL include the stored JWT as a Bearer token in the Authorization header of all authenticated API requests.

---

### Requirement 12: Result Screen

**User Story:** As a user, I want to see a clear summary of my assessment results, so that I can understand the state of each Dhatu.

#### Acceptance Criteria

1. THE App SHALL display the Health_Index score and its grade (Poor/Fair/Good/Excellent) prominently at the top of the Result screen.
2. THE App SHALL display the Balance_Status (Sama/Mild/Moderate/Severe) on the Result screen.
3. THE App SHALL display a bar chart using the fl_chart library showing the VK_Percent for both the Vriddhi and Kshaya dimensions of each of the 7 Dhatus, with bars color-coded by imbalance status.
4. THE App SHALL display a summary table listing each Dhatu, its Vriddhi VK_Percent, its Kshaya VK_Percent, and its imbalance status.
5. THE App SHALL display a combined result section indicating which Dhatus are in a balanced state (Sama) and which are imbalanced.
6. WHEN the User taps "View Recommendations", THE App SHALL navigate to the Recommendations screen passing the list of imbalanced Dhatus and their Vriddhi/Kshaya directions.
7. WHEN the Result screen is opened from the assessment history on the Dashboard, THE App SHALL call `GET /api/assessment/:id` to retrieve the stored result data and display a Shimmer loading placeholder until the response is received.

---

### Requirement 13: Recommendations Screen

**User Story:** As a user, I want to receive personalized diet, lifestyle, and medicine recommendations for each affected Dhatu, so that I can take actionable steps to restore balance.

#### Acceptance Criteria

1. THE App SHALL display recommendations for each Dhatu that has an imbalance status of Mild, Moderate, or Severe using the Recommendation_Table.
2. THE Recommendation_Table SHALL contain exactly 14 entries, one for each combination of the 7 Dhatus and the two conditions Vriddhi and Kshaya.
3. FOR EACH affected Dhatu condition, THE App SHALL display the following recommendation categories: Pathya_Aahar (recommended diet), Apathya_Aahar (diet to avoid), Pathya_Vihara (recommended lifestyle), Apathya_Vihara (lifestyle to avoid), and Aushadha (Ayurvedic medicine).
4. THE App SHALL render the Recommendations screen in a tabbed or accordion layout allowing the User to expand and collapse each Dhatu's recommendations section.
5. WHEN no Dhatus are imbalanced (Balance_Status = Sama), THE App SHALL display a congratulatory message on the Recommendations screen instead of recommendation entries.
6. THE App SHALL display recommendations content in both English and Hindi where translations are available in the Recommendation_Table.

---

### Requirement 14: API Integration and Authentication

**User Story:** As a user, I want all my data to be securely communicated with the server, so that my assessments and profile are stored safely.

#### Acceptance Criteria

1. THE App SHALL use the `dio` HTTP client for all Backend API calls, with a base URL configured via a single constant or environment variable.
2. THE App SHALL attach the JWT as a `Bearer` token in the `Authorization` header for all requests to authenticated endpoints: `GET /api/user/profile/:id`, `POST /api/user/profile`, `POST /api/assessment/submit`, `GET /api/assessment/history/:userId`, and `GET /api/assessment/:id`.
3. WHEN the Backend returns HTTP 401 on any authenticated request, THE App SHALL clear the stored JWT, clear the Provider state, and navigate the User to the Landing screen.
4. IF a network request fails due to a connection timeout or no internet connectivity, THEN THE App SHALL display a descriptive toast notification and not crash.
5. THE Backend SHALL expose the following routes: `POST /api/auth/check-user`, `POST /api/user/profile`, `GET /api/user/profile/:id`, `POST /api/assessment/submit`, `GET /api/assessment/history/:userId`, `GET /api/assessment/:id`.
6. THE Backend SHALL use Prisma with PostgreSQL as the persistence layer and JWT for session management.
7. THE Backend SHALL validate all incoming request payloads and return descriptive error messages with appropriate HTTP status codes for invalid inputs.

---

### Requirement 15: State Management

**User Story:** As a developer, I want all app state managed through the Provider pattern, so that UI is consistently in sync with data.

#### Acceptance Criteria

1. THE App SHALL use the Provider package for state management, with separate Provider classes for: AuthProvider (Firebase auth state, JWT, user ID), UserProvider (user profile data), AssessmentProvider (current assessment answers, scores, and progress), and HistoryProvider (past assessment list).
2. WHEN the User logs out or the JWT is cleared, THE App SHALL call `notifyListeners()` in the AuthProvider so all dependent widgets rebuild and reflect the unauthenticated state.
3. WHEN assessment progress is updated, THE AssessmentProvider SHALL persist the updated state to SharedPreferences within the same synchronous operation as the in-memory update.
4. THE App SHALL initialize all top-level Providers at the `MaterialApp` root using `MultiProvider` so that every screen can access shared state without prop drilling.

---

### Requirement 16: Design and Theming

**User Story:** As a user, I want the app to have a consistent, visually appealing Ayurvedic theme, so that the experience feels professional and culturally relevant.

#### Acceptance Criteria

1. THE App SHALL apply a global `ThemeData` with: primary color `#1A5C5A`, accent color `#E8A838`, background color `#F5F5F0`, Poppins as the headline font family, and Lato as the body text font family, both loaded via the `google_fonts` package.
2. THE App SHALL load and display the DhatuScan logo from `assets/images/dhatu_logo.png` on the Splash, Landing, and Dashboard screens.
3. THE App SHALL render all Hindi text using the Noto Sans Devanagari font to ensure correct Devanagari script rendering.
4. THE App SHALL use Shimmer loading placeholders on the Dashboard and Result screens whenever asynchronous data is being fetched.
5. THE App SHALL use Lottie animations on the Splash screen and on any loading or success transition states where a Lottie asset is available.

---

### Requirement 17: Local Persistence and Offline Resilience

**User Story:** As a user, I want my in-progress assessment to be saved locally so that I do not lose answers if the app is closed mid-assessment.

#### Acceptance Criteria

1. THE App SHALL persist Section 1 assessment progress (all VK_Scores and current question position) to SharedPreferences as a JSON-encoded string whenever any answer is recorded.
2. THE App SHALL persist Section 2 assessment progress (all Sara checkbox selections and current Sara category position) to SharedPreferences as a JSON-encoded string whenever any checkbox selection changes.
3. WHEN the App is relaunched and an incomplete Section 1 or Section 2 progress record is found in SharedPreferences, THE App SHALL restore the saved state and prompt the User to continue or restart.
4. WHEN an assessment is successfully submitted to the Backend, THE App SHALL delete the Section 1 and Section 2 progress records from SharedPreferences.
5. THE App SHALL store the JWT and user ID in SharedPreferences so that the User remains authenticated across app restarts without requiring re-login.
