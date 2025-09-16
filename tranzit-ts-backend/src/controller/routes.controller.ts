import { Router, Request, Response } from "express";
import { Prisma, PrismaClient } from "../generated/prisma";
import { withAccelerate } from '@prisma/extension-accelerate'

const router = Router();
const prisma = new PrismaClient().$extends(withAccelerate())

const formatInputString = (str: string) => {
    let lowercasedString = str.toLowerCase();
    let cleanedString = lowercasedString.replace(/[^a-z0-9]/g, '');
    return cleanedString;
}

router.get("/search", async (req, res) => {
  const { from, to } = req.query;
  const  formattedFrom = formatInputString(from as string);
  const  formattedTo = formatInputString(to as string);

  if (!formattedFrom || !formattedTo || typeof from !== "string" || typeof formattedTo !== "string") {
    return res.status(400).json({ error: "from and to query parameters are required" });
  }

  try {
    const fromStop = await prisma.stop.findUnique({ where: { name: formattedFrom } });
    const toStop   = await prisma.stop.findUnique({ where: { name: formattedTo } });

    if (!fromStop || !toStop) {
      return res.status(404).json({ error: "One or both stops not found" });
    }

    const routes = await prisma.route.findMany({
      include: {
        routeStops: true,
        vehicles: true,
      },
    });
    const results = [];

    for (const route of routes) {
      for (const vehicle of route.vehicles) {
        const fromOrder = route.routeStops.find(rs => rs.stopId === fromStop.id)?.order;
        const toOrder   = route.routeStops.find(rs => rs.stopId === toStop.id)?.order;


        if (!fromOrder || !toOrder) continue;

        if (
          (vehicle.direction === "FORWARD" && fromOrder < toOrder) ||
          (vehicle.direction === "REVERSE" && fromOrder > toOrder)
        ) {
          results.push({
            route: {
              id: route.id,
              name: route.name,
              transport: route.transport,
            },
            vehicle: {
              id: vehicle.id,
              vehicleId: vehicle.vehicleId,
              departure: vehicle.departure,
              arrival: vehicle.arrival,
              price: vehicle.price,
              direction: vehicle.direction,
            },
            fromStop: fromStop.name,
            toStop: toStop.name,
          });
        }
      }
    }

    return res.json({ results });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Internal server error" });
  }
});

export default router
