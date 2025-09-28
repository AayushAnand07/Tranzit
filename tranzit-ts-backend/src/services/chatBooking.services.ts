// searchService.ts
import { PrismaClient, TransportType } from "../generated/prisma";
import { VertexAI, HarmCategory, HarmBlockThreshold } from "@google-cloud/vertexai";
import { findSimilarStops} from "../utils/similarity-stops";
import { routeService } from "./route.services";
import * as ticketService from "../services/ticket.services";
import { NotificationService } from "./notification.services";
const prisma = new PrismaClient();

const project = process.env.GOOGLE_CLOUD_PROJECT || "";
const location = process.env.GOOGLE_CLOUD_LOCATION || "us-central1";
const model = "gemini-2.5-flash";

const vertexAI = new VertexAI({ project, location });
const generativeModel = vertexAI.getGenerativeModel({
    model,
    safetySettings: [
        {
            category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
            threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        },
    ],
    generationConfig: {
        maxOutputTokens: 150,
        temperature: 0.2,
    },
});

export class StopBookingViaSpeechService {
  async initiateSearchandBookingStops(message: string,uid:string,token:string) {
    if (!message) {
      throw new Error("Message is required");
    }
    
    const chat = generativeModel.startChat();
    const result = await chat.sendMessage(
        `You are a travel assistant. From the user's message, extract:
        1. From stop
        2. To stop
        3. Transport type (bus or metro)
        4. Passenger count

        Use format: From -> To | Transport: <type> | Passengers: <count>

        User message: ${message}`
);
    const content = result.response?.candidates?.[0]?.content;

    let textReply = "";
    if (content) {
      if (Array.isArray(content)) {
        textReply = content.map((c: any) => (c.parts ? c.parts.map((p: any) => p.text).join(" ") : c.text)).join(" ");
      } else if (content.parts) {
        textReply = content.parts.map((p: any) => p.text).join(" ");
      }
    }
     console.log(textReply)

     const match = textReply.match(/(.+?)\s*->\s*(.+?)\s*\|\s*Transport:\s*(\w+)(?:\s*\|\s*Passengers:\s*(\d+))?/i);

    if (!match) {
      return { reply: "Sorry, I couldn't identify the stops." };
    }
   

    const fromStopName = match[1];
    const toStopName = match[2];
    const transportType = this.parseTransportType(match[3].toLowerCase());
    const passengers: string = match[4] ? String(match[4]) : "1";

    

    try {
     
            const fromStops = await findSimilarStops(fromStopName, 3);
            const toStops = await findSimilarStops(toStopName, 3);

            if (fromStops.length === 0 || toStops.length === 0) {
            throw new Error("No similar stops found using embeddings");
            }
            console.log(fromStops)
            console.log(toStops)
            const nextVehicle = await routeService.getNextAvailableVehicle(fromStops[0].stop.name,toStops[0].stop.name,transportType!,passengers)
            if(nextVehicle ==null){
              if (token) {
            try {
                await NotificationService.sendPushNotification(token,"No Ride Found","No ride available to book right now");
                
                console.log("Push notification sent successfully!");
                } catch (notificationError) {
                console.error("Failed to send push notification:", notificationError);
                
                }
            } else {
                console.warn("No FCM token provided, skipping push notification");
            }
            }
            const bookingPayload = {
                    userId: uid,                         
                    vehicleId: nextVehicle.vehicle.id, 
                    fromStopId: fromStops[0].stop.id,  
                    toStopId: toStops[0].stop.id,      
                    passengers: parseInt(passengers,10),                     
                    journeyDate: new Date(nextVehicle.vehicle.departure), 
                    price: nextVehicle.vehicle.price
        };

        const ticket = await ticketService.bookTicket(bookingPayload);
        console.log("Ticket booked successfully:", ticket);
        if (token) {
            try {
                await NotificationService.sendBookingConfirmation(token, {
                    ticketId: ticket.ticket.id.toString(),
                    origin: fromStops[0].stop.name,
                    to: toStops[0].stop.name,
                    departureTime: nextVehicle.vehicle.departure,
                    price: nextVehicle.vehicle.price,
                    passengers: parseInt(passengers, 10),
                    transport: transportType!.toUpperCase(),
                });
                
                console.log("Push notification sent successfully!");
                } catch (notificationError) {
                console.error("Failed to send push notification:", notificationError);
                
                }
            } else {
                console.warn("No FCM token provided, skipping push notification");
            }
            return {
            from: {
                stop: fromStops[0].stop,
                similarity: fromStops[0].similarity,
                alternatives: fromStops.slice(1),
            },
            to: {
                stop: toStops[0].stop,
                similarity: toStops[0].similarity,
                alternatives: toStops.slice(1),
            },
            message: `Found route from ${fromStops[0].stop.name} to ${toStops[0].stop.name}`,
            };
    } catch {
            console.log("booking failed")
    }
  }

parseTransportType(text: string): TransportType | null {
  const t = text.toLowerCase();
  if (t === "metro") return TransportType.METRO;
  if (t === "bus" || t === "pmpml") return TransportType.PMPML;
  return null;
}
}
