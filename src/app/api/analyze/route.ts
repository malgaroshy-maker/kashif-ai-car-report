import { NextRequest, NextResponse } from "next/server";
import { parseScannerPdf } from "@/lib/pdf-parser";
import { analyzeReportWithGemini, normalizeDiagnosticReport, getKashifSystemInstruction } from "@/lib/gemini";
import { SAMPLE_BMW_528I, SAMPLE_TOYOTA_COROLLA } from "@/lib/sample-data";
import { tryAgyPrompt, parseAgyJson } from "@/lib/agy";
import { KashifError, errorPayload } from "@/lib/errors";
import { resolveModelId } from "@/lib/models";

/**
 * The demo reports, put through the same normaliser a real analysis goes
 * through.
 *
 * They used to be returned as written. That made the demo — the thing a new
 * reader judges the product by — disclose less than the real thing: it printed
 * OEM numbers with no "this came from the assistant, not the scanner" note,
 * engine specs with no "worked out from the VIN" mark, and a readiness score
 * with nothing saying it is an estimate. The report a real scan produces says
 * all three.
 *
 * It also fixes what the fixtures got wrong about themselves: the BMW sample
 * announced 28 faults above a list of 8, and the Toyota said four systems were
 * checked where three faults and three passed systems make six. The counts are
 * taken from the lists now, here as everywhere else.
 */
function demoReport(sample: unknown) {
  return normalizeDiagnosticReport(sample);
}

/** Uploads are base64'd for the model; cap before that. */
const MAX_UPLOAD_BYTES = 8 * 1024 * 1024;
const ALLOWED_MIME = /^(application\/pdf|image\/(jpeg|png|webp))$/;

export async function POST(req: NextRequest) {
  try {
    const contentType = req.headers.get("content-type") || "";
    const userApiKey = req.headers.get("x-gemini-api-key") || undefined;
    const providerHeader = req.headers.get("x-ai-provider") || undefined;
    const headerModel = req.headers.get("x-gemini-model") || undefined;

    // 1. Multipart Form Data (Direct File Upload)
    if (contentType.includes("multipart/form-data")) {
      const formData = await req.formData();
      const file = formData.get("file") as File | null;
      const sampleId = formData.get("sampleId") as string | null;
      const formApiKey = (formData.get("apiKey") as string) || userApiKey;
      const provider = (formData.get("provider") as string) || providerHeader || "gemini";

      if (sampleId === "bmw-528i") {
        return NextResponse.json({ success: true, report: demoReport(SAMPLE_BMW_528I) });
      }
      if (sampleId === "toyota-corolla") {
        return NextResponse.json({ success: true, report: demoReport(SAMPLE_TOYOTA_COROLLA) });
      }

      if (!file) throw new KashifError("NO_INPUT");
      if (file.size > MAX_UPLOAD_BYTES) {
        throw new KashifError("FILE_TOO_LARGE", `${file.size} bytes`);
      }
      const formModel = (formData.get("model") as string) || headerModel;

      const fileBuffer = Buffer.from(await file.arrayBuffer());
      const isPdf = file.type === "application/pdf" || file.name.endsWith(".pdf");

      if (isPdf) {
        const parsedPdf = await parseScannerPdf(fileBuffer);
        let report: unknown = null;

        // Try AGY CLI if selected
        if (provider === "agy") {
          const agyOutput = await tryAgyPrompt(
            `${getKashifSystemInstruction()}\n\nنص تقرير الفحص المستخرج:\n${parsedPdf.rawText}`,
            90_000
          );
          if (agyOutput) report = await parseAgyJson(agyOutput);
        }

        if (!report) {
          report = await analyzeReportWithGemini(
            {
              textReport: parsedPdf.rawText,
              vehicleInfo: {
                vin: parsedPdf.extractedVin,
                make: parsedPdf.extractedMake,
                model: parsedPdf.extractedModel,
                year: parsedPdf.extractedYear,
              },
            },
            formApiKey,
            resolveModelId(formModel)
          );
        }

        report = normalizeDiagnosticReport(report, {
          textReport: parsedPdf.rawText,
          vehicleInfo: {
            vin: parsedPdf.extractedVin,
            make: parsedPdf.extractedMake,
            model: parsedPdf.extractedModel,
            year: parsedPdf.extractedYear,
          },
        });

        return NextResponse.json({ success: true, report });
      } else {
        // Image upload (OCR & Vision AI)
        const mimeType = file.type || "image/jpeg";
        if (!ALLOWED_MIME.test(mimeType)) {
          throw new KashifError("UNSUPPORTED_FILE", mimeType);
        }
        const base64Data = fileBuffer.toString("base64");
        let report = await analyzeReportWithGemini(
          {
            imageParts: [{ inlineData: { data: base64Data, mimeType } }],
          },
          formApiKey,
          resolveModelId(formModel)
        );

        report = normalizeDiagnosticReport(report);

        return NextResponse.json({ success: true, report });
      }
    }

    // 2. JSON Request (Manual text, codes, or sample selection)
    const body = await req.json();
    const activeApiKey = body.apiKey || userApiKey;

    if (body.sampleId === "bmw-528i") {
      return NextResponse.json({ success: true, report: demoReport(SAMPLE_BMW_528I) });
    }
    if (body.sampleId === "toyota-corolla") {
      return NextResponse.json({ success: true, report: demoReport(SAMPLE_TOYOTA_COROLLA) });
    }

    // Without this, an empty body reached the model as a prompt with no scan
    // data in it and the request hung until something upstream gave up.
    if (!body.textReport && !body.manualCodes && !body.imageBase64) {
      throw new KashifError("NO_INPUT");
    }

    let report: unknown = null;

    if (body.provider === "agy" && (body.textReport || body.manualCodes)) {
      const inputData = body.textReport
        ? `تقرير الفحص:\n${body.textReport}`
        : `الأكواد:\n${body.manualCodes}\nالسيارة: ${JSON.stringify(body.vehicleInfo || {})}`;
      const agyOutput = await tryAgyPrompt(
        `${getKashifSystemInstruction()}\n\nبيانات الفحص:\n${inputData}`,
        90_000
      );
      if (agyOutput) report = await parseAgyJson(agyOutput);
    }

    if (!report) {
      report = await analyzeReportWithGemini(
        {
          textReport: body.textReport,
          manualCodes: body.manualCodes,
          vehicleInfo: body.vehicleInfo,
          imageParts: body.imageBase64
            ? [
                {
                  inlineData: {
                    data: body.imageBase64,
                    mimeType: body.imageMimeType || "image/jpeg",
                  },
                },
              ]
            : undefined,
        },
        activeApiKey,
        resolveModelId(body.model || headerModel)
      );
    }

    report = normalizeDiagnosticReport(report, body);

    return NextResponse.json({ success: true, report });
  } catch (error) {
    const { body, status } = errorPayload(error);
    if (error instanceof KashifError) {
      console.warn(`[analyze] ${error.code}: ${error.detail ?? ""}`);
    } else {
      // Never echo an unexpected error's message to the client: an upstream
      // body can contain the caller's own API key.
      console.error("[analyze] unexpected", error);
    }
    return NextResponse.json(body, { status });
  }
}
