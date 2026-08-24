import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "كاشف AI | فاحص أعطال السيارات الذكي بالمصطلحات الليبية",
  description:
    "وكيل ذكاء اصطناعي تفاعلي لتحليل تقارير أجهزة فحص السيارات (OBD-II Scanners) واستخراج الأعطال وأرقام قطع الغيار الأصلية بالمصطلحات الدارجة في ورش الصيانة الليبية.",
  keywords: [
    "فحص سيارات ليبي",
    "كاشف أعطال السيارات",
    "مصطلحات صيانة سيارات ليبيا",
    "OBD-II Libya",
    "Launch X431",
    "Ediag",
    "قطع غيار ليبيا",
  ],
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ar" dir="rtl" className="dark">
      <body className="min-h-screen bg-slate-950 text-slate-100 antialiased selection:bg-amber-500/30 selection:text-amber-200">
        {children}
      </body>
    </html>
  );
}
