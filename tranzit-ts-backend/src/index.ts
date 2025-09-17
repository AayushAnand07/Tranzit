import express, { Request, Response } from "express";
import { PrismaClient } from './generated/prisma'
import { withAccelerate } from '@prisma/extension-accelerate'
import userRouter from './controller/user.controller'
import searchRouter from './controller/routes.controller'
import ticketRouter from './controller/ticket.controller'


const app = express();

const prisma = new PrismaClient().$extends(withAccelerate())

const PORT = process.env.PORT || 3000;

app.use(express.json());



app.use('/api/v1/users/',userRouter);
app.use('/api/v1/routes/',searchRouter);
app.use('/api/v1/ticket/',ticketRouter);


app.get("/users", async (req, res) => {
  const users = await prisma.user.findMany();
  res.json(users);
});
app.get("/", (req: Request, res: Response) => {
  res.send("Hello from TypeScript Node.js Server ");
});


app.post("/echo", (req: Request, res: Response) => {
  res.json({
    message: "Data received",
    body: req.body,
  });
});

app.listen(PORT, () => {
  console.log(` Server is running at http://localhost:${PORT}`);
});
