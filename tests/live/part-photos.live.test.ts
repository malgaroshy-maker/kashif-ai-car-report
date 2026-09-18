import { afterAll, beforeAll, expect, it, vi } from "vitest";
import { searchPartImageOnline } from "@/lib/parts-search";
import { PART_IMAGE_HOSTS } from "@/lib/part-image-hosts";

/**
 * Does the photo search still find photographs?
 *
 * `audit:photos` refetches the curated registry, which answers "are the
 * hand-written URLs still alive". It cannot see the failure that actually took
 * this feature down. Wikimedia moved its thumbnails from
 * `upload.wikimedia.org/.../thumb/...` to `thumb.wikimedia.org`; every live
 * tier kept finding the right picture, and `isAllowedPartImage` then dropped
 * all of them on the floor because the new host was not on the allowlist.
 *
 * Nothing failed. The registry was green, the offline suite was green, the
 * cards fell back to their drawings — which is what they do when there is
 * honestly no photo — and the app lost its photographs for every part outside
 * the twenty-eight curated ones.
 *
 * Two checks, and the first is the one that would have caught it the same day:
 *
 *   1. Nothing may be dropped for being on an unallowed origin. A found photo
 *      that the allowlist refuses is a host that moved, not a bad photo.
 *   2. A floor on how many of these names come back with a photo at all, so
 *      that a search tier which quietly stops returning anything is visible.
 *
 * Network-bound and therefore not part of `npm test`: run `npm run audit:live`.
 */

/**
 * Parts a Libyan workshop actually reads off a scan, in both the English name
 * a catalogue uses and the name spoken at the counter. Deliberately wider than
 * the curated registry — over half of these have no curated entry, so they can
 * only pass through the live tiers, which is the thing being measured.
 */
const PARTS: [english: string, libyan: string][] = [
  ["Brake Pads", "تيل فرينو"],
  ["Shock Absorber", "مزاطوري"],
  ["Serpentine Belt", "سير"],
  ["Camshaft Position Sensor", "حساس كامة"],
  ["Water Pump", "بومبة مية"],
  ["Clock Spring", "شريط إيرباق الدومان"],
  ["Radiator", "رداتوري"],
  ["Wheel Bearing", "رمان بلي"],
  ["Tie Rod End", "بوكل دركسيون"],
  ["Engine Mount", "كرسي مكينة"],
  ["Fuel Injector", "رشاش"],
  ["Turbocharger", "تربو"],
  ["Knock Sensor", "حساس الطرق"],
  ["EGR Valve", "بلف EGR"],
  ["Purge Valve", "بلف الكانستر"],
  ["Cabin Air Filter", "فيلترو مكيف"],
  ["Wiper Blade", "مساحة"],
  ["Headlight Assembly", "فانوس"],
  ["Coolant Temperature Sensor", "حساس حرارة المية"],
  ["Throttle Body", "بوابة"],
  ["Steering Rack", "قرسيوني"],
  ["CV Joint", "بيضة"],
  ["A/C Compressor", "كمبروسر مكيف"],
  ["Battery", "بطارية"],
  ["Starter Motor", "مارش"],
  ["Spark Plug", "شمعات"],
  ["Air Filter", "فيلترو هواء"],
  ["Ignition Coil", "بوبين"],
  ["Oxygen Sensor", "حساس مرميطة"],
  ["Catalytic Converter", "علبة كربون"],
];

/**
 * Measured at 24 of these 30 once the five parts the live tiers could never
 * answer were looked up by hand. The floor sits below that rather than at it:
 * Commons is edited by other people, and a file being recategorised is not a
 * bug in this app. A tier going dark takes the number well under this —
 * losing the live tiers entirely leaves the registry's own count.
 *
 * The six that remain are photographed nowhere Wikimedia can reach: the
 * camshaft position sensor, the clock spring, the engine mount, the knock
 * sensor, the coolant temperature sensor and the EVAP purge valve. They are
 * drawn, and `part-photos.test.ts` keeps them that way.
 */
const MIN_HITS = 20;

let warnings: string[] = [];
let warn: ReturnType<typeof vi.spyOn>;

beforeAll(() => {
  warn = vi.spyOn(console, "warn").mockImplementation((...args: unknown[]) => {
    warnings.push(args.map(String).join(" "));
  });
});

afterAll(() => warn?.mockRestore());

it("finds photographs, and drops none of them on an unallowed origin", async () => {
  warnings = [];
  const found: string[] = [];

  for (const [english, libyan] of PARTS) {
    const url = await searchPartImageOnline("", english, "", "", "", libyan);
    if (url) found.push(english);
    const file = url ? decodeURIComponent(url).split("/").pop() : "";
    process.stdout.write(
      `${url ? "photo" : "  —  "}  ${english.padEnd(28)}${file}\n`
    );
  }

  const dropped = warnings.filter((w) => w.includes("not allowed"));
  process.stdout.write(
    `\n${found.length}/${PARTS.length} parts have a photo` +
      `${dropped.length ? `, ${dropped.length} dropped on an unallowed origin` : ""}\n`
  );

  // A photo was found and then thrown away. That is a host that moved, and it
  // is invisible in the app: the card falls back to its drawing exactly as it
  // does when no photo exists.
  expect(
    dropped,
    `A photo was found and discarded for being off the allowlist. Add the host to PART_IMAGE_HOSTS (currently ${PART_IMAGE_HOSTS.join(", ")}):\n${dropped.join("\n")}`
  ).toEqual([]);

  expect(
    found.length,
    `Only ${found.length} of ${PARTS.length} parts came back with a photo. Without the live tiers this number is about 10 — the curated registry alone.`
  ).toBeGreaterThanOrEqual(MIN_HITS);
}, 300_000);

/**
 * Two cards from a real Hyundai Elantra HD report, neither of which has a
 * photograph anywhere — and one of which was answered with a Volvo steering
 * wheel.
 *
 * "عمود ستيرسو كهربائي مع حساس التورك" is an electric steering column. It
 * contains "ستيرسو", whose dictionary gloss is "Steering wheel (sterzo)", and
 * once the English name missed, that gloss was what the archive was asked for.
 * The reader got a confident photograph of the wrong component in the same
 * corner of the car at a very different price.
 *
 * The right answer for both of these is no photograph at all: Commons and
 * Wikipedia have neither a steering angle sensor nor an EPS column. The card
 * then draws its schematic, which names the part without claiming to be a
 * picture of it.
 */
it("draws a schematic rather than answering with a different part", async () => {
  const column = await searchPartImageOnline(
    "",
    "EPS Column Assembly with Torque Sensor",
    "",
    "",
    "",
    "عمود ستيرسو كهربائي مع حساس التورك (سكاتولة فوقية) النترا HD"
  );
  expect(column, "a steering column must never be shown as a steering wheel").not.toMatch(
    /steering_wheel/i
  );

  const sensor = await searchPartImageOnline(
    "",
    "Steering Angle Sensor",
    "",
    "",
    "",
    "حساس زاوية الستيرسو / شريط الدومان النترا HD"
  );
  expect(sensor, "nor may the angle sensor be").not.toMatch(/steering_wheel/i);
}, 120_000);
