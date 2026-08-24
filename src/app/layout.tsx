import type { Metadata, Viewport } from "next";
import { Readex_Pro, Azeret_Mono } from "next/font/google";
import "./globals.css";

/**
 * Readex Pro is an Arabic-first variable family — not a Latin face with Arabic
 * bolted on — engineered for legibility at small sizes and poor contrast, which
 * is the scene this product is read in. Its Latin sibling keeps English fault
 * descriptions in the same voice.
 */
const readex = Readex_Pro({
  subsets: ["arabic", "latin"],
  variable: "--font-readex",
  display: "swap",
});

/**
 * Azeret Mono holds measured values only: DTCs, OEM numbers, VINs, voltages,
 * fuse ratings. It is here for data, never as a costume for "technical".
 */
const azeret = Azeret_Mono({
  subsets: ["latin"],
  weight: ["400", "600"],
  variable: "--font-azeret",
  display: "swap",
});

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

export const viewport: Viewport = {
  themeColor: [
    { media: "(prefers-color-scheme: light)", color: "#c9cbc4" },
    { media: "(prefers-color-scheme: dark)", color: "#17191a" },
  ],
};

/**
 * Applied before first paint so a stored theme never flashes the other lid.
 * Kept deliberately tiny and dependency-free.
 */
const THEME_SCRIPT = `(function(){try{var t=localStorage.getItem("kashif_theme");if(t==="light"||t==="dark")document.documentElement.dataset.theme=t}catch(e){}})()`;

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ar" dir="rtl" className={`${readex.variable} ${azeret.variable}`}>
      <head>
        <script dangerouslySetInnerHTML={{ __html: THEME_SCRIPT }} />
      </head>
      <body>
        {/*
          THESIS: Kashif does not draw a dashboard, it prints a fuse-box legend.
          Faults are cells in a moulded board, ordered by what strands the
          driver. It refuses this category's arrangement: floating rounded cards
          on a dark ground with a coloured gauge.
          OWN-WORLD: Moulded polymer board, silkscreen ink, hairline and heavy
          moulded ribs instead of shadows. Status colour is ISO/DIN 72581-3 blade
          fuse code — 10A red, 20A yellow, 30A green, 25A clear — plus 15A blue
          as the only interactive ink. Nothing else is chromatic. Nothing is
          rounded. One shadow exists, on a pulled cell.
          STORY: The mechanic reads faults in his own words, ranked by danger,
          with the test to run before buying the part.
          FIRST VIEWPORT: Masthead and vehicle plate, the legend key beside them,
          then the critical bank opening on a heavy rib — phone and desk alike.
          FORM: The Fuse-Box Lid; grounded candidate 3, assigned by seed 3a0b3d60
          and confirmed by the user over the certificate.
          FINISH: unreviewed and undocumented is unfinished; this build ends with
          the finish review, the verdict, DESIGN.md, and every shipping raster
          carrying its provenance.
        */}
        {children}
      </body>
    </html>
  );
}
