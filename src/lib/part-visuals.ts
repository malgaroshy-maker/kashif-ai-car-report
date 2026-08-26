/**
 * The part schematics.
 *
 * These are legend drawings, not product photos: line art on the paper the
 * report is printed on, in the same silkscreen language as the rest of the
 * app. They exist so a card is never empty when no photo was found — which is
 * the normal case, not the exception. A real Camry SRS report matched zero
 * photos for four parts.
 *
 * Three rules, each one a defect that shipped:
 *
 *  - **`currentColor` and nothing else.** These used to be dark-navy panels
 *    with cyan neon (`#070D1E`, `#00F0FF`) drawn from the pre-rebuild design.
 *    On the paper-white report that is four black boxes down the page, and on
 *    a printer it is four flooded rectangles of toner.
 *  - **No `<defs>` and no `id`.** Four cards each carried a gradient called
 *    `gen_metal`, so one document declared the same id four times and every
 *    reference resolved to the first. With no ids the bug cannot recur.
 *  - **No text.** A drawing that is the same for every part must not caption
 *    itself; the part's real name is printed directly underneath it.
 */

export function getPartVisualType(partName: string = "", oem: string = ""): string {
  const p = (partName + " " + oem).toLowerCase();

  // Safety first, and inside safety the specific before the general: every
  // one of these also contains the word إيرباق, so SIDE_AIRBAG cannot go first.
  if (p.includes("شريط ايرباق") || p.includes("شريط إيرباق") || p.includes("clock spring") || p.includes("clockspring") || p.includes("ملف الساعة") || p.includes("سبيرال")) {
    return "CLOCK_SPRING";
  }
  if (p.includes("طقطوقة") || p.includes("حزام امان") || p.includes("حزام أمان") || p.includes("seat belt") || p.includes("seatbelt") || p.includes("buckle")) {
    return "SEATBELT_BUCKLE";
  }
  if (p.includes("وزن") || p.includes("occupant") || p.includes("weight sensor") || p.includes("تصنيف الراكب") || p.includes("تصنيف ركاب")) {
    return "SEAT_WEIGHT_SENSOR";
  }
  if (p.includes("كمبيوتر الوسائد") || p.includes("srs module") || p.includes("airbag module") || p.includes("عقل الايرباق") || p.includes("عقل الإيرباق")) {
    return "SRS_MODULE";
  }
  if (p.includes("ايرباق") || p.includes("إيرباق") || p.includes("airbag") || p.includes("وسادة هوائية") || p.includes("squib")) {
    return "SIDE_AIRBAG";
  }

  if (p.includes("لمدا") || p.includes("lambda") || p.includes("oxygen") || p.includes("o2") || p.includes("عادم") || p.includes("شكمان")) {
    return "OXYGEN_SENSOR";
  }
  if (p.includes("بوبين") || p.includes("كويل") || p.includes("coil") || p.includes("ignition")) {
    return "IGNITION_COIL";
  }
  if (p.includes("شمع") || p.includes("بوجي") || p.includes("spark") || p.includes("plug")) {
    return "SPARK_PLUG";
  }
  if (p.includes("تيرستات") || p.includes("thermostat") || p.includes("حرارة") || p.includes("كوع")) {
    return "THERMOSTAT";
  }
  if (p.includes("طرمبة") || p.includes("بومبة بنزين") || p.includes("fuel pump") || p.includes("بانزين") || p.includes("ضغط الوقود")) {
    return "FUEL_PUMP";
  }
  if (p.includes("ماف") || p.includes("maf") || p.includes("air flow") || p.includes("حساس هواء") || p.includes("فيلترو")) {
    return "MAF_SENSOR";
  }
  if (p.includes("كتالايزر") || p.includes("كربون") || p.includes("catalytic") || p.includes("بيئة") || p.includes("دبة")) {
    return "CATALYTIC_CONVERTER";
  }
  if (p.includes("ديسك") || p.includes("فرامل") || p.includes("brake") || p.includes("فحمات") || p.includes("قماشات")) {
    return "BRAKE_DISC";
  }
  if (p.includes("مكيف") || p.includes("compressor") || p.includes("كومبروسر")) {
    return "AC_COMPRESSOR";
  }
  if (p.includes("abs") || p.includes("سرعة عجل") || p.includes("speed sensor")) {
    return "ABS_SENSOR";
  }
  if (p.includes("بومبة مية") || p.includes("water pump") || p.includes("مضخة ماء")) {
    return "WATER_PUMP";
  }
  return "GENERIC_PART";
}

/**
 * A schematic that is safe to write into the document.
 *
 * The only way to get one is `getPartSvg`, which returns a string literal from
 * the switch below and interpolates nothing. The branding is what stops a
 * caller passing an arbitrary string to `dangerouslySetInnerHTML` — the tag
 * cannot be forged outside this module.
 */
export type SafeSvg = string & { readonly __safeSvg: unique symbol };

/**
 * The only holes in these templates are the three literal constants below
 * (`OPEN`, `MASS`, `HAIR`), so nothing here can carry model output. This is
 * the belt to that brace: if a future edit ever adds a real template hole, the
 * schematic is dropped rather than written into the page.
 *
 * Checked at the boundary rather than trusted, because the consequence of
 * being wrong is script execution in the report.
 */
const UNSAFE = /<script|\son\w+\s*=|javascript:|<foreignObject|<iframe/i;

/** The empty drawing, for a part we have no schematic for. */
const NO_SVG = "" as SafeSvg;

export function getPartSvg(partName: string = "", oem: string = ""): SafeSvg {
  const svg = partSvgFor(getPartVisualType(partName, oem));
  if (UNSAFE.test(svg)) {
    console.error("[part-visuals] a schematic contained active content");
    return NO_SVG;
  }
  return svg as SafeSvg;
}

/**
 * Every drawing opens with this. `fill="none"` and `stroke="currentColor"` at
 * the root mean each shape only names what it overrides, and the whole
 * schematic takes the ink colour of whatever surface it lands on — paper in
 * the exported report, either theme in the app.
 */
const OPEN =
  `<svg viewBox="0 0 240 180" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg" class="part-svg" ` +
  `fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">`;

/** A solid mass. Kept light: this prints, and a filled panel costs toner. */
const MASS = `fill="currentColor" fill-opacity="0.09"`;
/** Hairlines — threads, ribs, hatching. */
const HAIR = `stroke-width="1.4" stroke-opacity="0.65"`;

function partSvgFor(type: string): string {
  switch (type) {
    // ── Safety / SRS ────────────────────────────────────────────────────
    case "CLOCK_SPRING":
      // A flat ribbon coiled inside a round cassette, with the two tails that
      // are the whole reason the part fails: they break where they leave it.
      return `${OPEN}
        <circle cx="112" cy="90" r="58" ${MASS}/>
        <circle cx="112" cy="90" r="58"/>
        <circle cx="112" cy="90" r="20"/>
        <path d="M 112 70 A 20 20 0 0 1 132 90 A 30 30 0 0 1 102 120 A 40 40 0 0 1 62 80 A 50 50 0 0 1 112 30" ${HAIR}/>
        <path d="M 112 78 A 12 12 0 0 1 124 90 A 22 22 0 0 1 102 112 A 32 32 0 0 1 70 80" ${HAIR}/>
        <path d="M 170 90 H 200"/>
        <rect x="200" y="78" width="26" height="24" rx="3" ${MASS}/>
        <rect x="200" y="78" width="26" height="24" rx="3"/>
        <path d="M 112 148 V 164 H 150" ${HAIR}/>
        <rect x="150" y="154" width="22" height="20" rx="3"/>
      </svg>`;

    case "SEATBELT_BUCKLE":
      // Buckle, tongue seated in it, and the switch pigtail underneath.
      return `${OPEN}
        <rect x="70" y="52" width="100" height="62" rx="10" ${MASS}/>
        <rect x="70" y="52" width="100" height="62" rx="10"/>
        <rect x="88" y="34" width="64" height="22" rx="4"/>
        <path d="M 104 44 h 32" ${HAIR}/>
        <rect x="96" y="70" width="48" height="14" rx="3" ${HAIR}/>
        <path d="M 120 114 V 132" />
        <path d="M 120 132 C 120 148 140 146 152 154" ${HAIR}/>
        <rect x="152" y="144" width="26" height="22" rx="3" ${MASS}/>
        <rect x="152" y="144" width="26" height="22" rx="3"/>
        <path d="M 62 132 h 116" ${HAIR} stroke-dasharray="5 5"/>
      </svg>`;

    case "SEAT_WEIGHT_SENSOR":
      // The mat under the cushion, on the seat pan, with its connector.
      return `${OPEN}
        <path d="M 40 118 h 160" />
        <path d="M 56 118 v 22 M 184 118 v 22" ${HAIR}/>
        <rect x="56" y="80" width="128" height="38" rx="8" ${MASS}/>
        <rect x="56" y="80" width="128" height="38" rx="8"/>
        <path d="M 78 80 V 44 a 10 10 0 0 1 10 -10 h 12" ${HAIR}/>
        <circle cx="90" cy="99" r="7" ${HAIR}/>
        <circle cx="120" cy="99" r="7" ${HAIR}/>
        <circle cx="150" cy="99" r="7" ${HAIR}/>
        <path d="M 90 99 h 60" ${HAIR}/>
        <path d="M 184 99 h 22"/>
        <rect x="206" y="88" width="20" height="22" rx="3"/>
      </svg>`;

    case "SIDE_AIRBAG":
      // The folded module bolted to the seat frame, and its igniter lead.
      return `${OPEN}
        <path d="M 52 32 v 116" ${HAIR}/>
        <rect x="66" y="46" width="104" height="88" rx="8" ${MASS}/>
        <rect x="66" y="46" width="104" height="88" rx="8"/>
        <path d="M 66 68 h 104 M 66 90 h 104 M 66 112 h 104" ${HAIR}/>
        <circle cx="170" cy="90" r="14"/>
        <path d="M 170 76 v 28" ${HAIR}/>
        <path d="M 184 90 h 22"/>
        <rect x="206" y="79" width="20" height="22" rx="3" ${MASS}/>
        <rect x="206" y="79" width="20" height="22" rx="3"/>
        <circle cx="76" cy="56" r="3.5" ${HAIR}/>
        <circle cx="76" cy="124" r="3.5" ${HAIR}/>
      </svg>`;

    case "SRS_MODULE":
      // A control unit: box, mounting ears, multi-pin header on one edge.
      return `${OPEN}
        <rect x="58" y="46" width="124" height="88" rx="6" ${MASS}/>
        <rect x="58" y="46" width="124" height="88" rx="6"/>
        <path d="M 58 62 h 124" ${HAIR}/>
        <rect x="76" y="76" width="88" height="42" rx="4" ${HAIR}/>
        <path d="M 88 88 h 64 M 88 100 h 64 M 88 112 h 40" ${HAIR}/>
        <path d="M 34 62 h 24 M 34 118 h 24" />
        <circle cx="34" cy="62" r="6" ${HAIR}/>
        <circle cx="34" cy="118" r="6" ${HAIR}/>
        <rect x="182" y="70" width="30" height="40" rx="3"/>
        <path d="M 190 80 v 20 M 198 80 v 20 M 206 80 v 20" ${HAIR}/>
      </svg>`;

    // ── Engine / fuel / air ─────────────────────────────────────────────
    case "OXYGEN_SENSOR":
      return `${OPEN}
        <path d="M 40 90 h 26"/>
        <rect x="66" y="72" width="22" height="36" rx="2" ${MASS}/>
        <rect x="66" y="72" width="22" height="36" rx="2"/>
        <path d="M 88 76 h 26 v 28 h -26 z" ${MASS}/>
        <path d="M 88 76 h 26 v 28 h -26 z"/>
        <path d="M 92 82 h 18 M 92 90 h 18 M 92 98 h 18" ${HAIR}/>
        <rect x="114" y="66" width="34" height="48" rx="4" ${MASS}/>
        <rect x="114" y="66" width="34" height="48" rx="4"/>
        <path d="M 148 90 c 22 0 18 -32 38 -32" />
        <rect x="186" y="46" width="26" height="24" rx="3"/>
      </svg>`;

    case "IGNITION_COIL":
      return `${OPEN}
        <rect x="82" y="30" width="66" height="70" rx="6" ${MASS}/>
        <rect x="82" y="30" width="66" height="70" rx="6"/>
        <path d="M 82 46 h 66 M 82 62 h 66 M 82 78 h 66" ${HAIR}/>
        <rect x="148" y="42" width="30" height="30" rx="3"/>
        <path d="M 156 50 v 14 M 164 50 v 14 M 172 50 v 14" ${HAIR}/>
        <path d="M 100 100 h 30 v 26 h -30 z" ${MASS}/>
        <path d="M 100 100 h 30 v 26 h -30 z"/>
        <path d="M 106 126 h 18 v 26 a 9 9 0 0 1 -18 0 z" ${MASS}/>
        <path d="M 106 126 h 18 v 26 a 9 9 0 0 1 -18 0 z"/>
      </svg>`;

    case "SPARK_PLUG":
      return `${OPEN}
        <path d="M 106 22 h 28 v 30 h -28 z" ${MASS}/>
        <path d="M 106 22 h 28 v 30 h -28 z"/>
        <path d="M 100 52 h 40 v 34 h -40 z" ${MASS}/>
        <path d="M 100 52 h 40 v 34 h -40 z"/>
        <path d="M 100 62 h 40 M 100 72 h 40" ${HAIR}/>
        <path d="M 104 86 h 32 v 30 h -32 z" ${MASS}/>
        <path d="M 104 86 h 32 v 30 h -32 z"/>
        <path d="M 104 94 h 32 M 104 102 h 32 M 104 110 h 32" ${HAIR}/>
        <path d="M 114 116 h 12 v 30 h -12 z" ${HAIR}/>
        <path d="M 120 146 v 12 M 120 158 h 16 v -14" />
      </svg>`;

    case "THERMOSTAT":
      return `${OPEN}
        <circle cx="120" cy="90" r="52" ${MASS}/>
        <circle cx="120" cy="90" r="52"/>
        <circle cx="120" cy="90" r="30"/>
        <circle cx="120" cy="90" r="10" ${MASS}/>
        <path d="M 120 60 v -18 M 120 120 v 18" ${HAIR}/>
        <path d="M 96 74 q 24 16 48 0 M 96 106 q 24 -16 48 0" ${HAIR}/>
        <circle cx="80" cy="50" r="4" ${HAIR}/>
        <circle cx="160" cy="130" r="4" ${HAIR}/>
      </svg>`;

    case "FUEL_PUMP":
      return `${OPEN}
        <rect x="82" y="36" width="76" height="98" rx="10" ${MASS}/>
        <rect x="82" y="36" width="76" height="98" rx="10"/>
        <path d="M 82 58 h 76 M 82 112 h 76" ${HAIR}/>
        <path d="M 120 36 v -14 h 22" />
        <rect x="142" y="12" width="22" height="20" rx="3"/>
        <path d="M 100 134 q 20 24 40 0" ${HAIR}/>
        <path d="M 92 148 h 56 v 14 h -56 z" ${HAIR}/>
        <path d="M 100 148 v 14 M 112 148 v 14 M 124 148 v 14 M 136 148 v 14" ${HAIR}/>
      </svg>`;

    case "MAF_SENSOR":
      return `${OPEN}
        <path d="M 40 56 h 160 v 68 h -160 z" ${MASS}/>
        <path d="M 40 56 h 160 v 68 h -160 z"/>
        <path d="M 40 46 v 88 M 200 46 v 88"/>
        <rect x="96" y="24" width="48" height="34" rx="4" ${MASS}/>
        <rect x="96" y="24" width="48" height="34" rx="4"/>
        <path d="M 120 58 v 40" ${HAIR}/>
        <path d="M 108 98 h 24" ${HAIR}/>
        <path d="M 60 90 h 26 M 154 90 h 26" ${HAIR} stroke-dasharray="6 5"/>
        <rect x="144" y="28" width="26" height="24" rx="3"/>
      </svg>`;

    case "CATALYTIC_CONVERTER":
      return `${OPEN}
        <path d="M 20 90 h 34" />
        <path d="M 54 62 h 132 v 56 h -132 z" ${MASS}/>
        <path d="M 54 62 h 132 v 56 h -132 z"/>
        <path d="M 54 62 q -14 28 0 56 M 186 62 q 14 28 0 56" ${HAIR}/>
        <path d="M 70 62 v 56 M 86 62 v 56 M 102 62 v 56 M 118 62 v 56 M 134 62 v 56 M 150 62 v 56 M 166 62 v 56" ${HAIR}/>
        <path d="M 186 90 h 34" />
        <rect x="96" y="34" width="24" height="22" rx="3" ${HAIR}/>
        <path d="M 108 56 v 6" ${HAIR}/>
      </svg>`;

    case "BRAKE_DISC":
      return `${OPEN}
        <circle cx="104" cy="90" r="66" ${MASS}/>
        <circle cx="104" cy="90" r="66"/>
        <circle cx="104" cy="90" r="30"/>
        <circle cx="104" cy="90" r="9" ${HAIR}/>
        <circle cx="104" cy="66" r="4" ${HAIR}/>
        <circle cx="126" cy="102" r="4" ${HAIR}/>
        <circle cx="82" cy="102" r="4" ${HAIR}/>
        <path d="M 104 24 v 20 M 104 136 v 20 M 38 90 h 20 M 150 90 h 20" ${HAIR}/>
        <path d="M 180 52 h 34 v 76 h -34 z" ${MASS}/>
        <path d="M 180 52 h 34 v 76 h -34 z"/>
        <path d="M 180 66 h 34" ${HAIR}/>
      </svg>`;

    case "AC_COMPRESSOR":
      return `${OPEN}
        <rect x="76" y="52" width="104" height="76" rx="12" ${MASS}/>
        <rect x="76" y="52" width="104" height="76" rx="12"/>
        <path d="M 76 72 h 104 M 76 108 h 104" ${HAIR}/>
        <circle cx="60" cy="90" r="34" ${MASS}/>
        <circle cx="60" cy="90" r="34"/>
        <circle cx="60" cy="90" r="20"/>
        <circle cx="60" cy="90" r="7" ${HAIR}/>
        <path d="M 180 72 h 26 M 180 108 h 26"/>
        <circle cx="212" cy="72" r="7" ${HAIR}/>
        <circle cx="212" cy="108" r="7" ${HAIR}/>
      </svg>`;

    case "ABS_SENSOR":
      return `${OPEN}
        <path d="M 54 66 h 40 v 48 h -40 z" ${MASS}/>
        <path d="M 54 66 h 40 v 48 h -40 z"/>
        <circle cx="74" cy="90" r="10" ${HAIR}/>
        <path d="M 94 78 h 26 v 24 h -26 z" ${MASS}/>
        <path d="M 94 78 h 26 v 24 h -26 z"/>
        <circle cx="46" cy="90" r="12"/>
        <circle cx="46" cy="90" r="5" ${HAIR}/>
        <path d="M 120 90 c 30 0 26 44 56 44"/>
        <rect x="176" y="122" width="30" height="24" rx="3" ${MASS}/>
        <rect x="176" y="122" width="30" height="24" rx="3"/>
      </svg>`;

    case "WATER_PUMP":
      return `${OPEN}
        <circle cx="112" cy="90" r="56" ${MASS}/>
        <circle cx="112" cy="90" r="56"/>
        <circle cx="112" cy="90" r="22"/>
        <path d="M 112 68 q 22 8 16 30 M 134 90 q -8 22 -30 16 M 90 106 q -22 -8 -16 -30 M 74 90 q 8 -22 30 -16" ${HAIR}/>
        <circle cx="112" cy="90" r="8" ${MASS}/>
        <path d="M 168 90 h 30 v 30" ${HAIR}/>
        <circle cx="66" cy="44" r="4" ${HAIR}/>
        <circle cx="158" cy="44" r="4" ${HAIR}/>
        <circle cx="66" cy="136" r="4" ${HAIR}/>
        <circle cx="158" cy="136" r="4" ${HAIR}/>
      </svg>`;

    // ── Anything with no drawing of its own ─────────────────────────────
    default:
      // Deliberately reads as a schematic placeholder rather than as a
      // specific component: a housing and a connector, nothing claimed.
      return `${OPEN}
        <rect x="62" y="52" width="116" height="76" rx="6" ${MASS}/>
        <rect x="62" y="52" width="116" height="76" rx="6"/>
        <path d="M 62 52 L 178 128 M 178 52 L 62 128" ${HAIR} stroke-dasharray="6 6"/>
        <rect x="98" y="76" width="44" height="28" rx="3" fill="none"/>
        <path d="M 178 78 h 26 M 178 102 h 26" ${HAIR}/>
        <rect x="204" y="68" width="20" height="44" rx="3"/>
      </svg>`;
  }
}
