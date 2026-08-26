import type { MetadataRoute } from "next";

/**
 * Installable, because of where this is used.
 *
 * The reader is standing next to a car in a workshop with a phone, not sitting
 * at a desk. Installed, Kashif opens from the home screen with no browser
 * chrome eating the top of a small screen, and the two demo reports still work
 * with no key and no network round trip.
 *
 * `dir` and `lang` are set explicitly: an installed RTL app that launches LTR
 * looks broken before it has drawn anything.
 */
export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "كاشف AI — فاحص أعطال السيارات",
    short_name: "كاشف",
    description:
      "يقرا تقرير جهاز الفحص ويترجمه لمصطلحات الورش الليبية، بأرقام القطع والفحص المطلوب قبل الشراء.",
    lang: "ar",
    dir: "rtl",
    start_url: "/",
    scope: "/",
    display: "standalone",
    orientation: "portrait",
    // The lid, in each theme. `background_color` is the splash behind the app
    // while it boots, so it matches the board rather than flashing white.
    background_color: "#d5d7cf",
    theme_color: "#d5d7cf",
    categories: ["utilities", "productivity"],
    icons: [
      {
        src: "/icon.svg",
        sizes: "any",
        type: "image/svg+xml",
        purpose: "any",
      },
      {
        src: "/icon-maskable.svg",
        sizes: "any",
        type: "image/svg+xml",
        purpose: "maskable",
      },
    ],
  };
}
