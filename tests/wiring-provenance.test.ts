import { describe, expect, it } from "vitest";
import { getElectricalDiagnosticsForCode } from "@/lib/sensor-locator";

/**
 * The wiring reference is the one place a reader acts physically on what the
 * app says: they pull a fuse, and they put a probe on a pin.
 *
 * A previous version derived a fuse box, a fuse number, an amperage, a relay
 * name, a position on the engine diagram and a full multimeter pinout from the
 * first three characters of any code it did not recognise — `F03 / 15A`,
 * `coordinatePct: { x: 50, y: 50 }`, `5.0V مرجعي ثابت`. It also drew a
 * sixteen-cell fuse-box "schematic" that was identical for every car.
 */
describe("wiring guidance states where it came from", () => {
  it("gives real reference data for a code that is on file", () => {
    const d = getElectricalDiagnosticsForCode("P0100", "Toyota");
    expect(d.provenance).toBe("reference");
    expect(d.fuseInfo.fuseNumber).toBeTruthy();
    expect(d.sensorLocation.coordinatePct).not.toBeNull();
  });

  it("invents no fuse number for a code it does not know", () => {
    const d = getElectricalDiagnosticsForCode("B2321", "Toyota");
    expect(d.provenance).toBe("general");
    expect(d.fuseInfo.fuseNumber).toBeNull();
    expect(d.fuseInfo.rating).toBeNull();
    expect(d.fuseInfo.relayName).toBeNull();
  });

  it("puts no marker on the engine diagram it cannot place", () => {
    const d = getElectricalDiagnosticsForCode("U0100");
    expect(d.sensorLocation.coordinatePct).toBeNull();
  });

  it("quotes no reference voltage it did not read", () => {
    const d = getElectricalDiagnosticsForCode("P9999");
    expect(d.multimeterTest.referenceVoltage).toBeNull();
  });

  it("never produces the specific values the old version derived", () => {
    // Every unknown code used to land on one of four hardcoded blocks.
    for (const code of ["P0155", "P0299", "P0455", "P0599", "U0121", "B1234"]) {
      const json = JSON.stringify(getElectricalDiagnosticsForCode(code, "BMW"));
      for (const invented of [
        "F03 / 15A",
        "F10 / ECU-15A",
        "EFI-15A / F14",
        "F02 / IGN-30A",
        "O2-HTR-15A",
        "15A (أزرق)",
        "5.0V مرجعي ثابت",
      ]) {
        expect(json, `${code} still emits ${invented}`).not.toContain(invented);
      }
    }
  });

  it("still gives guidance that is true of the code family", () => {
    // Dropping the invented specifics must not leave an empty screen: which
    // end of the engine bay a sensor family lives in, and how to check a
    // supply and a ground, are real workshop practice.
    const d = getElectricalDiagnosticsForCode("P0113");
    expect(d.sensorLocation.engineZone).toBe("front-air");
    expect(d.sensorLocation.areaName.length).toBeGreaterThan(10);
    expect(d.multimeterTest.testingTipLibyan.length).toBeGreaterThan(20);
    expect(d.fuseInfo.circuitDescription).toContain("P0113");
  });

  it("marks an incomplete table entry as general rather than reference", () => {
    // A hit that is missing a sub-block used to be topped up with the same
    // invented generics and still presented as this car's wiring.
    const codes = ["P0100", "P0101", "P0102", "P0113", "P0300", "P0301"];
    for (const code of codes) {
      const d = getElectricalDiagnosticsForCode(code);
      if (d.provenance === "reference") {
        expect(d.fuseInfo.fuseNumber, code).toBeTruthy();
        expect(d.sensorLocation.coordinatePct, code).not.toBeNull();
      }
    }
  });
});

describe("the airbag family", () => {
  const SRS = ["B1811", "B1821", "B1826", "B1650", "B1653", "B1655", "B1660", "B0100"];

  it("never tells the reader to put a meter on a squib circuit", () => {
    // The catch-all branch told every unknown code to check for 12V and a
    // good ground, and called it advice that applies to most circuits. On an
    // airbag igniter the meter's own test current can fire the charge. A real
    // Camry report carried that line on all seven of its faults, every one of
    // them an SRS code.
    for (const code of SRS) {
      const d = getElectricalDiagnosticsForCode(code);
      expect(d.warning, code).toBeTruthy();
      expect(d.multimeterTest.powerPin, code).not.toContain("12V");
      expect(d.multimeterTest.testingTipLibyan, code).not.toContain("12V");
    }
  });

  it("puts the circuit in the cabin, not in the engine bay", () => {
    for (const code of SRS) {
      const d = getElectricalDiagnosticsForCode(code);
      expect(d.sensorLocation.engineZone, code).toBe("cabin");
      expect(d.sensorLocation.coordinatePct, code).toBeNull();
    }
  });

  it("names no fuse number, because a B-code is manufacturer-specific", () => {
    // The same B1650 is a different circuit on a Toyota than on a Ford, so a
    // table keyed on the number alone would be inventing.
    for (const code of SRS) {
      const d = getElectricalDiagnosticsForCode(code);
      expect(d.fuseInfo.fuseNumber, code).toBeNull();
      expect(d.fuseInfo.rating, code).toBeNull();
      expect(d.provenance, code).toBe("general");
    }
  });

  it("leaves the engine families carrying no warning", () => {
    for (const code of ["P0100", "P0301", "P0420", "P0171"]) {
      expect(getElectricalDiagnosticsForCode(code).warning ?? null, code).toBeNull();
    }
  });
});

describe("the chassis and network families", () => {
  it("sends a C-code to the wheel, not to the engine bay", () => {
    for (const code of ["C1201", "C0035", "C1241"]) {
      const d = getElectricalDiagnosticsForCode(code);
      expect(d.sensorLocation.engineZone, code).toBe("wheel-hub");
      expect(d.fuseInfo.fuseNumber, code).toBeNull();
      expect(d.provenance, code).toBe("general");
      expect(d.warning ?? null, code).toBeNull();
    }
  });

  it("tells a U-code it is looking for a conversation, not a sensor", () => {
    for (const code of ["U0100", "U0155", "U1000"]) {
      const d = getElectricalDiagnosticsForCode(code);
      expect(d.sensorLocation.engineZone, code).toBe("cabin");
      // The 60-ohm reading across the bus is the one measurement that is true
      // of every CAN car, and it is the whole first step.
      expect(d.multimeterTest.signalPin, code).toContain("60");
      expect(d.fuseInfo.fuseNumber, code).toBeNull();
    }
  });

  it("still claims no fuse number for either", () => {
    for (const code of ["C1201", "U0100"]) {
      const d = getElectricalDiagnosticsForCode(code);
      expect(d.fuseInfo.rating, code).toBeNull();
      expect(d.sensorLocation.coordinatePct, code).toBeNull();
      expect(d.fuseInfo.circuitDescription, code).toContain(code);
    }
  });
});
