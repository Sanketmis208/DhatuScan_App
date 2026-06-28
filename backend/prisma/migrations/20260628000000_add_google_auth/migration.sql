-- Migration: add Google OAuth fields to users table
-- Adds: email (unique), googleId (unique)
-- Drops: firebaseUid, phone (replaced by email-based auth)

-- Step 1: Add email column (nullable first so existing rows don't fail)
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "email" TEXT;
ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "googleId" TEXT;

-- Step 2: Backfill email from phone for any existing rows so NOT NULL works
UPDATE "users" SET "email" = CONCAT("phone", '@placeholder.dhatuscan.com') WHERE "email" IS NULL;

-- Step 3: Make email NOT NULL and add unique constraint
ALTER TABLE "users" ALTER COLUMN "email" SET NOT NULL;

-- Step 4: Add unique indexes (IF NOT EXISTS to be safe)
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes WHERE tablename='users' AND indexname='users_email_key'
  ) THEN
    CREATE UNIQUE INDEX "users_email_key" ON "users"("email");
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes WHERE tablename='users' AND indexname='users_googleId_key'
  ) THEN
    CREATE UNIQUE INDEX "users_googleId_key" ON "users"("googleId");
  END IF;
END $$;
