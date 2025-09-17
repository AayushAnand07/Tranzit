-- CreateEnum
CREATE TYPE "public"."Role" AS ENUM ('USER', 'ADMIN');

-- CreateEnum
CREATE TYPE "public"."RouteDirection" AS ENUM ('FORWARD', 'REVERSE');

-- CreateEnum
CREATE TYPE "public"."TransportType" AS ENUM ('METRO', 'MTC');

-- CreateEnum
CREATE TYPE "public"."TicketStatus" AS ENUM ('BOOKED', 'CHECKED_IN', 'CHECKED_OUT');

-- CreateTable
CREATE TABLE "public"."User" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "role" "public"."Role" NOT NULL DEFAULT 'USER',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Stop" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "Stop_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Route" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "transport" "public"."TransportType" NOT NULL,

    CONSTRAINT "Route_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."RouteStop" (
    "id" SERIAL NOT NULL,
    "routeId" INTEGER NOT NULL,
    "stopId" INTEGER NOT NULL,
    "order" INTEGER NOT NULL,

    CONSTRAINT "RouteStop_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Vehicle" (
    "id" SERIAL NOT NULL,
    "vehicleId" TEXT NOT NULL,
    "routeId" INTEGER NOT NULL,
    "departure" TIMESTAMP(3) NOT NULL,
    "arrival" TIMESTAMP(3) NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "direction" "public"."RouteDirection" NOT NULL DEFAULT 'FORWARD',

    CONSTRAINT "Vehicle_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Ticket" (
    "id" SERIAL NOT NULL,
    "userId" TEXT NOT NULL,
    "vehicleId" INTEGER NOT NULL,
    "fromStopId" INTEGER NOT NULL,
    "toStopId" INTEGER NOT NULL,
    "status" "public"."TicketStatus" NOT NULL DEFAULT 'BOOKED',
    "qrCode" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Ticket_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Stop_name_key" ON "public"."Stop"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Vehicle_vehicleId_key" ON "public"."Vehicle"("vehicleId");

-- AddForeignKey
ALTER TABLE "public"."RouteStop" ADD CONSTRAINT "RouteStop_routeId_fkey" FOREIGN KEY ("routeId") REFERENCES "public"."Route"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."RouteStop" ADD CONSTRAINT "RouteStop_stopId_fkey" FOREIGN KEY ("stopId") REFERENCES "public"."Stop"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Vehicle" ADD CONSTRAINT "Vehicle_routeId_fkey" FOREIGN KEY ("routeId") REFERENCES "public"."Route"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Ticket" ADD CONSTRAINT "Ticket_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Ticket" ADD CONSTRAINT "Ticket_vehicleId_fkey" FOREIGN KEY ("vehicleId") REFERENCES "public"."Vehicle"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Ticket" ADD CONSTRAINT "Ticket_fromStopId_fkey" FOREIGN KEY ("fromStopId") REFERENCES "public"."Stop"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Ticket" ADD CONSTRAINT "Ticket_toStopId_fkey" FOREIGN KEY ("toStopId") REFERENCES "public"."Stop"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
