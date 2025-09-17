// src/prisma/seed.ts
import { PrismaClient } from "../generated/prisma";

const prisma = new PrismaClient();

async function main() {

// await prisma.$executeRaw`TRUNCATE TABLE "Vehicle" CASCADE`;
// await prisma.$executeRaw`TRUNCATE TABLE "RouteStop" CASCADE`;
// await prisma.$executeRaw`TRUNCATE TABLE "Route" CASCADE`;
// await prisma.$executeRaw`TRUNCATE TABLE "Stop" CASCADE`;

// await prisma.$executeRaw`ALTER SEQUENCE "Route_id_seq" RESTART WITH 1`;
// await prisma.$executeRaw`ALTER SEQUENCE "Stop_id_seq" RESTART WITH 1`;
// await prisma.$executeRaw`ALTER SEQUENCE "Vehicle_id_seq" RESTART WITH 1`;
// await prisma.$executeRaw`ALTER SEQUENCE "RouteStop_id_seq" RESTART WITH 1`;


  // PMPML Bus route Swargate → Hinjewadi

  const busRoute = await prisma.route.create({
    data: { name: "Swargate-Hinjewadi", transport: "MTC" }, // buses = MTC enum
  });

  const busStops = [
    "swargate",
    "deccan",
    "shivajinagar",
    "puneuniversity",
    "aupune",
    "baner",
    "balewadi",
    "wakad",
    "hinjewadi",
  ];

  for (let i = 0; i < busStops.length; i++) {
    let stop = await prisma.stop.findUnique({ where: { name: busStops[i] } });
    if (!stop) {
      stop = await prisma.stop.create({ data: { name: busStops[i] } });
    }

    await prisma.routeStop.create({
      data: { routeId: busRoute.id, stopId: stop.id, order: i + 1 },
    });
  }

  // Multiple buses FORWARD (Swargate → Hinjewadi)
  await prisma.vehicle.createMany({
    data: [
      {
        vehicleId: "pmpml01",
        routeId: busRoute.id,
        departure: new Date("2025-09-15T05:30:00Z"),
        arrival: new Date("2025-09-15T07:00:00Z"),
        price: 25,
        direction: "FORWARD",
      },
      {
        vehicleId: "pmpml03",
        routeId: busRoute.id,
        departure: new Date("2025-09-15T06:30:00Z"),
        arrival: new Date("2025-09-15T08:00:00Z"),
        price: 25,
        direction: "FORWARD",
      },
      {
        vehicleId: "pmpml05",
        routeId: busRoute.id,
        departure: new Date("2025-09-15T07:30:00Z"),
        arrival: new Date("2025-09-15T09:00:00Z"),
        price: 25,
        direction: "FORWARD",
      },
    ],
  });

  // Multiple buses REVERSE (Hinjewadi → Swargate)
  await prisma.vehicle.createMany({
    data: [
      {
        vehicleId: "pmpml02",
        routeId: busRoute.id,
        departure: new Date("2025-09-15T07:00:00Z"),
        arrival: new Date("2025-09-15T08:30:00Z"),
        price: 25,
        direction: "REVERSE",
      },
      {
        vehicleId: "pmpml04",
        routeId: busRoute.id,
        departure: new Date("2025-09-15T08:00:00Z"),
        arrival: new Date("2025-09-15T09:30:00Z"),
        price: 25,
        direction: "REVERSE",
      },
      {
        vehicleId: "pmpml06",
        routeId: busRoute.id,
        departure: new Date("2025-09-15T09:00:00Z"),
        arrival: new Date("2025-09-15T10:30:00Z"),
        price: 25,
        direction: "REVERSE",
      },
    ],
  });

  
  //  Pune Metro Aqua Line Route: PCMC → Swargate

  const metroRoute = await prisma.route.create({
    data: { name: "Pune Metro Aqua Line", transport: "METRO" },
  });

  const metroStops = [
    "pcmc",
    "santtukaramnagar",
    "bhosari",
    "kasarwadi",
    "phugewadi",
    "dapodi",
    "bopodi",
    "rangehill",
    "shivajinagar",
    "civilcourt",
    "mandai",
    "swargate",
  ];

  for (let i = 0; i < metroStops.length; i++) {
    let stop = await prisma.stop.findUnique({ where: { name: metroStops[i] } });
    if (!stop) {
      stop = await prisma.stop.create({ data: { name: metroStops[i] } });
    }

    await prisma.routeStop.create({
      data: { routeId: metroRoute.id, stopId: stop.id, order: i + 1 },
    });
  }

  // Multiple Metro trains FORWARD (PCMC → Swargate)
  await prisma.vehicle.createMany({
    data: [
      {
        vehicleId: "metro_pune01",
        routeId: metroRoute.id,
        departure: new Date("2025-09-15T06:00:00Z"),
        arrival: new Date("2025-09-15T06:40:00Z"),
        price: 40,
        direction: "FORWARD",
      },
      {
        vehicleId: "metro_pune03",
        routeId: metroRoute.id,
        departure: new Date("2025-09-15T06:30:00Z"),
        arrival: new Date("2025-09-15T07:10:00Z"),
        price: 40,
        direction: "FORWARD",
      },
      {
        vehicleId: "metro_pune05",
        routeId: metroRoute.id,
        departure: new Date("2025-09-15T07:00:00Z"),
        arrival: new Date("2025-09-15T07:40:00Z"),
        price: 40,
        direction: "FORWARD",
      },
    ],
  });

  //  Metro trains REVERSE (Swargate → PCMC)
  await prisma.vehicle.createMany({
    data: [
      {
        vehicleId: "metro_pune02",
        routeId: metroRoute.id,
        departure: new Date("2025-09-15T07:30:00Z"),
        arrival: new Date("2025-09-15T08:10:00Z"),
        price: 40,
        direction: "REVERSE",
      },
      {
        vehicleId: "metro_pune04",
        routeId: metroRoute.id,
        departure: new Date("2025-09-15T08:00:00Z"),
        arrival: new Date("2025-09-15T08:40:00Z"),
        price: 40,
        direction: "REVERSE",
      },
      {
        vehicleId: "metro_pune06",
        routeId: metroRoute.id,
        departure: new Date("2025-09-15T08:30:00Z"),
        arrival: new Date("2025-09-15T09:10:00Z"),
        price: 40,
        direction: "REVERSE",
      },
    ],
  });

  console.log(
    "Seed completed: PMPML Swargate-Hinjewadi buses + Pune Metro Aqua Line trains with multiple FORWARD/REVERSE timings."
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
