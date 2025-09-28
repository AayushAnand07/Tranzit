import { Router} from "express";
import { StopBookingViaSpeechService } from "../services/chatBooking.services";
const router = Router();
const stopBookingservice = new StopBookingViaSpeechService();



router.post("/book", async (req, res) => {
  const { message,token } = req.body;

  try {
  console.log(token)
    await stopBookingservice.initiateSearchandBookingStops(message,req.uid!,token);
  } catch (error) {
    console.error("Error in search route:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});


export default router;