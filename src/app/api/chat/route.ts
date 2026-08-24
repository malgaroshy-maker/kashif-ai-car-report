import { NextRequest, NextResponse } from "next/server";
import { askMechanicAssistant } from "@/lib/gemini";
import { runAgyPrompt, getAgyCliStatus } from "@/lib/antigravity-cli";
import { KashifDiagnosticReport } from "@/lib/types";
import { KashifError, errorPayload } from "@/lib/errors";
import { resolveModelId } from "@/lib/models";

export async function POST(req: NextRequest) {
  try {
    const userApiKey = req.headers.get("x-gemini-api-key") || undefined;
    const body = await req.json();
    const { report, question, history, apiKey, provider, model } = body as {
      report: KashifDiagnosticReport;
      question: string;
      history: { sender: "user" | "assistant"; text: string }[];
      apiKey?: string;
      provider?: "gemini" | "agy";
      model?: string;
    };

    if (!report || !question) throw new KashifError("NO_INPUT");

    if (provider === "agy") {
      try {
        const agyStatus = await getAgyCliStatus();
        if (agyStatus.available) {
          const prompt = `أنت "الأسطى كاشف"، فني ميكانيكا وخبير فحص سيارات ليبي.
سياق السيارة الحالية: ${report.vehicle.make} ${report.vehicle.model} (${report.vehicle.year})، رقم الهيكل: ${report.vehicle.vin}.
الأعطال المسجلة: ${report.faultCategories.criticalFaults.concat(report.faultCategories.moderateFaults).map(f => `${f.code}: ${f.libyanTerm}`).join("، ")}.
سؤال المستخدم: "${question}".
أجب بلهجة ليبية فنية محترفة ودقيقة وقدم خطوات عملية فورية:`;
          const reply = await runAgyPrompt(prompt, 15000);
          if (reply && reply.trim()) {
            return NextResponse.json({ reply: reply.trim(), engine: "Antigravity CLI (agy)" });
          }
        }
      } catch (agyErr) {
        console.warn("AGY Chat failed, falling back to Gemini API:", agyErr);
      }
    }

    const reply = await askMechanicAssistant(
      report,
      question,
      history || [],
      apiKey || userApiKey,
      resolveModelId(model || req.headers.get("x-gemini-model"))
    );
    return NextResponse.json({ reply, engine: "Google Gemini Cloud API" });
  } catch (err) {
    const { body: payload, status } = errorPayload(err);
    if (err instanceof KashifError) {
      console.warn(`[chat] ${err.code}: ${err.detail ?? ""}`);
    } else {
      console.error("[chat] unexpected", err);
    }
    return NextResponse.json({ ...payload, reply: null }, { status });
  }
}
