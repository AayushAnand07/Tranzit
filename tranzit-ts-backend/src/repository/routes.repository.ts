import { withAccelerate } from "@prisma/extension-accelerate";
import { PrismaClient } from "../generated/prisma";

const prisma = new PrismaClient().$extends(withAccelerate())

export const routeRepository = {
  async getStopByName(name: string) {
    return prisma.stop.findUnique({ where: { name } });
  },

  async getAllRoutesWithStopsAndVehicles() {
    return prisma.route.findMany({
      include: {
        routeStops: true,
        vehicles: true,
      },
    });
  },


  async getAllStopsInTheRoute(routeId:number){
   
    return prisma.routeStop.findMany({
    where: { routeId },
    include: { stop: true }, 
    orderBy: { order: "asc" }, 
  });

  },


  async  getStopsBetween(routeId: number, fromStopName: string, toStopName: string) {
  
  const stops = await prisma.routeStop.findMany({
    where: {
      routeId,
      stop: {
        name: { in: [fromStopName, toStopName] }
      }
    },
    include: { stop: true },
  });

  if (stops.length < 2) {
    throw new Error("Both stops must exist on the given route");
  }

  const [fromStop, toStop] = stops.sort((a, b) => a.order - b.order);

  const betweenStops = await prisma.routeStop.findMany({
    where: {
      routeId,
      order: {
        gte: fromStop.order,  
        lte: toStop.order,    
      },
    },
    include: { stop: true },
    orderBy: { order: "asc" },
  });

  return betweenStops.map(rs => rs.stop.name);
},

async  getAllStops() {
  return await prisma.stop.findMany({
    orderBy: { name: "asc" }, 
  });
}

};
