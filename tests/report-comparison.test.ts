import { describe, expect, it } from "vitest";
import {
  compareDiagnosticReports,
  generateComparisonShareableText,
} from "@/lib/report-comparison";
import type { KashifDiagnosticReport, DiagnosticCodeDetail } from "@/lib/types";

function createMockReport(overrides: Partial<KashifDiagnosticReport>): KashifDiagnosticReport {
  return {
    reportId: "test-" + Math.random(),
    generatedAt: "2026-10-21T10:00:00Z",
    scannerInfo: { toolName: "Launch X431" },
    vehicle: {
      make: "Toyota",
      model: "Camry",
      year: "2015",
      vin: "4T1BF1FK5EU123456",
      mileage: "120000 km",
    },
    summary: {
      overallHealthScore: 70,
      severityStatus: "متوسط / انتبه",
      briefSummaryArabic: "تقرير تجريبي",
      isScoreEstimated: false,
      systemsCheckedCount: 10,
      faultsFoundCount: 2,
      passedSystemsCount: 8,
    },
    faultCategories: {
      criticalFaults: [],
      moderateFaults: [],
      minorOrHistoricalFaults: [],
    },
    passedSystems: [],
    sparePartsRequired: [],
    workshopChecklist: [],
    ...overrides,
  };
}

function makeFault(code: string, desc: string): DiagnosticCodeDetail {
  return {
    code,
    module: "ECM",
    moduleNameArabic: "كمبيوتر المحرك",
    standardDescriptionEn: desc,
    libyanTerm: desc,
    standardArabicDescription: desc,
    driverSymptoms: [],
    rootCauses: [],
    urgencyLevel: "متوسط",
    impactOnVehicle: {
      safety: "متوسط",
      fuelEconomy: "متأثر",
      drivability: "عزم ضعيف / تفتفة",
    },
    recommendedAction: "فحص الحساس",
  };
}

describe("Report Comparison Service", () => {
  it("correctly identifies resolved, persistent, and new faults", () => {
    const before = createMockReport({
      summary: {
        overallHealthScore: 50,
        severityStatus: "حرج / خطر",
        briefSummaryArabic: "فحص أولي قبل الصيانة",
        isScoreEstimated: false,
        systemsCheckedCount: 10,
        faultsFoundCount: 2,
        passedSystemsCount: 8,
      },
      faultCategories: {
        criticalFaults: [makeFault("P0300", "تفتفة في المحرك")],
        moderateFaults: [makeFault("P0171", "خليط وقود فقير")],
        minorOrHistoricalFaults: [],
      },
    });

    const after = createMockReport({
      summary: {
        overallHealthScore: 85,
        severityStatus: "سليم / خفيف",
        briefSummaryArabic: "فحص بعد الصيانة",
        isScoreEstimated: false,
        systemsCheckedCount: 10,
        faultsFoundCount: 1,
        passedSystemsCount: 9,
      },
      faultCategories: {
        criticalFaults: [],
        moderateFaults: [makeFault("P0171", "خليط وقود فقير")], // persistent
        minorOrHistoricalFaults: [makeFault("C0035", "حساس سرعة العجلة")], // new
      },
    });

    const result = compareDiagnosticReports(before, after);

    expect(result.healthScoreBefore).toBe(50);
    expect(result.healthScoreAfter).toBe(85);
    expect(result.healthScoreDiff).toBe(35);
    expect(result.isImproved).toBe(true);
    expect(result.improvementBadge).toBe("+35% تحسن");

    // Resolved: P0300 was in before, but not in after
    expect(result.resolvedFaults.length).toBe(1);
    expect(result.resolvedFaults[0].code).toBe("P0300");

    // Persistent: P0171 is in both
    expect(result.persistentFaults.length).toBe(1);
    expect(result.persistentFaults[0].code).toBe("P0171");

    // New: C0035 is in after, was not in before
    expect(result.newFaults.length).toBe(1);
    expect(result.newFaults[0].code).toBe("C0035");
  });

  it("generates formatted WhatsApp text certificate", () => {
    const before = createMockReport({
      summary: { overallHealthScore: 60, severityStatus: "متوسط / انتبه", briefSummaryArabic: "قبل", isScoreEstimated: false, systemsCheckedCount: 10, faultsFoundCount: 1, passedSystemsCount: 9 },
      faultCategories: {
        criticalFaults: [makeFault("P0300", "تفتفة")],
        moderateFaults: [],
        minorOrHistoricalFaults: [],
      },
    });

    const after = createMockReport({
      summary: { overallHealthScore: 90, severityStatus: "سليم / خفيف", briefSummaryArabic: "بعد", isScoreEstimated: false, systemsCheckedCount: 10, faultsFoundCount: 0, passedSystemsCount: 10 },
      faultCategories: {
        criticalFaults: [],
        moderateFaults: [],
        minorOrHistoricalFaults: [],
      },
    });

    const result = compareDiagnosticReports(before, after);
    const text = generateComparisonShareableText(result, "مركز طرابلس الهندسي");

    expect(text).toContain("شهادة مقارنة وإثبات الصيانة");
    expect(text).toContain("مركز طرابلس الهندسي");
    expect(text).toContain("Toyota Camry");
    expect(text).toContain("+30% تحسن");
    expect(text).toContain("أعطال تم إصلاحها بنجاح");
    expect(text).toContain("P0300");
  });
});
