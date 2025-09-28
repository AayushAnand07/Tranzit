
import admin from "firebase-admin";

export class NotificationService{
static async sendPushNotification(
    userToken: string, 
    title: string, 
    body: string, 
    data?: Record<string, string>
  ) {
    try {
      const message = {
        notification: {
          title,
          body,
        },
        data: data || {},
        token: userToken,
      };

      const response = await admin.messaging().send(message);
      console.log("✅ Push notification sent successfully:", response);
      return response;
    } catch (error) {
      console.error("❌ Error sending push notification:", error);
      throw error;
    }
  }

    static async sendBookingConfirmation(
    userToken: string,
    ticketDetails: {
      ticketId: string;
      origin: string;
      to: string;
      departureTime: string;
      price: number;
      passengers: number;
      transport: string;
    }
  ) {
    const title = "🎫 Booking Confirmed!";
    const body = `Your ${ticketDetails.transport} ticket from ${ticketDetails.origin} to ${ticketDetails.to} is confirmed`;
    
    const data = {
      type: "booking_confirmation",
      ticketId: ticketDetails.ticketId,
      origin: ticketDetails.origin,
      to: ticketDetails.to,
      departureTime: ticketDetails.departureTime,
      price: ticketDetails.price.toString(),
      passengers: ticketDetails.passengers.toString(),
      transport: ticketDetails.transport,
    };

    return this.sendPushNotification(userToken, title, body, data);
  }
}