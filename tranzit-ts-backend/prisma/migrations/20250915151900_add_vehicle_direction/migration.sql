-- CreateEnum
CREATE TYPE "public"."RouteDirection" AS ENUM ('FORWARD', 'REVERSE');

-- AlterTable
ALTER TABLE "public"."Vehicle" ADD COLUMN     "direction" "public"."RouteDirection" NOT NULL DEFAULT 'FORWARD';
