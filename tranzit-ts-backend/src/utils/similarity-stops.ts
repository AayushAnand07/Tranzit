
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

export async function generateQueryEmbedding(text: string): Promise<number[]> {
  const project = process.env.GOOGLE_CLOUD_PROJECT;
  const location = "us-central1";
  
  if (!project) {
    throw new Error("GOOGLE_CLOUD_PROJECT environment variable is required");
  }

  const accessToken = await getAccessToken();
  
  try {
    const url = `https://${location}-aiplatform.googleapis.com/v1/projects/${project}/locations/${location}/publishers/google/models/text-embedding-004:predict`;
    
    const requestBody = {
      instances: [{ content: text }]
    };

    const response = await axios.post(url, requestBody, {
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      },
      timeout: 10000
    });

    if (!response.data.predictions || response.data.predictions.length === 0) {
      throw new Error(`No predictions returned for text: ${text}`);
    }

    const prediction = response.data.predictions[0];
    let embedding: number[] = [];

    if (prediction.embeddings && prediction.embeddings.values) {
      embedding = prediction.embeddings.values;
    } else if (prediction.embedding && Array.isArray(prediction.embedding)) {
      embedding = prediction.embedding;
    } else if (prediction.values && Array.isArray(prediction.values)) {
      embedding = prediction.values;
    }

    if (!embedding || embedding.length === 0) {
      throw new Error(`Empty embedding returned for text: ${text}`);
    }

    return embedding;
    
  } catch (error: any) {
    console.error(`Error generating embedding for query: ${text}`, error.response?.data || error.message);
    throw error;
  }
}


function cosineSimilarity(vecA: number[], vecB: number[]): number {
  if (vecA.length !== vecB.length) {
    throw new Error("Vectors must have the same length");
  }

  let dotProduct = 0;
  let normA = 0;
  let normB = 0;

  for (let i = 0; i < vecA.length; i++) {
    dotProduct += vecA[i] * vecB[i];
    normA += vecA[i] * vecA[i];
    normB += vecB[i] * vecB[i];
  }

  if (normA === 0 || normB === 0) {
    return 0;
  }

  return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
}


export async function findSimilarStops(queryText: string, limit: number = 5): Promise<Array<{stop: any, similarity: number}>> {
  try {
    
    const queryEmbedding = await generateQueryEmbedding(queryText);
    
  
    const stopEmbeddings = await prisma.stopEmbedding.findMany({
      include: {
        stop: true
      }
    });

    if (stopEmbeddings.length === 0) {
      console.warn("No stop embeddings found in database. Run the seed script first.");
      return [];
    }

    
const similarities = stopEmbeddings.map(stopEmb => {
      const similarity = cosineSimilarity(queryEmbedding, stopEmb.vector);
      return {
        stop: stopEmb.stop,
        similarity
      };
    });

   
 return similarities
      .sort((a, b) => b.similarity - a.similarity)
      .slice(0, limit);
      
  } catch (error) {
    console.error('Error in findSimilarStops:', error);
    throw error;
  }
}

