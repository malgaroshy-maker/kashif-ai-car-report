import { NextRequest, NextResponse } from "next/server";
import { parseScannerPdf } from "@/lib/pdf-parser";
import { analyzeReportWithGemini, normalizeDiagnosticReport, getKashifSystemInstruction } from "@/lib/gemini";
import { SAMPLE_BMW_528I, SAMPLE_TOYOTA_COROLLA } from "@/lib/sample-data";
import { enrichReportWithOnlinePartImages } from "@/lib/parts-search";
import { runAgyPrompt, extractJsonFromAgyResponse, getAgyCliStatus } from "@/lib/antigravity-cli";

export async function POST(req: NextRequest) {
  try {
    const contentType = req.headers.get("content-type") || "";
    const userApiKey = req.headers.get("x-gemini-api-key") || undefined;
    const providerHeader = req.headers.get("x-ai-provider") || undefined;

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

      if (!file) {
        return NextResponse.json(
          { success: false, error: "لم يتم استلام أي ملف للفحص" },
          { status: 400 }
        );
      }

      const fileBuffer = Buffer.from(await file.arrayBuffer());
      const isPdf = file.type === "application/pdf" || file.name.endsWith(".pdf");

      if (isPdf) {
        const parsedPdf = await parseScannerPdf(fileBuffer);
        let report: any = null;

        // Try AGY CLI if selected
        if (provider === "agy") {
          try {
            const agyStatus = await getAgyCliStatus();
            if (agyStatus.available) {
              const fullPrompt = `${getKashifSystemInstruction()}\n\nنص تقرير الفحص المستخرج:\n${parsedPdf.rawText}`;
              const agyOutput = await runAgyPrompt(fullPrompt, 90000);
              report = extractJsonFromAgyResponse(agyOutput);
            }
          } catch (agyErr) {
            console.warn("AGY execution failed, falling back to Gemini API:", agyErr);
          }
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
            formApiKey
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
              report?.vehicle?.make,
              report?.vehicle?.model,
              report?.vehicle?.year
            );
          } catch (e) {
            console.warn("Could not enrich part images:", e);
          }
        }

        return NextResponse.json({ success: true, report });
      } else {
        // Image upload (OCR & Vision AI)
        const base64Data = fileBuffer.toString("base64");
        const mimeType = file.type || "image/jpeg";
        let report = await analyzeReportWithGemini(
          {
            imageParts: [{ inlineData: { data: base64Data, mimeType } }],
          },
          formApiKey
        );

        report = normalizeDiagnosticReport(report);

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

    let report: any = null;

    if (body.provider === "agy" && (body.textReport || body.manualCodes)) {
      try {
        const agyStatus = await getAgyCliStatus();
        if (agyStatus.available) {
          const inputData = body.textReport ? `تقرير الفحص:\n${body.textReport}` : `الأكواد:\n${body.manualCodes}\nالسيارة: ${JSON.stringify(body.vehicleInfo || {})}`;
          const fullPrompt = `${getKashifSystemInstruction()}\n\nبيانات الفحص:\n${inputData}`;
          const agyOutput = await runAgyPrompt(fullPrompt, 90000);
          report = extractJsonFromAgyResponse(agyOutput);
        }
      } catch (agyErr) {
        console.warn("AGY JSON analyze failed, falling back to Gemini API:", agyErr);
      }
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
        activeApiKey
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
  } catch (error: any) {
    console.error("API Analyze Error:", error);
    return NextResponse.json(
      { success: false, error: error.message || "حدث خطأ أثناء معالجة التقرير" },
      { status: 500 }
    );
  }
}
