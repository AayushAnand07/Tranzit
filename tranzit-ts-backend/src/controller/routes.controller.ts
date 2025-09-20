import { Router, Request, Response } from "express";
import { routeService } from "../services/route.services";
import { routeRepository } from "../repository/routes.repository";
import { TransportType } from "../generated/prisma";
const router = Router();


const formatInputString = (str: string) => {
    let lowercasedString = str.toLowerCase();
    let cleanedString = lowercasedString.replace(/[^a-z0-9]/g, '');
    return cleanedString;
}

router.get("/", async (req: Request, res: Response) => {
  const { from, to, transportType } = req.query;

  const formattedFrom = formatInputString(from as string);
  const formattedTo = formatInputString(to as string);

  if (!formattedFrom || !formattedTo) {
    return res.status(400).json({ error: "from and to query parameters are required" });
  }

  let transportTypeEnum: TransportType | undefined;
  if (typeof transportType === "string") {
    if (Object.values(TransportType).includes(transportType as TransportType)) {
      transportTypeEnum = transportType as TransportType;
    } else {
      return res.status(400).json({ error: "Invalid transportType value" });
    }
  } else if (typeof transportType === "undefined") {
    transportTypeEnum = undefined;
  } else {
    return res.status(400).json({ error: "Invalid transportType format" });
  }

  try {
    const results = await routeService.searchRoutes(formattedFrom, formattedTo, transportTypeEnum);
    return res.json({ results });
  } catch (err: any) {
    if (err.message === "STOP_NOT_FOUND") {
      return res.status(404).json({ error: "One or both stops not found" });
    }
    console.error(err);
    return res.status(500).json({ error: "Internal server error" });
  }
});


router.get('/between', async (req,res)=>{
  
  try {
    const { routeId, from, to } = req.query;

    if (!routeId || !from || !to) {
      return res.status(400).json({ error: "routeId, from, and to are required" });
    }

    const result = await routeRepository.getStopsBetween(
      Number(routeId),
      String(from),
      String(to)
    );

    return res.json(result);
  } catch (err: any) {
    return res.status(500).json({ error: err.message });
  }

})

router.get('/allStops',async (req,res)=>{
  try{
      const stops=await routeRepository.getAllStops();
      return res.status(200).json(stops);
  }
 catch(err){
    return res.status(500).json({ error: "Internal server error" });
  }
})


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
