# Implementation Plan: DhatuScan

## Overview

Implement the DhatuScan Ayurvedic health-assessment app in the priority order:
Auth → Backend → Flutter Screens → Section 1 Assessment → Section 2 Assessment → Results → Recommendations.
Core models, services, and `ScoreCalculator` are already scaffolded; tasks build on top of that existing code.
Property-based tests use the [`dart_check`](https://pub.dev/packages/dart_check) package (minimum 100 iterations each).

---

## Tasks

- [x] 1. Auth Flow — Firebase OTP Phone Authentication
  - [x] 1.1 Migrate `ApiService` from `http` to `dio` with JWT interceptor
    - Replace all `http.post`/`http.get` calls in `lib/services/api_service.dart` with `Dio` equivalents
    - Add a `Dio` request interceptor that attaches `Authorization: Bearer <token>` from `LocalStorageService.authToken`
    - Add a `Dio` response interceptor that catches HTTP 401, calls `LocalStorageService.logout()`, and broadcasts an unauthenticated event via a `GlobalKey<NavigatorState>` push to `/landing`
    - Add `connectivity_plus` pre-flight check; throw a descriptive `ApiException` when offline
    - Remove the `http` import once migration is complete
    - _Requirements: 14.1, 14.2, 14.3, 14.4_

  - [x]* 1.2 Write property test — Phone input validation (Property 1)
    - **Property 1: Phone input validation**
    - *For any* string input, `validatePhone(input)` SHALL accept it if and only if it matches `/^\d{10}$/`
    - Use `dart_check` arbitrary string generator (alphanumeric, shorter, longer, special chars)
    - Tag: `// Feature: dhatu-scan-app, Property 1: phone input validation`
    - **Validates: Requirements 3.1, 3.2, 3.3**
    - File: `test/unit/phone_validation_test.dart`

  - [x] 1.3 Implement `PhoneInputScreen`
    - Create `lib/screens/auth/phone_input_screen.dart`
    - Fixed `+91` prefix label + 10-digit `TextField` (numeric keyboard, `maxLength: 10`)
    - "Send OTP" button calls `AuthProvider.sendOtp(phone)`
    - Inline error shown when fewer than 10 digits are entered
    - Concurrently call `ApiService.checkUser(phone)` and store `isNewUser` in `AuthProvider`
    - Show `CircularProgressIndicator` while `AuthState.sendingOtp`
    - On `AuthState.otpSent`, navigate to `/otp` passing `verificationId`
    - On `AuthState.error`, show `fluttertoast` with `errorMessage`
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

  - [x] 1.4 Implement `OtpVerificationScreen`
    - Create `lib/screens/auth/otp_verification_screen.dart`
    - 6-digit `Pinput` widget bound to a `TextEditingController`
    - 60-second countdown using `Timer.periodic`; "Resend OTP" disabled while timer runs, enabled at zero
    - "Resend OTP" tap calls `AuthProvider.resendOtp()` and restarts countdown
    - "Verify" tap calls `AuthProvider.verifyOtp(otp)`
    - On success + `isNewUser == true` → navigate to `/profile/new`
    - On success + `isNewUser == false` → navigate to `/dashboard`
    - On incorrect OTP: show inline error on `Pinput` field
    - On expired OTP: show toast prompting resend
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 4.10_

  - [x]* 1.5 Write unit tests — Auth state transitions
    - Mock `AuthService` and `ApiService`; verify `AuthState` transitions for sendOtp, verifyOtp success/failure/expiry
    - Verify 401 from `checkUser` triggers logout and navigation
    - File: `test/unit/auth_provider_test.dart`

- [ ] 2. Checkpoint — Auth flow complete
  - Ensure auth unit and property tests pass. Run `flutter test test/unit/ --run`. Ask the user if questions arise.

- [ ] 3. Backend — Node.js + Express + Prisma + PostgreSQL
  - [ ] 3.1 Initialise backend project and Prisma schema
    - Scaffold `backend/` directory with `package.json` (Node.js 18+, Express 4, Prisma 5, `zod`, `jsonwebtoken`, `firebase-admin`)
    - Write `prisma/schema.prisma` with `User` and `Assessment` models exactly as defined in the design
    - Add `datasource` using `DATABASE_URL` env var
    - Run `prisma generate` and `prisma migrate dev --name init` against a local PostgreSQL 15 instance
    - _Requirements: 14.5, 14.6_

  - [ ] 3.2 Implement Firebase Admin initialisation and JWT helpers
    - Create `src/config/firebase.js` — initialise Firebase Admin SDK from `GOOGLE_APPLICATION_CREDENTIALS`
    - Create `src/utils/jwt.js` — `signToken(userId)` (7-day expiry) and `verifyToken(token)` using `JWT_SECRET`
    - _Requirements: 14.6_

  - [ ] 3.3 Implement JWT auth middleware and Zod validation middleware
    - Create `src/middleware/auth.js` — `verifyJWT` extracts Bearer token, verifies with `jwt.verify`, attaches `req.userId`; returns 401 on failure
    - Create `src/middleware/validate.js` — factory function taking a Zod schema; returns 400 with `errors` array on parse failure
    - _Requirements: 14.6, 14.7_

  - [ ] 3.4 Implement `POST /api/auth/check-user` route and controller
    - Route: no auth middleware
    - Zod schema: `{ phone: z.string().regex(/^\d{10}$/) }`
    - Controller: verify Firebase ID token if `firebaseUid` provided; upsert `User` by `phone`; sign JWT; return `{ token, userId, isNewUser }`
    - _Requirements: 3.6, 14.5_

  - [ ] 3.5 Implement user profile routes and controller
    - `POST /api/user/profile` (Bearer) — create or update user profile; validate all fields with Zod; return updated `User`
    - `GET /api/user/profile/:id` (Bearer) — fetch by UUID; return 404 if not found
    - _Requirements: 5.5, 5.6, 6.1, 14.5_

  - [ ] 3.6 Implement assessment routes and controller
    - `POST /api/assessment/submit` (Bearer) — Zod-validate payload; persist `Assessment` via Prisma; return `{ assessmentId }`
    - `GET /api/assessment/history/:userId` (Bearer) — return list of past `Assessment` records for user, sorted by `assessmentDate` descending
    - `GET /api/assessment/:id` (Bearer) — return single assessment by UUID; 404 if not found
    - _Requirements: 11.1, 12.7, 14.5_

  - [ ] 3.7 Wire Express app and start server
    - Create `src/app.js` — register JSON body parser, CORS, and all route files under `/api`
    - Create `src/server.js` — `app.listen(PORT)` with graceful startup log
    - Add global error handler middleware returning `500 { message: 'Internal server error' }`
    - _Requirements: 14.5, 14.7_

  - [ ]* 3.8 Write backend integration tests
    - Use `supertest` + `jest` to test each route: happy path, invalid payload (400), missing auth (401), not found (404)
    - Use a separate test PostgreSQL database; reset with `prisma migrate reset` before each suite
    - File: `backend/tests/`

- [ ] 4. Checkpoint — Backend complete
  - Ensure all backend tests pass (`npm test`). Verify `prisma studio` shows correct schema. Ask the user if questions arise.

- [ ] 5. Flutter Screens — Core UI Scaffolding
  - [ ] 5.1 Set up global theme, routes, and MultiProvider root
    - Update `lib/core/theme/app_theme.dart` with `ThemeData`: primary `#1A5C5A`, accent `#E8A838`, background `#F5F5F0`, Poppins headlines, Lato body via `google_fonts`
    - Create `lib/core/constants/app_routes.dart` with all named route constants
    - Update `lib/app.dart` — `MaterialApp` with `theme`, `initialRoute: AppRoutes.splash`, and full `routes` map
    - Update `lib/main.dart` — `MultiProvider` with `AuthProvider`, `UserProvider`, `AssessmentProvider`, `HistoryProvider` at root; `LocalStorageService.init()` before `runApp()`
    - _Requirements: 15.1, 15.4, 16.1_

  - [ ] 5.2 Implement `SplashScreen`
    - Create `lib/screens/splash/splash_screen.dart`
    - Dark green gradient background, DhatuScan logo from `assets/images/dhatu_logo.png`, app name in Poppins
    - `Lottie.asset(...)` with null-safe fallback to static logo if asset missing
    - `Future.delayed(2.5 seconds)` then check `LocalStorageService.isLoggedIn`; navigate to `/dashboard` or `/landing`
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

  - [ ] 5.3 Implement `LandingScreen`
    - Create `lib/screens/landing/landing_screen.dart`
    - DhatuScan logo, subtitle text, "Begin Assessment" button (accent `#E8A838`), "I already have account" button
    - Both buttons navigate to `/phone`
    - Headings in Poppins with `#1A5C5A`; body in Lato
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [ ] 5.4 Implement `PersonalDetailsScreen`
    - Create `lib/screens/onboarding/personal_details_screen.dart`
    - All fields from Requirement 5.1; `DatePicker` for DOB; auto-compute `age` on DOB change
    - Auto-compute BMI when height and weight both filled; display rounded to 1 dp (read-only)
    - `Menstrual Regularity` shown only when `gender == 'Female'`
    - Validation highlights empty required fields on "Submit" tap
    - On valid submit: call `UserProvider.saveProfile(model)`; navigate to `/dashboard` on success; toast on error
    - Disable back navigation (use `WillPopScope` or `PopScope` returning false)
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7_

  - [ ]* 5.5 Write property test — BMI computation (Property 2)
    - **Property 2: BMI computation**
    - *For any* height `h > 0` cm and weight `w > 0` kg, `UserModel.calculateBmi(h, w)` SHALL equal `w / (h/100)²` rounded to 1 dp and be positive finite
    - Generator: `(h: double 1–300, w: double 1–300)`
    - Tag: `// Feature: dhatu-scan-app, Property 2: BMI computation`
    - **Validates: Requirements 5.3**
    - File: `test/unit/bmi_calculation_test.dart`

  - [ ] 5.6 Implement `DashboardScreen`
    - Create `lib/screens/dashboard/dashboard_screen.dart`
    - On `initState`: call `UserProvider.fetchProfile()` and `HistoryProvider.fetchHistory()`; show `LoadingShimmer` widget until both complete
    - Display greeting with user name, health score card (latest `healthIndex` + `balanceStatus`), quick-action buttons, past assessment list
    - Empty state message when history is empty
    - "Start Assessment" button navigates to `/assessment`
    - Past assessment list item tap navigates to `/assessment/result` with `assessmentId`
    - On HTTP 401 during fetch: `LocalStorageService.logout()`, clear providers, navigate to `/landing`
    - Create `lib/widgets/common/loading_shimmer.dart` if not already present
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7_

  - [ ]* 5.7 Write widget tests — Splash routing and Landing navigation
    - `SplashScreen`: mock `isLoggedIn = true` → assert Navigator push to `/dashboard`; `isLoggedIn = false` → assert push to `/landing`
    - `LandingScreen`: tap "Begin Assessment" → assert push to `/phone`
    - File: `test/widget/splash_landing_test.dart`

- [ ] 6. Checkpoint — Core screens complete
  - Ensure all Flutter unit and widget tests pass (`flutter test`). Hot-reload the app and verify splash → landing → phone navigation. Ask the user if questions arise.

- [ ] 7. Assessment Section 1 — Dhatu Vriddhi-Kshaya
  - [ ] 7.1 Create `AssessmentProvider` with Section 1 state management
    - Create `lib/providers/assessment_provider.dart`
    - In-memory state: `Map<String, DhatuVKAnswers> vkAnswers`, `int currentDhatuIndex`, `String currentSubsection`
    - `setVKAnswer(dhatu, subsection, symptom, score)`: update in-memory map; immediately call `LocalStorageService.saveVKAnswers(toJson())`
    - `getKshayaMax(dhatu, gender)`: return gender-adjusted max (Shukra Kshaya: 6 for non-male, 15 for male)
    - `restoreFromCache()`: read `LocalStorageService.savedVKAnswers`; populate state if present
    - `finishSection1()`: call `ScoreCalculator.calculateVriddhiKshaya(vkAnswers)` and `calculateBalanceStatus()`; store `vkResults` and `balanceStatus`; set `section1Complete = true`
    - _Requirements: 8.9, 8.10, 15.3, 17.1_

  - [ ]* 7.2 Write property test — VK_Percent computation (Property 3)
    - **Property 3: VK_Percent computation**
    - *For any* list of VK_Scores (each in `[0,3]`) and `maxScore > 0`, `ScoreCalculator` percent SHALL equal `(sum/max)*100` rounded to 1 dp and be in `[0.0, 100.0]`
    - Generator: `(scores: List<int 0–3> length 1–12, maxScore: int 1–36)`
    - Tag: `// Feature: dhatu-scan-app, Property 3: VK_Percent computation`
    - **Validates: Requirements 9.1, 9.2**
    - File: `test/unit/score_calculator_test.dart`

  - [ ]* 7.3 Write property test — Imbalance status threshold (Property 4)
    - **Property 4: Imbalance status threshold classification**
    - *For any* `VK_Percent` value in `[0.0, 100.0]`, `_getVKStatus` returns exactly one of the four statuses with no gaps or overlaps
    - Generator: `double 0.0–100.0`
    - Tag: `// Feature: dhatu-scan-app, Property 4: imbalance status threshold`
    - **Validates: Requirements 9.3**
    - File: `test/unit/score_calculator_test.dart`

  - [ ]* 7.4 Write property test — Balance_Status classification (Property 5)
    - **Property 5: Balance_Status classification**
    - *For any* `affectedCount` in `[0, 14]`, `ScoreCalculator.calculateBalanceStatus` returns the correct status string
    - Generator: `int 0–14`
    - Tag: `// Feature: dhatu-scan-app, Property 5: Balance_Status classification`
    - **Validates: Requirements 9.4, 9.5**
    - File: `test/unit/score_calculator_test.dart`

  - [ ] 7.5 Create `VKQuestionCard` and `AssessmentHomeScreen`
    - Create `lib/widgets/assessment/vk_question_card.dart` — bilingual question text (English + Hindi via `NotoSansDevanagari`), 4-point radio row (No / Mild / Moderate / Severe), fires `onChanged(int score)` callback
    - Create `lib/screens/assessment/assessment_home_screen.dart` — two section cards with estimated time (20–30 min); Section 1 card shows completion indicator when `section1Complete`; "Start" navigates to respective section; back → `/dashboard` without clearing progress
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 8.3_

  - [ ] 7.6 Implement `Section1Screen`
    - Create `lib/screens/assessment/section1_screen.dart`
    - Ordered Dhatu list: Rasa, Rakta, Mamsa, Meda, Asthi, Majja, Shukra
    - Each Dhatu: Vriddhi subsection then Kshaya subsection, each rendered as a `ListView` of `VKQuestionCard`
    - Filter male-only Shukra Kshaya questions when `UserProvider.user.gender != 'Male'`
    - Progress indicator: answered / total questions in current subsection
    - "Next" advances subsection; "Previous" navigates back without clearing answers
    - On `restoreFromCache()` result present, resume from last unanswered question
    - "Finish Section 1" calls `AssessmentProvider.finishSection1()` then navigates to `/assessment`
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9, 8.10, 8.11, 9.6_

  - [ ]* 7.7 Write unit tests — Section 1 gender filtering and score edge cases
    - Verify Shukra Kshaya max = 6 for non-male, 15 for male
    - Verify zero-score results → "No Significant Change" for all Dhatus
    - Verify max-score results → "Severe" for all Dhatus
    - File: `test/unit/score_calculator_test.dart`

- [ ] 8. Checkpoint — Section 1 complete
  - Ensure all Section 1 property and unit tests pass. Manually step through all 7 Dhatus in a simulator to confirm progress persistence. Ask the user if questions arise.

- [ ] 9. Assessment Section 2 — Dhatu Sarata
  - [ ] 9.1 Extend `AssessmentProvider` with Section 2 state management
    - Add `Map<String, Map<String, bool>> sarataSelections`, `int currentSarataIndex`, `bool section2Complete`
    - `setSarataSelection(dhatu, item, selected)`: update in-memory map; immediately call `LocalStorageService.saveSarataAnswers(toJson())`
    - `restoreFromCache()`: also restore `sarataSelections` and `currentSarataIndex` from `LocalStorageService.savedSarataAnswers`
    - `finishSection2()`: compute per-Sara scores from `sarataSelections` using `SarataQuestionBank` point values; call `ScoreCalculator.calculateSarata(scores)`; store `sarataResult`; set `section2Complete = true`
    - _Requirements: 10.5, 10.6, 15.3, 17.2_

  - [ ]* 9.2 Write property test — Health_Index computation and grade (Property 6)
    - **Property 6: Health_Index computation and grade**
    - *For any* total Sarata score `s` in `[0, 126]`, `ScoreCalculator.calculateSarata` SHALL produce `healthIndex = (s/126)*100` rounded to 1 dp in `[0,100]` with the correct grade
    - Generator: `double 0.0–126.0`
    - Tag: `// Feature: dhatu-scan-app, Property 6: Health_Index computation and grade`
    - **Validates: Requirements 10.7, 10.8**
    - File: `test/unit/score_calculator_test.dart`

  - [ ] 9.3 Create `SarataGroupCard` widget
    - Create `lib/widgets/assessment/sarata_group_card.dart`
    - Renders a named group with multi-select checkboxes (default) or single-select radio buttons (`isSingleSelect: true`)
    - Each item displays bilingual text (English + Hindi) and its point value if > 1
    - Fires `onChanged(String item, bool selected)` callback
    - _Requirements: 10.2, 10.3_

  - [ ] 9.4 Implement `Section2Screen`
    - Create `lib/screens/assessment/section2_screen.dart`
    - 8 Sara category pages in order: Rasa, Rakta, Mamsa, Meda, Asthi, Majja, Shukra, Satva
    - Progress indicator: answered Sara categories / 8
    - Restore from cache on open; resume from last unanswered Sara category
    - "Next" / "Previous" navigation between categories
    - "Finish Section 2" calls `AssessmentProvider.finishSection2()` then `AssessmentProvider.submitAssessment()`, then navigates to `/assessment/result`
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7, 10.8, 11.1, 11.2, 11.3_

  - [ ]* 9.5 Write property test — Assessment state JSON round-trip (Property 8)
    - **Property 8: Assessment state serialization round-trip**
    - *For any* valid Section 1 `vkAnswers` map and Section 2 `sarataSelections` map, `jsonEncode` then `jsonDecode` SHALL produce structurally and value-equal maps with no loss, mutation, or addition
    - Use `DhatuVKAnswers.toJson()` / `fromJson()` and the raw `sarataSelections` map
    - Tag: `// Feature: dhatu-scan-app, Property 8: assessment state JSON round-trip`
    - **Validates: Requirements 15.3, 17.1, 17.2**
    - File: `test/unit/assessment_serialization_test.dart`

- [ ] 10. Checkpoint — Section 2 complete
  - Ensure all Section 2 property and unit tests pass. Verify SharedPreferences persistence by killing and restarting the app mid-section. Ask the user if questions arise.

- [ ] 11. Result Screen
  - [ ] 11.1 Implement `DhatuBarChart` widget
    - Create `lib/widgets/result/dhatu_bar_chart.dart`
    - Use `fl_chart` `BarChart` widget
    - Two bar groups per Dhatu (Vriddhi, Kshaya), each bar height = `VK_Percent` value
    - Color-code bars by status: green (No Significant Change), yellow (Mild), orange (Moderate), red (Severe)
    - X-axis labels: Dhatu abbreviations; Y-axis: 0–100%
    - _Requirements: 12.3_

  - [ ] 11.2 Implement `HealthScoreCard` widget
    - Create `lib/widgets/result/health_score_card.dart`
    - Display `healthIndex` as a large numeric value with grade badge
    - Display `balanceStatus` with appropriate color coding
    - Show Shimmer placeholder while data is loading
    - _Requirements: 12.1, 12.2, 16.4_

  - [ ] 11.3 Implement `ResultScreen`
    - Create `lib/screens/result/result_screen.dart`
    - If opened from Dashboard (has `assessmentId` route argument): call `HistoryProvider.fetchDetail(id)` and show `LoadingShimmer` until loaded
    - If opened after fresh submission: read computed results from `AssessmentProvider`
    - Display: `HealthScoreCard`, `DhatuBarChart`, summary table (Dhatu | Vriddhi% | Kshaya% | Status), balanced vs imbalanced Dhatu list
    - "View Recommendations" button navigates to `/assessment/recommendations` passing affected Dhatu list
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7_

  - [ ]* 11.4 Write unit tests — Result screen data binding
    - Verify `HealthScoreCard` renders correct grade string for each grade boundary value
    - Verify `DhatuBarChart` assigns correct bar colors for each status
    - File: `test/widget/result_widgets_test.dart`

- [ ] 12. Checkpoint — Result screen complete
  - Ensure tests pass. Verify full assessment → result navigation end-to-end in a simulator. Ask the user if questions arise.

- [ ] 13. Recommendations Screen
  - [ ] 13.1 Create hardcoded `Recommendation` data class and lookup table
    - Create `lib/core/constants/recommendations_data.dart`
    - Define the `Recommendation` class with fields: `dhatu`, `condition`, `pathyaAahar`, `pathyaAaharHi`, `apathyaAahar`, `apathyaAaharHi`, `pathyaVihara`, `pathyaViharaHi`, `apathyaVihara`, `apathyaViharaHi`, `aushadha`, `aushadhaHi`
    - Define `const List<Recommendation> recommendationTable` with exactly 14 entries (7 Dhatus × Vriddhi + Kshaya)
    - Define `getRecommendation(String dhatu, String condition)` lookup function returning nullable `Recommendation`
    - _Requirements: 13.1, 13.2, 13.3, 13.6_

  - [ ]* 13.2 Write property test — Recommendation table completeness (Property 7)
    - **Property 7: Recommendation table completeness**
    - *For any* of the 14 `(dhatu, condition)` pairs, `getRecommendation(dhatu, condition)` SHALL return a non-null `Recommendation` with all five English fields non-empty
    - Enumerate all 14 pairs as the generator
    - Tag: `// Feature: dhatu-scan-app, Property 7: recommendation table completeness`
    - **Validates: Requirements 13.1, 13.2, 13.3**
    - File: `test/unit/recommendations_test.dart`

  - [ ] 13.3 Implement `RecommendationsScreen`
    - Create `lib/screens/recommendations/recommendations_screen.dart`
    - Receive `List<AffectedDhatu>` from route arguments (populated by `ScoreCalculator.getTopAffectedDhatus()`)
    - When `balanceStatus == 'Sama Dhatu (Well Balanced)'`: show congratulatory message; no recommendation entries
    - For each affected Dhatu: call `getRecommendation(dhatu, condition)` and render an `ExpansionTile` (accordion) or tab showing all 5 categories
    - Each category section shows English text and Hindi text (using `NotoSansDevanagari` font) where available
    - _Requirements: 13.1, 13.3, 13.4, 13.5, 13.6_

  - [ ]* 13.4 Write unit tests — Recommendations screen edge cases
    - Verify `balanceStatus = 'Sama Dhatu (Well Balanced)'` renders congratulatory message with no expansion tiles
    - Verify each of the 5 recommendation categories is present in an `ExpansionTile` for a known imbalanced Dhatu
    - File: `test/widget/recommendations_screen_test.dart`

- [ ] 14. Final Checkpoint — Full flow complete
  - Run `flutter test --coverage` and ensure all property tests (P1–P8) and unit/widget tests pass with 0 failures.
  - Verify coverage ≥ 80% on `score_calculator.dart` and `recommendations_data.dart`.
  - Run the complete user journey in a simulator: splash → phone → OTP → personal details → dashboard → assessment → section 1 → section 2 → result → recommendations.
  - Ask the user if questions arise before closing the spec.

