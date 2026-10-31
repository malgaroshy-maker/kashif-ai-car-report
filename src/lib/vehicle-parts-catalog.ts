/**
 * Database of authentic OEM part numbers, verified aftermarket replacements,
 * and market price ranges for the most common car makes & models in Libya.
 * Ported from Flow Cars / Kashif Mobile (vehicle_parts_catalog.dart).
 */

import { SparePartItem } from "./types";

export interface VehicleMatchInfo {
  make?: string | null;
  model?: string | null;
  year?: string | number | null;
  vin?: string | null;
}

export class VehiclePartsCatalog {
  /**
   * Generates a direct 1-tap Google/EPC catalog search link pre-filtered by vehicle & part.
   */
  static generateCatalogSearchUrl(
    vehicle: VehicleMatchInfo | null | undefined,
    part: { partNameEnglish?: string; partNameLibyan?: string; oemPartNumber?: string | null }
  ): string {
    const vin = (vehicle?.vin || "").trim();
    if (vin && vin !== "غير محدد" && vin.length >= 11) {
      return `https://partsouq.com/en/search/all?q=${encodeURIComponent(vin)}`;
    }
    const car = `${vehicle?.year || ""} ${vehicle?.make || ""} ${vehicle?.model || ""}`.trim();
    const pName = part.partNameEnglish || part.partNameLibyan || "";
    const oem =
      part.oemPartNumber &&
      !part.oemPartNumber.includes("VIN") &&
      !part.oemPartNumber.includes("مطابقة")
        ? part.oemPartNumber
        : "";
    const query = `${car} ${pName} ${oem} OEM part number`.trim();
    return `https://www.google.com/search?q=${encodeURIComponent(query)}`;
  }

  /**
   * Resolves and corrects spare part items for a specific vehicle using
   * verified manufacturer catalogs and automotive engineering rules.
   */
  static resolve(
    vehicle: VehicleMatchInfo | null | undefined,
    part: Partial<SparePartItem>
  ): SparePartItem | null {
    if (!vehicle) return null;

    const make = (vehicle.make || "").toUpperCase().trim();
    const model = (vehicle.model || "").toUpperCase().trim();
    const yearStr = (vehicle.year != null ? String(vehicle.year) : "").replace(/[^0-9]/g, "");
    const year = parseInt(yearStr, 10) || 0;
    const vin = (vehicle.vin || "").toUpperCase().trim();

    const pLibyan = (part.partNameLibyan || "").toLowerCase();
    const pEnglish = (part.partNameEnglish || "").toLowerCase();
    const pStandard = (part.partNameStandardArabic || "").toLowerCase();
    const code = (part.relatedCode || "").toUpperCase().trim();
    const rawOem = (part.oemPartNumber || "").trim();

    const partId = part.id || `part_${Date.now()}`;

    // =========================================================================
    // 1. HONDA CIVIC (سيفيك)
    // =========================================================================
    if (make.includes("HONDA") && (model.includes("CIVIC") || vin.startsWith("SHHMB") || vin.startsWith("JHMEK"))) {
      // 1.A. Generation 6 (1996 - 2000) e.g. Civic Aero / EK / MB4 / EJ (D14/D15/D16 Engine)
      // CRITICAL: Uses Ignition Distributor (ديلكو), NOT individual Coil-on-Plug coils!
      if ((year >= 1996 && year <= 2000) || vin.startsWith("SHHMB") || vin.startsWith("JHMEK")) {
        // Spark Plug Wires (خيوط البوجيهات) - Check first
        if (this.isSparkPlugWire(pLibyan, pEnglish, pStandard)) {
          return {
            id: partId,
            relatedCode: part.relatedCode || "P0301-P0304",
            partNameLibyan: "طقم خيوط شمعات الاحتراق (خيوط بوجيهات ديلكو)",
            partNameStandardArabic: "أسلاك توصيل شمعات الإشعال عالية الجهد",
            partNameEnglish: "Ignition Spark Plug Wire Set",
            oemPartNumber: "32722-P2A-003",
            aftermarketReplacements: [
              "NGK RC-HE73 (Stock No. 8018)",
              "Seiwa Japan 50058",
              "Denso 671-4045",
            ],
            estimatedPriceRangeLYD: {
              min: 60,
              max: 130,
              marketNote: "سعر طقم خيوط البوجيهات في ليبيا",
            },
            diagramCategory: "المحرك",
            isOemNumberUnverified: false,
            confidence: "verified",
            catalogSearchUrl: this.generateCatalogSearchUrl(vehicle, {
              partNameEnglish: "Ignition Spark Plug Wire Set",
              oemPartNumber: "32722-P2A-003",
            }),
          };
        }

        // Spark Plugs (الشمعات / البوجيهات)
        if (this.isSparkPlug(pLibyan, pEnglish, pStandard, code) || rawOem.includes("98066-")) {
          return {
            id: partId,
            relatedCode: part.relatedCode || "P0301-P0304",
            partNameLibyan: "شمعات احتراق أصلية (بوجيهات سن ممتد)",
            partNameStandardArabic: "شمعات إشعال أصلية لمحرك هوندا سيفيك D16/D15",
            partNameEnglish: "Genuine Spark Plugs (Extended Reach)",
            oemPartNumber: "98079-5514P (NGK ZFR5F-11)",
            aftermarketReplacements: [
              "NGK ZFR5F-11 (Stock No. 2262)",
              "NGK ZFR6F-11 (Stock No. 4291)",
              "Denso KJ16CR-L11",
              "Denso Iridium IK16",
            ],
            estimatedPriceRangeLYD: {
              min: 20,
              max: 45,
              marketNote: "سعر الشمعة الواحدة 20 - 45 د.ل (طقم 80 - 180 د.ل)",
            },
            diagramCategory: "المحرك",
            isOemNumberUnverified: false,
            confidence: "verified",
            catalogSearchUrl: "https://www.google.com/search?q=1999+Honda+Civic+98079-5514P+ZFR5F-11+spark+plug",
          };
        }

        // Airbag SRS Box (بوكس وسائد هوائية)
        if (this.isAirbagBox(pLibyan, pEnglish, pStandard, code) || rawOem.includes("77510") || rawOem.includes("77960")) {
          return {
            id: partId,
            relatedCode: part.relatedCode || "SRS-07-02",
            partNameLibyan: "بوكس منظومة الوسائد الهوائية (كمبيوتر SRS)",
            partNameStandardArabic: "وحدة التحكم الإلكترونية للوسائد الهوائية",
            partNameEnglish: "SRS Airbag Control Unit Module",
            oemPartNumber: "77960-ST3-E82 (مطابقة برقم الهيكل SHHMB4)",
            aftermarketReplacements: [
              "Honda Genuine 77960-ST3",
              "Honda OEM 77960-S04",
              "تشليح أصلي وكالة معتمد",
            ],
            estimatedPriceRangeLYD: {
              min: 350,
              max: 750,
              marketNote: "سعر كمبيوتر الإيرباق أصلي استيراد / تشليح",
            },
            diagramCategory: "الأمان والوسائد الهوائية",
            isOemNumberUnverified: false,
            confidence: "verified",
            catalogSearchUrl: this.generateCatalogSearchUrl(vehicle, {
              partNameEnglish: "SRS Airbag Control Module",
              oemPartNumber: "77960-ST3-E82",
            }),
          };
        }

        // Misfire / Ignition / Bobina
        if (this.isIgnitionOrCoil(pLibyan, pEnglish, pStandard, code) || rawOem.includes("30510-PLM")) {
          return {
            id: partId,
            relatedCode: part.relatedCode || "P0301-P0304",
            partNameLibyan: "بوبينة ديلكو داخلية (أو موزع شرارة ديلكو كامل)",
            partNameStandardArabic: "ملف إشعال داخلي للديلكو (أو موزع إشعال كامل)",
            partNameEnglish: "Internal Distributor Ignition Coil / Complete Distributor",
            oemPartNumber: "30510-PT2-006 (ديلكو كامل: 30100-P2E-A01)",
            aftermarketReplacements: [
              "Hitachi / TEC TD-80U",
              "Denso 673-2301",
              "Standard Motor JH-142",
              "قطع ديلكو أصلي وكالة / تشليح",
            ],
            estimatedPriceRangeLYD: {
              min: 80,
              max: 180,
              marketNote: "سعر البوبينة 80-180 د.ل والديلكو كامل 250-550 د.ل",
            },
            diagramCategory: "المحرك",
            isOemNumberUnverified: false,
            confidence: "verified",
            catalogSearchUrl: "https://www.google.com/search?q=1999+Honda+Civic+1.6+30510-PT2-006+distributor+coil+OEM",
          };
        }
      }

      // 1.B. Generation 7 (2001 - 2005) e.g. Civic ES/EU (D17 Engine)
      if (year >= 2001 && year <= 2005) {
        if (this.isIgnitionOrCoil(pLibyan, pEnglish, pStandard, code)) {
          return {
            id: partId,
            relatedCode: part.relatedCode || "P0300",
            partNameLibyan: "بوبينة إشعال أصلية (كويل سيفيك D17)",
            partNameStandardArabic: "ملف إشعال المحرك (بوبينة)",
            partNameEnglish: "Ignition Coil Honda Civic 1.7L",
            oemPartNumber: "30520-PZ3-000 (30520-PGK-A01)",
            aftermarketReplacements: [
              "Denso 099700-061 (673-2302)",
              "Hitachi IGC0054",
              "Bosch 0986221042",
            ],
            estimatedPriceRangeLYD: { min: 75, max: 160, marketNote: "سعر البوبينة الواحدة" },
            diagramCategory: "المحرك",
            isOemNumberUnverified: false,
            confidence: "verified",
            catalogSearchUrl: this.generateCatalogSearchUrl(vehicle, {
              partNameEnglish: "Ignition Coil",
              oemPartNumber: "30520-PZ3-000",
            }),
          };
        }
        if (this.isSparkPlug(pLibyan, pEnglish, pStandard, code)) {
          return {
            id: partId,
            relatedCode: part.relatedCode || "P0300",
            partNameLibyan: "شمعات احتراق أصلية",
            partNameStandardArabic: "شمعات إشعال أصلية هوندا سيفيك 1.7",
            partNameEnglish: "Genuine Spark Plugs Honda D17",
            oemPartNumber: "98079-5614E (NGK ZFR6J-11)",
            aftermarketReplacements: [
              "NGK ZFR6J-11 (Stock No. 5585)",
              "Denso KJ20CR-L11",
            ],
            estimatedPriceRangeLYD: { min: 25, max: 50, marketNote: "سعر الشمعة" },
            diagramCategory: "المحرك",
            isOemNumberUnverified: false,
            confidence: "verified",
          };
        }
      }

      // 1.C. Generation 8 (2006 - 2011) Civic FD / FK (R18A 1.8L Engine)
      if (year >= 2006 && year <= 2011) {
        if (this.isIgnitionOrCoil(pLibyan, pEnglish, pStandard, code)) {
          return {
            id: partId,
            relatedCode: part.relatedCode || "P0300",
            partNameLibyan: "بوبينة إشعال أصلية (كويل سيفيك R18)",
            partNameStandardArabic: "ملف إشعال محرك هوندا سيفيك 1.8",
            partNameEnglish: "Ignition Coil Honda Civic R18",
            oemPartNumber: "30520-RNA-A01",
            aftermarketReplacements: [
              "Denso 099700-101 (673-2308)",
              "Hitachi IGC0057",
              "NGK 48337 (U5058)",
            ],
            estimatedPriceRangeLYD: { min: 80, max: 175, marketNote: "سعر البوبينة" },
            diagramCategory: "المحرك",
            isOemNumberUnverified: false,
            confidence: "verified",
          };
        }
        if (this.isSparkPlug(pLibyan, pEnglish, pStandard, code)) {
          return {
            id: partId,
            relatedCode: part.relatedCode || "P0300",
            partNameLibyan: "شمعات احتراق ليزر إيريديوم أصلية",
            partNameStandardArabic: "شمعات إشعال إيريديوم هوندا R18",
            partNameEnglish: "Laser Iridium Spark Plugs",
            oemPartNumber: "98079-5615E (NGK IZFR6K-11S)",
            aftermarketReplacements: [
              "NGK IZFR6K-11S (Stock No. 5266)",
              "Denso SKJ20DR-M11",
            ],
            estimatedPriceRangeLYD: { min: 40, max: 85, marketNote: "سعر الشمعة إيريديوم" },
            diagramCategory: "المحرك",
            isOemNumberUnverified: false,
            confidence: "verified",
          };
        }
      }
    }

    // =========================================================================
    // 2. HYUNDAI SANTA FE (سنتافي CM 2006 - 2012)
    // =========================================================================
    if (make.includes("HYUNDAI") && model.includes("SANTA")) {
      if ((year >= 2006 && year <= 2012) || vin.startsWith("5NM") || vin.startsWith("KM8")) {
        // EVAP Purge Control Valve
        if (code.includes("P044") || code.includes("P045") || pLibyan.includes("بخر") || pEnglish.includes("purge") || pEnglish.includes("evap")) {
          return {
            id: partId,
            relatedCode: part.relatedCode || "P0442",
            partNameLibyan: "صمام بخر خزان البنزين (بلف الفاب / Purge Valve)",
            partNameStandardArabic: "صمام التحكم في تصريف أبخرة الوقود (EVAP)",
            partNameEnglish: "EVAP Purge Control Solenoid Valve",
            oemPartNumber: "28910-25000 (28910-3C100)",
            aftermarketReplacements: [
              "Bosch 0280142427",
              "Hyundai Mobis Genuine 28910-25000",
              "Standard Motor CP541",
              "Dorman 911-808",
            ],
            estimatedPriceRangeLYD: {
              min: 80,
              max: 170,
              marketNote: "سعر بلف البخر في سوق قطع الغيار في ليبيا",
            },
            diagramCategory: "المحرك",
            isOemNumberUnverified: false,
            confidence: "verified",
            catalogSearchUrl: "https://www.google.com/search?q=Hyundai+Santa+Fe+28910-25000+purge+valve+OEM",
          };
        }

        // Oxygen Sensor / Rich Trim (P2188, P2190, P0171, P0172)
        if (code.includes("P218") || code.includes("P219") || code.includes("P017") || pLibyan.includes("مرميط") || pEnglish.includes("oxygen") || pEnglish.includes("o2")) {
          return {
            id: partId,
            relatedCode: part.relatedCode || "P2188",
            partNameLibyan: "حساس مرميطة علوي (حساس أكسجين بنك 1 / بنك 2)",
            partNameStandardArabic: "مستشعر الأكسجين العلوي قبل دبة البيئة",
            partNameEnglish: "Upstream Oxygen / Air-Fuel Ratio Sensor",
            oemPartNumber: "39210-3C100 (Bank 1) / 39210-3C200 (Bank 2)",
            aftermarketReplacements: [
              "Bosch 0258017025",
              "Denso 234-4854",
              "Hyundai Mobis Genuine",
            ],
            estimatedPriceRangeLYD: { min: 160, max: 320, marketNote: "سعر حساس الأكسجين الأصلي" },
            diagramCategory: "الفرامل والعادم",
            isOemNumberUnverified: false,
            confidence: "verified",
          };
        }

        // MAF Sensor
        if (code.includes("P010") || pLibyan.includes("سيرزو") || pLibyan.includes("تدفق") || pEnglish.includes("maf") || pEnglish.includes("air flow")) {
          return {
            id: partId,
            relatedCode: part.relatedCode || "P0101",
            partNameLibyan: "حساس قياس تدفق الهواء (سيرزو / MAF)",
            partNameStandardArabic: "مستشعر كتلة تدفق الهواء للمحرك",
            partNameEnglish: "Mass Air Flow Sensor (MAF)",
            oemPartNumber: "28164-37200",
            aftermarketReplacements: [
              "Bosch 0280218106",
              "Hyundai Mobis Genuine 28164-37200",
            ],
            estimatedPriceRangeLYD: { min: 220, max: 450, marketNote: "سعر حساس الهواء MAF" },
            diagramCategory: "المحرك",
            isOemNumberUnverified: false,
            confidence: "verified",
          };
        }
      }
    }

    // =========================================================================
    // 3. TOYOTA CAMRY (كامري 2007 - 2011 XV40 2.4L / 2.5L)
    // =========================================================================
    if (make.includes("TOYOTA") && model.includes("CAMRY")) {
      if (year >= 2006 && year <= 2011) {
        if (this.isIgnitionOrCoil(pLibyan, pEnglish, pStandard, code)) {
          return {
            id: partId,
            relatedCode: part.relatedCode || "P0351",
            partNameLibyan: "بوبينة إشعال أصلية (كويل كامري 2.4)",
            partNameStandardArabic: "ملف إشعال محرك تويوتا كامري 2AZ-FE",
            partNameEnglish: "Ignition Coil Toyota Camry 2.4L",
            oemPartNumber: "90919-02244 (90919-02266)",
            aftermarketReplacements: [
              "Denso 673-1307",
              "Diamond Japan 90919-02244",
              "Bosch 0986221096",
            ],
            estimatedPriceRangeLYD: { min: 75, max: 160, marketNote: "سعر البوبينة الواحدة" },
            diagramCategory: "المحرك",
            isOemNumberUnverified: false,
            confidence: "verified",
          };
        }
        if (this.isSparkPlug(pLibyan, pEnglish, pStandard, code)) {
          return {
            id: partId,
            relatedCode: part.relatedCode || "P0300",
            partNameLibyan: "شمعات احتراق إيريديوم أصلية",
            partNameStandardArabic: "شمعات إشعال إيريديوم تويوتا 2AZ-FE",
            partNameEnglish: "Iridium Long-Life Spark Plugs",
            oemPartNumber: "90919-01210 (Denso SK20R11)",
            aftermarketReplacements: [
              "Denso SK20R11 (Stock No. 3297)",
              "NGK IFR6A11 (Stock No. 1095)",
            ],
            estimatedPriceRangeLYD: { min: 35, max: 75, marketNote: "سعر الشمعة إيريديوم" },
            diagramCategory: "المحرك",
            isOemNumberUnverified: false,
            confidence: "verified",
          };
        }
        if (this.isClockSpring(pLibyan, pEnglish, pStandard, code)) {
          return {
            id: partId,
            relatedCode: part.relatedCode || "B1801",
            partNameLibyan: "شريط إيرباق الدومان (الفيشة الحلزونية للستيرسو)",
            partNameStandardArabic: "شريط الوسائد الهوائية لعجلة القيادة",
            partNameEnglish: "Airbag Clock Spring Spiral Cable",
            oemPartNumber: "84306-06140 (84306-48030)",
            aftermarketReplacements: [
              "Toyota Genuine 84306-06140",
              "Tokai Rika Japan",
            ],
            estimatedPriceRangeLYD: { min: 120, max: 250, marketNote: "سعر شريط الإيرباق" },
            diagramCategory: "الأمان والوسائد الهوائية",
            isOemNumberUnverified: false,
            confidence: "verified",
          };
        }
      }
    }

    // =========================================================================
    // 4. TOYOTA COROLLA (كورولا 2008 - 2013 1.6L 1ZR / 1.8L 2ZR)
    // =========================================================================
    if (make.includes("TOYOTA") && model.includes("COROLLA")) {
      if (year >= 2008 && year <= 2013) {
        if (this.isIgnitionOrCoil(pLibyan, pEnglish, pStandard, code)) {
          return {
            id: partId,
            relatedCode: part.relatedCode || "P0351",
            partNameLibyan: "بوبينة إشعال أصلية (كويل كورولا 1ZR / 2ZR)",
            partNameStandardArabic: "ملف إشعال محرك تويوتا كورولا Dual VVT-i",
            partNameEnglish: "Ignition Coil Toyota Corolla 1.6/1.8L",
            oemPartNumber: "90919-02258 (90919-02252)",
            aftermarketReplacements: [
              "Denso 673-1309",
              "Diamond Japan",
              "Bosch 0986221098",
            ],
            estimatedPriceRangeLYD: { min: 75, max: 155, marketNote: "سعر البوبينة" },
            diagramCategory: "المحرك",
            isOemNumberUnverified: false,
            confidence: "verified",
          };
        }
        if (this.isSparkPlug(pLibyan, pEnglish, pStandard, code)) {
          return {
            id: partId,
            relatedCode: part.relatedCode || "P0300",
            partNameLibyan: "شمعات احتراق إيريديوم سن رفيع أصلية",
            partNameStandardArabic: "شمعات إشعال تويوتا كورولا SC20HR11",
            partNameEnglish: "Iridium Spark Plugs Toyota 1ZR/2ZR",
            oemPartNumber: "90919-01253 (Denso SC20HR11)",
            aftermarketReplacements: [
              "Denso SC20HR11 (Stock No. 3444)",
              "NGK ILKAR7B11 (Stock No. 4912)",
            ],
            estimatedPriceRangeLYD: { min: 30, max: 70, marketNote: "سعر الشمعة" },
            diagramCategory: "المحرك",
            isOemNumberUnverified: false,
            confidence: "verified",
          };
        }
      }
    }

    // =========================================================================
    // 5. HYUNDAI ELANTRA & ACCENT (1.6L Gamma / 1.4L)
    // =========================================================================
    if (make.includes("HYUNDAI") && (model.includes("ELANTRA") || model.includes("ACCENT") || model.includes("VERNA"))) {
      if (this.isIgnitionOrCoil(pLibyan, pEnglish, pStandard, code)) {
        return {
          id: partId,
          relatedCode: part.relatedCode || "P0300",
          partNameLibyan: "بوبينة إشعال أصلية (كويل النترا / أكسنت 1.6)",
          partNameStandardArabic: "ملف إشعال محرك هيونداي كيا 1.6 Gamma",
          partNameEnglish: "Ignition Coil Hyundai/Kia 1.6L",
          oemPartNumber: "27301-2B010 (27301-2B000)",
          aftermarketReplacements: [
            "Yura Tech 27301-2B010",
            "Denso 673-8305",
            "Mobis Genuine Korea",
          ],
          estimatedPriceRangeLYD: { min: 60, max: 130, marketNote: "سعر البوبينة" },
          diagramCategory: "المحرك",
          isOemNumberUnverified: false,
          confidence: "verified",
        };
      }
      if (this.isSparkPlug(pLibyan, pEnglish, pStandard, code)) {
        return {
          id: partId,
          relatedCode: part.relatedCode || "P0300",
          partNameLibyan: "شمعات احتراق أصلية هيونداي كيا",
          partNameStandardArabic: "شمعات إشعال محرك Gamma 1.6L",
          partNameEnglish: "Genuine Spark Plugs Hyundai/Kia",
          oemPartNumber: "18855-10060 (NGK LZKR6B-10E)",
          aftermarketReplacements: [
            "NGK LZKR6B-10E (Stock No. 1578)",
            "Champion RER8YC",
            "Mobis Genuine",
          ],
          estimatedPriceRangeLYD: { min: 20, max: 45, marketNote: "سعر الشمعة" },
          diagramCategory: "المحرك",
          isOemNumberUnverified: false,
          confidence: "verified",
        };
      }
      if (this.isClockSpring(pLibyan, pEnglish, pStandard, code)) {
        return {
          id: partId,
          relatedCode: part.relatedCode || "B1811",
          partNameLibyan: "شريط إيرباق الدومان (الفيشة الحلزونية للستيرسو)",
          partNameStandardArabic: "شريط الوسائد الهوائية لعجلة القيادة",
          partNameEnglish: "Airbag Clock Spring Hyundai",
          oemPartNumber: "93490-2H000 (HD) / 93490-3X020 (MD)",
          aftermarketReplacements: [
            "Mobis Genuine Korea",
            "Mando OEM",
          ],
          estimatedPriceRangeLYD: { min: 90, max: 180, marketNote: "سعر شريط الإيرباق" },
          diagramCategory: "الأمان والوسائد الهوائية",
          isOemNumberUnverified: false,
          confidence: "verified",
        };
      }
    }

    // =========================================================================
    // 6. NISSAN SUNNY (صني N16 2000-2011 QG16 / N17 2012+ HR15)
    // =========================================================================
    if (make.includes("NISSAN") && model.includes("SUNNY")) {
      const isN16 = year <= 2011;
      if (this.isIgnitionOrCoil(pLibyan, pEnglish, pStandard, code)) {
        return {
          id: partId,
          relatedCode: part.relatedCode || "P0350",
          partNameLibyan: isN16 ? "بوبينة إشعال نيسان صني N16" : "بوبينة إشعال نيسان صني N17",
          partNameStandardArabic: "ملف إشعال محرك نيسان صني",
          partNameEnglish: "Ignition Coil Nissan Sunny",
          oemPartNumber: isN16 ? "22448-6N015" : "22448-ED000",
          aftermarketReplacements: [
            "Hanshin Japan Genuine",
            "Hitachi IGC0071",
            "Denso Aftermarket",
          ],
          estimatedPriceRangeLYD: { min: 65, max: 140, marketNote: "سعر البوبينة" },
          diagramCategory: "المحرك",
          isOemNumberUnverified: false,
          confidence: "verified",
        };
      }
      if (this.isSparkPlug(pLibyan, pEnglish, pStandard, code)) {
        return {
          id: partId,
          relatedCode: part.relatedCode || "P0300",
          partNameLibyan: "شمعات احتراق أصلية نيسان",
          partNameStandardArabic: "شمعات إشعال نيسان صني",
          partNameEnglish: "Genuine Spark Plugs Nissan",
          oemPartNumber: isN16 ? "22401-50Y05 (BKR5E-11)" : "22401-ED815 (LZKAR6AP-11)",
          aftermarketReplacements: [
            "NGK LZKAR6AP-11 (Stock No. 6643)",
            "Denso FXE20HR11",
          ],
          estimatedPriceRangeLYD: { min: 25, max: 55, marketNote: "سعر الشمعة" },
          diagramCategory: "المحرك",
          isOemNumberUnverified: false,
          confidence: "verified",
        };
      }
    }

    // =========================================================================
    // 7. OPEL ASTRA G (1998 - 2004)
    // =========================================================================
    if (make.includes("OPEL") && model.includes("ASTRA")) {
      // Camshaft Sensor
      if (code.includes("P0340") || pLibyan.includes("كامة") || pEnglish.includes("camshaft")) {
        return {
          id: partId,
          relatedCode: part.relatedCode || "P0340",
          partNameLibyan: "حساس الكامة الأصلي (سنسور الامبروكم)",
          partNameStandardArabic: "مستشعر موضع عمود الكامات لمحرك أوبل استرا G",
          partNameEnglish: "Camshaft Position Sensor (CMP)",
          oemPartNumber: "90536064 (GM / Siemens 5WK90551Z)",
          aftermarketReplacements: [
            "Siemens VDO 5WK90551Z",
            "Hella 6PU 009 121-081",
            "Bosch 0986280412",
          ],
          estimatedPriceRangeLYD: { min: 120, max: 240, marketNote: "سعر حساس الكامة الأصلي" },
          diagramCategory: "الكهرباء والحساسات" as any,
          isOemNumberUnverified: false,
          confidence: "verified",
        };
      }
      // Crankshaft Sensor
      if (code.includes("P0335") || pLibyan.includes("كرنك") || pEnglish.includes("crankshaft")) {
        return {
          id: partId,
          relatedCode: part.relatedCode || "P0335",
          partNameLibyan: "حساس الكرنك الأصلي (سنسور الكولوا)",
          partNameStandardArabic: "مستشعر موضع عمود الكرنك أوبل استرا",
          partNameEnglish: "Crankshaft Position Sensor (CKP)",
          oemPartNumber: "6238153 (GM 90536064 / 9118368)",
          aftermarketReplacements: [
            "Bosch 0261210160",
            "Hella 6PU 009 146-241",
            "VDO S103557002Z",
          ],
          estimatedPriceRangeLYD: { min: 110, max: 220, marketNote: "سعر حساس الكرنك الأصلي" },
          diagramCategory: "الكهرباء والحساسات" as any,
          isOemNumberUnverified: false,
          confidence: "verified",
        };
      }
      // Ignition Module / Cassette
      if (this.isIgnitionOrCoil(pLibyan, pEnglish, pStandard, code)) {
        return {
          id: partId,
          relatedCode: part.relatedCode || "P0300",
          partNameLibyan: "مسطرة بوبينات أوبل استرا (كاسيت الإشعال الرباعي)",
          partNameStandardArabic: "وحدة ملفات الإشعال المتكاملة (كاسيت الإشعال)",
          partNameEnglish: "Ignition Coil Pack Cassette Opel Astra G 1.6",
          oemPartNumber: "1208008 (GM 1104038 / 9115380)",
          aftermarketReplacements: [
            "Delphi GN10234-12B1",
            "Bosch 0221503472",
            "NGK 48005",
          ],
          estimatedPriceRangeLYD: { min: 250, max: 550, marketNote: "سعر مسطرة كاسيت الإشعال" },
          diagramCategory: "المحرك",
          isOemNumberUnverified: false,
          confidence: "verified",
        };
      }
    }

    // =========================================================================
    // 8. BMW 5-SERIES (E39 / 528i M52)
    // =========================================================================
    if (make.includes("BMW") && (model.includes("528") || model.includes("E39") || vin.startsWith("WBADD"))) {
      if (this.isIgnitionOrCoil(pLibyan, pEnglish, pStandard, code)) {
        return {
          id: partId,
          relatedCode: part.relatedCode || "02",
          partNameLibyan: "بوبينة إشعال أصلية BMW M52 (بريمي / بوش)",
          partNameStandardArabic: "ملف إشعال محرك بي إم دبليو M52 ستة سلندر",
          partNameEnglish: "Ignition Coil BMW E39 528i M52",
          oemPartNumber: "12131748018 (Bremi 11860 / Bosch 0221504006)",
          aftermarketReplacements: [
            "Bremi 11860 Germany",
            "Bosch 0221504006",
            "NGK 48012 (U5014)",
          ],
          estimatedPriceRangeLYD: { min: 85, max: 180, marketNote: "سعر البوبينة الواحدة بريمي ألماني" },
          diagramCategory: "المحرك",
          isOemNumberUnverified: false,
          confidence: "verified",
        };
      }
      if (this.isSparkPlug(pLibyan, pEnglish, pStandard, code)) {
        return {
          id: partId,
          relatedCode: part.relatedCode || "02",
          partNameLibyan: "شمعات احتراق 4 شمعات ليزر بلاتينيوم (NGK BKR6EQUP)",
          partNameStandardArabic: "شمعات إشعال أصلية BMW High Power 4-Electrode",
          partNameEnglish: "Spark Plug NGK Laser Platinum 4-Ground BKR6EQUP",
          oemPartNumber: "12129071003 (NGK BKR6EQUP Stock No. 3199)",
          aftermarketReplacements: [
            "NGK BKR6EQUP (Stock No. 3199)",
            "Bosch FGR7DQP (0242236562)",
          ],
          estimatedPriceRangeLYD: { min: 35, max: 70, marketNote: "سعر الشمعة الواحدة رباعية الأقطاب" },
          diagramCategory: "المحرك",
          isOemNumberUnverified: false,
          confidence: "verified",
        };
      }
      if (code.includes("D6") || pLibyan.includes("سرعة") || pEnglish.includes("speed")) {
        return {
          id: partId,
          relatedCode: part.relatedCode || "D6",
          partNameLibyan: "حساس سرعة العجلة الخلفية والـ ABS (حساس عداد السرعة)",
          partNameStandardArabic: "مستشعر سرعة العجلة الخلفية ومنظومة ABS / ASC",
          partNameEnglish: "Rear ABS / Wheel Speed Sensor (Blue Connector)",
          oemPartNumber: "34521182160 (خلفي - فيشة زرقاء لموديل ما قبل 1998)",
          aftermarketReplacements: [
            "Bosch 0265006223",
            "ATE 24.0711-5077.3",
            "Hella 6PU 009 106-251",
          ],
          estimatedPriceRangeLYD: { min: 140, max: 280, marketNote: "سعر حساس الـ ABS الخلفي" },
          diagramCategory: "الفرامل",
          isOemNumberUnverified: false,
          confidence: "verified",
        };
      }
    }

    return null;
  }

  /**
   * Enriches a full list of spare parts for a vehicle, ensuring that
   * authentic verified OEM parts are used and critical components are included.
   */
  static enrichPartsList(
    vehicle: VehicleMatchInfo | null | undefined,
    parts: SparePartItem[]
  ): SparePartItem[] {
    if (!vehicle || !Array.isArray(parts) || parts.length === 0) return parts;

    const resolvedList: SparePartItem[] = [];
    const seenNames = new Set<string>();

    for (const p of parts) {
      const match = this.resolve(vehicle, p);
      const finalPart = match ? { ...p, ...match } : p;

      // Ensure catalogSearchUrl is populated
      if (!finalPart.catalogSearchUrl) {
        finalPart.catalogSearchUrl = this.generateCatalogSearchUrl(vehicle, finalPart);
      }

      const key = (finalPart.partNameLibyan || "").trim().toLowerCase();
      if (!seenNames.has(key)) {
        seenNames.add(key);
        resolvedList.push(finalPart);
      }
    }

    // Special automotive rule: 1996-2000 Honda Civic (Distributor Ignition System)
    const make = (vehicle.make || "").toUpperCase().trim();
    const model = (vehicle.model || "").toUpperCase().trim();
    const yearStr = (vehicle.year != null ? String(vehicle.year) : "").replace(/[^0-9]/g, "");
    const year = parseInt(yearStr, 10) || 0;
    const vin = (vehicle.vin || "").toUpperCase().trim();

    if (
      make.includes("HONDA") &&
      (model.includes("CIVIC") || vin.startsWith("SHHMB")) &&
      ((year >= 1996 && year <= 2000) || vin.startsWith("SHHMB"))
    ) {
      const hasMisfire = parts.some(
        (p) =>
          p.relatedCode.includes("P030") ||
          p.relatedCode.includes("P1399") ||
          p.partNameLibyan.includes("بوبينة") ||
          p.partNameLibyan.includes("شمعة")
      );

      const hasWires = resolvedList.some(
        (p) =>
          p.partNameLibyan.includes("خيوط") ||
          p.partNameEnglish.toLowerCase().includes("wire")
      );

      if (hasMisfire && !hasWires) {
        resolvedList.push({
          id: `part_honda_wires_${resolvedList.length}`,
          relatedCode: "P0301-P0304",
          partNameLibyan: "طقم خيوط شمعات الاحتراق (خيوط بوجيهات ديلكو)",
          partNameStandardArabic: "أسلاك توصيل شمعات الإشعال عالية الجهد",
          partNameEnglish: "Ignition Spark Plug Wire Set",
          oemPartNumber: "32722-P2A-003",
          aftermarketReplacements: [
            "NGK RC-HE73 (Stock No. 8018)",
            "Seiwa Japan 50058",
            "Denso 671-4045",
          ],
          estimatedPriceRangeLYD: {
            min: 60,
            max: 130,
            marketNote: "سعر طقم خيوط البوجيهات في ليبيا",
          },
          diagramCategory: "المحرك",
          isOemNumberUnverified: false,
          confidence: "verified",
          catalogSearchUrl: this.generateCatalogSearchUrl(vehicle, {
            partNameEnglish: "Ignition Spark Plug Wire Set",
            oemPartNumber: "32722-P2A-003",
          }),
        });
      }
    }

    return resolvedList;
  }

  private static isSparkPlugWire(l: string, e: string, s: string): boolean {
    return (
      l.includes("خيط") ||
      l.includes("خيوط") ||
      l.includes("سلك") ||
      l.includes("أسلاك") ||
      l.includes("اسلاك") ||
      e.includes("wire") ||
      e.includes("lead") ||
      e.includes("cable") ||
      s.includes("سلك") ||
      s.includes("أسلاك")
    );
  }

  private static isIgnitionOrCoil(l: string, e: string, s: string, code: string): boolean {
    if (this.isSparkPlug(l, e, s, code) || this.isSparkPlugWire(l, e, s) || this.isAirbagBox(l, e, s, code)) {
      return false;
    }
    return (
      l.includes("بوبين") ||
      l.includes("كويل") ||
      l.includes("ديلكو") ||
      e.includes("coil") ||
      e.includes("ignition") ||
      e.includes("distributor") ||
      s.includes("إشعال") ||
      s.includes("ملف") ||
      code.includes("P030") ||
      code === "P1399" ||
      code.includes("P035") ||
      code === "02"
    );
  }

  private static isSparkPlug(l: string, e: string, s: string, code: string): boolean {
    if (this.isSparkPlugWire(l, e, s)) return false;
    return (
      l.includes("شمع") ||
      l.includes("بوجي") ||
      e.includes("spark") ||
      e.includes("plug") ||
      s.includes("شمعة") ||
      s.includes("شمعات")
    );
  }

  private static isAirbagBox(l: string, e: string, s: string, code: string): boolean {
    return (
      l.includes("إيرباق") ||
      l.includes("ايرباق") ||
      l.includes("وسائد") ||
      e.includes("airbag") ||
      e.includes("srs") ||
      s.includes("وسائد") ||
      code.includes("SRS") ||
      code.startsWith("B18") ||
      code.startsWith("B16")
    );
  }

  private static isClockSpring(l: string, e: string, s: string, code: string): boolean {
    return (
      l.includes("شريط") ||
      l.includes("حلزون") ||
      e.includes("clock") ||
      e.includes("spiral") ||
      s.includes("شريط") ||
      code.includes("B1811") ||
      code.includes("B1801")
    );
  }
}
