import { Router, Request, Response } from "express";
import { Prisma, PrismaClient } from "../generated/prisma";
import { withAccelerate } from '@prisma/extension-accelerate'
import { routeService } from "../services/route.services";

const router = Router();
const prisma = new PrismaClient().$extends(withAccelerate())

const formatInputString = (str: string) => {
    let lowercasedString = str.toLowerCase();
    let cleanedString = lowercasedString.replace(/[^a-z0-9]/g, '');
    return cleanedString;
}

router.get("/", async (req: Request, res: Response) => {
  const { from, to } = req.query;

  const formattedFrom = formatInputString(from as string);
  const formattedTo   = formatInputString(to as string);

  if (!formattedFrom || !formattedTo) {
    return res.status(400).json({ error: "from and to query parameters are required" });
  }

  try {
    const results = await routeService.searchRoutes(formattedFrom, formattedTo);
    return res.json({ results });
  } catch (err: any) {
    if (err.message === "STOP_NOT_FOUND") {
      return res.status(404).json({ error: "One or both stops not found" });
    }
    console.error(err);
    return res.status(500).json({ error: "Internal server error" });
  }
});

router.get('/:id',async (req,res)=>{
  try{
    const routeId = Number(req.params.id);
    console.log(routeId)
    const allStops=await routeService.getRouteStops(routeId)
    return res.status(200).json({allStops});
  }
  catch(err){
    return res.status(500).json({ error: "Internal server error" });
  }
})

export default router;
