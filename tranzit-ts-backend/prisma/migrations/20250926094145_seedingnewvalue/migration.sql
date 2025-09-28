/*
  Warnings:

  - Added the required column `journeyDate` to the `Ticket` table without a default value. This is not possible if the table is not empty.
  - Added the required column `passengers` to the `Ticket` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "public"."Ticket" ADD COLUMN     "journeyDate" TIMESTAMP(3) NOT NULL,
ADD COLUMN     "passengers" INTEGER NOT NULL;
