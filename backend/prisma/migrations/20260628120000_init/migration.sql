-- DhatuScan — Initial schema migration
-- Generated from prisma/schema.prisma
-- Drops existing tables first (safe on fresh Render PostgreSQL DB)

-- Drop tables if they exist from previous broken migrations
DROP TABLE IF EXISTS "assessments" CASCADE;
DROP TABLE IF EXISTS "users" CASCADE;

-- CreateTable: users
CREATE TABLE "users" (
    "id"               TEXT        NOT NULL,
    "email"            TEXT        NOT NULL,
    "googleId"         TEXT,
    "phone"            TEXT,
    "name"             TEXT,
    "dateOfBirth"      TIMESTAMP(3),
    "age"              INTEGER,
    "gender"           TEXT,
    "address"          TEXT,
    "height"           DOUBLE PRECISION,
    "weight"           DOUBLE PRECISION,
    "bmi"              DOUBLE PRECISION,
    "bp"               TEXT,
    "pulseRate"        INTEGER,
    "medicalHistory"   TEXT,
    "occupation"       TEXT,
    "physicalActivity" TEXT,
    "sleepDuration"    TEXT,
    "appetitePattern"  TEXT,
    "waterIntake"      TEXT,
    "isProfileComplete" BOOLEAN    NOT NULL DEFAULT false,
    "createdAt"        TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt"        TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable: assessments
CREATE TABLE "assessments" (
    "id"                TEXT        NOT NULL,
    "userId"            TEXT        NOT NULL,
    "assessmentDate"    TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "vkResults"         JSONB       NOT NULL,
    "sarataResult"      JSONB       NOT NULL,
    "healthIndex"       DOUBLE PRECISION NOT NULL,
    "healthGrade"       TEXT        NOT NULL,
    "balanceStatus"     TEXT        NOT NULL,
    "dominantSara"      TEXT        NOT NULL,
    "secondarySara"     TEXT        NOT NULL,
    "weakestSara"       TEXT        NOT NULL,
    "predominantKshaya" TEXT        NOT NULL,
    "predominantVriddhi" TEXT       NOT NULL,
    "createdAt"         TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "assessments_pkey" PRIMARY KEY ("id")
);

-- CreateIndex: unique email
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex: unique googleId
CREATE UNIQUE INDEX "users_googleId_key" ON "users"("googleId");

-- CreateIndex: assessments by userId
CREATE INDEX "assessments_userId_idx" ON "assessments"("userId");

-- AddForeignKey
ALTER TABLE "assessments"
    ADD CONSTRAINT "assessments_userId_fkey"
    FOREIGN KEY ("userId")
    REFERENCES "users"("id")
    ON DELETE CASCADE
    ON UPDATE CASCADE;
