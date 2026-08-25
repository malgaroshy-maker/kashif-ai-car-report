import PDFParser from "pdf2json";

/**
 * pdf2json ships types that do not describe the two-argument constructor or
 * `getRawTextContent()`, both of which are documented and in use. This is the
 * shape actually called, declared once here rather than cast at each call.
 */
interface RawTextPdfParser {
  on(event: "pdfParser_dataError", handler: (err: { parserError?: unknown }) => void): void;
  on(event: "pdfParser_dataReady", handler: () => void): void;
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

export async function parseScannerPdf(buffer: Buffer): Promise<ExtractedScannerData> {
  let rawText = "";

  try {
    rawText = await new Promise<string>((resolve) => {
      const pdfParser = new (PDFParser as unknown as RawTextPdfParserCtor)(null, 1);

      pdfParser.on("pdfParser_dataError", (errData) => {
        console.warn("PDF parser error:", errData?.parserError);
        resolve(buffer.toString("utf-8"));
      });

      pdfParser.on("pdfParser_dataReady", () => {
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
  const standardCodes = Array.from(new Set(rawText.match(dtcRegex) || []));

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
