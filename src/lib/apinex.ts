import { getKashifSystemInstruction } from "./gemini";

export interface ApinexChatPayload {
  model?: string;
  prompt: string;
  apiKey?: string;
  systemInstruction?: string;
}

export async function callApinexChat({
  model = "free/deepseek-v4.1-flash",
  prompt,
  apiKey,
  systemInstruction,
}: ApinexChatPayload): Promise<string> {
  const activeKey = apiKey || process.env.APINEX_API_KEY || "";
  const baseUrl = process.env.APINEX_BASE_URL || "https://api.apinex.bond/v1";

  if (!activeKey) {
    throw new Error("لم يتم إدخال مفتاح APInex في الإعدادات. يرجى لصق مفتاحك الخاص من موقع apinex.bond.");
  }

  const sys = systemInstruction || getKashifSystemInstruction();

  const res = await fetch(`${baseUrl}/chat/completions`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${activeKey}`,
      "User-Agent": "KashifWeb/1.0.0 (Diagnostics; Web)",
    },
    body: JSON.stringify({
      model: model || "free/deepseek-v4.1-flash",
      messages: [
        { role: "system", content: sys },
        { role: "user", content: prompt },
      ],
      temperature: 0.1,
    }),
  });

  if (!res.ok) {
    const errorText = await res.text();
    throw new Error(`خطأ سيرفر APInex (${res.status}): ${errorText}`);
  }

  const json: any = await res.json();
  const text = json.choices?.[0]?.message?.content || "";
  return text;
}

export function parseApinexJson(text: string): unknown {
  const cleanJson = text
    .replace(/^```json\s*/m, "")
    .replace(/^```\s*/m, "")
    .replace(/```$/m, "")
    .trim();

  return JSON.parse(cleanJson);
}
