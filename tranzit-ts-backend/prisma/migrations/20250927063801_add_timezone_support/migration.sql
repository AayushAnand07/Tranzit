/*
  Warnings:

  - A unique constraint covering the columns `[routeId,stopId]` on the table `RouteStop` will be added. If there are existing duplicate values, this will fail.

*/
-- AlterTable
ALTER TABLE "public"."Ticket" ALTER COLUMN "createdAt" SET DATA TYPE TIMESTAMPTZ,
ALTER COLUMN "journeyDate" SET DATA TYPE TIMESTAMPTZ;

-- AlterTable
ALTER TABLE "public"."User" ALTER COLUMN "createdAt" SET DATA TYPE TIMESTAMPTZ,
ALTER COLUMN "updatedAt" SET DATA TYPE TIMESTAMPTZ;

-- AlterTable
ALTER TABLE "public"."Vehicle" ALTER COLUMN "departure" SET DATA TYPE TIMESTAMPTZ,
ALTER COLUMN "arrival" SET DATA TYPE TIMESTAMPTZ;

-- CreateIndex
CREATE UNIQUE INDEX "RouteStop_routeId_stopId_key" ON "public"."RouteStop"("routeId", "stopId");
