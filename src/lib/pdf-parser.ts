import PDFParser from "pdf2json";

/**
 * pdf2json ships types that do not describe the two-argument constructor,
 * `getRawTextContent()` or the shape handed to `pdfParser_dataReady`. This is
 * what is actually called, declared once here rather than cast at each call.
 */
export interface PdfTextRun {
  T: string;
}
export interface PdfText {
  x: number;
  y: number;
  R: PdfTextRun[];
}
export interface PdfPage {
  Texts: PdfText[];
}
export interface PdfOutput {
  Pages?: PdfPage[];
}
interface RawTextPdfParser {
  on(event: "pdfParser_dataError", handler: (err: { parserError?: unknown }) => void): void;
  on(event: "pdfParser_dataReady", handler: (data: PdfOutput) => void): void;
  getRawTextContent(): string;
  parseBuffer(buffer: Buffer): void;
}
type RawTextPdfParserCtor = new (context: null, textOnly: 0 | 1) => RawTextPdfParser;

export interface ExtractedScannerData {
  rawText: string;
  extractedVin?: string;
  extractedMake?: string;
  extractedModel?: string;
  extractedYear?: string;
  extractedMileage?: string;
  scannerTool?: string;
  codesFound: string[];
}

/**
 * Two text runs belong to the same printed line when their baselines are this
 * close. pdf2json reports y in its own grid units where one line step on these
 * scanner reports is ~0.94, so half a step separates lines without splitting a
 * line whose runs sit a hair apart.
 */
const SAME_LINE_TOLERANCE = 0.4;

/**
 * Reading order, recovered from the page geometry.
 *
 * `getRawTextContent()` emits the runs in the order the PDF's content stream
 * happens to list them, and the Ediag/Launch scanners write their pages from
 * the bottom up. So the raw text came out upside down: on a real Camry scan
 * the model was shown
 *
 *     History
 *     Circuit
 *     8.B1826 Open in Side Squib (Passenger Seat Side)
 *
 * where the page reads `8.B1826 …` / `Circuit` / `History`. Every status word
 * (Current / Pending / History) sat above the code it belongs to and directly
 * under a *different* code, and every wrapped description came before its own
 * code line. The model was being asked to diagnose a car from a report printed
 * backwards, and which fault was current and which was history — the thing
 * that decides whether somebody drives the car — was attached to the wrong
 * row.
 *
 * The page data carries x and y for every run, so the order can just be
 * recovered: pages in order, lines down the page, runs across the line.
 */
export function textInReadingOrder(data: PdfOutput): string {
  const pages = data?.Pages;
  if (!Array.isArray(pages)) return "";

  return pages
    .map((page) => {
      const runs = (page?.Texts ?? []).map((t) => ({
        x: t.x,
        y: t.y,
        text: (t.R ?? []).map((r) => decodeText(r.T)).join(""),
      }));

      // Down the page first, then across each line. RTL pages are handled by
      // the same left-to-right sort: the runs carry their own glyph order and
      // the scanner reports are Latin-scripted regardless.
      runs.sort((a, b) =>
        Math.abs(a.y - b.y) <= SAME_LINE_TOLERANCE ? a.x - b.x : a.y - b.y
      );

      const lines: string[] = [];
      let lineY: number | null = null;
      for (const run of runs) {
        if (lineY !== null && Math.abs(run.y - lineY) <= SAME_LINE_TOLERANCE) {
          lines[lines.length - 1] += run.text;
        } else {
          lines.push(run.text);
          lineY = run.y;
        }
      }

      return lines.map((l) => l.trim()).filter(Boolean).join("\n");
    })
    .filter(Boolean)
    .join("\n\n");
}

/** pdf2json percent-encodes run text; a malformed run must not kill the page. */
function decodeText(raw: string): string {
  try {
    return decodeURIComponent(raw);
  } catch {
    return raw;
  }
}

export async function parseScannerPdf(buffer: Buffer): Promise<ExtractedScannerData> {
  let rawText = "";

  try {
    rawText = await new Promise<string>((resolve) => {
      const pdfParser = new (PDFParser as unknown as RawTextPdfParserCtor)(null, 1);

      pdfParser.on("pdfParser_dataError", (errData) => {
        console.warn("PDF parser error:", errData?.parserError);
        resolve(buffer.toString("utf-8"));
      });

      pdfParser.on("pdfParser_dataReady", (data) => {
        // Geometry first. `getRawTextContent()` is kept as the fallback for a
        // PDF whose page data does not come through, since garbled text still
        // beats no text.
        const ordered = textInReadingOrder(data);
        if (ordered.trim()) return resolve(ordered);
        const text = pdfParser.getRawTextContent();
        resolve(text || buffer.toString("utf-8"));
      });

      pdfParser.parseBuffer(buffer);
    });
  } catch (err) {
    console.warn("Error in parseScannerPdf:", err);
    rawText = buffer.toString("utf-8");
  }

  // Extract VIN (17 alphanumeric characters, excluding I, O, Q)
  const vinMatch =
    rawText.match(/\bVIN[:\s]*([A-HJ-NPR-Z0-9]{17})\b/i) ||
    rawText.match(/\b([A-HJ-NPR-Z0-9]{17})\b/);
  const extractedVin = vinMatch ? vinMatch[1].toUpperCase() : undefined;

  // Extract Make
  const makeMatch = rawText.match(/Make[:\s]*([^\n\r]+)/i);
  const extractedMake = makeMatch ? makeMatch[1].trim() : undefined;

  // Extract Model
  const modelMatch = rawText.match(/Model[:\s]*([^\n\r]+)/i);
  const extractedModel = modelMatch ? modelMatch[1].trim() : undefined;

  // Extract Year
  const yearMatch = rawText.match(/Year[:\s]*([^\n\r]+)/i);
  const extractedYear = yearMatch ? yearMatch[1].trim() : undefined;

  // Extract Mileage
  const mileageMatch = rawText.match(/Mileage[:\s]*([^\n\r]+)/i);
  const extractedMileage = mileageMatch ? mileageMatch[1].trim() : undefined;

  // Extract Scanner Tool name
  const scannerMatch = rawText.match(/The Report is created by\s+([^\n\r]+)/i);
  const scannerTool = scannerMatch ? scannerMatch[1].trim() : "Ediag / Launch OBD-II Scanner";

  // Extract DTC codes (e.g. P0102, B2321, C1201, U0100)
  const dtcRegex = /\b([PBUC][0-9A-Fa-f]{4})\b/g;
  const standardCodes = Array.from(
    new Set((rawText.match(dtcRegex) || []).map((c) => c.toUpperCase()))
  );

  return {
    rawText,
    extractedVin,
    extractedMake,
    extractedModel,
    extractedYear,
    extractedMileage,
    scannerTool,
    codesFound: standardCodes,
  };
}
