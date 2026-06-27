-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "firebaseUid" TEXT,
    "phone" TEXT NOT NULL,
    "name" TEXT,
    "dateOfBirth" TIMESTAMP(3),
    "age" INTEGER,
    "gender" TEXT,
    "address" TEXT,
    "height" DOUBLE PRECISION,
    "weight" DOUBLE PRECISION,
    "bmi" DOUBLE PRECISION,
    "bp" TEXT,
    "pulseRate" INTEGER,
    "medicalHistory" TEXT,
    "occupation" TEXT,
    "physicalActivity" TEXT,
    "sleepDuration" TEXT,
    "appetitePattern" TEXT,
    "waterIntake" TEXT,
    "isProfileComplete" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "assessments" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "assessmentDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "vkResults" JSONB NOT NULL,
    "sarataResult" JSONB NOT NULL,
    "healthIndex" DOUBLE PRECISION NOT NULL,
    "healthGrade" TEXT NOT NULL,
    "balanceStatus" TEXT NOT NULL,
    "dominantSara" TEXT NOT NULL,
    "secondarySara" TEXT NOT NULL,
    "weakestSara" TEXT NOT NULL,
    "predominantKshaya" TEXT NOT NULL,
    "predominantVriddhi" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "assessments_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_firebaseUid_key" ON "users"("firebaseUid");

-- CreateIndex
CREATE UNIQUE INDEX "users_phone_key" ON "users"("phone");

-- CreateIndex
CREATE INDEX "assessments_userId_idx" ON "assessments"("userId");

-- AddForeignKey
ALTER TABLE "assessments" ADD CONSTRAINT "assessments_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
