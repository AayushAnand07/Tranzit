import { Router, Request, Response } from "express";
import * as ticketService from "../services/ticket.services";

const router = Router();

router.post("/book", async (req: Request, res: Response) => {
  try {
    const { ticket, qrPayload } = await ticketService.bookTicket(req.body);
    res.status(200).json({ success: true, message: "Ticket booked successfully", qrPayload, ticket });
  } catch (err: any) {
    console.error(err);
    res.status(500).json({ success: false, error: err.message || "Booking failed" });
  }
});

router.get("/", async (req: Request, res: Response) => {
  try {
    const userId = req.uid;
    const tickets = await ticketService.getUserTickets(userId!);
    res.json({ tickets });
  } catch (err: any) {
    console.error(err);
    res.status(500).json({ error: err.message || "Could not fetch tickets" });
  }
});

router.post("/checkin", async (req: Request, res: Response) => {
  try {
    const ticket = await ticketService.checkInTicket(req.body.ticketId);
    res.json({ success: true, ticket });
  } catch (err: any) {
    console.error(err);
    res.status(400).json({ success: false, error: err.message });
  }
});

router.post("/checkout", async (req: Request, res: Response) => {
  try {
    const ticket = await ticketService.checkOutTicket(req.body.ticketId);
    res.json({ success: true, ticket });
  } catch (err: any) {
    console.error(err);
    res.status(400).json({ success: false, error: err.message });
  }
});

export default router;
