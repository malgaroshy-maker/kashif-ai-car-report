import dotenv from "dotenv";
dotenv.config({ path: ".env.local", override: true });

import { streamMechanicAssistant } from "../src/lib/gemini";
import { SAMPLE_TOYOTA_COROLLA } from "../src/lib/sample-data";
import { chatContextOf } from "../src/lib/api-client";

async function main() {
  console.log("=== Testing Live Gemini Assistant Streaming ===");
  const context = chatContextOf(SAMPLE_TOYOTA_COROLLA);
  const question = "شنو الخطوات الأولى لفحص الكود P0102؟";
  
  console.log("Sending query with model gemini-3.7-flash...");
  const startTime = Date.now();
  let chunkCount = 0;
  let fullResponse = "";

  try {
    const stream = streamMechanicAssistant(
      context,
      question,
      [],
      process.env.GEMINI_API_KEY,
      "gemini-2.5-flash"
    );

    for await (const chunk of stream) {
      chunkCount++;
      fullResponse += chunk;
      process.stdout.write(chunk);
    }

    const elapsed = ((Date.now() - startTime) / 1000).toFixed(2);
    console.log(`\n\n=== Streaming SUCCESS! ===`);
    console.log(`Chunks received: ${chunkCount}`);
    console.log(`Total characters: ${fullResponse.length}`);
    console.log(`Total time: ${elapsed}s`);
  } catch (err) {
    console.error("\nStreaming failed with error:", err);
    process.exit(1);
  }
}

main();
