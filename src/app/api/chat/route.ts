import { NextRequest, NextResponse } from "next/server";
import { streamMechanicAssistant } from "@/lib/gemini";
import { tryAgyPrompt } from "@/lib/agy";
import { ChatReportContext } from "@/lib/types";
import { KashifError, errorPayload } from "@/lib/errors";
import { resolveModelId } from "@/lib/models";

/** Turns of conversation sent upstream. Six is three exchanges. */
const MAX_HISTORY = 6;

/**
 * One line of NDJSON per event.
 *
 * `{"delta":"…"}` for text, `{"done":true,…}` to close. Newline-delimited
 * rather than Server-Sent Events because the reply is Arabic prose that
 * contains blank lines, and SSE reserves those as record separators — an
 * answer with a paragraph break would be cut in half by its own formatting.
 */
function line(value: unknown): Uint8Array {
  return new TextEncoder().encode(JSON.stringify(value) + "\n");
}

const STREAM_HEADERS = {
  "Content-Type": "application/x-ndjson; charset=utf-8",
  "Cache-Control": "no-store",
  // Nothing between here and the browser may hold the reply back to buffer it;
  // a buffered stream is the old behaviour with extra steps.
  "X-Accel-Buffering": "no",
} as const;

export async function POST(req: NextRequest) {
  try {
    const userApiKey = req.headers.get("x-gemini-api-key") || undefined;
    const body = await req.json();
    const { report, question, history, apiKey, provider, model } = body as {
      report: ChatReportContext;
      question: string;
      history: { sender: "user" | "assistant"; text: string }[];
      apiKey?: string;
      provider?: "gemini" | "agy";
      model?: string;
    };

    if (!report || !question) throw new KashifError("NO_INPUT");

    // The panel keeps the whole conversation, but the model does not need all
    // of it and every turn is re-uploaded. Keep the recent exchanges.
    const recentHistory = Array.isArray(history) ? history.slice(-MAX_HISTORY) : [];

    if (provider === "agy") {
      const prompt = `أنت "الأسطى كاشف"، فني ميكانيكا وخبير فحص سيارات ليبي.
سياق السيارة الحالية: ${report.vehicle.make} ${report.vehicle.model} (${report.vehicle.year})، رقم الهيكل: ${report.vehicle.vin}.
الأعطال المسجلة: ${report.faultCategories.criticalFaults.concat(report.faultCategories.moderateFaults).map(f => `${f.code}: ${f.libyanTerm}`).join("، ")}.
سؤال المستخدم: "${question}".
أجب بلهجة ليبية فنية محترفة ودقيقة وقدم خطوات عملية فورية:`;

      const reply = await tryAgyPrompt(prompt, 15_000);
      if (reply) {
        // agy answers all at once, so there is nothing to stream. It still
        // goes out in the streaming envelope: one shape for the client to
        // read means the panel does not need to know which engine replied.
        return new Response(
          new ReadableStream({
            start(controller) {
              controller.enqueue(line({ delta: reply.trim() }));
              controller.enqueue(line({ done: true, engine: "Antigravity CLI (agy)" }));
              controller.close();
            },
          }),
          { headers: STREAM_HEADERS }
        );
      }
    }

    const answer = streamMechanicAssistant(
      report,
      question,
      recentHistory,
      apiKey || userApiKey,
      resolveModelId(model || req.headers.get("x-gemini-model"))
    );

    // Pull the first piece before answering 200.
    //
    // Everything that goes wrong before the model produces a token — no key,
    // a rejected key, an exhausted quota, no available model — is knowable
    // here, and here it can still be reported the way every other route
    // reports it: a JSON body with a real status code. Once the response has
    // begun the status is already sent and an error can only be a line in the
    // body, which is a worse thing to hand a caller. So the switch from one
    // to the other happens at the first token, not before it.
    const first = await answer.next();

    return new Response(
      new ReadableStream({
        async start(controller) {
          try {
            if (!first.done && first.value) {
              controller.enqueue(line({ delta: first.value }));
            }
            for await (const delta of answer) {
              controller.enqueue(line({ delta }));
            }
            controller.enqueue(line({ done: true, engine: "Google Gemini Cloud API" }));
          } catch (err) {
            // The answer broke off part-way. The client keeps the text it has
            // and shows this underneath it, rather than discarding a reply
            // that was most of the way there.
            const { body: payload } = errorPayload(err);
            console.warn("[chat] stream ended early:", err);
            controller.enqueue(line({ error: payload.error }));
          } finally {
            controller.close();
          }
        },
      }),
      { headers: STREAM_HEADERS }
    );
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
