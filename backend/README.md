# DhatuScan Backend

Node.js + Express + Prisma REST API for the DhatuScan Ayurvedic health-assessment app.

## Stack

| Layer | Technology |
|-------|-----------|
| Runtime | Node.js 18+ (ESM) |
| Framework | Express 4 |
| ORM | Prisma 5 |
| Database | PostgreSQL 15 |
| Auth | Firebase Admin SDK + `jsonwebtoken` |
| Validation | `zod` |
| Testing | Jest + supertest |

## Project Structure

```
backend/
├── src/
│   ├── app.js               # Express app factory (no server binding)
│   ├── server.js            # HTTP server entry point
│   ├── config/
│   │   ├── database.js      # Prisma client singleton
│   │   └── firebase.js      # Firebase Admin SDK init
│   ├── middleware/
│   │   ├── auth.js          # verifyJWT middleware
│   │   └── validate.js      # Zod validation middleware factory
│   ├── routes/
│   │   ├── auth.routes.js
│   │   ├── user.routes.js
│   │   └── assessment.routes.js
│   ├── controllers/
│   │   ├── auth.controller.js
│   │   ├── user.controller.js
│   │   └── assessment.controller.js
│   └── utils/
│       └── jwt.js           # signToken / verifyToken
├── prisma/
│   └── schema.prisma
├── tests/
│   ├── helpers/
│   │   ├── db.js            # Prisma mock factory
│   │   └── fixtures.js      # Test data
│   ├── auth.test.js
│   ├── user.test.js
│   ├── assessment.test.js
│   ├── middleware.test.js
│   └── health.test.js
├── .env.example
└── package.json
```

## API Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/health` | No | Health check |
| POST | `/api/auth/check-user` | No | Upsert user by phone, return JWT |
| POST | `/api/user/profile` | Bearer | Create/update user profile |
| GET | `/api/user/profile/:id` | Bearer | Fetch user profile by UUID |
| POST | `/api/assessment/submit` | Bearer | Save completed assessment |
| GET | `/api/assessment/history/:userId` | Bearer | List past assessments |
| GET | `/api/assessment/:id` | Bearer | Fetch single assessment |

## Setup

### 1. Prerequisites

- Node.js 18+
- PostgreSQL 15 running locally
- Firebase project with Phone Auth enabled

### 2. Environment

```bash
cp .env.example .env
# Edit .env with your DATABASE_URL, JWT_SECRET, and Firebase credentials
```

### 3. Install dependencies

```bash
npm install
```

### 4. Database setup

```bash
# Generate Prisma client
npm run db:generate

# Run migrations (creates tables)
npm run db:migrate

# (Optional) Open Prisma Studio
npm run db:studio
```

### 5. Firebase service account

Download your Firebase service account JSON from:
**Firebase Console → Project Settings → Service Accounts → Generate new private key**

Save it as `firebase-service-account.json` in the `backend/` directory and set:
```
GOOGLE_APPLICATION_CREDENTIALS=./firebase-service-account.json
```

## Running

```bash
# Development (with file watcher)
npm run dev

# Production
npm start
```

## Testing

Tests use Jest + supertest with **Prisma fully mocked** — no database required.

```bash
# Run all tests
npm test

# With coverage
npm run test:coverage
```

All tests should pass with 0 database connections.

## Error Responses

| Status | Condition |
|--------|-----------|
| 400 | Zod validation failure — body includes `errors` array |
| 401 | Missing/invalid/expired JWT Bearer token |
| 404 | Resource not found |
| 500 | Unexpected server error |
