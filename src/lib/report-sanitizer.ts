/**
 * Libyan Automotive Workshop Terminology Sanitizer & Device Brand Filter
 * Ported from Flow Cars / Kashif Mobile (report_sanitizer.dart)
 */

import { KashifDiagnosticReport, DiagnosticCodeDetail, SparePartItem } from "./types";

const rxCache = new Map<string, RegExp>();

function rx(pattern: string, flags: string = "g"): RegExp {
  const key = `${flags}|${pattern}`;
  let r = rxCache.get(key);
  if (!r) {
    r = new RegExp(pattern, flags);
    rxCache.set(key, r);
  }
  return r;
}

export class ReportSanitizer {
  static clean(input?: string | null): string {
    if (!input || !input.trim()) return "";

    let text = input
      .replace(rx(String.raw`بواسطة\s+جهاز\s+(كشف|فحص)\s+[A-Za-z0-9_\-]+(\s+[A-Za-z0-9_\-]+)*`, "gi"), "عبر الفحص الإلكتروني الشامل")
      .replace(rx(String.raw`بجهاز\s+(كشف|فحص)\s+[A-Za-z0-9_\-]+(\s+بدون\s+إنترنت)?(\s+[A-Za-z0-9_\-]+)*`, "gi"), "عبر الفحص الإلكتروني الشامل")
      .replace(rx(String.raw`تقرير\s+جهاز\s+[A-Za-z0-9_\-]+(\s+[A-Za-z0-9_\-]+)*`, "gi"), "تقرير الفحص الإلكتروني")
      .replace(rx(String.raw`جهاز\s+(كشف|فحص)\s+(Ediag|Launch|Autel|Thinkdiag|G-Scan|OBD)(\s+[A-Za-z0-9_\-]+)*`, "gi"), "جهاز الفحص")
      .replace(rx(String.raw`\(Ediag\s+أو\s+ما\s+يعادله\)`, "gi"), "بجهاز الفحص المعتمد")
      .replace(rx(String.raw`Ediag|Thinkdiag|Autel|Launch`, "gi"), "")
      .replace(rx(String.raw`خطوات\s+فحص\s+الأ?سطى\s+والورشة|خطوات\s+فحص\s+الأ?سطى|فحص\s+الأ?سطى`, "gi"), "خطوات الفحص الفني والورشة")
      .replace(rx(String.raw`الأ?سطى`, "gi"), "الفني");

    return this.applyTerms(text).replace(rx(String.raw`\s{2,}`), " ").trim();
  }

  static applyTerms(input: string): string {
    if (!input) return "";
    let text = input;
    // Arabic letter boundary helper:
    // (?<![\u0621-\u0647\u0649\u064A]) ensures not preceded by an Arabic letter
    // (?![\u0621-\u064A]) ensures not followed by an Arabic letter
    // 1. Transmission: قير / جير / فتيس / ناقل حركة -> كمبيو
    text = text.replace(rx(String.raw`ناقل\s+الحركة\s+الأوتوماتيكي?`), "الكمبيو الأوتوماتيك");
    text = text.replace(rx(String.raw`ناقل\s+الحركة\s+العادي?|ناقل\s+الحركة\s+اليدوي?`), "الكمبيو العادي");
    text = text.replace(rx(String.raw`ناقل\s+الحركة`), "الكمبيو");
    text = text.replace(rx(String.raw`ناقل\s+حركة`), "كمبيو");
    text = text.replace(rx(String.raw`طنجرة\s+(القير|الجير)`), "طنجرة الكمبيو (الكونفيرتا)");
    text = text.replace(rx(String.raw`عقل\s+(القير|الجير)|مخ\s+(القير|الجير)`), "بوكس الكمبيو (الفالف بدي)");
    text = text.replace(rx(String.raw`زيت\s+(القير|الجير)`), "زيت الكمبيو");
    text = text.replace(rx(String.raw`فلتر\s+(القير|الجير)`), "فيلترو الكمبيو");
    text = text.replace(rx(String.raw`مبرد\s+(القير|الجير)`), "مبرد الكمبيو");
    text = text.replace(rx(String.raw`حساس\s+(القير|الجير)|حساسات\s+(القير|الجير)`), "حساس الكمبيو");
    text = text.replace(rx(String.raw`كمبيوتر\s+(القير|الجير)`), "كمبيوتر الكمبيو (TCM)");
    text = text.replace(rx(String.raw`عصا\s+(القير|الجير)|ذراع\s+(القير|الجير)`), "مارشا");
    // Definite: القير / الجير / الفتيس
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)(قير|قاير|جير|فتيس)(?![\u0621-\u064A])`), "$1كمبيو");
    // Plural: قيرات / جيرات
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)?(قيرات|جيرات)(?![\u0621-\u064A])`), "كمبيوات");
    // Indefinite: قير / جير / فتيس
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(قير|قاير|جير|فتيس)(?![\u0621-\u064A])`), "كمبيو");
    // 2. Fuel / Water / Oil Pump: طرمبة / طلمبة -> بومبة
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)(طرمب|طلمب)(ة|ات)(?![\u0621-\u064A])`), "$1بومب$3");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(طرمب|طلمب)ة(?![\u0621-\u064A])`), "بومبة");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(طرمب|طلمب)ات(?![\u0621-\u064A])`), "بومبات");
    // 3. Brake Pads: فحمات / قماشات / تيل فرامل -> باطنيات
    text = text.replace(rx(String.raw`تيل\s+الفرامل|أقمشة\s+الفرامل|فحمات\s+الفرامل`), "باطنيات ديسكو");
    text = text.replace(rx(String.raw`تيل\s+فرامل|أقمشة\s+فرامل|فحمات\s+فرامل`), "باطنيات ديسكو");
    // 4. Control Arms: مقصات / مقص -> براتشوات / براتشو
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)مقصات(?![\u0621-\u064A])`), "$1براتشوات");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])مقصات(?![\u0621-\u064A])`), "براتشوات");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)مقص(?![\u0621-\u064A])`), "$1براتشو");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])مقص(?![\u0621-\u064A])`), "براتشو");
    // 5. Shock Absorbers: مساعدين / مساعدات -> مزاطوريات
    text = text.replace(rx(String.raw`مساعدات\s+الصدمات|ممتصات\s+الصدمات|مساعدين\s+الصدمات`), "مزاطوريات");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)(مساعدين|مساعدات)(?![\u0621-\u064A])`), "$1مزاطوريات");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(مساعدين|مساعدات)(?![\u0621-\u064A])`), "مزاطوريات");
    text = text.replace(rx(String.raw`مساعد\s+(أمامي|خلفي|يمين|يسار)`), "مزاطوري $1");
    text = text.replace(rx(String.raw`المساعد\s+(الأمامي|الخلفي|الأيمن|الأيسر)`), "المزاطوري $1");
    // 6. Axles / CV Joints: عكوس / عكس -> سمياصات / سمياص
    text = text.replace(rx(String.raw`جلدة\s+العكس|جلد\s+العكوس`), "كرشيرة / قومة سمياص");
    text = text.replace(rx(String.raw`رأس\s+العكس|رؤوس\s+العكوس`), "رأس السمياص");
    text = text.replace(rx(String.raw`عمود\s+العكس|أعمدة\s+العكوس`), "عمود السمياص");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)عكوس(?![\u0621-\u064A])`), "$1سمياصات");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])عكوس(?![\u0621-\u064A])`), "سمياصات");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)عكس\s+(الأيمن|الأيسر|الأمامي|الخلفي|الداخلي|الخارجي)`), "$1سمياص $2");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])عكس\s+(أيمن|أيسر|أمامي|خلفي|داخلي|خارجي)`), "سمياص $1");
    // 7. Wheel Bearings: رمان بلي / صرة -> كوشينتي / موتسو
    text = text.replace(rx(String.raw`رمان\s+بلي\s+العجلة|رمان\s+بلي`), "كوشينتي");
    text = text.replace(rx(String.raw`الرمان\s+بلي`), "الكوشينتي");
    text = text.replace(rx(String.raw`صرة\s+العجلة`), "موتسو العجلة");
    // 8. Timing Belt / Chain: سير تيمن / سير تايمن -> كاتينة
    text = text.replace(rx(String.raw`سير\s+(التا?يمن|التوقيت|الكاتينة)`), "كاتينة");
    text = text.replace(rx(String.raw`سير\s+(المحرك|المكينة|الدينمو)`), "قايش المحرك");
    // 9. Exhaust: شكمان -> مرميطة
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)شكمان(?![\u0621-\u064A])`), "$1مرميطة");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])شكمان(?![\u0621-\u064A])`), "مرميطة");
    text = text.replace(rx(String.raw`دبة\s+التلوث|محول\s+حفاز|المحول\s+الحفاز`), "علبة كربون المرميطة");
    // 10. Radiator: رديتر / ردياتير / راديتر -> رداتوري
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)(راديتر|ردياتير|رديتر)(?![\u0621-\u064A])`), "$1رداتوري");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(راديتر|ردياتير|رديتر)(?![\u0621-\u064A])`), "رداتوري");
    // 11. Starter: سلف -> موتورينو (مارش)
    text = text.replace(rx(String.raw`سلف\s+التشغيل|مارش\s+التشغيل`), "موتورينو التشغيل");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)سلف(?![\u0621-\u064A])`), "$1موتورينو");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])سلف(?![\u0621-\u064A])`), "موتورينو");
    // 12. Oil Pan: كرتير / كارتير -> ستاقوبا
    text = text.replace(rx(String.raw`كرتير\s+الزيت|كارتير\s+الزيت`), "ستاقوبا الزيت");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)(كرتير|كارتير)(?![\u0621-\u064A])`), "$1ستاقوبا");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(كرتير|كارتير)(?![\u0621-\u064A])`), "ستاقوبا");
    // 13. Steering: دركسون / دركسيون -> ستيرسو / دومان
    text = text.replace(rx(String.raw`طارة\s+(الدركسون|الدركسيون)|عجلة\s+القيادة`), "الدومان (الستيرسو)");
    text = text.replace(rx(String.raw`دودة\s+(الدركسون|الدركسيون)|علبة\s+(الدركسون|الدركسيون)`), "سكاتولة الستيرسو");
    text = text.replace(rx(String.raw`زيت\s+(الدركسون|الدركسيون)`), "زيت الستيرسو");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)(دركسون|دركسيون)(?![\u0621-\u064A])`), "$1ستيرسو");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(دركسون|دركسيون)(?![\u0621-\u064A])`), "ستيرسو");
    // 14. Spark Plugs: بواجي / بوجيه -> شمعات / شمعة
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)(بواجي|بوجيهات)(?![\u0621-\u064A])`), "$1شمعات");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(بواجي|بوجيهات)(?![\u0621-\u064A])`), "شمعات");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)بوجيه(?![\u0621-\u064A])`), "$1شمعة");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])بوجيه(?![\u0621-\u064A])`), "شمعة");
    // 15. Ignition Coils: كويلات / كويل -> بوبينات / بوبينة
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)كويلات(?![\u0621-\u064A])`), "$1بوبينات");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])كويلات(?![\u0621-\u064A])`), "بوبينات");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)كويل(?![\u0621-\u064A])`), "$1بوبينة");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])كويل(?![\u0621-\u064A])`), "بوبينة");
    // 16. Fuel Injectors: بخاخات / بخاخ -> رشاشات / رشاش
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)بخاخات(?![\u0621-\u064A])`), "$1رشاشات");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])بخاخات(?![\u0621-\u064A])`), "رشاشات");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)بخاخ(?![\u0621-\u064A])`), "$1رشاش");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])بخاخ(?![\u0621-\u064A])`), "رشاش");
    // 17. Tires: كفرات -> قومّات
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])(ال|بال|لل|فال|وال)كفرات(?![\u0621-\u064A])`), "$1قومّات");
    text = text.replace(rx(String.raw`(?<![\u0621-\u0647\u0649\u064A])كفرات(?![\u0621-\u064A])`), "قومّات");
    // 18. Body: صدام -> براونطي, كبوت -> كوفنو
    text = text.replace(rx(String.raw`صدام\s+(أمامي|خلفي)`), "براونطي $1");
    text = text.replace(rx(String.raw`الصدام\s+(الأمامي|الخلفي)`), "البراونطي $1");
    text = text.replace(rx(String.raw`كبوت\s+السيارة|غطاء\s+المحرك`), "كوفنو السيارة");
    text = text.replace(rx(String.raw`شنطة\s+السيارة`), "باقاج السيارة");
    // 19. Electrical Grounding: أرضية سيئة -> ضعف خط الماس/الأرضي
    // 20. Bad/Loose Connection: اتصال سيئ -> ضعف تلامس كهربائي أو أكسدة في فيشة الحساس
    // 21. Cylinder / Piston: سلندر / مكبس -> بسطوني
    text = text.replace(rx(String.raw`حلقات\s+(ال)?مكبس|سنابر|سيجمانات`), "شنابر");
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال|بال|لل|فال|وال)?(سلندرات|مكابس|بساتم)(?![ء-ي])`), "$1بسطونات");
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال|بال|لل|فال|وال)?(سلندر|مكبس|بستم|بيستون|بستون)(?:اً|ا)?(?![ء-ي])`), "$1بسطوني");
    // 22. Pumps: مضخة -> بومبة
    text = text.replace(rx(String.raw`مضخة\s+(ال)?توجيه(\s+المعزز)?`), "بومبة ستيرسو");
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال|بال|لل|فال|وال)?مضخ(ة|ات)(?![ء-ي])`), "$1بومب$2");
    // 23. Brakes: مكابح -> فرامل, discs -> ديسكو
    text = text.replace(rx(String.raw`أقراص\s+(ال)?(فرامل|مكابح)`), "ديسكوات");
    text = text.replace(rx(String.raw`قرص\s+(ال)?(فرامل|مكابح)`), "ديسكو");
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال|بال|لل|فال|وال)?مكابح(?![ء-ي])`), "$1فرامل");
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال|بال|لل|فال|وال)?(دبرياج|دبريج|قابض)(?![ء-ي])`), "$1فرسيوني");
    // 24. Engine internals & electrical
    text = text.replace(rx(String.raw`رأس\s+(ال)?(محرك|سلندر)|راس\s+(ال)?محرك|سلندر\s+هيد`), "التستاتا");
    text = text.replace(rx(String.raw`كتلة\s+(ال)?(اسطوانات|أسطوانات|محرك)|بلوك\s+المحرك`), "المونوبلوكو");
    text = text.replace(rx(String.raw`ذراع\s+التوصيل|بيالة|بيله`), "البيّلا");
    text = text.replace(rx(String.raw`عمود\s+(ال)?(مرفق|كرنك)|كرنك\s+شافت`), "الكولوا");
    text = text.replace(rx(String.raw`عمود\s+(ال)?كامات|كامشافت`), "الامبروكم");
    text = text.replace(rx(String.raw`عجلة\s+(ال)?توازن|فلاي\s+ويل`), "الفولانو");
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال|بال|لل|فال|وال)?(دينامو|مولد\s+(ال)?كهرباء|مولد\s+كهربائي|مولد)(?![ء-ي])`), "$1دينمو");
    text = text.replace(rx(String.raw`حشية\s+غطاء\s+(ال)?صمامات|جوان\s+غطاء\s+(ال)?صمامات`), "قرسيوني الكوبيركو");
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال|بال|لل|فال|وال)?(حشية|جوان|حشوة)(?![ء-ي])`), "$1قرسيوني");
    text = text.replace(rx(String.raw`سبرنك|سبرنغات|نابض\s+حلزوني|يايات|ياي`), "موليّات (سبرنقات)");
    text = text.replace(rx(String.raw`ماص(ات)?\s+(ال)?صدمات`), "مزاطوري");
    // 25. Filters: فلتر / مرشح -> فيلترو
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال|بال|لل|فال|وال)?(فلتر|فلاتر|مرشح)(?![ء-ي])`), "$1فيلترو");
    // 26. Body, lights, interior
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال|بال|لل|فال|وال)?(مصباح|مصابيح)\s+(ال)?أمامي(ة)?`), "$1فنار");
    text = text.replace(rx(String.raw`لوحة\s+(ال)?عدادات|عداد\s+السرعة\s+والمؤشرات`), "لوحة العدادات (الطبلون)");
    text = text.replace(rx(String.raw`لوحة\s+(ال)?قيادة|داشبورد|داش\s+بورد`), "الطبلون");
    text = text.replace(rx(String.raw`ماسحات\s+(ال)?زجاج`), "المساحات");
    text = text.replace(rx(String.raw`مقبض\s+(ال)?باب`), "مانيليا الباب");
    text = text.replace(rx(String.raw`الإطار\s+الاحتياطي|إطار\s+احتياطي|الاستبن|استبن`), "العجلة الاحتياط (السبير)");
    text = text.replace(rx(String.raw`ماسورة\s+(ال)?عادم|أنبوب\s+(ال)?عادم|نظام\s+(ال)?عادم`), "المرميطة");
    text = text.replace(rx(String.raw`كاتم\s+(ال)?صوت|دبة\s+الرنين`), "كاتم المرميطة");
    text = text.replace(rx(String.raw`مفصل\s+(ال)?تعليق\s+(ال)?كروي|(ال)?جوزة\s+الكروية`), "فوزيلي");
    text = text.replace(rx(String.raw`رأس\s+ذراع\s+(ال)?توجيه|ذراع\s+(ال)?توجيه`), "نوتشي");
    text = text.replace(rx(String.raw`مفتاح\s+(ال)?ربط\s+(ال)?صليبة`), "مفتاح كريك");
    // 27. Diagnostics: ECU -> كمبيوتر السيارة, Relays: كتاوت -> ريليه
    text = text.replace(rx(String.raw`وحدة\s+(ال)?تحكم\s+(ال)?إلكترونية|وحدة\s+(ال)?تحكم\s+(في\s+)?(ال)?محرك`), "كمبيوتر السيارة");
    text = text.replace(rx(String.raw`مرحل\s+كهربائي|المرحل\s+الكهربائي|(?<![ء-هىي])المرحل(?![ء-ي])`), "الريلي");
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال|بال|لل|فال|وال)?كتاوتات(?![ء-ي])`), "$1ريليهات");
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال|بال|لل|فال|وال)?كتاوت(?![ء-ي])`), "$1ريليه");
    // 28. Words the AI invents or uses in formal Arabic / other dialects
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال)?(مذياع|مذيع)(?![ء-ي])`), "$1راديو");
    text = text.replace(rx(String.raw`(طقطوقة|طكاكة)(\s*/\s*(طقطوقة|طكاكة))?(\s+حزام\s+(ال)?أمان|\s+(ال)?شنتورة)?`), "قفل حزام الأمان");
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال|بال|لل|فال|وال)?شنتور[ةة](?![ء-ي])`), "$1حزام أمان");
    // Idle speed: سلانسيه -> سيلانتي
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال)?سلانسيه(?![ء-ي])`), "السيلانتي (الوقوف)");
    // Tires: تواير -> قومات
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال)?تواير(?![ء-ي])`), "قومّات");
    // Wheels: جنط / جنوط -> ديسكو / ديسكوات
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال|بال|لل|فال|وال)?جنوط(?![ء-ي])`), "$1ديسكوات");
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال|بال|لل|فال|وال)?جنط(?![ء-ي])`), "$1ديسكو");
    // Tire puncture shop: بنشر -> ورشة تصليح قومات
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال)?بنشر(?![ء-ي])`), "محل تصليح القومّات (البيلكانو)");
    // Engine knock: collapse stutters and convert cleanly
    text = text.replace(rx(String.raw`دق\s+وتصفيق\s+(ال)?محرك|دق\s+وتصفيق`), "طرق المحرك / الصرقعة (Knock)");
    text = text.replace(rx(String.raw`(?<!طرق المحرك\s*/\s*)(?<![ء-هىي])(ال)?صرقعة(?![ء-ي])(?!\s*\(Knock\))`), "طرق المحرك / الصرقعة (Knock)");
    // Spark plugs: شماعي -> شمعات
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال)?شماعي(?![ء-ي])`), "شمعات");
    // Radiator descaling: تسييخ -> تسليك وغسيل
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال)?تسييخ(?![ء-ي])`), "تسليك وغسيل");
    // Hoses: خرطوم / خراطيم -> مناكوطي / توبو
    text = text.replace(rx(String.raw`خرطوم\s+(ال)?(ماء|مية|الرداتوري|تبريد)`), "مناكوطي الرداتوري");
    text = text.replace(rx(String.raw`خرطوم\s+(ال)?(هواء|فاكيوم|بوابة|شفط)`), "توبو الهواء والفاكيوم");
    // Bearings: رمان بلي / البلية -> كوشينتي
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال)?بلية(?![ء-ي])`), "الكوشينتي");
    // Exhaust catalytic converter: دبة تلوث / دبة بيئة -> علبة كربون المرميطة
    text = text.replace(rx(String.raw`دبة\s+(ال)?(تلوث|بيئة|البيئة)`), "علبة كربون المرميطة");
    // 29. Airbags / SRS: Must NEVER be referred to as "الأكسجين"
    text = text.replace(rx(String.raw`منظومة\s+الأكسجين\s*\(SRS\)`), "منظومة الوسائد الهوائية (الأيرباق - SRS)");
    text = text.replace(rx(String.raw`وحدة\s+الأكسجين\s*\(SRS\)`), "وحدة الوسائد الهوائية (الأيرباق - SRS)");
    text = text.replace(rx(String.raw`وحدة\s+الأكسجين`), "وحدة الوسائد الهوائية (الأيرباق - SRS)");
    text = text.replace(rx(String.raw`في\s+الأكسجين\s*\(SRS\)`), "في منظومة الوسائد الهوائية (الأيرباق - SRS)");
    text = text.replace(rx(String.raw`الأكسجين\s*\(SRS\)`), "الوسائد الهوائية (الأيرباق - SRS)");
    // 30. MAP vs MAF corrections & cleanups
    text = text.replace(rx(String.raw`حساس\s+ماف\s*\(\s*MAP\s*\)`, "gi"), "حساس ماب (ضغط المانيفولد)");
    text = text.replace(rx(String.raw`حساس\s+ماف\s+والتسريبات\s+في\s+المانيهول`), "حساس ماب والتسريبات في المانيفولد");
    text = text.replace(rx(String.raw`المانيهول`), "المانيفولد");
    text = text.replaceAll("راديو الراديو", "راديو");
    // 31. Chassis / VIN: شاسي / شاصي -> هيكل
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال|بال|لل|فال|وال)?(شاسيه|شاصيه|شاسي|شاصي)(?![ء-ي])`), "$1هيكل");
    // 32. Control Units / Box: عقل -> بوكس (مثل: بوكس كمبيو، بوكس محرك، بوكس السيارة)
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال|بال|لل|فال|وال)?عقول(ها|هم)?(?![ء-ي])`), "$1بوكسات$2");
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال|بال|لل|فال|وال)?عقل(ه|ها)?(?![ء-ي])`), "$1بوكس$2");
    // 33. Misfire / Engine Stutter: تفتفة -> فطفطة (اللهجة الليبية الدارجة)
    text = text.replace(rx(String.raw`(?<![ء-هىي])(ال|بال|لل|فال|وال|ل)?تفتف(ة|ات)(?![ء-ي])`), "$1فطفط$2");
    text = text.replace(rx(String.raw`(?<![ء-هىي])(تتفتف|يتفتف|تفتفت)(?![ء-ي])`), "تفطفط");
    // Collapse "X (X)" left behind when a term and its gloss became identical.
    // Collapse "X (X)" left behind when a term and its gloss became identical
    text = text.replace(rx(String.raw`([\u0621-\u064A][\u0621-\u064A ]*?)\s*\(\1\)`), "$1");

    return text;
  }

  static sanitizeReport(report: KashifDiagnosticReport): KashifDiagnosticReport {
    if (!report) return report;
    if (report.summary?.briefSummaryArabic) {
      report.summary.briefSummaryArabic = this.clean(report.summary.briefSummaryArabic);
    }
    const cleanFault = (f: DiagnosticCodeDetail) => {
      f.libyanTerm = this.clean(f.libyanTerm);
      f.standardArabicDescription = this.clean(f.standardArabicDescription);
      f.recommendedAction = this.clean(f.recommendedAction);
      if (f.driverSymptoms) {
        f.driverSymptoms = f.driverSymptoms.map((s) => this.clean(s));
      }
      if (f.rootCauses) {
        f.rootCauses = f.rootCauses.map((r) => this.clean(r));
      }
      if (f.electricalDiagnostics) {
        if (f.electricalDiagnostics.multimeterTest?.testingTipLibyan) {
          f.electricalDiagnostics.multimeterTest.testingTipLibyan = this.clean(f.electricalDiagnostics.multimeterTest.testingTipLibyan);
        }
        if (f.electricalDiagnostics.fuseInfo?.circuitDescription) {
          f.electricalDiagnostics.fuseInfo.circuitDescription = this.clean(f.electricalDiagnostics.fuseInfo.circuitDescription);
        }
      }
    };
    if (report.faultCategories) {
      report.faultCategories.criticalFaults?.forEach(cleanFault);
      report.faultCategories.moderateFaults?.forEach(cleanFault);
      report.faultCategories.minorOrHistoricalFaults?.forEach(cleanFault);
    }
    if (Array.isArray(report.sparePartsRequired)) {
      report.sparePartsRequired.forEach((part: SparePartItem) => {
        part.partNameLibyan = this.clean(part.partNameLibyan);
        part.partNameStandardArabic = this.clean(part.partNameStandardArabic);
        if (part.estimatedPriceRangeLYD?.marketNote) {
          part.estimatedPriceRangeLYD.marketNote = this.clean(part.estimatedPriceRangeLYD.marketNote);
        }
      });
    }

    return report;
  }
}
