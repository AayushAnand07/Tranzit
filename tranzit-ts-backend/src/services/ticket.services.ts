import { PrismaClient } from "../generated/prisma";
const prisma = new PrismaClient();


export async function bookTicket(payload: {
  userId: string;
  vehicleId: number;
  fromStopId: number;
  toStopId: number;
  passengers?: number;
  journeyDate: Date | string;
  price?: number;
}) {
  const { userId, vehicleId, fromStopId, toStopId, passengers, journeyDate, price } = payload;

  const vehicle = await prisma.vehicle.findUnique({ where: { id: vehicleId } });
  if (!vehicle) throw new Error("Vehicle not found");

  const passengerCount = Number(passengers ?? 1);
  const typeprice = Number(price ?? 1);
  const journeyDateUTC = new Date(journeyDate);

  const ticket = await prisma.ticket.create({
    data: {
      userId,
      vehicleId,
      fromStopId,
      toStopId,
      passengers: passengerCount,
      journeyDate: journeyDateUTC,
      price: typeprice,
    },
    include: { vehicle: true, fromStop: true, toStop: true },
  });

  const qrPayload = `${userId}-${vehicleId}-${ticket.id}-${journeyDateUTC.toISOString().split('T')[0]}`;

  return { ticket, qrPayload };
}


export async function getUserTickets(userId: string) {
  const tickets = await prisma.ticket.findMany({
    where: { userId },
    include: { vehicle: true, fromStop: true, toStop: true },
    orderBy: { journeyDate: "asc" },
  });

  return tickets.map(ticket => {
    const formattedDate = ticket.journeyDate.toISOString().split('T')[0];
    const qrPayload = `${userId}-${ticket.vehicleId}-${ticket.id}-${formattedDate}`;
    return { ...ticket, qrPayload };
  });
}

/**
 * Check-in a ticket
 */
export async function checkInTicket(ticketId: number) {
  const ticket = await prisma.ticket.findUnique({ where: { id: ticketId } });
  if (!ticket) throw new Error("Ticket not found");

  const nowUTC = new Date();
  const journeyDateTime = new Date(ticket.journeyDate);

  const journeyDate = new Date(journeyDateTime);
  journeyDate.setHours(0, 0, 0, 0);

  const today = new Date(nowUTC);
  today.setHours(0, 0, 0, 0);

  if (today.getTime() !== journeyDate.getTime()) throw new Error("Check-in allowed only on journey date");
  if (nowUTC < journeyDateTime) throw new Error("Check-in not allowed before journey time");
  if (ticket.status === "CHECKED_IN" || ticket.status === "CHECKED_OUT") throw new Error("Ticket already checked in");

  return prisma.ticket.update({
    where: { id: ticketId },
    data: { status: "CHECKED_IN", createdAt: nowUTC },
    include: { vehicle: true, fromStop: true, toStop: true },
  });
}

/**
 * Check-out a ticket
 */
export async function checkOutTicket(ticketId: number) {
  const ticket = await prisma.ticket.findUnique({ where: { id: ticketId } });
  if (!ticket) throw new Error("Ticket not found");
  if (ticket.status === "CHECKED_OUT") throw new Error("Ticket already checked out");

  return prisma.ticket.update({
    where: { id: ticketId },
    data: { status: "CHECKED_OUT" },
    include: { vehicle: true, fromStop: true, toStop: true },
  });
}
