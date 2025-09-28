/*
  Warnings:

  - Added the required column `price` to the `Ticket` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "public"."Ticket" ADD COLUMN     "price" INTEGER NOT NULL;
