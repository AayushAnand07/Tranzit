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

  }
};
