import { Router, Request, Response } from "express";
import { Prisma, PrismaClient } from "../generated/prisma";
import { withAccelerate } from '@prisma/extension-accelerate'
import QRCode from "qrcode";

const router = Router();
const prisma = new PrismaClient().$extends(withAccelerate())

router.post('/book', async (req: Request, res: Response) => {
   
    try {
        const { vehicleId, fromStopId, toStopId , userId} = req.body;
        const vehicle = await prisma.vehicle.findUnique({ where: {id: vehicleId } });
        if (!vehicle) {
            return res.status(404).json({ error: "Vehicle not found" });
        }
          let qrPayload = `${userId}-${vehicleId}-${Date.now()}`;
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
        qrPayload = `${userId}-${vehicleId}-${ticket.id}-${Date.now()}`;
         res.status(200).json({
      success: true,
      message: "Ticket booked successfully",
      qrPayload, 
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, error: "Booking failed" });
  }
});
router.get("/", async (req, res) => {
  try {
    const userId = req.uid;

   const tickets = await 
   prisma.ticket.findMany({
   
     where: { userId },
      include: {
        vehicle: true,
        fromStop: true,
        toStop: true,
      },
      orderBy: {
        createdAt: "desc",  
      },
    });

   console.log(tickets);

    res.json({ tickets });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Could not fetch tickets" });
  }
});


router.post("/checkin", async (req, res) => {
  try {
    const { ticketId } = req.body;

    const ticket = await prisma.ticket.findUnique({
      where: { id: ticketId }
    });

    if (!ticket) {
      return res.status(404).json({ success: false, error: "Ticket not found" });
    }

    if (ticket.status === "CHECKED_OUT" || ticket.status === "CHECKED_IN" ) {
      return res.json({ success: false, error: "Ticket already checked in" });
    }

    await prisma.ticket.update({
      where: { id: ticketId },
      data: { status: "CHECKED_IN" },
      include: { vehicle: true, fromStop: true, toStop: true },
    });

    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Check-in failed" });
  }
});

router.post("/checkout", async (req, res) => {
  try {
    const { ticketId } = req.body;

    const ticket = await prisma.ticket.findUnique({
      where: { id: ticketId }
    });

    if (!ticket) {
      return res.status(404).json({ success: false, error: "Ticket not found" });
    }

    if (ticket.status === "CHECKED_OUT") {
      return res.json({ success: false, error: "Ticket already checked in" });
    }

    await prisma.ticket.update({
      where: { id: ticketId },
      data: { status: "CHECKED_OUT" },
      include: { vehicle: true, fromStop: true, toStop: true },
    });

    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Check-in failed" });
  }
});




export default router;