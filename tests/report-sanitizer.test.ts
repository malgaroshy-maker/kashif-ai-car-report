import { describe, expect, it } from "vitest";
import { ReportSanitizer } from "@/lib/report-sanitizer";

describe("ReportSanitizer", () => {
  it("cleans scanner device vendor branding", () => {
    expect(ReportSanitizer.clean("تم الفحص بواسطة جهاز كشف Ediag")).toBe("تم الفحص عبر الفحص الإلكتروني الشامل");
    expect(ReportSanitizer.clean("تقرير جهاز Launch X431")).toBe("تقرير الفحص الإلكتروني");
    expect(ReportSanitizer.clean("جهاز فحص Autel")).toBe("جهاز الفحص");
  });

  it("converts non-Libyan dialect words to authentic Libyan workshop terms", () => {
    // Transmission
    expect(ReportSanitizer.clean("فحص القير العادي والقير الأوتوماتيكي")).toContain("الكمبيو");
    expect(ReportSanitizer.clean("طنجرة القير")).toContain("طنجرة الكمبيو (الكونفيرتا)");
    expect(ReportSanitizer.clean("عقل القير")).toContain("بوكس الكمبيو (الفالف بدي)");

    // Spark Plugs & Coils
    expect(ReportSanitizer.clean("تبديل البواجي والكويلات")).toContain("شمعات");
    expect(ReportSanitizer.clean("تبديل البواجي والكويلات")).toContain("بوبينات");

    // Suspension
    expect(ReportSanitizer.clean("تغيير المساعدين والمقصات")).toContain("مزاطوريات");
    expect(ReportSanitizer.clean("تغيير المساعدين والمقصات")).toContain("براتشوات");

    // Brakes
    expect(ReportSanitizer.clean("تغيير فحمات الفرامل")).toContain("باطنيات ديسكو");

    // Fuel pump
    expect(ReportSanitizer.clean("طرمبة البنزين")).toContain("بومبة البنزين");

    // Misfire / Stutter
    expect(ReportSanitizer.clean("رعشة وتفتفة في المحرك")).toContain("فطفطة");

    // Technician label
    expect(ReportSanitizer.clean("خطوات فحص الأسطى")).toContain("خطوات الفحص الفني والورشة");
  });

  it("replaces Control Unit 'عقل' with 'بوكس'", () => {
    expect(ReportSanitizer.clean("عقل الكمبيو")).toContain("بوكس الكمبيو");
    expect(ReportSanitizer.clean("عقل الإيرباق")).toContain("بوكس الإيرباق");
  });

  it("collapses duplicate parentheticals like X (X)", () => {
    expect(ReportSanitizer.clean("كمبيو (كمبيو)")).toBe("كمبيو");
  });
});
