import { PrismaClient } from "../generated/prisma";

const prisma = new PrismaClient();


function addMinutesToDate(date: Date, minsToAdd: number): Date {
  const newDate = new Date(date);
  newDate.setUTCMinutes(newDate.getUTCMinutes() + minsToAdd);
  return newDate;
}


function generateUTCTimes(startHour: number, endHour: number, intervalMins: number): Date[] {
  const times = [];
  
  for (let h = startHour; h <= endHour; h++) {
    for (let m = 0; m < 60; m += intervalMins) {
      if (h === endHour && m > 0) break;
      
    
      const utcTime = new Date();
      utcTime.setUTCFullYear(2024, 0, 1); 
      utcTime.setUTCHours(h, m, 0, 0);
      
      times.push(utcTime);
    }
  }
  return times;
}

async function main() {
  console.log("Starting seed process with UTC times...");
  
 
  console.log("Creating PMPML bus route...");
  const busRoute = await prisma.route.create({
    data: { name: "Swargate-Hinjewadi", transport: "PMPML" },
  });

  const busStops = [
    "Swargate", "Deccan", "Shivajinagar", "Pune University", "Aundh",
    "Baner", "Balewadi", "Wakad", "Hinjewadi",
  ];

  console.log("Creating bus stops...");
  for (let i = 0; i < busStops.length; i++) {
    let stop = await prisma.stop.findUnique({ where: { name: busStops[i] } });
    if (!stop) {
      stop = await prisma.stop.create({ data: { name: busStops[i] } });
    }
    await prisma.routeStop.create({
      data: { routeId: busRoute.id, stopId: stop.id, order: i + 1 },
    });
  }


  const busTimesForward = generateUTCTimes(1, 17, 30);
  const busTimesReverse = generateUTCTimes(1, 17, 30);

  console.log(`Creating ${busTimesForward.length} forward bus vehicles...`);
  for (let i = 0; i < busTimesForward.length; i++) {
    const departureUTC = busTimesForward[i];
    const arrivalUTC = addMinutesToDate(departureUTC, 90);
    
    await prisma.vehicle.create({
      data: {
        vehicleId: `PMPML-FWD-${String(i + 1).padStart(3, "0")}`,
        routeId: busRoute.id,
        departure: departureUTC,
        arrival: arrivalUTC,
        price: 25,
        direction: "FORWARD",
      },
    });
  }

  console.log(`Creating ${busTimesReverse.length} reverse bus vehicles...`);
  for (let i = 0; i < busTimesReverse.length; i++) {
    const departureUTC = busTimesReverse[i];
    const arrivalUTC = addMinutesToDate(departureUTC, 90); // 90 minutes journey
    
    await prisma.vehicle.create({
      data: {
        vehicleId: `PMPML-REV-${String(i + 1).padStart(3, "0")}`,
        routeId: busRoute.id,
        departure: departureUTC,
        arrival: arrivalUTC,
        price: 25,
        direction: "REVERSE",
      },
    });
  }


  console.log("Creating Metro route...");
  const metroRoute = await prisma.route.create({
    data: { name: "Pune Metro Aqua Line", transport: "METRO" },
  });

  const metroStops = [
    "PCMC", "Sant Tukaram Nagar", "Bhosari", "Kasarwadi", "Phugewadi", "Dapodi",
    "Bopodi", "Range Hill", "Shivajinagar", "Civil Court", "Mandai", "Swargate"
  ];

  console.log("Creating metro stops...");
  for (let i = 0; i < metroStops.length; i++) {
    let stop = await prisma.stop.findUnique({ where: { name: metroStops[i] } });
    if (!stop) {
      stop = await prisma.stop.create({ data: { name: metroStops[i] } });
    }
    await prisma.routeStop.create({
      data: { routeId: metroRoute.id, stopId: stop.id, order: i + 1 },
    });
  }

  const metroTimesForward = generateUTCTimes(1, 17, 30);
  const metroTimesReverse = generateUTCTimes(1, 17, 30);

  console.log(`Creating ${metroTimesForward.length} forward metro vehicles...`);
  for (let i = 0; i < metroTimesForward.length; i++) {
    const departureUTC = metroTimesForward[i];
    const arrivalUTC = addMinutesToDate(departureUTC, 40); // 40 minutes journey
    
    await prisma.vehicle.create({
      data: {
        vehicleId: `METRO-AQ-FWD-${String(i + 1).padStart(3, "0")}`,
        routeId: metroRoute.id,
        departure: departureUTC,
        arrival: arrivalUTC,
        price: 40,
        direction: "FORWARD",
      },
    });
  }

  console.log(`Creating ${metroTimesReverse.length} reverse metro vehicles...`);
  for (let i = 0; i < metroTimesReverse.length; i++) {
    const departureUTC = metroTimesReverse[i];
    const arrivalUTC = addMinutesToDate(departureUTC, 40); // 40 minutes journey
    
    await prisma.vehicle.create({
      data: {
        vehicleId: `METRO-AQ-REV-${String(i + 1).padStart(3, "0")}`,
        routeId: metroRoute.id,
        departure: departureUTC,
        arrival: arrivalUTC,
        price: 40,
        direction: "REVERSE",
      },
    });
  }


}

main()
  .then(async () => {
    console.log("Seed process completed successfully.");
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error("Error during seed process:", e);
    await prisma.$disconnect();
    process.exit(1);
  });