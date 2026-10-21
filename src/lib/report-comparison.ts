import { KashifDiagnosticReport, DiagnosticCodeDetail, orUnknown } from "./types";

export interface ReportComparisonResult {
  beforeReport: KashifDiagnosticReport;
  afterReport: KashifDiagnosticReport;
  healthScoreBefore: number;
  healthScoreAfter: number;
  healthScoreDiff: number;
  resolvedFaults: DiagnosticCodeDetail[];
  persistentFaults: DiagnosticCodeDetail[];
  newFaults: DiagnosticCodeDetail[];
  isImproved: boolean;
  improvementBadge: string;
}

function extractAllCodes(report: KashifDiagnosticReport): DiagnosticCodeDetail[] {
  const cats = report.faultCategories || {
    criticalFaults: [],
    moderateFaults: [],
    minorOrHistoricalFaults: [],
  };
  return [
    ...(cats.criticalFaults || []),
    ...(cats.moderateFaults || []),
    ...(cats.minorOrHistoricalFaults || []),
  ];
}

export function compareDiagnosticReports(
  before: KashifDiagnosticReport,
  after: KashifDiagnosticReport
): ReportComparisonResult {
  const beforeFaults = extractAllCodes(before);
  const afterFaults = extractAllCodes(after);

  const beforeCodeSet = new Set(beforeFaults.map((f) => f.code.trim().toUpperCase()));
  const afterCodeSet = new Set(afterFaults.map((f) => f.code.trim().toUpperCase()));

  // 1. Resolved: in before, not in after
  const resolvedFaults = beforeFaults.filter(
    (f) => !afterCodeSet.has(f.code.trim().toUpperCase())
  );

  // 2. Persistent: in both before and after
  const persistentFaults = afterFaults.filter((f) =>
    beforeCodeSet.has(f.code.trim().toUpperCase())
  );

  // 3. New: in after, not in before
  const newFaults = afterFaults.filter(
    (f) => !beforeCodeSet.has(f.code.trim().toUpperCase())
  );

  const scoreBefore = before.summary?.overallHealthScore ?? 0;
  const scoreAfter = after.summary?.overallHealthScore ?? 0;
  const diff = scoreAfter - scoreBefore;

  let badge = "لا تغيير في النقاط";
  if (diff > 0) {
    badge = `+${diff}% تحسن`;
  } else if (diff < 0) {
    badge = `${diff}% تراجع`;
  }

  return {
    beforeReport: before,
    afterReport: after,
    healthScoreBefore: scoreBefore,
    healthScoreAfter: scoreAfter,
    healthScoreDiff: diff,
    resolvedFaults,
    persistentFaults,
    newFaults,
    isImproved: diff > 0 || resolvedFaults.length > 0,
    improvementBadge: badge,
  };
}

export function generateComparisonShareableText(
  res: ReportComparisonResult,
  workshopName?: string
): string {
  const v = res.afterReport.vehicle;
  const carName = `${orUnknown(v.make, "سيارة")} ${orUnknown(v.model, "")} (${orUnknown(v.year, "")})`.trim();
  const vin = orUnknown(v.vin);

  const lines: string[] = [];
  lines.push(`📋 *شهادة مقارنة وإثبات الصيانة — Flow Cars*`);
  if (workshopName?.trim()) {
    lines.push(`🏢 *الورشة المعتمدة:* ${workshopName.trim()}`);
  }
  lines.push("━━━━━━━━━━━━━━━━━━━━━");
  lines.push(`🚗 *المركبة:* ${carName}`);
  if (vin && vin !== "غير محدد") {
    lines.push(`🔢 *رقم الهيكل (VIN):* ${vin}`);
  }
  lines.push("");
  lines.push(`📅 *فحص ما قبل الصيانة:* ${res.beforeReport.generatedAt.slice(0, 10)}`);
  lines.push(`📊 *نسبة الجاهزية الأولية:* ${res.healthScoreBefore}% (${res.beforeReport.summary.severityStatus})`);
  lines.push("");
  lines.push(`📅 *فحص ما بعد الصيانة:* ${res.afterReport.generatedAt.slice(0, 10)}`);
  lines.push(`📊 *نسبة الجاهزية الحالية:* ${res.healthScoreAfter}% (${res.afterReport.summary.severityStatus})`);
  lines.push(`📈 *مستوى التحسن:* ${res.improvementBadge}`);
  lines.push("━━━━━━━━━━━━━━━━━━━━━");

  if (res.resolvedFaults.length > 0) {
    lines.push(`✅ *أعطال تم إصلاحها بنجاح (${res.resolvedFaults.length}):*`);
    for (const f of res.resolvedFaults) {
      lines.push(`  • [${f.code}] ${f.libyanTerm || f.standardArabicDescription}`);
    }
    lines.push("");
  }

  if (res.persistentFaults.length > 0) {
    lines.push(`⚠️ *أعطال مستمرة لا تزال قائمة (${res.persistentFaults.length}):*`);
    for (const f of res.persistentFaults) {
      lines.push(`  • [${f.code}] ${f.libyanTerm || f.standardArabicDescription}`);
    }
    lines.push("");
  }

  if (res.newFaults.length > 0) {
    lines.push(`🔴 *أعطال جديدة ظهرت بالفحص الأخير (${res.newFaults.length}):*`);
    for (const f of res.newFaults) {
      lines.push(`  • [${f.code}] ${f.libyanTerm || f.standardArabicDescription}`);
    }
    lines.push("");
  }

  lines.push("━━━━━━━━━━━━━━━━━━━━━");
  lines.push("✨ تم الفحص والمقارنة آلياً عبر نظام كاشف Flow Cars");

  return lines.join("\n");
}
