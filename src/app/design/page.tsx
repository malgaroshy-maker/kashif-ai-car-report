import type { Metadata } from "next";
import { Zap, Gauge, Wrench, Printer } from "lucide-react";
import {
  BankRule,
  Button,
  Cell,
  CodePlate,
  Field,
  SeverityLegend,
} from "@/components/ui/primitives";
import { SeverityMark, SeveritySeat } from "@/components/ui/SeverityMark";
import { ThemeToggle } from "@/components/ui/ThemeToggle";
import { SEVERITY, SEVERITY_ORDER, ACCENT } from "@/lib/design/severity";

export const metadata: Metadata = {
  title: "نظام التصميم — كاشف AI",
  robots: { index: false, follow: false },
};

function Section({
  title,
  note,
  children,
}: {
  title: string;
  note?: string;
  children: React.ReactNode;
}) {
  return (
    <section className="space-y-[var(--s4)]">
      <div className="rib-heavy pt-[var(--s2)]">
        <h2 className="k-bank uppercase">{title}</h2>
        {note && (
          <p className="max-w-[var(--measure)] text-[var(--ink-2)]">{note}</p>
        )}
      </div>
      {children}
    </section>
  );
}

const SPACE = ["s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8"];

const TYPE_ROWS: [string, string, string][] = [
  ["--t-score", "48", "المؤشر فقط"],
  ["--t-title", "BMW 528i (E39)", "اسم المركبة فقط"],
  ["--t-bank", "حرج", "عنوان البنك"],
  ["--t-body", "نص التقرير كله", "المقاس الوحيد"],
  ["--t-plate", "P0102", "لوحة الكود"],
  ["--t-label", "رقم الهيكل", "عنوان الحقل"],
];

export default function DesignSystemPage() {
  return (
    <div className="min-h-screen bg-[var(--board)] px-[var(--s4)] py-[var(--s6)] sm:px-[var(--s6)]">
      <div className="mx-auto max-w-5xl space-y-[var(--s7)]">
        <header className="flex flex-wrap items-end justify-between gap-[var(--s4)]">
          <div>
            <h1 className="text-[length:var(--t-title)] font-bold">
              نظام التصميم — لوحة الفيوزات
            </h1>
            <p className="max-w-[var(--measure)] text-[var(--ink-2)]">
              الألوان ليست اختياراً جمالياً: هي كود ألوان الفيوزات القياسي
              ISO/DIN 72581-3 الموجود في كل سيارة. العمق حافة مصبوبة، مش ظل.
            </p>
          </div>
          <ThemeToggle />
        </header>

        <Section
          title="الأحبار"
          note="كل درجة خطورة تستعير لونها من فيوز حقيقي. المربع الكبير هو لون بلاستيك الفيوز نفسه؛ أي أرضية مليانة أو علامة تستعمل درجة الحبر الأغمق عشان تبقى مقروءة."
        >
          <div className="grid gap-[var(--s3)] sm:grid-cols-2 lg:grid-cols-4">
            {SEVERITY_ORDER.map((s) => {
              const t = SEVERITY[s];
              return (
                <Cell key={s} className="space-y-[var(--s3)]">
                  <div className="flex items-center gap-[var(--s2)]">
                    <SeveritySeat severity={s} />
                    <span
                      className="text-[length:var(--t-body)] font-bold"
                      style={{ color: t.ink }}
                    >
                      {t.labelAr}
                    </span>
                  </div>
                  <div
                    className="h-10 border border-[var(--rib)]"
                    style={{ backgroundColor: t.tab }}
                    aria-hidden
                  />
                  <p className="text-[var(--ink-2)]">{t.descriptionAr}</p>
                </Cell>
              );
            })}
          </div>

          <Cell className="flex flex-wrap items-center gap-[var(--s3)]">
            <div
              className="size-10 border border-[var(--rib)]"
              style={{ backgroundColor: ACCENT.tab }}
              aria-hidden
            />
            <div>
              <div className="font-bold" style={{ color: ACCENT.ink }}>
                الأزرق التفاعلي
              </div>
              <p className="text-[var(--ink-2)]">
                الروابط، التركيز، الأزرار الأساسية. ممنوع استخدامه لأي حالة.
              </p>
            </div>
            <CodePlate className="ms-auto">{ACCENT.ampRating}</CodePlate>
          </Cell>
        </Section>

        <Section
          title="الشكل يحمل الخطورة"
          note="اللون وحده ما يحمل الخطورة أبداً. كل درجة معاها شكل مرسوم، عشان التقرير يتقرا مطبوع بالأبيض والأسود ومن فني عنده عمى ألوان."
        >
          <Cell className="flex flex-wrap items-center gap-[var(--s6)]">
            {SEVERITY_ORDER.map((s) => (
              <div key={s} className="flex items-center gap-[var(--s2)]">
                <SeverityMark severity={s} size={20} labelled />
                <span className="k-label uppercase">{SEVERITY[s].shape}</span>
              </div>
            ))}
            <span className="ms-auto flex items-center gap-[var(--s2)] text-[var(--ink-2)]">
              <Printer className="size-4" aria-hidden />
              يبقى مقروء بعد ما يختفي اللون
            </span>
          </Cell>
        </Section>

        <Section
          title="الخطوط"
          note="مقاس واحد للنص كله. الترتيب يجي من الوزن والحالة والخط الفاصل — مش من ستة مقاسات."
        >
          <div className="grid gap-[var(--s3)] lg:grid-cols-2">
            <Cell className="space-y-[var(--s4)]">
              <div>
                <div className="k-label uppercase">Readex Pro — عربي ولاتيني</div>
                <p className="max-w-[var(--measure)] pt-[var(--s2)]">
                  بوبينة وشمعات السلندر الرابع (البسطوني) — حساس ماف، مزاطوري،
                  براتشو، كونفيرتا، بيانتو.
                </p>
                <p className="text-[var(--ink-2)]">
                  Ignition Coil / Misfire Cylinder 4 — Mass Air Flow Sensor
                </p>
              </div>
              <div className="rib pt-[var(--s3)]">
                <div className="k-label uppercase">Azeret Mono — القيم المقيسة</div>
                <p data-num className="pt-[var(--s2)]">
                  P0102 · 22204-22010 · WBADD6100VBSAMPLE · 14.2V · F14 15A
                </p>
              </div>
            </Cell>

            <Cell className="space-y-[var(--s3)]">
              {TYPE_ROWS.map(([token, sample, use]) => (
                <div
                  key={token}
                  className="flex items-baseline justify-between gap-[var(--s3)] border-b border-[var(--rib)] pb-[var(--s2)]"
                >
                  <span
                    style={{ fontSize: `var(${token})` }}
                    className={
                      token === "--t-label"
                        ? "k-label uppercase"
                        : token === "--t-plate"
                          ? "font-mono"
                          : "font-bold"
                    }
                  >
                    {sample}
                  </span>
                  <span className="k-label shrink-0 text-[var(--ink-3)]">
                    {use}
                  </span>
                </div>
              ))}
            </Cell>
          </div>
        </Section>

        <Section
          title="الحافة المصبوبة"
          note="العمق سطر غامق مع سطر منوّر جنبه — هكي تتقرا الحافة في البلاستيك المصبوب. في ظل واحد بس في المنظومة كلها، وهو للخلية المسحوبة."
        >
          <div className="grid gap-[var(--s3)] sm:grid-cols-3">
            <Cell className="space-y-[var(--s2)]">
              <div className="k-label uppercase">حافة رفيعة</div>
              <div className="rib h-[var(--s6)]" />
            </Cell>
            <Cell className="space-y-[var(--s2)]">
              <div className="k-label uppercase">حافة ثقيلة</div>
              <div className="rib-heavy h-[var(--s6)]" />
            </Cell>
            <Cell lifted className="space-y-[var(--s2)]">
              <div className="k-label uppercase">خلية مسحوبة</div>
              <div className="flex h-[var(--s6)] items-center text-[var(--ink-2)]">
                الظل الوحيد
              </div>
            </Cell>
          </div>
        </Section>

        <Section title="المسافات" note="وحدة 4px — لوحة الفيوزات شبكة بخطوة ثابتة.">
          <Cell className="space-y-[var(--s2)]">
            {SPACE.map((s) => (
              <div key={s} className="flex items-center gap-[var(--s3)]">
                <span data-num className="k-label w-8 shrink-0">
                  {s}
                </span>
                <span
                  className="h-3"
                  style={{
                    width: `var(--${s})`,
                    backgroundColor: "var(--amp-15-ink)",
                  }}
                  aria-hidden
                />
              </div>
            ))}
          </Cell>
        </Section>

        <Section title="المكوّنات">
          <SeverityLegend />

          <div className="space-y-[var(--s3)]">
            <BankRule severity="critical" count={3} />

            <Cell className="space-y-[var(--s3)]">
              <div className="flex flex-wrap items-center gap-[var(--s2)]">
                <SeveritySeat severity="critical" />
                <CodePlate>ECM 02</CodePlate>
                <h3 className="font-bold">
                  بوبينة وشمعات السلندر الرابع (البسطوني)
                </h3>
              </div>
              <p className="text-[var(--ink-2)]">
                Ignition Coil / Misfire Cylinder 4
              </p>
              <div className="grid gap-[var(--s4)] sm:grid-cols-3">
                <Field label="الفيوز" value="F14 · 15A أزرق" mono />
                <Field label="رقم القطعة OEM" value="12137594937" mono />
                <Field label="الممشى" value={null} />
              </div>
              <div className="flex flex-wrap gap-[var(--s2)]">
                <Button variant="primary">
                  <Zap className="size-4" aria-hidden />
                  اسحب الفيوز
                </Button>
                <Button>
                  <Wrench className="size-4" aria-hidden />
                  خطوات الفحص
                </Button>
                <Button variant="ghost" disabled>
                  <Gauge className="size-4" aria-hidden />
                  غير متاح
                </Button>
              </div>
            </Cell>

            <BankRule severity="moderate" count={3} />
            <BankRule severity="passed" count={6} />
          </div>
        </Section>

        <Section
          title="أسطح المتصفح"
          note="التحديد، مؤشر الكتابة، حلقة التركيز، وشريط التمرير كلها مصبوغة من نفس اللوحة."
        >
          <Cell className="space-y-[var(--s3)]">
            <p className="max-w-[var(--measure)]">
              حدّد هذا النص عشان تشوف لون التحديد، أو اضغط Tab باش تشوف حلقة
              التركيز على الحقل تحت.
            </p>
            <input
              className="w-full max-w-sm border border-[var(--rib)] bg-[var(--cell)] px-[var(--s3)] py-[var(--s2)] text-[var(--ink)] placeholder:text-[var(--ink-3)]"
              style={{ borderRadius: "var(--radius-input)" }}
              placeholder="P0102, ECM 02"
              aria-label="حقل تجريبي"
            />
            <div className="h-24 overflow-y-auto border border-[var(--rib)] p-[var(--s3)]">
              <div className="h-48 text-[var(--ink-2)]">
                مرّر هنا عشان تشوف شريط التمرير المربّع.
              </div>
            </div>
          </Cell>
        </Section>
      </div>
    </div>
  );
}
