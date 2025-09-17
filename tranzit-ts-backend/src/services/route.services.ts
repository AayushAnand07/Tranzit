import { routeRepository } from "../repository/routes.repository";



export const routeService = {
  async searchRoutes(from: string, to: string) {
    const fromStop = await routeRepository.getStopByName(from);
    const toStop   = await routeRepository.getStopByName(to);

    if (!fromStop || !toStop) {
      throw new Error("STOP_NOT_FOUND");
    }

    const routes = await routeRepository.getAllRoutesWithStopsAndVehicles();
    const results: any[] = [];

    for (const route of routes) {
      for (const vehicle of route.vehicles) {
        const fromOrder = route.routeStops.find(rs => rs.stopId === fromStop.id)?.order;
        const toOrder   = route.routeStops.find(rs => rs.stopId === toStop.id)?.order;

        if (!fromOrder || !toOrder) continue;

        const validForward = vehicle.direction === "FORWARD" && fromOrder < toOrder;
        const validReverse = vehicle.direction === "REVERSE" && fromOrder > toOrder;

        if (validForward || validReverse) {
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

    return results;
  },


  async  getRouteStops(routeId: number) {
  const routeStops = routeRepository.getAllStopsInTheRoute(routeId)

  return routeStops;
}






};
