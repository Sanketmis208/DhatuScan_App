# Design Document — DhatuScan

## Overview

DhatuScan is a bilingual (English + Hindi) Ayurvedic health-assessment mobile application. Users authenticate via Firebase Phone OTP, complete a two-section assessment covering all 7 Dhatus, and receive personalised diet, lifestyle, and medicine recommendations. The system consists of:

- **Flutter (Dart)** client — UI, state management via Provider, local persistence via SharedPreferences
- **Node.js + Express** backend — REST API, JWT authentication, Prisma ORM
- **PostgreSQL** — persistent data store for users and assessments
- **Firebase Auth** — Phone OTP verification

The app targets Android and iOS. All computation-heavy logic (score calculation, threshold classification) lives on the Flutter client so the app degrades gracefully when offline.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Client (Dart)                    │
│                                                             │
│  Screens ──► Providers ──► Services ──► Backend API         │
│                │                │                           │
│                │                ├──► Firebase Auth (OTP)    │
│                │                └──► SharedPreferences      │
│                └──► Models (plain Dart objects)             │
└─────────────────────────────────────────────────────────────┘
                          │  HTTP/REST (JWT Bearer)
┌─────────────────────────────────────────────────────────────┐
│                Node.js + Express Backend                     │
│                                                             │
│  Routes ──► Middleware (JWT) ──► Controllers ──► Prisma     │
│                                                    │        │
│                                              PostgreSQL DB  │
└─────────────────────────────────────────────────────────────┘
```

**Key design decisions:**

1. Score calculation runs entirely on-device. The backend stores computed results but never recalculates, keeping the backend thin and offline-resilient.
2. SharedPreferences stores in-progress assessment state as JSON so users never lose answers on app close.
3. JWT is issued by the backend after Firebase UID verification and stored in SharedPreferences for persistence across restarts.
4. The recommendation table is hardcoded in Flutter (not fetched from backend) to ensure offline availability.

---

## Flutter Project Structure

```
dhatuscan/lib/
├── main.dart                          # App entry point, MultiProvider root, Firebase init
├── app.dart                           # MaterialApp, theme, initial route
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Color palette (#1A5C5A, #E8A838, etc.)
│   │   ├── app_strings.dart           # All UI copy strings (English)
│   │   └── app_routes.dart            # Named route constants
│   ├── theme/
│   │   └── app_theme.dart             # ThemeData: Poppins headlines, Lato body
│   └── utils/
│       └── score_calculator.dart      # VK_Percent, Health_Index, Balance_Status
│
├── models/
│   ├── user_model.dart                # UserModel with fromJson/toJson/copyWith
│   ├── assessment_model.dart          # DhatuVKAnswers, QuestionBank, SarataQuestionBank
│   └── result_model.dart              # DhatuVKResult, SarataResult, AssessmentResult
│
├── providers/
│   ├── auth_provider.dart             # Firebase OTP state, JWT, isNewUser flag
│   ├── user_provider.dart             # UserModel state, profile fetch/save
│   ├── assessment_provider.dart       # In-progress answers, scores, section completion
│   └── history_provider.dart          # Past AssessmentResult list
│
├── services/
│   ├── api_service.dart               # HTTP client wrapper (dio), all endpoint calls
│   ├── auth_service.dart              # Firebase Auth calls
│   └── local_storage_service.dart     # SharedPreferences abstraction
│
├── screens/
│   ├── splash/splash_screen.dart
│   ├── landing/landing_screen.dart
│   ├── auth/
│   │   ├── phone_input_screen.dart
│   │   └── otp_verification_screen.dart
│   ├── onboarding/personal_details_screen.dart
│   ├── dashboard/dashboard_screen.dart
│   ├── assessment/
│   │   ├── assessment_home_screen.dart
│   │   ├── section1_screen.dart
│   │   └── section2_screen.dart
│   ├── result/result_screen.dart
│   └── recommendations/recommendations_screen.dart
│
└── widgets/
    ├── common/
    │   ├── dhatu_app_bar.dart
    │   ├── loading_shimmer.dart
    │   └── toast_helper.dart
    ├── assessment/
    │   ├── vk_question_card.dart      # 4-point radio row (No/Mild/Moderate/Severe)
    │   └── sarata_group_card.dart     # Multi-select checkbox group
    └── result/
        ├── dhatu_bar_chart.dart       # fl_chart bar chart for VK_Percent
        └── health_score_card.dart
```

---

## Components and Interfaces

### Provider Classes

#### AuthProvider (`ChangeNotifier`)

```dart
enum AuthState { initial, sendingOtp, otpSent, verifying, authenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthState get state;
  String? get verificationId;
  String? get errorMessage;
  String? get phoneNumber;
  bool get isNewUser;       // set after POST /api/auth/check-user
  bool get isLoggedIn;      // reads from LocalStorageService

  Future<void> sendOtp(String phone);
  Future<void> resendOtp();
  Future<bool> verifyOtp(String otp);  // returns true on success
  Future<void> signOut();
  void clearError();
}
```

#### UserProvider (`ChangeNotifier`)

```dart
class UserProvider extends ChangeNotifier {
  UserModel? get user;
  bool get isLoading;
  String? get errorMessage;
  bool get isProfileComplete;

  void loadFromCache();
  Future<bool> fetchProfile();          // GET /api/user/profile/:id
  Future<bool> saveProfile(UserModel);  // POST /api/user/profile
  void setUserPhone(String phone);
  void clear();
}
```

#### AssessmentProvider (`ChangeNotifier`)

```dart
class AssessmentProvider extends ChangeNotifier {
  // Section 1 state
  Map<String, DhatuVKAnswers> get vkAnswers;
  int get currentDhatuIndex;
  String get currentSubsection;   // 'vriddhi' | 'kshaya'
  bool get section1Complete;

  // Section 2 state
  Map<String, Map<String, bool>> get sarataSelections;  // dhatu -> itemText -> selected
  int get currentSarataIndex;
  bool get section2Complete;

  // Computed (available after section completion)
  List<DhatuVKResult>? get vkResults;
  SarataResult? get sarataResult;
  String? get balanceStatus;

  // Mutation
  void setVKAnswer(String dhatu, String subsection, String symptom, int score);
  void setSarataSelection(String dhatu, String item, bool selected);
  void finishSection1();  // runs ScoreCalculator, persists state
  void finishSection2();  // runs ScoreCalculator, persists state
  Future<bool> submitAssessment();  // POST /api/assessment/submit
  void restoreFromCache();
  void reset();

  // Gender-aware max score lookup
  int getKshayaMax(String dhatu, String? gender);
}
```

#### HistoryProvider (`ChangeNotifier`)

```dart
class HistoryProvider extends ChangeNotifier {
  List<AssessmentResult> get history;
  bool get isLoading;
  String? get errorMessage;

  Future<void> fetchHistory();  // GET /api/assessment/history/:userId
  Future<AssessmentResult?> fetchDetail(String assessmentId);  // GET /api/assessment/:id
  void clear();
}
```

### ApiService Interface

`ApiService` is a singleton wrapping the `dio` HTTP client. All requests attach `Authorization: Bearer <jwt>` via a Dio interceptor. On 401 responses, the interceptor clears local storage and broadcasts an `unauthenticated` event that the root navigator listens to.

```dart
class ApiService {
  static const String baseUrl = '...';  // from app_config.dart

  Future<Map<String, dynamic>> checkUser(String phone, {String? firebaseUid});
  Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getProfile(String userId);
  Future<Map<String, dynamic>> submitAssessment(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getAssessmentHistory(String userId);
  Future<Map<String, dynamic>> getAssessment(String assessmentId);
}
```

---

## Data Models

### UserModel

| Field | Type | Notes |
|-------|------|-------|
| `id` | `String?` | PostgreSQL UUID, null before profile save |
| `firebaseUid` | `String?` | Firebase UID |
| `phone` | `String` | E.164 without country code, e.g. `9876543210` |
| `name` | `String?` | Full name |
| `dateOfBirth` | `DateTime?` | ISO 8601 |
| `age` | `int?` | Auto-computed from DOB |
| `gender` | `String?` | `"Male"` \| `"Female"` \| `"Other"` |
| `height` | `double?` | cm |
| `weight` | `double?` | kg |
| `bmi` | `double?` | Computed: `weight / (height_m)²`, 1 dp |
| `bp` | `String?` | `"120/80"` format |
| `pulseRate` | `int?` | bpm |
| `medicalHistory` | `String?` | Free text or comma-separated |
| `occupation` | `String?` | |
| `physicalActivity` | `String?` | `"Sedentary"` \| `"Moderate"` \| `"Active"` |
| `sleepDuration` | `String?` | e.g. `"7-8 hours"` |
| `appetitePattern` | `String?` | |
| `waterIntake` | `String?` | |
| `isProfileComplete` | `bool` | Set to `true` after first profile save |

### AssessmentModel

**DhatuVKAnswers** — per-Dhatu answer container:

```dart
class DhatuVKAnswers {
  final Map<String, int> vriddhiAnswers;  // symptom -> 0|1|2|3
  final Map<String, int> kshayaAnswers;   // symptom -> 0|1|2|3
  int get vriddhiScore;  // sum of vriddhiAnswers.values
  int get kshayaScore;   // sum of kshayaAnswers.values
}
```

**QuestionBank** — compile-time constant map `{dhatu -> {vriddhi/kshaya -> [AssessmentQuestion]}}`. `AssessmentQuestion` carries `symptom` (English) and `isMaleOnly` flag. The full question set is embedded in the binary (not fetched from backend).

**SarataQuestionBank** — compile-time constant list of `SarataSection` objects, one per Sara category. Each section has a `maxScore`, a `dhatu` name, and a list of `SarataGroup` objects. Groups are either multi-select (default) or single-select (`isSingleSelect: true`). Each `SarataItem` has a `points` value (default 1).

### ResultModel

**DhatuVKResult** — computed per-Dhatu result:

| Field | Type |
|-------|------|
| `dhatu` | `String` |
| `vriddhiScore` / `kshayaScore` | `int` |
| `vriddhiMax` / `kshayaMax` | `int` |
| `vriddhiPercent` / `kshayaPercent` | `double` |
| `vriddhiStatus` / `kshayaStatus` | `String` |
| `dominant` | `"Vriddhi"` \| `"Kshaya"` \| `"Balanced"` |

**SarataResult**:

| Field | Type |
|-------|------|
| `scores` | `Map<String, double>` — per-Sara percentage |
| `totalScore` | `double` |
| `healthIndex` | `double` — 0–100 |
| `healthGrade` | `"Poor"` \| `"Fair"` \| `"Good"` \| `"Excellent"` |
| `dominantSara` / `secondarySara` / `weakestSara` | `String` |

**AssessmentResult** — full assessment record stored in backend and cached locally:

| Field | Type |
|-------|------|
| `id` | `String?` — backend UUID |
| `userId` | `String` |
| `assessmentDate` | `DateTime` |
| `vkResults` | `List<DhatuVKResult>` |
| `sarataResult` | `SarataResult` |
| `healthIndex` | `double` |
| `healthGrade` | `String` |
| `dominantSara` / `secondarySara` / `weakestSara` | `String` |
| `predominantKshaya` / `predominantVriddhi` | `String` |
| `balanceStatus` | `String` |

---

## Screen Navigation Flow / Routing

Named routes are defined in `app_routes.dart` and registered in `MaterialApp.routes`.

```
SplashScreen
    │ isLoggedIn?
    ├─ YES ──► DashboardScreen
    └─ NO  ──► LandingScreen
                   │
                   ├─ "Begin Assessment" ──► PhoneInputScreen
                   └─ "I already have account" ──► PhoneInputScreen
                                │
                            OtpVerificationScreen
                                │ Firebase success
                                ├─ isNewUser = true ──► PersonalDetailsScreen ──► DashboardScreen
                                └─ isNewUser = false ─────────────────────────► DashboardScreen
                                                                                      │
                                                                              AssessmentHomeScreen
                                                                              ┌────────┤
                                                                     Section1Screen  Section2Screen
                                                                              └────────┤
                                                                                  ResultScreen
                                                                                       │
                                                                           RecommendationsScreen
```

**Back-navigation rules:**
- Splash → no back
- OTP → back to PhoneInput
- PersonalDetails → no back (prevent OTP bypass)
- Assessment screens → back allowed within section, not across section boundary to Dashboard (would lose progress)
- Result → back to Dashboard (not assessment)

**JWT expiry redirect:** Any `ApiService` call receiving HTTP 401 calls `LocalStorageService.logout()`, clears all Providers, and pushes the Landing route with `pushNamedAndRemoveUntil`.

### Route Constants (`app_routes.dart`)

```dart
class AppRoutes {
  static const String splash        = '/';
  static const String landing       = '/landing';
  static const String phoneInput    = '/phone';
  static const String otpVerify     = '/otp';
  static const String personalDetails = '/profile/new';
  static const String dashboard     = '/dashboard';
  static const String assessmentHome = '/assessment';
  static const String section1      = '/assessment/section1';
  static const String section2      = '/assessment/section2';
  static const String result        = '/assessment/result';
  static const String recommendations = '/assessment/recommendations';
}
```

---

## Backend Architecture

### Technology Stack

| Layer | Technology |
|-------|-----------|
| Runtime | Node.js 18+ |
| Framework | Express 4 |
| ORM | Prisma 5 |
| Database | PostgreSQL 15 |
| Auth | Firebase Admin SDK (token verification) + `jsonwebtoken` |
| Validation | `zod` |

### Project Structure

```
backend/
├── src/
│   ├── app.js               # Express app, middleware registration
│   ├── server.js            # HTTP server entry point
│   ├── config/
│   │   ├── database.js      # Prisma client singleton
│   │   └── firebase.js      # Firebase Admin App init
│   ├── middleware/
│   │   ├── auth.js          # verifyJWT middleware
│   │   └── validate.js      # Zod schema validation middleware
│   ├── routes/
│   │   ├── auth.routes.js
│   │   ├── user.routes.js
│   │   └── assessment.routes.js
│   ├── controllers/
│   │   ├── auth.controller.js
│   │   ├── user.controller.js
│   │   └── assessment.controller.js
│   └── utils/
│       └── jwt.js           # sign/verify helpers
├── prisma/
│   └── schema.prisma
└── package.json
```

### Express Routes

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/auth/check-user` | No | Check if phone exists; return JWT + userId + isNewUser |
| POST | `/api/user/profile` | Bearer | Create or update user profile |
| GET | `/api/user/profile/:id` | Bearer | Fetch user profile by ID |
| POST | `/api/assessment/submit` | Bearer | Save completed assessment |
| GET | `/api/assessment/history/:userId` | Bearer | List past assessments for user |
| GET | `/api/assessment/:id` | Bearer | Fetch single assessment by ID |

### JWT Auth Middleware

```js
// middleware/auth.js
export function verifyJWT(req, res, next) {
  const header = req.headers['authorization'];
  if (!header?.startsWith('Bearer ')) return res.status(401).json({ message: 'No token' });
  try {
    const payload = jwt.verify(header.slice(7), process.env.JWT_SECRET);
    req.userId = payload.userId;
    next();
  } catch {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
}
```

### Prisma Schema

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id               String   @id @default(uuid())
  firebaseUid      String   @unique
  phone            String   @unique
  name             String?
  dateOfBirth      DateTime?
  age              Int?
  gender           String?
  height           Float?
  weight           Float?
  bmi              Float?
  bp               String?
  pulseRate        Int?
  medicalHistory   String?
  occupation       String?
  physicalActivity String?
  sleepDuration    String?
  appetitePattern  String?
  waterIntake      String?
  isProfileComplete Boolean  @default(false)
  createdAt        DateTime @default(now())
  updatedAt        DateTime @updatedAt

  assessments  Assessment[]
}

model Assessment {
  id              String   @id @default(uuid())
  userId          String
  assessmentDate  DateTime @default(now())
  vkResults       Json     // serialised List<DhatuVKResult>
  sarataResult    Json     // serialised SarataResult
  healthIndex     Float
  healthGrade     String
  balanceStatus   String
  dominantSara    String
  secondarySara   String
  weakestSara     String
  predominantKshaya  String
  predominantVriddhi String
  createdAt       DateTime @default(now())

  user  User @relation(fields: [userId], references: [id], onDelete: Cascade)
}
```

---

## Score Calculation Algorithms

All calculations live in `lib/core/utils/score_calculator.dart`.

### VK_Percent

```
VK_Percent(dimension) = (sum of VK_Scores for dimension / maxScore for dimension) * 100
```

Rounded to 1 decimal place. Always in range [0.0, 100.0].

Max scores per Dhatu dimension (hardcoded):

| Dhatu | Vriddhi Max | Kshaya Max (male) | Kshaya Max (non-male) |
|-------|------------|-------------------|----------------------|
| Rasa | 21 | 18 | 18 |
| Rakta | 36 | 12 | 12 |
| Mamsa | 15 | 9 | 9 |
| Meda | 15 | 9 | 9 |
| Asthi | 6 | 12 | 12 |
| Majja | 9 | 9 | 9 |
| Shukra | 6 | 15 | 6* |

*Non-male Shukra Kshaya: 3 male-only questions removed (max 9 pts deducted → 15 − 9 = 6).

### Imbalance Status Threshold

```
percent < 40   → "No Significant Change"
40 ≤ percent < 60   → "Mild"
60 ≤ percent < 80   → "Moderate"
percent ≥ 80   → "Severe"
```

### Balance_Status

```
affectedCount = count of Dhatu dimensions where status ≠ "No Significant Change"

affectedCount = 0     → "Sama Dhatu (Well Balanced)"
1 ≤ affectedCount ≤ 2 → "Mild Imbalance"
3 ≤ affectedCount ≤ 4 → "Moderate Imbalance"
affectedCount ≥ 5     → "Severe Imbalance"
```

Note: `affectedCount` counts individual Vriddhi and Kshaya dimensions independently, so the maximum is 14 (7 Dhatus × 2 dimensions). The spec uses 5–7 affected Dhatus for Severe, but the implementation counts dimensions — up to 14.

### Health_Index

```
Health_Index = (totalSarataScore / 126) * 100
```

Rounded to 1 decimal place. Always in range [0.0, 100.0].

Total Sarata max = Rasa(26) + Rakta(9) + Mamsa(14) + Meda(21) + Asthi(10) + Majja(11) + Shukra(20) + Satva(15) = **126**.

### Health_Index Grade

```
Health_Index ≤ 40   → "Poor"
40 < Health_Index ≤ 60  → "Fair"
60 < Health_Index ≤ 80  → "Good"
Health_Index > 80   → "Excellent"
```

### Top Affected Dhatus (for recommendations)

`ScoreCalculator.getTopAffectedDhatus()` returns at most 3 `AffectedDhatu` records, sorted by severity (Severe > Moderate > Mild) then by descending percent. Each record carries `dhatu`, `type` (Vriddhi/Kshaya), `status`, and `percent`.

---

## Recommendation Lookup Table Structure

The lookup table is a hardcoded Dart constant in `lib/core/constants/recommendations_data.dart`.

### Structure

```dart
class Recommendation {
  final String dhatu;
  final String condition;          // "Vriddhi" | "Kshaya"
  final String pathyaAahar;        // Recommended diet (EN)
  final String pathyaAaharHi;      // Recommended diet (HI)
  final String apathyaAahar;       // Diet to avoid (EN)
  final String apathyaAaharHi;     // Diet to avoid (HI)
  final String pathyaVihara;       // Recommended lifestyle (EN)
  final String pathyaViharaHi;     // Recommended lifestyle (HI)
  final String apathyaVihara;      // Lifestyle to avoid (EN)
  final String apathyaViharaHi;    // Lifestyle to avoid (HI)
  final String aushadha;           // Ayurvedic medicine (EN)
  final String aushadhaHi;         // Ayurvedic medicine (HI)
}

// Top-level constant — 14 entries total
const List<Recommendation> recommendationTable = [ ... ];
```

### Lookup API

```dart
// lib/core/constants/recommendations_data.dart

Recommendation? getRecommendation(String dhatu, String condition) {
  return recommendationTable.firstWhereOrNull(
    (r) => r.dhatu == dhatu && r.condition == condition,
  );
}
```

The Recommendations screen calls `getRecommendation(dhatu, 'Vriddhi')` and/or `getRecommendation(dhatu, 'Kshaya')` for each affected Dhatu returned by `ScoreCalculator.getTopAffectedDhatus()`.

### Table Keys (14 entries)

| # | Dhatu | Condition |
|---|-------|-----------|
| 1 | Rasa | Vriddhi |
| 2 | Rasa | Kshaya |
| 3 | Rakta | Vriddhi |
| 4 | Rakta | Kshaya |
| 5 | Mamsa | Vriddhi |
| 6 | Mamsa | Kshaya |
| 7 | Meda | Vriddhi |
| 8 | Meda | Kshaya |
| 9 | Asthi | Vriddhi |
| 10 | Asthi | Kshaya |
| 11 | Majja | Vriddhi |
| 12 | Majja | Kshaya |
| 13 | Shukra | Vriddhi |
| 14 | Shukra | Kshaya |

---

## Local Persistence Strategy

All persistence goes through `LocalStorageService`, which wraps `SharedPreferences`. The service is initialised once in `main.dart` before `runApp()`.

### SharedPreferences Key Schema

| Key | Type | Description |
|-----|------|-------------|
| `isLoggedIn` | `bool` | True while JWT is active |
| `authToken` | `String` | JWT bearer token |
| `userId` | `String` | Backend user UUID |
| `userData` | `String` (JSON) | Serialised `UserModel.toJson()` |
| `vkAnswers` | `String` (JSON) | Section 1 progress (see below) |
| `sarataAnswers` | `String` (JSON) | Section 2 progress (see below) |

### Section 1 JSON Schema (`vkAnswers`)

```json
{
  "currentDhatuIndex": 3,
  "currentSubsection": "kshaya",
  "answers": {
    "Rasa": {
      "vriddhi": { "Excessive Salivation": 1, "Loss of Appetite": 2 },
      "kshaya":  { "Dryness": 0 }
    },
    "Rakta": { "vriddhi": {}, "kshaya": {} }
  }
}
```

- `currentDhatuIndex`: 0-based index into the ordered Dhatu list
- `currentSubsection`: `"vriddhi"` or `"kshaya"`
- `answers`: map of dhatu name → `DhatuVKAnswers.toJson()` (only answered Dhatus need to be present)

### Section 2 JSON Schema (`sarataAnswers`)

```json
{
  "currentSarataIndex": 2,
  "selections": {
    "Rasa": {
      "Oily skin": true,
      "Smooth skin": false,
      "Never ill (4 pts)": true
    },
    "Rakta": {}
  }
}
```

- `currentSarataIndex`: 0-based index into the 8 Sara categories
- `selections`: map of dhatu → item text → boolean

### Persistence Lifecycle

1. **Answer recorded** → `AssessmentProvider` updates in-memory state → immediately calls `LocalStorageService.saveVKAnswers()` or `saveSarataAnswers()`.
2. **App relaunched** → `AssessmentProvider.restoreFromCache()` reads both keys on first access, restores state, flags which sections are in-progress.
3. **Assessment submitted** → `LocalStorageService.clearAssessmentProgress()` removes `vkAnswers` and `sarataAnswers`.
4. **Logout** → `LocalStorageService.logout()` removes auth keys and assessment progress (full wipe except device preferences).

---

## Key Flutter Packages

| Package | Version | Role |
|---------|---------|------|
| `provider` | ^6.1.1 | State management — `ChangeNotifier` / `MultiProvider` / `Consumer` |
| `firebase_core` | ^2.27.0 | Firebase SDK initialisation |
| `firebase_auth` | ^4.17.0 | Phone OTP: `verifyPhoneNumber`, `signInWithCredential` |
| `dio` | ^5.4.0 | HTTP client with interceptors for JWT attachment and 401 handling |
| `shared_preferences` | ^2.2.2 | Local key-value storage for JWT, user data, assessment progress |
| `google_fonts` | ^6.1.0 | Poppins (headlines) and Lato (body) font loading |
| `pinput` | ^3.0.1 | Styled 6-digit OTP input widget |
| `fl_chart` | ^0.66.2 | Bar charts for VK_Percent visualisation on Result screen |
| `shimmer` | ^3.0.0 | Loading placeholders on Dashboard and Result screens |
| `lottie` | ^3.0.0 | Splash screen and transition animations |
| `fluttertoast` | ^8.2.4 | Toast notifications for errors and success messages |
| `intl` | ^0.18.1 | Date formatting (DOB display, assessment date) |
| `connectivity_plus` | ^5.0.2 | Network connectivity check before API calls |
| `flutter_svg` | ^2.0.9 | SVG asset rendering if logo is in SVG format |

**Note on `http` vs `dio`:** The existing `api_service.dart` uses `http`, but `pubspec.yaml` also declares `dio`. The design calls for migrating `ApiService` fully to `dio` to leverage interceptors for JWT attachment and unified 401 handling. The `http` package can be removed once the migration is complete.

**NotoSansDevanagari** is bundled as a local font (not via `google_fonts`) because it requires correct `.ttf` loading for Devanagari rendering:

```yaml
fonts:
  - family: NotoSansDevanagari
    fonts:
      - asset: assets/fonts/NotoSansDevanagari-Regular.ttf
      - asset: assets/fonts/NotoSansDevanagari-Bold.ttf
        weight: 700
```

Hindi text widgets use `TextStyle(fontFamily: 'NotoSansDevanagari')` explicitly.

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Phone input validation

*For any* string input to the phone field, the validation function SHALL accept it if and only if it consists of exactly 10 ASCII digit characters (matching `/^\d{10}$/`). Any string shorter, longer, or containing non-digits SHALL be rejected.

**Validates: Requirements 3.1, 3.2, 3.3**

---

### Property 2: BMI computation

*For any* height value `h` in cm where `h > 0` and weight value `w` in kg where `w > 0`, the computed BMI SHALL equal `w / (h / 100)²` rounded to 1 decimal place, and the result SHALL be a positive finite number.

**Validates: Requirements 5.3**

---

### Property 3: VK_Percent computation

*For any* list of VK_Scores (each in `[0, 3]`) and the corresponding dimension max score `maxScore > 0`, the computed `VK_Percent` SHALL equal `(sum(scores) / maxScore) * 100` rounded to 1 decimal place, and the result SHALL always be in the range `[0.0, 100.0]`.

**Validates: Requirements 9.1, 9.2**

---

### Property 4: Imbalance status threshold classification

*For any* `VK_Percent` value `p` in `[0.0, 100.0]`, the assigned imbalance status SHALL satisfy:
- `p < 40.0` → `"No Significant Change"`
- `40.0 ≤ p < 60.0` → `"Mild"`
- `60.0 ≤ p < 80.0` → `"Moderate"`
- `p ≥ 80.0` → `"Severe"`

Every possible value in `[0, 100]` SHALL map to exactly one status (no gaps or overlaps).

**Validates: Requirements 9.3**

---

### Property 5: Balance_Status classification

*For any* non-negative integer `affectedCount` representing the number of Dhatu dimensions outside "No Significant Change", the assigned `Balance_Status` SHALL satisfy:
- `affectedCount = 0` → `"Sama Dhatu (Well Balanced)"`
- `1 ≤ affectedCount ≤ 2` → `"Mild Imbalance"`
- `3 ≤ affectedCount ≤ 4` → `"Moderate Imbalance"`
- `affectedCount ≥ 5` → `"Severe Imbalance"`

**Validates: Requirements 9.4, 9.5**

---

### Property 6: Health_Index computation and grade

*For any* total Sarata score `s` in `[0, 126]`, the computed `Health_Index` SHALL equal `(s / 126) * 100` rounded to 1 decimal place and SHALL be in `[0.0, 100.0]`. The assigned grade SHALL satisfy:
- `Health_Index ≤ 40.0` → `"Poor"`
- `40.0 < Health_Index ≤ 60.0` → `"Fair"`
- `60.0 < Health_Index ≤ 80.0` → `"Good"`
- `Health_Index > 80.0` → `"Excellent"`

**Validates: Requirements 10.7, 10.8**

---

### Property 7: Recommendation table completeness

*For any* `AffectedDhatu` in the list produced by `ScoreCalculator.getTopAffectedDhatus()`, calling `getRecommendation(dhatu, condition)` SHALL return a non-null `Recommendation` object with all five fields (`pathyaAahar`, `apathyaAahar`, `pathyaVihara`, `apathyaVihara`, `aushadha`) containing non-empty strings for every combination of the 7 Dhatu names and the two condition values `"Vriddhi"` and `"Kshaya"`.

**Validates: Requirements 13.1, 13.2, 13.3**

---

### Property 8: Assessment state serialization round-trip

*For any* valid Section 1 progress state (a map of Dhatu names to `DhatuVKAnswers`) and Section 2 progress state (a map of Sara category names to item-selection maps), encoding the state to a JSON string via `jsonEncode` and then decoding it via `jsonDecode` SHALL produce a map structurally and value-equal to the original. No answer values SHALL be lost, mutated, or added during the round-trip.

**Validates: Requirements 15.3, 17.1, 17.2**

---

## Error Handling

### Client-side (Flutter)

| Scenario | Behaviour |
|----------|-----------|
| Firebase OTP send failure | `AuthProvider._state = error`, `errorMessage` shown as toast |
| Incorrect OTP | Inline error on Pinput field; user may re-enter |
| OTP expired | Toast prompting resend; Resend button enabled |
| API 401 | `LocalStorageService.logout()`, clear Providers, navigate to Landing |
| API 4xx (non-401) | Toast with `error.message` from response body |
| Network timeout / no connectivity | `connectivity_plus` check before call; toast "No internet connection" |
| Profile save failure | Toast; stay on PersonalDetails screen |
| Assessment submit failure | Toast; retain SharedPreferences state; show retry option |
| Missing Lottie asset | Graceful fallback to static logo (null-safe asset loading) |

### Server-side (Node.js)

- All route handlers wrapped in try/catch; unhandled exceptions return `500 { message: 'Internal server error' }`.
- Zod schema validation middleware returns `400 { message: '...', errors: [...] }` for invalid payloads.
- JWT middleware returns `401 { message: 'Invalid or expired token' }`.
- `prisma.$connect()` failures on startup terminate the process (let the process manager restart).

### Offline Resilience

The app is fully functional for assessment completion without internet. Network calls are only required for:
1. OTP send/verify (Firebase — must be online)
2. Profile fetch/save
3. Assessment submit

If submit fails, answers remain in SharedPreferences and the user can retry from the Dashboard. A "Pending submission" badge on the Dashboard is recommended but out of scope for this spec phase.

---

## Testing Strategy

### Unit Tests (Dart / `flutter_test`)

Unit tests cover pure functions and example-based screen logic. They should be kept lean — property tests handle the wide input coverage, so unit tests focus on:

- **ScoreCalculator**: specific numeric examples for VK_Percent, Health_Index, Balance_Status, and edge cases (zero scores, max scores, gender-adjusted Shukra).
- **UserModel.calculateBmi**: concrete examples (170 cm / 70 kg → 24.2).
- **LocalStorageService**: save/read/clear flow using a fake `SharedPreferences` instance.
- **ApiService**: mocked Dio responses for each endpoint (success, 401, 500, timeout).
- **AuthProvider**: state transitions on sendOtp / verifyOtp using mocked `AuthService`.
- **Widget tests**: SplashScreen routing, LandingScreen button navigation, OTP countdown timer enable/disable.

### Property-Based Tests (Dart `dart_test` + `dart_check` or `fast_check`)

Use the [`dart_check`](https://pub.dev/packages/dart_check) package (or `dart_quickcheck`). Each property test runs a minimum of **100 iterations**.

Tag format per test: `// Feature: dhatu-scan-app, Property N: <property text>`

| Test | Property | Generator |
|------|----------|-----------|
| `phoneValidation_acceptsOnlyTenDigits` | P1 | Arbitrary strings (alphanumeric, shorter/longer, special chars) |
| `bmiComputation_isCorrectForAnyPositiveInput` | P2 | `(h: double 1–300, w: double 1–300)` |
| `vkPercent_alwaysInRangeAndCorrectFormula` | P3 | `(scores: List<int 0–3>, max: int 1–36)` |
| `imbalanceStatus_coverageNoBlanks` | P4 | `double 0–100` |
| `balanceStatus_correctForAnyCount` | P5 | `int 0–14` |
| `healthIndexAndGrade_correctForAnyScore` | P6 | `double 0–126` |
| `recommendationTable_completeForAllDhatuConditions` | P7 | Enumerated — all 14 (dhatu, condition) pairs |
| `assessmentState_jsonRoundTrip` | P8 | Arbitrary VK answer maps and Sarata selection maps |

### Integration Tests

- Full OTP → profile → assessment → result flow using Firebase Emulator Suite and a test PostgreSQL database.
- JWT 401 redirect test: mock backend returning 401, verify Flutter navigates to Landing and clears state.
- Assessment submit retry: mock backend returning 500 on first call, 200 on second, verify SharedPreferences cleared only on success.

### Test Execution

```bash
# Unit + property tests
flutter test --coverage

# Integration tests (requires emulators)
flutter test integration_test/
```

Minimum requirement: unit and property tests pass with 0 failures before any PR merge.
