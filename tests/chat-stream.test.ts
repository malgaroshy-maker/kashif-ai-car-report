import { afterEach, describe, expect, it, vi } from "vitest";
import { ApiError, streamAssistant } from "@/lib/api-client";
import { SAMPLE_TOYOTA_COROLLA } from "@/lib/sample-data";

/**
 * The assistant's reply arrives in pieces, and the pieces do not respect
 * anything. A chunk boundary lands in the middle of a JSON object, in the
 * middle of a multi-byte Arabic character, or between the two halves of a
 * newline-separated pair. Every case here is one the reader has to survive,
 * because the alternative is a reply that renders as mojibake or silently
 * loses a sentence.
 */

function respondWith(chunks: (string | Uint8Array)[], ndjson = true) {
  const body = new ReadableStream<Uint8Array>({
    start(controller) {
      const enc = new TextEncoder();
      for (const c of chunks) {
        controller.enqueue(typeof c === "string" ? enc.encode(c) : c);
      }
      controller.close();
    },
  });
  return new Response(body, {
    headers: {
      "Content-Type": ndjson
        ? "application/x-ndjson; charset=utf-8"
        : "application/json",
    },
  });
}

function mockFetch(res: Response) {
  vi.stubGlobal("fetch", vi.fn().mockResolvedValue(res));
}

async function collect(): Promise<string> {
  let out = "";
  for await (const d of streamAssistant(SAMPLE_TOYOTA_COROLLA, "س؟", [])) out += d;
  return out;
}

afterEach(() => vi.unstubAllGlobals());

describe("reading the assistant's stream", () => {
  it("joins deltas that were split across chunk boundaries mid-JSON", async () => {
    // The server wrote one complete line; the network delivered it in three
    // pieces, one of which ends inside the JSON string.
    const line = JSON.stringify({ delta: "شوف يا غالي" }) + "\n";
    mockFetch(
      respondWith([line.slice(0, 9), line.slice(9, 20), line.slice(20)])
    );
    expect(await collect()).toBe("شوف يا غالي");
  });

  it("does not mangle an Arabic character split across two chunks", async () => {
    // A single delta, encoded, then cut in the middle of a two-byte character.
    const enc = new TextEncoder();
    const bytes = enc.encode(JSON.stringify({ delta: "مرحبتين بيك" }) + "\n");
    const cut = 11;

    // The cut has to actually land inside a character for this test to be
    // testing anything. Decoding the first half alone must fail; if someone
    // edits the string above and the boundary becomes clean, this fails loudly
    // rather than quietly passing forever.
    expect(() =>
      new TextDecoder("utf-8", { fatal: true }).decode(bytes.slice(0, cut))
    ).toThrow();

    mockFetch(respondWith([bytes.slice(0, cut), bytes.slice(cut)]));
    expect(await collect()).toBe("مرحبتين بيك");
  });

  it("keeps every delta when several arrive in one chunk", async () => {
    mockFetch(
      respondWith([
        JSON.stringify({ delta: "أول " }) +
          "\n" +
          JSON.stringify({ delta: "ثاني " }) +
          "\n" +
          JSON.stringify({ delta: "ثالث" }) +
          "\n" +
          JSON.stringify({ done: true }) +
          "\n",
      ])
    );
    expect(await collect()).toBe("أول ثاني ثالث");
  });

  it("surfaces an error that arrives after some text, and keeps the text", async () => {
    // The answer broke off part-way. What arrived before the break is the
    // caller's to keep — the panel appends the message under it rather than
    // discarding a reply that was most of the way there.
    mockFetch(
      respondWith([
        JSON.stringify({ delta: "نص وصل" }) +
          "\n" +
          JSON.stringify({ error: "انقطع الاتصال" }) +
          "\n",
      ])
    );

    let got = "";
    await expect(async () => {
      for await (const d of streamAssistant(SAMPLE_TOYOTA_COROLLA, "س؟", [])) {
        got += d;
      }
    }).rejects.toThrow(ApiError);
    expect(got).toBe("نص وصل");
  });

  it("reports a pre-stream failure as the server phrased it", async () => {
    // Nothing had been sent yet, so the route answered with an ordinary JSON
    // error and a status. That path must keep working: it is how "no API key"
    // reaches the user.
    mockFetch(
      new Response(JSON.stringify({ success: false, error: "لم يتم ضبط مفتاح" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      })
    );
    await expect(collect()).rejects.toThrow("لم يتم ضبط مفتاح");
  });

  it("treats a stream that carried no text as a failure, not an empty answer", async () => {
    // An empty reply rendered as a blank line from the assistant, which reads
    // as the mechanic having nothing to say about the car.
    mockFetch(respondWith([JSON.stringify({ done: true }) + "\n"]));
    await expect(collect()).rejects.toThrow(ApiError);
  });

  it("ignores a line that is not JSON rather than losing the rest", async () => {
    mockFetch(
      respondWith([
        "not json at all" +
          "\n" +
          JSON.stringify({ delta: "الباقي" }) +
          "\n",
      ])
    );
    expect(await collect()).toBe("الباقي");
  });
});
