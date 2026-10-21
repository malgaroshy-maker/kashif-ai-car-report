import { describe, expect, it } from "vitest";
import {
  findDtcByCode,
  searchOfflineDtc,
  OFFLINE_DTC_DATABASE,
  QUICK_CODES,
} from "@/lib/offline-dtc";

describe("DTC Offline Encyclopedia", () => {
  it("contains more than 100 offline DTC entries", () => {
    expect(OFFLINE_DTC_DATABASE.length).toBeGreaterThan(100);
  });

  it("finds P0300 misfire code correctly", () => {
    const p0300 = findDtcByCode("P0300");
    expect(p0300).toBeDefined();
    expect(p0300?.code).toBe("P0300");
    expect(p0300?.libyanTerm).toBeDefined();
    expect(p0300?.driverSymptoms.length).toBeGreaterThan(0);
    expect(p0300?.rootCauses.length).toBeGreaterThan(0);
  });

  it("filters by category prefix (P, C, B, U)", () => {
    const engineCodes = searchOfflineDtc("", "P");
    expect(engineCodes.length).toBeGreaterThan(0);
    expect(engineCodes.every((c) => c.code.startsWith("P"))).toBe(true);

    const chassisCodes = searchOfflineDtc("", "C");
    expect(chassisCodes.every((c) => c.code.startsWith("C"))).toBe(true);
  });

  it("searches by Libyan symptom query", () => {
    const results = searchOfflineDtc("عزم");
    expect(results.length).toBeGreaterThan(0);
  });

  it("includes all quick codes in database", () => {
    for (const q of QUICK_CODES) {
      const match = findDtcByCode(q);
      expect(match).toBeDefined();
      expect(match?.code).toBe(q);
    }
  });
});
