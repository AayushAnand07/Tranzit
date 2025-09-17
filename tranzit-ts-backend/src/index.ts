import express, { Request, Response } from "express";
import { PrismaClient } from './generated/prisma'
import { withAccelerate } from '@prisma/extension-accelerate'
import userRouter from './controller/user.controller'
import searchRouter from './controller/routes.controller'
import ticketRouter from './controller/ticket.controller'
import { authenticateFirebaseToken } from "./utils/authenticateRoute";


const app = express();

const prisma = new PrismaClient().$extends(withAccelerate())

const PORT = process.env.PORT || 3000;

app.use(express.json());



app.use('/api/v1/users/',authenticateFirebaseToken,userRouter);
app.use('/api/v1/routes/',authenticateFirebaseToken,searchRouter);
app.use('/api/v1/ticket/',authenticateFirebaseToken,ticketRouter);

app.listen(PORT, () => {
  console.log(` Server is running at http://localhost:${PORT}`);
});
