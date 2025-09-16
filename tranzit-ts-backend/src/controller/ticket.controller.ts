import { Router, Request, Response } from "express";
import { Prisma, PrismaClient } from "../generated/prisma";
import { withAccelerate } from '@prisma/extension-accelerate'
import QRCode from "qrcode";

const router = Router();
const prisma = new PrismaClient().$extends(withAccelerate())

router.post('/book', async (req: Request, res: Response) => {
    console.log('Hello');
    try {
        const { vehicleId, fromStopId, toStopId } = req.body;
        const userId = 'dummy-user-123';
        const vehicle = await prisma.vehicle.findUnique({ where: {id: vehicleId } });
        if (!vehicle) {
            return res.status(404).json({ error: "Vehicle not found" });
        }
        const qrPayload = `${userId}-${vehicleId}-${Date.now()}`;
        const qrCode = await QRCode.toDataURL(qrPayload);

        const ticket = await prisma.ticket.create({
            data: {
                userId,
                vehicleId,
                fromStopId,
                toStopId,
                qrCode
            },
            include: { vehicle: true, fromStop: true, toStop: true },
        });
        res.json({ ticket });
    } catch (error) {
        console.log(error);
        res.status(500).json({ error: "Booking failed" });
    }
});

router.get("/", async (req, res) => {
  try {
    const userId = "dummy-user-123";

    const tickets = await prisma.ticket.findMany({
      where: { userId },
      include: { vehicle: true, fromStop: true, toStop: true },
    });

    res.json({ tickets });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Could not fetch tickets" });
  }
});

router.post("/checkin", async (req, res) => {
  try {
    const { ticketId } = req.body;
    const ticket = await prisma.ticket.update({
      where: { id: ticketId },
      data: { status: "CHECKED_IN" },
      include: { vehicle: true, fromStop: true, toStop: true },
    });
    res.json({ ticket });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Check-in failed" });
  }
});

router.post("/checkout", async (req, res) => {
  try {
    const { ticketId } = req.body;
    const ticket = await prisma.ticket.update({
      where: { id: ticketId },
      data: { status: "CHECKED_OUT" },
      include: { vehicle: true, fromStop: true, toStop: true },
    });
    res.json({ ticket });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Check-out failed" });
  }
});

export default router;