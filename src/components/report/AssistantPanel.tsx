"use client";

import * as React from "react";
import { Button, Cell } from "@/components/ui/primitives";
import { streamAssistant, messageOf } from "@/lib/api-client";
import { ACCENT } from "@/lib/design/severity";
import type { ChatMessage, KashifDiagnosticReport } from "@/lib/types";

/**
 * Asking the report a question.
 *
 * It sits at the bottom of the board, in the reading order, rather than
 * floating over it in a drawer. A floating bubble is a support widget; this is
 * the last section of a document — you have read what is wrong with the car,
 * and now you ask the follow-up. It also stops the drawer covering the parts
 * list, which is exactly what people are asking about.
 *
 * Nothing here is persisted. A conversation about the Corolla should not be
 * waiting when the BMW is loaded.
 */
export function AssistantPanel({ report }: { report: KashifDiagnosticReport }) {
  const vehicleName =
    [report.vehicle.make, report.vehicle.model].filter(Boolean).join(" ") ||
    "السيارة";

  const [messages, setMessages] = React.useState<ChatMessage[]>([]);
  const [input, setInput] = React.useState("");
  const [busy, setBusy] = React.useState(false);
  const endRef = React.useRef<HTMLDivElement>(null);

  /** Cancels the question in flight when another is sent or the page leaves. */
  const pending = React.useRef<AbortController | null>(null);
  React.useEffect(() => () => pending.current?.abort(), []);

  React.useEffect(() => {
    if (messages.length > 0) {
      endRef.current?.scrollIntoView({ behavior: "smooth", block: "nearest" });
    }
  }, [messages]);

  const stamp = () =>
    new Date().toLocaleTimeString("ar-LY", { hour: "2-digit", minute: "2-digit" });

  // "Preparing the reply" belongs to the gap before the first word, not to the
  // whole answer. Once text is arriving the text itself is the progress, and
  // leaving the notice up under a reply already being written says the app has
  // not noticed what it is doing.
  const waiting =
    busy && messages[messages.length - 1]?.text === "";

  const send = async (text: string) => {
    const question = text.trim();
    if (!question || busy) return;

    const asked: ChatMessage = {
      id: `q-${Date.now()}`,
      sender: "user",
      text: question,
      timestamp: stamp(),
    };

    // The answer's line is added empty and filled in as the text arrives, so
    // the reply appears where it will finally sit rather than jumping into
    // place at the end.
    const answerId = `a-${Date.now()}`;
    const blank: ChatMessage = {
      id: answerId,
      sender: "assistant",
      text: "",
      timestamp: stamp(),
    };

    // Sender and text only. The ids and display timestamps were being
    // uploaded on every turn and mean nothing to the model.
    const history = messages.map((m) => ({ sender: m.sender, text: m.text }));

    setMessages((prev) => [...prev, asked, blank]);
    setInput("");
    setBusy(true);

    pending.current?.abort();
    const controller = new AbortController();
    pending.current = controller;

    let received = "";
    try {
      for await (const delta of streamAssistant(
        report,
        question,
        history,
        controller.signal
      )) {
        received += delta;
        const soFar = received;
        setMessages((prev) =>
          prev.map((m) => (m.id === answerId ? { ...m, text: soFar } : m))
        );
      }
    } catch (err) {
      // A question that was replaced by a newer one is not worth a line in the
      // transcript.
      const superseded =
        controller.signal.aborted &&
        !(err instanceof DOMException && err.name === "TimeoutError");
      if (superseded) {
        setMessages((prev) => prev.filter((m) => m.id !== answerId));
        return;
      }

      // The old panel answered every failure with "connection problem", which
      // hid the one that actually matters: no API key set.
      const said = messageOf(err, "تعذر الاتصال حالياً، جرب مرة ثانية.");

      // Text that already arrived is kept. An answer that broke off three
      // quarters of the way through is still worth more than the error alone,
      // and throwing it away to show a message is the wrong trade.
      setMessages((prev) =>
        prev.map((m) =>
          m.id === answerId
            ? { ...m, text: received ? `${received}\n\n— ${said}` : said }
            : m
        )
      );
    } finally {
      if (pending.current === controller) {
        pending.current = null;
        setBusy(false);
      }
    }
  };

  return (
    <section
      className="no-print space-y-[var(--s3)]"
      aria-labelledby="assistant-heading"
    >
      <div className="rib-heavy flex items-center gap-[var(--s2)] pt-[var(--s2)]">
        <h2 id="assistant-heading" className="k-bank uppercase text-(color:--ink)">
          اسأل عن التقرير
        </h2>
        <span className="rib mt-[2px] h-px flex-1" aria-hidden />
        <span className="k-label uppercase">{vehicleName}</span>
      </div>

      <Cell className="p-[var(--s4)]">
        {messages.length === 0 ? (
          <p className="leading-relaxed text-(color:--ink-2)">
            اسأل عن أي عطل فوق: شنو معناه، هل السيارة تمشي بيه، وشنو يتفحص قبل
            ما تشري القطعة.
          </p>
        ) : (
          <ol className="space-y-[var(--s4)]">
            {messages.map((m) => (
              <li key={m.id}>
                <div className="flex items-baseline gap-[var(--s2)]">
                  <span
                    className="k-label uppercase"
                    style={
                      m.sender === "assistant"
                        ? { color: ACCENT.ink }
                        : undefined
                    }
                  >
                    {m.sender === "user" ? "سؤالك" : "الأسطى كاشف"}
                  </span>
                  <span data-num className="k-label">
                    {m.timestamp}
                  </span>
                </div>
                <p
                  className={
                    m.sender === "assistant"
                      ? "mt-[var(--s1)] whitespace-pre-line leading-relaxed text-(color:--ink)"
                      : "mt-[var(--s1)] leading-relaxed text-(color:--ink-2)"
                  }
                >
                  {m.text}
                </p>
              </li>
            ))}
          </ol>
        )}

        {waiting && (
          <p className="k-label normal-case mt-[var(--s3)]" role="status" aria-live="polite">
            جاري إعداد الرد…
          </p>
        )}
        <div ref={endRef} />

        <form
          onSubmit={(e) => {
            e.preventDefault();
            send(input);
          }}
          className="rib mt-[var(--s4)] flex gap-[var(--s2)] pt-[var(--s3)]"
        >
          <input
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="اكتب سؤالك…"
            aria-label="سؤالك عن التقرير"
            disabled={busy}
            className="min-h-[var(--tap)] min-w-0 flex-1 border border-[var(--rib)] bg-[var(--cell)] px-[var(--s3)] text-(color:--ink) outline-none focus-visible:border-[var(--amp-15-ink)] disabled:opacity-45"
          />
          <Button type="submit" variant="primary" disabled={busy || !input.trim()}>
            اسأل
          </Button>
        </form>

        {messages.length === 0 && (
          <div className="mt-[var(--s3)] flex flex-wrap gap-[var(--s2)]">
            {SUGGESTIONS.map((q) => (
              <Button
                key={q}
                onClick={() => send(q)}
                disabled={busy}
                className="text-(length:--t-plate)"
              >
                {q}
              </Button>
            ))}
          </div>
        )}
      </Cell>
    </section>
  );
}

/** Openers, phrased the way somebody standing at the counter would ask. */
const SUGGESTIONS = [
  "شنو أخطر عطل عندي؟",
  "السيارة تمشي بيها ولا لا؟",
  "شنو نفحص قبل ما نشري القطع؟",
];
