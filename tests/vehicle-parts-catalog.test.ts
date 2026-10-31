import { describe, expect, it } from "vitest";
import { VehiclePartsCatalog } from "@/lib/vehicle-parts-catalog";
import { SparePartItem } from "@/lib/types";

describe("VehiclePartsCatalog", () => {
  it("resolves Honda Civic 1999 distributor spark wires instead of individual COP coils", () => {
    const vehicle = {
      make: "Honda",
      model: "Civic Aero",
      year: "1999",
      vin: "SHHMB4760XU100255",
    };

    const part = {
      id: "p1",
      relatedCode: "P0301",
      partNameLibyan: "خيوط بوجيهات",
      partNameEnglish: "Spark plug wires",
      partNameStandardArabic: "أسلاك شمعات الإشعال",
    };

    const match = VehiclePartsCatalog.resolve(vehicle, part);
    expect(match).toBeDefined();
    expect(match?.oemPartNumber).toBe("32722-P2A-003");
    expect(match?.aftermarketReplacements).toContain("NGK RC-HE73 (Stock No. 8018)");
    expect(match?.confidence).toBe("verified");
  });

  it("resolves Honda Civic 1999 genuine spark plugs NGK ZFR5F-11", () => {
    const vehicle = {
      make: "Honda",
      model: "Civic",
      year: "1999",
      vin: "SHHMB4760XU100255",
    };

    const part = {
      id: "p2",
      relatedCode: "P0302",
      partNameLibyan: "شمعات احتراق",
      partNameEnglish: "Spark plugs",
      partNameStandardArabic: "شمعات إشعال",
    };

    const match = VehiclePartsCatalog.resolve(vehicle, part);
    expect(match).toBeDefined();
    expect(match?.oemPartNumber).toContain("98079-5514P");
    expect(match?.aftermarketReplacements).toContain("NGK ZFR5F-11 (Stock No. 2262)");
  });

  it("resolves Toyota Camry 2007 ignition coils and spark plugs", () => {
    const vehicle = {
      make: "Toyota",
      model: "Camry",
      year: "2007",
    };

    const coilPart = {
      id: "p3",
      relatedCode: "P0351",
      partNameLibyan: "بوبينة إشعال",
      partNameEnglish: "Ignition coil",
      partNameStandardArabic: "ملف إشعال",
    };

    const coilMatch = VehiclePartsCatalog.resolve(vehicle, coilPart);
    expect(coilMatch).toBeDefined();
    expect(coilMatch?.oemPartNumber).toContain("90919-02244");
    expect(coilMatch?.aftermarketReplacements).toContain("Denso 673-1307");
  });

  it("generates PartSouq catalog search link when VIN is present", () => {
    const vehicle = {
      make: "Toyota",
      model: "Camry",
      year: "2007",
      vin: "4T1BE46K17U046638",
    };

    const url = VehiclePartsCatalog.generateCatalogSearchUrl(vehicle, {
      partNameEnglish: "Brake pads",
      oemPartNumber: "04465-33471",
    });

    expect(url).toContain("partsouq.com");
    expect(url).toContain("4T1BE46K17U046638");
  });

  it("automatically enriches misfiring Honda Civic with distributor wires if missing", () => {
    const vehicle = {
      make: "Honda",
      model: "Civic",
      year: "1999",
      vin: "SHHMB4760XU100255",
    };

    const initialParts: SparePartItem[] = [
      {
        id: "p1",
        relatedCode: "P0301",
        partNameLibyan: "شمعات",
        partNameStandardArabic: "شمعات إشعال",
        partNameEnglish: "Spark plugs",
        oemPartNumber: null,
        aftermarketReplacements: [],
        estimatedPriceRangeLYD: null,
        diagramCategory: "المحرك",
      },
    ];

    const enriched = VehiclePartsCatalog.enrichPartsList(vehicle, initialParts);
    expect(enriched.length).toBe(2);
    const wiresPart = enriched.find((p) => p.oemPartNumber === "32722-P2A-003");
    expect(wiresPart).toBeDefined();
  });
});
