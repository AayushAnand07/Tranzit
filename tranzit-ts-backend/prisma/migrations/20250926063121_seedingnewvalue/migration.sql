/*
  Warnings:

  - The values [MTC] on the enum `TransportType` will be removed. If these variants are still used in the database, this will fail.

*/
-- AlterEnum
BEGIN;
CREATE TYPE "public"."TransportType_new" AS ENUM ('METRO', 'PMPML');
ALTER TABLE "public"."Route" ALTER COLUMN "transport" TYPE "public"."TransportType_new" USING ("transport"::text::"public"."TransportType_new");
ALTER TYPE "public"."TransportType" RENAME TO "TransportType_old";
ALTER TYPE "public"."TransportType_new" RENAME TO "TransportType";
DROP TYPE "public"."TransportType_old";
COMMIT;
