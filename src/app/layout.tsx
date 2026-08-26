import type { Metadata, Viewport } from "next";
import { Readex_Pro, Azeret_Mono } from "next/font/google";
import "./globals.css";
import { SITE_URL } from "@/lib/site";

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

const TITLE = "كاشف AI | فحص أعطال السيارات بمصطلحات الورش الليبية";
const DESCRIPTION =
  "يقرا تقرير جهاز الفحص (OBD-II) ويترجمه لمصطلحات الورش الليبية، بأرقام قطع الغيار الأصلية والفحص المطلوب قبل الشراء.";

export const metadata: Metadata = {
  // Without metadataBase every og:image and canonical resolves against
  // localhost, so a link shared from the workshop previewed as nothing.
  metadataBase: new URL(SITE_URL),
  title: TITLE,
  description:
    "تحليل تقارير أجهزة فحص السيارات (OBD-II) واستخراج الأعطال وأرقام قطع الغيار بمصطلحات ورش الصيانة الليبية.",
  keywords: [
    "فحص سيارات ليبي",
    "كاشف أعطال السيارات",
    "مصطلحات صيانة سيارات ليبيا",
    "OBD-II Libya",
    "Launch X431",
    "Ediag",
    "قطع غيار ليبيا",
  ],
  applicationName: "كاشف",
  manifest: "/manifest.webmanifest",
  icons: {
    icon: [
      { url: "/favicon.ico", sizes: "any" },
      { url: "/icon.svg", type: "image/svg+xml" },
    ],
    apple: "/icon.svg",
  },
  alternates: { canonical: "/" },
  openGraph: {
    type: "website",
    locale: "ar_LY",
    siteName: "كاشف",
    title: TITLE,
    description: DESCRIPTION,
    url: "/",
    // PNG, not the SVG it is drawn from: WhatsApp — which is how a link to
    // this actually travels — ignores an SVG og:image completely, and so do
    // Facebook and Twitter, so an SVG here means no preview at all.
    // Regenerate with `npm run og` after editing public/og.svg.
    images: [
      {
        url: "/og.png",
        width: 1200,
        height: 630,
        type: "image/png",
        alt: "كاشف — يقرا تقرير جهاز الفحص ويترجمه لمصطلحات الورش الليبية",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: TITLE,
    description: DESCRIPTION,
    images: ["/og.png"],
  },
  robots: { index: true, follow: true },
  formatDetection: {
    // A VIN and an OEM part number are both long digit runs, and iOS turns
    // them into phone links you cannot select to copy.
    telephone: false,
  },
};

export const viewport: Viewport = {
  // The board's own colour, so the phone's chrome continues the lid instead of
  // sitting on it as a separate object.
  themeColor: [
    { media: "(prefers-color-scheme: light)", color: "#d5d7cf" },
    { media: "(prefers-color-scheme: dark)", color: "#17191a" },
  ],
  // The report is dense and gets read at arm's length in daylight. Pinch-zoom
  // has to keep working, so no maximum-scale and no user-scalable: false.
  width: "device-width",
  initialScale: 1,
  viewportFit: "cover",
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
        <a href="#main" className="k-skip">
          تخطَّ إلى التقرير
        </a>
        {children}
      </body>
    </html>
  );
}
