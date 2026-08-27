import { describe, expect, it } from "vitest";
import { getPartSvg, getPartVisualType } from "@/lib/part-visuals";
import manifest from "@/app/manifest";
import robots from "@/app/robots";
import sitemap from "@/app/sitemap";

/**
 * The part schematics are written into the page with
 * `dangerouslySetInnerHTML`, so the invariant that makes that safe — that they
 * are literals in `part-visuals.ts` and interpolate nothing — has to be
 * checked rather than remembered.
 */
describe("part schematics carry no active content", () => {
  const NAMES = [
    "Oxygen Sensor",
    "Ignition Coil",
    "Spark Plug",
    "Thermostat",
    "Fuel Pump",
    "Catalytic Converter",
    "Brake Disc",
    "Mass Air Flow Sensor",
    "something we have no drawing for at all",
    "",
  ];

  it("never emits a script, an event handler or a javascript: url", () => {
    for (const name of NAMES) {
      const svg = getPartSvg(name, "22204-22010");
      expect(svg, name).not.toMatch(/<script/i);
      expect(svg, name).not.toMatch(/\son\w+\s*=/i);
      expect(svg, name).not.toMatch(/javascript:/i);
      expect(svg, name).not.toMatch(/<iframe|<foreignObject/i);
    }
  });

  it("cannot be steered by the part name or the OEM number", () => {
    // Both are model output. If either reached the markup, this would fail.
    const hostile = '"><script>alert(1)</script>';
    const svg = getPartSvg(hostile, hostile);
    expect(svg).not.toContain("alert(1)");
    expect(svg).not.toContain(hostile);
  });

  it("claims nothing about the part it is drawing", () => {
    // The generic fallback used to print "GENUINE OEM", "OEM SPEC" and
    // "AUTO COMPONENT" onto a drawing that is the same for every part.
    for (const name of NAMES) {
      const svg = getPartSvg(name);
      for (const claim of ["GENUINE OEM", "OEM SPEC", "AUTO COMPONENT"]) {
        expect(svg, `${name} still claims ${claim}`).not.toContain(claim);
      }
    }
  });

  it("returns a drawing for the parts it does know", () => {
    expect(getPartVisualType("Oxygen Sensor")).toBe("OXYGEN_SENSOR");
    expect(getPartSvg("Oxygen Sensor").length).toBeGreaterThan(200);
  });

  it("routes a part to its own drawing and not to a neighbour's", () => {
    // Two of these are bare-substring traps that shipped: "brake" matches
    // inside "brake pad", and "abs" inside "shock ABSorber", so both parts
    // drew the wrong component until the specific test was put first.
    const cases: [string, string][] = [
      ["Shock Absorber", "SHOCK_ABSORBER"],
      ["مزاطوري أمامي", "SHOCK_ABSORBER"],
      ["ABS Wheel Speed Sensor", "ABS_SENSOR"],
      ["Brake Pad", "BRAKE_PAD"],
      ["باطنيات", "BRAKE_PAD"],
      ["Brake Disc", "BRAKE_DISC"],
      ["Radiator", "RADIATOR"],
      ["رداتوري", "RADIATOR"],
      // The clock spring is named "airbag ribbon of the steering wheel"; the
      // general airbag test must not take it first.
      ["شريط إيرباق الدومان", "CLOCK_SPRING"],
      ["إيرباق جانب الكرسي", "SIDE_AIRBAG"],
      ["طقطوقة حزام الأمان", "SEATBELT_BUCKLE"],
    ];
    for (const [name, type] of cases) {
      expect(getPartVisualType(name), name).toBe(type);
      expect(getPartSvg(name).length, name).toBeGreaterThan(200);
    }
  });
});

describe("the installed app", () => {
  it("launches right-to-left, in Arabic, on the board's own colour", () => {
    const m = manifest();
    expect(m.lang).toBe("ar");
    expect(m.dir).toBe("rtl");
    expect(m.start_url).toBe("/");
    expect(m.display).toBe("standalone");
    // A white splash behind an app whose board is #d5d7cf flashes on launch.
    expect(m.background_color).toBe("#d5d7cf");
  });

  it("ships a maskable icon, so a round launcher does not crop the mark", () => {
    const purposes = (manifest().icons ?? []).map((i) => i.purpose);
    expect(purposes).toContain("maskable");
    expect(purposes).toContain("any");
  });
});

describe("crawlers", () => {
  it("are kept off the API, where every route costs the user money", () => {
    const rules = robots().rules;
    const rule = Array.isArray(rules) ? rules[0] : rules;
    expect(rule.disallow).toContain("/api/");
    expect(rule.allow).toBe("/");
  });

  it("get an absolute sitemap, not a localhost one", () => {
    for (const entry of sitemap()) {
      expect(entry.url).toMatch(/^https:\/\//);
      expect(entry.url).not.toContain("localhost");
    }
    expect(robots().sitemap).toMatch(/^https:\/\/.+\/sitemap\.xml$/);
  });
});
