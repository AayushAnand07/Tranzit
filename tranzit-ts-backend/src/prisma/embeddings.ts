
import { GoogleAuth } from 'google-auth-library';
import axios from 'axios';
import { PrismaClient } from "../generated/prisma";

const prisma = new PrismaClient();


async function getAccessToken(): Promise<string> {
  const auth = new GoogleAuth({
    scopes: ['https://www.googleapis.com/auth/cloud-platform']
  });
  
  const client = await auth.getClient();
  const accessTokenResponse = await client.getAccessToken();
  
  if (!accessTokenResponse.token) {
    throw new Error('Failed to obtain access token');
  }
  
  return accessTokenResponse.token;
}

async function getEmbeddings(texts: string[], batchSize: number = 2): Promise<number[][]> {
  if (!texts || texts.length === 0) {
    throw new Error("No texts provided for embedding generation");
  }

  const project = process.env.GOOGLE_CLOUD_PROJECT;
  const location ="us-central1";
  
  if (!project) {
    throw new Error("GOOGLE_CLOUD_PROJECT environment variable is required");
  }

  const accessToken = await getAccessToken();
  const allEmbeddings: number[][] = [];
  
  
  for (let i = 0; i < texts.length; i += batchSize) {
    const batch = texts.slice(i, i + batchSize);
    console.log(`Processing batch ${Math.floor(i/batchSize) + 1}/${Math.ceil(texts.length/batchSize)}: [${batch.join(', ')}]`);
    
    try {
      const url = `https://${location}-aiplatform.googleapis.com/v1/projects/${project}/locations/${location}/publishers/google/models/text-embedding-004:predict`;
      
      const requestBody = {
        instances: batch.map(text => ({
          content: text
        }))
      };

      const response = await axios.post(url, requestBody, {
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json'
        },
        timeout: 30000
      });

      if (!response.data.predictions || response.data.predictions.length === 0) {
        throw new Error(`No predictions returned for batch: [${batch.join(', ')}]`);
      }

      if (response.data.predictions.length !== batch.length) {
        throw new Error(`Expected ${batch.length} predictions, got ${response.data.predictions.length}`);
      }

      const batchEmbeddings: number[][] = response.data.predictions.map((prediction: any, index: number) => {
        let embedding: number[] = [];

        if (prediction.embeddings && prediction.embeddings.values) {
          embedding = prediction.embeddings.values;
        } else if (prediction.embedding && Array.isArray(prediction.embedding)) {
          embedding = prediction.embedding;
        } else if (prediction.values && Array.isArray(prediction.values)) {
          embedding = prediction.values;
        } else {
          console.error(`Unexpected prediction structure for "${batch[index]}":`, prediction);
          throw new Error(`Invalid embedding structure for text: ${batch[index]}`);
        }

        if (!embedding || embedding.length === 0) {
          throw new Error(`Empty embedding returned for text: ${batch[index]}`);
        }

        return embedding;
      });

      allEmbeddings.push(...batchEmbeddings);
      
     
      if (i + batchSize < texts.length) {
        console.log('  Waiting 5 seconds before next batch...');
        await new Promise(resolve => setTimeout(resolve, 5000));
      }
      
    } catch (error: any) {
      console.error(`Error processing batch: [${batch.join(', ')}]`);
      
      if (error.response) {
        console.error('Response status:', error.response.status);
        console.error('Response data:', JSON.stringify(error.response.data, null, 2));
        
       
        if (error.response.status === 429) {
          const waitTime = Math.min(10000 * Math.pow(2, Math.floor(i/batchSize)), 120000); // Max 2 minutes
          console.log(`Rate limit/quota exceeded, waiting ${waitTime/1000} seconds before retry...`);
          await new Promise(resolve => setTimeout(resolve, waitTime));
          
         
          i -= batchSize;
          continue;
        }
      }
      
    
     
      
      throw new Error(`Failed to generate embeddings for batch [${batch.join(', ')}] - ${error.message}`);
    }
  }

  return allEmbeddings;
}


async function generateEmbeddingsOnly() {
  console.log("Starting embeddings generation for existing stops...");

  try {
   
    const allStops = await prisma.stop.findMany({
      select: { id: true, name: true }
    });

    if (allStops.length === 0) {
      console.error("No stops found in database! Please run the full seed script first.");
      console.error("Run: ts-node src/prisma/seed.ts");
      return;
    }

    console.log(`Found ${allStops.length} stops in database`);

    
    const existingEmbeddings = await prisma.stopEmbedding.findMany({
      select: { stopId: true, stop: { select: { name: true } } }
    });

    const stopsWithEmbeddings = new Set(existingEmbeddings.map(e => e.stopId));
    const stopsNeedingEmbeddings = allStops.filter(stop => !stopsWithEmbeddings.has(stop.id));

   

    console.log("\n Deleting all existing embeddings...");
    const deletedCount = await prisma.stopEmbedding.deleteMany({});
    console.log(`Deleted ${deletedCount.count} existing embeddings`);

    console.log(`Need to generate embeddings for ${stopsNeedingEmbeddings.length} stops:`);
    stopsNeedingEmbeddings.forEach((stop, i) => {
      console.log(`  ${i + 1}. ${stop.name}`);
    });

    if (existingEmbeddings.length > 0) {
      console.log(`\nAlready have embeddings for ${existingEmbeddings.length} stops:`);
      existingEmbeddings.forEach((emb, i) => {
        console.log(`  ${i + 1}. ${emb.stop.name}`);
      });
    }


    const stopNames = stopsNeedingEmbeddings.map(s => s.name);
    
    console.log(`Generating embeddings with batch size of 2 and 5-second delays`);
    const embeddings = await getEmbeddings(stopNames, 2);

    console.log("Saving embeddings to database...");
    for (let i = 0; i < stopsNeedingEmbeddings.length; i++) {
      const stop = stopsNeedingEmbeddings[i];
      const vector = embeddings[i];

      if (!vector || vector.length === 0) {
        console.warn(`Warning: Empty embedding for stop ${stop.name}, skipping...`);
        continue;
      }

      await prisma.stopEmbedding.upsert({
        where: { stopId: stop.id },
        update: { vector },
        create: { stopId: stop.id, vector },
      });

      console.log(`Saved embedding for: ${stop.name} (${vector.length} dimensions)`);
    }

    
    const finalCount = await prisma.stopEmbedding.count();
    console.log(`Embeddings generation completed successfully!`);
    console.log(`Total stops with embeddings: ${finalCount}/${allStops.length}`);

  } catch (error) {
    console.error("Error during embeddings generation:", error);
    throw error;
  }
}


generateEmbeddingsOnly()
  .then(async () => {
    console.log("Disconnecting from database");
    await prisma.$disconnect();
    console.log("Done!");
  })
  .catch(async (e) => {
    console.error("Fatal error:", e);
    await prisma.$disconnect();
    process.exit(1);
  });