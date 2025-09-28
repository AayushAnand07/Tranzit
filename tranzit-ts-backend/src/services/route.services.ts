import { routeRepository } from "../repository/routes.repository";
import { TransportType } from "../generated/prisma"; 

export const routeService = {


  
  async searchRoutes(
    from: string,
    to: string,
    transportType?: TransportType,
    journeyDate?: Date,
    passengers?: string
  ) {
    const fromStop = await routeRepository.getStopByName(from);
    const toStop = await routeRepository.getStopByName(to);

    if (!fromStop || !toStop) {
      throw new Error("STOP_NOT_FOUND");
    }

    const routes = await routeRepository.getAllRoutesWithStopsAndVehicles();
    const results: any[] = [];
    const nowUTC = new Date();

    console.log("=== SEARCH DEBUG ===");
    console.log("nowUTC:", nowUTC.toISOString());
    console.log("journeyDate:", journeyDate?.toISOString());

    const searchDate = journeyDate || nowUTC;
    
   
    const searchingForToday = !journeyDate || 
      journeyDate.toDateString() === nowUTC.toDateString();
    
    
  

    for (const route of routes) {
      if (transportType && route.transport.toUpperCase() !== transportType.toUpperCase()) {
        continue;
      }

      const fromRouteStop = route.routeStops.find(rs => rs.stopId === fromStop.id);
      const toRouteStop = route.routeStops.find(rs => rs.stopId === toStop.id);
      
      if (!fromRouteStop || !toRouteStop) {
        continue;
      }

      for (const vehicle of route.vehicles) {
        const vehicleDepartureTime = new Date(vehicle.departure);
        const vehicleArrivalTime = new Date(vehicle.arrival);
        
      
       const actualDepartureUTC = new Date(Date.UTC(
          searchDate.getUTCFullYear(),
          searchDate.getUTCMonth(),
          searchDate.getUTCDate(),
          vehicleDepartureTime.getUTCHours(),
          vehicleDepartureTime.getUTCMinutes(),
          vehicleDepartureTime.getUTCSeconds()
        ));

        const actualArrivalUTC = new Date(Date.UTC(
          searchDate.getUTCFullYear(),
          searchDate.getUTCMonth(),
          searchDate.getUTCDate(),
          vehicleArrivalTime.getUTCHours(),
          vehicleArrivalTime.getUTCMinutes(),
          vehicleArrivalTime.getUTCSeconds()
        ));

          if (vehicleArrivalTime.getUTCHours() < vehicleDepartureTime.getUTCHours() ||
            (vehicleArrivalTime.getUTCHours() === vehicleDepartureTime.getUTCHours() && 
             vehicleArrivalTime.getUTCMinutes() < vehicleDepartureTime.getUTCMinutes())) {
        
          actualArrivalUTC.setUTCDate(actualArrivalUTC.getUTCDate() + 1);
        }

      

        if (searchingForToday && actualDepartureUTC <= nowUTC) {
          
          continue;
        }

        
        const direction = vehicle.direction.toUpperCase();
        const isValidDirection = 
          (direction === "FORWARD" && fromRouteStop.order < toRouteStop.order) ||
          (direction === "REVERSE" && fromRouteStop.order > toRouteStop.order);

        if (!isValidDirection) {
          continue;
        }
        
        const cleanPassengers = passengers?.toString().trim();
        
        const passengerCount = cleanPassengers && Number(cleanPassengers) > 0 ? Number(cleanPassengers) : 1;

        const stopsBetween = Math.abs(toRouteStop.order - fromRouteStop.order) - 1;
        const totalPrice = (vehicle.price + (stopsBetween * 2.5)) * passengerCount;
          
       

        results.push({
          route: {
            id: route.id,
            name: route.name,
            transport: route.transport,
          },
          vehicle: {
            id: vehicle.id,
            vehicleId: vehicle.vehicleId,
            departure: actualDepartureUTC.toISOString(),
            arrival: actualArrivalUTC.toISOString(),
            price: totalPrice,
            direction: direction,
          },
          fromStop: fromStop.name,
          toStop: toStop.name,
        });
      }
    }

    results.sort((a, b) => new Date(a.vehicle.departure).getTime() - new Date(b.vehicle.departure).getTime());  
    return results;
  },
 async getNextAvailableVehicle(
    from: string,
    to: string,
    transportType: TransportType,
    passengers?: string
  ) {
    const nowUTC = new Date();
    const passengerCount = passengers && passengers.trim() !== "" ? passengers : "1";
   

    let results = await this.searchRoutes(from, to, transportType, nowUTC, passengerCount);

    if (results.length === 0) {
       nowUTC.setUTCDate(nowUTC.getUTCDate() + 1);
       nowUTC.setUTCHours(5, 0, 0, 0); 
       results =await this.searchRoutes(from, to, transportType, nowUTC, passengerCount);
      //return null;
    }

    return results[0];
  },


  async getRouteStops(routeId: number) {
    const routeStops = await routeRepository.getAllStopsInTheRoute(routeId);
    return routeStops;
  }
};