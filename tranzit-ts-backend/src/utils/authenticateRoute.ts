import { Request, Response, NextFunction } from "express";
import admin from "firebase-admin";
import path from "path";

const serviceAccount = require(path.resolve(__dirname, "../../firebase-service-account.json"));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

declare global {
  namespace Express {
    interface Request {
      uid?: string;
    }
  }
}

export async function authenticateFirebaseToken(
  req: Request,
  res: Response,
  next: NextFunction
) {
    try{
  const authHeader = req.headers.authorization || "";

  if (!authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Unauthorized" });
  }

  const idToken = authHeader.split("Bearer ")[1];

    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.uid = decodedToken.uid; 
    next();
  } catch (err) {
    return res.status(401).json({ error: "Unauthorized" });
  }
}
