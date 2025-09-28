import express, { Request, Response } from "express";
import userRouter from './controller/user.controller'
import searchRouter from './controller/routes.controller'
import ticketRouter from './controller/ticket.controller'
import chatRouter from './controller/chat.controller'
import { authenticateFirebaseToken } from "./utils/authenticateRoute";


const app = express();

const PORT = process.env.PORT || 3000;

app.use(express.json());



app.use('/api/v1/users/',authenticateFirebaseToken,userRouter);
app.use('/api/v1/routes/',authenticateFirebaseToken,searchRouter);
app.use('/api/v1/ticket/',authenticateFirebaseToken,ticketRouter);
app.use('/api/v1/chat/',authenticateFirebaseToken,chatRouter);

app.listen(PORT, () => {
  console.log(` Server is running at http://localhost:${PORT}`);
});
