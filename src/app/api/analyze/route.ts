import { NextRequest, NextResponse } from "next/server";
import { parseScannerPdf } from "@/lib/pdf-parser";
import { analyzeReportWithGemini, normalizeDiagnosticReport, getKashifSystemInstruction } from "@/lib/gemini";
import { SAMPLE_BMW_528I, SAMPLE_TOYOTA_COROLLA } from "@/lib/sample-data";
import { enrichReportWithOnlinePartImages } from "@/lib/parts-search";
import { tryAgyPrompt, parseAgyJson } from "@/lib/agy";
import { KashifError, errorPayload } from "@/lib/errors";
import { resolveModelId } from "@/lib/models";

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
        return NextResponse.json({ success: true, report: SAMPLE_BMW_528I });
      }
      if (sampleId === "toyota-corolla") {
        return NextResponse.json({ success: true, report: SAMPLE_TOYOTA_COROLLA });
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
        let report: any = null;

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

        // Dynamically enrich parts with live internet image search
        if (report && report.sparePartsRequired && report.sparePartsRequired.length > 0) {
          try {
            report.sparePartsRequired = await enrichReportWithOnlinePartImages(
              report.sparePartsRequired,
              report?.vehicle?.make ?? undefined,
              report?.vehicle?.model ?? undefined,
              report?.vehicle?.year ?? undefined
            );
          } catch (e) {
            console.warn("Could not enrich part images:", e);
          }
        }

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

        if (report && report.sparePartsRequired && report.sparePartsRequired.length > 0) {
          try {
            report.sparePartsRequired = await enrichReportWithOnlinePartImages(
              report.sparePartsRequired,
              report?.vehicle?.make ?? undefined,
              report?.vehicle?.model ?? undefined,
              report?.vehicle?.year ?? undefined
            );
          } catch (e) {
            console.warn("Could not enrich part images:", e);
          }
        }

        return NextResponse.json({ success: true, report });
      }
    }

    // 2. JSON Request (Manual text, codes, or sample selection)
    const body = await req.json();
    const activeApiKey = body.apiKey || userApiKey;

    if (body.sampleId === "bmw-528i") {
      return NextResponse.json({ success: true, report: SAMPLE_BMW_528I });
    }
    if (body.sampleId === "toyota-corolla") {
      return NextResponse.json({ success: true, report: SAMPLE_TOYOTA_COROLLA });
    }

    // Without this, an empty body reached the model as a prompt with no scan
    // data in it and the request hung until something upstream gave up.
    if (!body.textReport && !body.manualCodes && !body.imageBase64) {
      throw new KashifError("NO_INPUT");
    }

    let report: any = null;

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

    // Dynamically search the internet for part images
    if (report && report.sparePartsRequired && report.sparePartsRequired.length > 0) {
      try {
        report.sparePartsRequired = await enrichReportWithOnlinePartImages(
          report.sparePartsRequired,
          report?.vehicle?.make,
          report?.vehicle?.model,
          report?.vehicle?.year
        );
      } catch (e) {
        console.warn("Could not enrich part images:", e);
      }
    }

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
