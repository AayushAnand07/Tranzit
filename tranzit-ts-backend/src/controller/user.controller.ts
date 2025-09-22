import { Router,Request , Response } from "express";

import { Prisma, PrismaClient } from "../generated/prisma";
import { UserRepository } from "../repository/user.repository";

const router= Router();
const prisma = new PrismaClient();
const userRepo= new UserRepository();


router.post('/create', async (req,res)=> {
    try{
        const {id,name} =  req.body;
    const user= userRepo.createUser(id,name);
    res.status(201).json(user)
}
catch(err){  
     res.status(400).json({ error: "User creation failed", details: err })
}
})


router.get("/:id", async (req: Request, res: Response) => {
  const user = await userRepo.findByUID(req.params.id)
  if (!user) return res.status(404).json({ error: "User not found" });
  res.json(user.name);
});


export default router