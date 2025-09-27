import { Router, Request, Response } from "express";
import { PrismaClient } from "../generated/prisma";
import { VertexAI, HarmCategory, HarmBlockThreshold } from "@google-cloud/vertexai";

const router = Router();
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

const normalizeName = (name: string) => name.toLowerCase().replace(/[^a-z0-9]/g, '');

router.post("/", async (req: Request, res: Response) => {
    console.log('Chat request received');
    const { userId, message } = req.body;
    if (!userId || !message) return res.status(400).json({ error: "userId and message are required" });

    try {
        const stops = await prisma.stop.findMany({ select: { id: true, name: true } });

        const chat = generativeModel.startChat();
        await chat.sendMessage(
            "You are a travel assistant. Extract from/to stops from the user's message. Use format: From -> To."
        );

        const result = await chat.sendMessage(message);
        const content = result.response?.candidates?.[0]?.content;
        let textReply = "";
        if (content) {
            if (Array.isArray(content)) {
                textReply = content.map((c: any) => (c.parts ? c.parts.map((p: any) => p.text).join(" ") : c.text)).join(" ");
            } else if (content.parts) {
                textReply = content.parts.map((p: any) => p.text).join(" ");
            }
        }


        const match = textReply.match(/(\w+)\s*->\s*(\w+)/);
        if (!match) return res.json({ reply: "Sorry, I couldn't identify the stops." });

        const fromStopName = normalizeName(match[1]);
        const toStopName = normalizeName(match[2]);

        const fromStop = await prisma.stop.findFirst({ where: { name: fromStopName } });
        const toStop = await prisma.stop.findFirst({ where: { name: toStopName } });

        if (!fromStop || !toStop) return res.json({ reply: `Stops not recognized: ${match[1]}, ${match[2]}` });

        const routes = await prisma.route.findMany({ include: { routeStops: true, vehicles: true } });
        let selectedVehicle = null;

        for (const route of routes) {
            const fromOrder = route.routeStops.find(rs => rs.stopId === fromStop.id)?.order;
            const toOrder = route.routeStops.find(rs => rs.stopId === toStop.id)?.order;
            if (!fromOrder || !toOrder) continue;

            selectedVehicle = route.vehicles.find(v =>
                (v.direction === "FORWARD" && fromOrder < toOrder) ||
                (v.direction === "REVERSE" && fromOrder > toOrder)
            );

            if (selectedVehicle) break;
        }

        if (!selectedVehicle) return res.json({ reply: `No vehicles available from ${fromStopName} to ${toStopName}.` });

        const ticket = await prisma.ticket.create({
            data: {
                userId,
                vehicleId: selectedVehicle.id,
                fromStopId: fromStop.id,
                toStopId: toStop.id,
                qrCode: `qr-${Date.now()}`
            },
            include: { vehicle: true, fromStop: true, toStop: true }
        });

        const replyMessage = `Ticket booked successfully!\nRoute: ${selectedVehicle.routeId}\nVehicle: ${selectedVehicle.vehicleId}\nPrice: ${selectedVehicle.price}\nFrom: ${fromStop.name}\nTo: ${toStop.name}`;

        res.json({ reply: replyMessage, ticket });

    } catch (err) {
        console.log(err);
        console.error(err);
        res.status(500).json({ error: "Booking failed" });
    }
});
router.get("",  (req: Request, res: Response) => {
    res.send("Hello from chat controller");
});
router.post("/search", async (req: Request, res: Response) => {
    const { userId, message } = req.body;
    if (!userId || !message) return res.status(400).json({ error: "userId and message are required" });

    try {
        const stops = await prisma.stop.findMany({ select: { id: true, name: true } });

        const chat = generativeModel.startChat();

        const result = await chat.sendMessage("You are a travel assistant. Extract from/to stops from the user's message. Use format: From -> To." + message);
        const content = result.response?.candidates?.[0]?.content;
        let textReply = "";
        if (content) {
            if (Array.isArray(content)) {
                textReply = content.map((c: any) => (c.parts ? c.parts.map((p: any) => p.text).join(" ") : c.text)).join(" ");
            } else if (content.parts) {
                textReply = content.parts.map((p: any) => p.text).join(" ");
            }
        }


        const match = textReply.match(/(\w+)\s*->\s*(\w+)/);
        if (!match) return res.json({ reply: "Sorry, I couldn't identify the stops." });

        const fromStopName = normalizeName(match[1]);
        const toStopName = normalizeName(match[2]);

        const fromStop = await prisma.stop.findFirst({ where: { name: fromStopName } });
        const toStop = await prisma.stop.findFirst({ where: { name: toStopName } });

        if (!fromStop || !toStop) return res.json({ reply: `Stops not recognized: ${match[1]}, ${match[2]}` });

        const routes = await prisma.route.findMany({ include: { routeStops: true, vehicles: true } });
        res.json({ reply: "Here are the available routes:", routes });

    } catch (err) {
        console.log('Hello');
        console.error(err);
        res.status(500).json({ error: err});
    }
});

export default router;
