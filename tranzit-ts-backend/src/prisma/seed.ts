// src/prisma/seed.ts
import { PrismaClient } from "../generated/prisma";

const prisma = new PrismaClient();

async function main() {
  // ----------------------
  // 1️⃣ Create 570S MTC bus route
  // ----------------------
  const busRoute = await prisma.route.create({
    data: { name: "570s", transport: "MTC" },
  });

  const busStops = [
    "cmbt",
    "mmdacolony",
    "vadapalani",
    "ashoknagar",
    "ekkatuthangal",
    "guindy",
    "velachery",
    "tharamani",
    "srptools",
    "sholinganallur",
    "navalur",
    "sipcot",
    "siruseriitpark",
  ];

  const busStopRecords: Record<string, number> = {};

  for (let i = 0; i < busStops.length; i++) {
    let stop = await prisma.stop.findUnique({ where: { name: busStops[i] } });
    if (!stop) {
      stop = await prisma.stop.create({ data: { name: busStops[i] } });
    }
    busStopRecords[busStops[i]] = stop.id;

    await prisma.routeStop.create({
      data: { routeId: busRoute.id, stopId: stop.id, order: i + 1 },
    });
  }

  // FORWARD bus vehicle
  await prisma.vehicle.create({
    data: {
      vehicleId: "tn01ab1234",
      routeId: busRoute.id,
      departure: new Date("2025-09-15T05:00:00Z"),
      arrival: new Date("2025-09-15T06:30:00Z"),
      price: 30,
      direction: "FORWARD",
    },
  });

  // REVERSE bus vehicle
  await prisma.vehicle.create({
    data: {
      vehicleId: "tn01ab1235",
      routeId: busRoute.id,
      departure: new Date("2025-09-15T07:00:00Z"),
      arrival: new Date("2025-09-15T08:30:00Z"),
      price: 30,
      direction: "REVERSE",
    },
  });

  // ----------------------
  // 2️⃣ Create Metro Route: Central → Airport
  // ----------------------
  const metroRoute = await prisma.route.create({
    data: { name: "metro central-airport", transport: "METRO" },
  });

  const metroStops = [
    "central",
    "egmore",
    "nehrupark",
    "kilpauk",
    "pachaiyappa",
    "shenoynagar",
    "annanagareast",
    "annanagartower",
    "thirumangalam",
    "koyambedu",
    "cmbt",
    "ekkatuthangal",
    "guindy",
    "arignarannaalandur",
    "nanganallurroad",
    "meenambakkam",
    "chennaiinternationalairport",
  ];

  const metroStopRecords: Record<string, number> = {};

  for (let i = 0; i < metroStops.length; i++) {
    let stop = await prisma.stop.findUnique({ where: { name: metroStops[i] } });
    if (!stop) {
      stop = await prisma.stop.create({ data: { name: metroStops[i] } });
    }
    metroStopRecords[metroStops[i]] = stop.id;

    await prisma.routeStop.create({
      data: { routeId: metroRoute.id, stopId: stop.id, order: i + 1 },
    });
  }

  // FORWARD metro vehicle
  await prisma.vehicle.create({
    data: {
      vehicleId: "metro01",
      routeId: metroRoute.id,
      departure: new Date("2025-09-15T06:00:00Z"),
      arrival: new Date("2025-09-15T06:45:00Z"),
      price: 50,
      direction: "FORWARD",
    },
  });

  // REVERSE metro vehicle
  await prisma.vehicle.create({
    data: {
      vehicleId: "metro02",
      routeId: metroRoute.id,
      departure: new Date("2025-09-15T07:00:00Z"),
      arrival: new Date("2025-09-15T07:45:00Z"),
      price: 50,
      direction: "REVERSE",
    },
  });

  console.log(
    "Seed completed: 570S bus + Metro Central-Airport routes with FORWARD/REVERSE vehicles."
  );
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
