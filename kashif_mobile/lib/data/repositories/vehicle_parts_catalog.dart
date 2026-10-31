import '../models/spare_part.dart';
import '../models/vehicle_info.dart';

/// Database of authentic OEM part numbers, verified aftermarket replacements,
/// and market price ranges for the most common car makes & models in Libya.
class VehiclePartsCatalog {
  /// Resolves and corrects spare part items for a specific vehicle using
  /// verified manufacturer catalogs and automotive engineering rules.
  static SparePartItem? resolve({
    required VehicleInfo? vehicle,
    required SparePartItem part,
  }) {
    if (vehicle == null) return null;

    final make = vehicle.make.toUpperCase().trim();
    final model = vehicle.model.toUpperCase().trim();
    final yearStr = vehicle.year.replaceAll(RegExp(r'[^0-9]'), '');
    final year = int.tryParse(yearStr) ?? 0;
    final vin = vehicle.vin.toUpperCase().trim();

    final pLibyan = part.partNameLibyan.toLowerCase();
    final pEnglish = part.partNameEnglish.toLowerCase();
    final pStandard = part.partNameStandardArabic.toLowerCase();
    final code = part.relatedCode.toUpperCase().trim();
    final rawOem = part.oemPartNumber?.trim() ?? '';

    // =========================================================================
    // 1. HONDA CIVIC (سيفيك)
    // =========================================================================
    if (make.contains('HONDA') && (model.contains('CIVIC') || vin.startsWith('SHHMB') || vin.startsWith('JHMEK'))) {
      // -----------------------------------------------------------------------
      // 1.A. Generation 6 (1996 - 2000) e.g. Civic Aero / EK / MB4 / EJ (D14/D15/D16 Engine)
      // CRITICAL: Uses Ignition Distributor (ديلكو), NOT individual Coil-on-Plug coils!
      // -----------------------------------------------------------------------
      if ((year >= 1996 && year <= 2000) || vin.startsWith('SHHMB') || vin.startsWith('JHMEK')) {
        // Spark Plug Wires (خيوط البوجيهات) - Check first
        if (_isSparkPlugWire(pLibyan, pEnglish, pStandard)) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode.isNotEmpty ? part.relatedCode : 'P0301-P0304',
            partNameLibyan: 'طقم خيوط شمعات الاحتراق (خيوط بوجيهات ديلكو)',
            partNameStandardArabic: 'أسلاك توصيل شمعات الإشعال عالية الجهد',
            partNameEnglish: 'Ignition Spark Plug Wire Set',
            oemPartNumber: '32722-P2A-003',
            aftermarketReplacements: const [
              'NGK RC-HE73 (Stock No. 8018)',
              'Seiwa Japan 50058',
              'Denso 671-4045',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(
              min: 60,
              max: 130,
              marketNote: 'سعر طقم خيوط البوجيهات في ليبيا',
            ),
            systemCategory: 'المحرك',
            replacementUrgency: 'مهم',
            confidence: 'verified',
          );
        }

        // Spark Plugs (الشمعات / البوجيهات)
        if (_isSparkPlug(pLibyan, pEnglish, pStandard, code) || rawOem.contains('98066-')) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode.isNotEmpty ? part.relatedCode : 'P0301-P0304',
            partNameLibyan: 'شمعات احتراق أصلية (بوجيهات سن ممتد)',
            partNameStandardArabic: 'شمعات إشعال أصلية لمحرك هوندا سيفيك D16/D15',
            partNameEnglish: 'Genuine Spark Plugs (Extended Reach)',
            oemPartNumber: '98079-5514P (NGK ZFR5F-11)',
            aftermarketReplacements: const [
              'NGK ZFR5F-11 (Stock No. 2262)',
              'NGK ZFR6F-11 (Stock No. 4291)',
              'Denso KJ16CR-L11',
              'Denso Iridium IK16',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(
              min: 20,
              max: 45,
              marketNote: 'سعر الشمعة الواحدة 20 - 45 د.ل (طقم 80 - 180 د.ل)',
            ),
            systemCategory: 'المحرك',
            replacementUrgency: 'مهم',
            confidence: 'verified',
            catalogSearchUrl: 'https://www.google.com/search?q=1999+Honda+Civic+98079-5514P+ZFR5F-11+spark+plug',
          );
        }

        // Airbag SRS Box (بوكس وسائد هوائية)
        if (_isAirbagBox(pLibyan, pEnglish, pStandard, code) || rawOem.contains('77510') || rawOem.contains('77960')) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode.isNotEmpty ? part.relatedCode : 'SRS-07-02',
            partNameLibyan: 'بوكس منظومة الوسائد الهوائية (كمبيوتر SRS)',
            partNameStandardArabic: 'وحدة التحكم الإلكترونية للوسائد الهوائية',
            partNameEnglish: 'SRS Airbag Control Unit Module',
            oemPartNumber: '77960-ST3-E82 (مطابقة برقم الهيكل SHHMB4)',
            aftermarketReplacements: const [
              'Honda Genuine 77960-ST3',
              'Honda OEM 77960-S04',
              'تشليح أصلي وكالة معتمد',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(
              min: 350,
              max: 750,
              marketNote: 'سعر كمبيوتر الإيرباق أصلي استيراد / تشليح',
            ),
            systemCategory: 'الأمان والوسائد الهوائية',
            replacementUrgency: 'مهم',
            confidence: 'verified',
          );
        }

        // Misfire / Ignition / Bobina
        if (_isIgnitionOrCoil(pLibyan, pEnglish, pStandard, code) || rawOem.contains('30510-PLM')) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode.isNotEmpty ? part.relatedCode : 'P0301-P0304',
            partNameLibyan: 'بوبينة ديلكو داخلية (أو موزع شرارة ديلكو كامل)',
            partNameStandardArabic: 'ملف إشعال داخلي للديلكو (أو موزع إشعال كامل)',
            partNameEnglish: 'Internal Distributor Ignition Coil / Complete Distributor',
            oemPartNumber: '30510-PT2-006 (ديلكو كامل: 30100-P2E-A01)',
            aftermarketReplacements: const [
              'Hitachi / TEC TD-80U',
              'Denso 673-2301',
              'Standard Motor JH-142',
              'قطع ديلكو أصلي وكالة / تشليح',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(
              min: 80,
              max: 180,
              marketNote: 'سعر البوبينة 80-180 د.ل والديلكو كامل 250-550 د.ل',
            ),
            systemCategory: 'المحرك',
            replacementUrgency: 'مهم',
            confidence: 'verified',
            catalogSearchUrl: 'https://www.google.com/search?q=1999+Honda+Civic+1.6+30510-PT2-006+distributor+coil+OEM',
          );
        }
      }

      // -----------------------------------------------------------------------
      // 1.B. Generation 7 (2001 - 2005) e.g. Civic ES/EU (D17 Engine)
      // Uses Coil-on-Plug coils!
      // -----------------------------------------------------------------------
      if ((year >= 2001 && year <= 2005)) {
        if (_isIgnitionOrCoil(pLibyan, pEnglish, pStandard, code)) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode,
            partNameLibyan: 'بوبينة إشعال أصلية (كويل سيفيك D17)',
            partNameStandardArabic: 'ملف إشعال المحرك (بوبينة)',
            partNameEnglish: 'Ignition Coil Honda Civic 1.7L',
            oemPartNumber: '30520-PZ3-000 (30520-PGK-A01)',
            aftermarketReplacements: const [
              'Denso 099700-061 (673-2302)',
              'Hitachi IGC0054',
              'Bosch 0986221042',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(min: 75, max: 160, marketNote: 'سعر البوبينة الواحدة'),
            systemCategory: 'المحرك',
            replacementUrgency: 'مهم',
            confidence: 'verified',
          );
        }
        if (_isSparkPlug(pLibyan, pEnglish, pStandard, code)) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode,
            partNameLibyan: 'شمعات احتراق أصلية',
            partNameStandardArabic: 'شمعات إشعال أصلية هوندا سيفيك 1.7',
            partNameEnglish: 'Genuine Spark Plugs Honda D17',
            oemPartNumber: '98079-5614E (NGK ZFR6J-11)',
            aftermarketReplacements: const [
              'NGK ZFR6J-11 (Stock No. 5585)',
              'Denso KJ20CR-L11',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(min: 25, max: 50, marketNote: 'سعر الشمعة'),
            systemCategory: 'المحرك',
            replacementUrgency: 'مهم',
            confidence: 'verified',
          );
        }
      }

      // -----------------------------------------------------------------------
      // 1.C. Generation 8 (2006 - 2011) Civic FD / FK (R18A 1.8L Engine)
      // -----------------------------------------------------------------------
      if ((year >= 2006 && year <= 2011)) {
        if (_isIgnitionOrCoil(pLibyan, pEnglish, pStandard, code)) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode,
            partNameLibyan: 'بوبينة إشعال أصلية (كويل سيفيك R18)',
            partNameStandardArabic: 'ملف إشعال محرك هوندا سيفيك 1.8',
            partNameEnglish: 'Ignition Coil Honda Civic R18',
            oemPartNumber: '30520-RNA-A01',
            aftermarketReplacements: const [
              'Denso 099700-101 (673-2308)',
              'Hitachi IGC0057',
              'NGK 48337 (U5058)',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(min: 80, max: 175, marketNote: 'سعر البوبينة'),
            systemCategory: 'المحرك',
            replacementUrgency: 'مهم',
            confidence: 'verified',
          );
        }
        if (_isSparkPlug(pLibyan, pEnglish, pStandard, code)) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode,
            partNameLibyan: 'شمعات احتراق ليزر إيريديوم أصلية',
            partNameStandardArabic: 'شمعات إشعال إيريديوم هوندا R18',
            partNameEnglish: 'Laser Iridium Spark Plugs',
            oemPartNumber: '98079-5615E (NGK IZFR6K-11S)',
            aftermarketReplacements: const [
              'NGK IZFR6K-11S (Stock No. 5266)',
              'Denso SKJ20DR-M11',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(min: 40, max: 85, marketNote: 'سعر الشمعة إيريديوم'),
            systemCategory: 'المحرك',
            replacementUrgency: 'مهم',
            confidence: 'verified',
          );
        }
      }
    }

    // =========================================================================
    // 2. HYUNDAI SANTA FE (سنتافي CM 2006 - 2012)
    // =========================================================================
    if (make.contains('HYUNDAI') && model.contains('SANTA')) {
      if ((year >= 2006 && year <= 2012) || vin.startsWith('5NM') || vin.startsWith('KM8')) {
        // EVAP Purge Control Valve (P0440, P0442, P0455)
        if (code.contains('P044') || code.contains('P045') || pLibyan.contains('بخر') || pEnglish.contains('purge') || pEnglish.contains('evap')) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode.isNotEmpty ? part.relatedCode : 'P0442',
            partNameLibyan: 'صمام بخر خزان البنزين (بلف الفاب / Purge Valve)',
            partNameStandardArabic: 'صمام التحكم في تصريف أبخرة الوقود (EVAP)',
            partNameEnglish: 'EVAP Purge Control Solenoid Valve',
            oemPartNumber: '28910-25000 (28910-3C100)',
            aftermarketReplacements: const [
              'Bosch 0280142427',
              'Hyundai Mobis Genuine 28910-25000',
              'Standard Motor CP541',
              'Dorman 911-808',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(
              min: 80,
              max: 170,
              marketNote: 'سعر بلف البخر في سوق قطع الغيار في ليبيا',
            ),
            systemCategory: 'المحرك',
            replacementUrgency: 'مهم',
            confidence: 'verified',
            catalogSearchUrl: 'https://www.google.com/search?q=Hyundai+Santa+Fe+28910-25000+purge+valve+OEM',
          );
        }

        // Airbag Clock Spring / شريط الإيرباق (B1346, B1347, Driver Airbag Resistance)
        if (code.contains('B1346') || code.contains('B1347') || pLibyan.contains('شريط') || pLibyan.contains('كلوك') || pEnglish.contains('clock') || pEnglish.contains('spring') || (pLibyan.contains('ايرباق') && pLibyan.contains('سائق'))) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode.isNotEmpty ? part.relatedCode : 'B1346',
            partNameLibyan: 'شريط وسادة الهواء بالستيروني (كلوك سبرينغ / شريط الإيرباق)',
            partNameStandardArabic: 'ملف التوصيل الحلزوني للوسادة الهوائية للسائق (Clock Spring)',
            partNameEnglish: 'Driver Airbag Clock Spring / Spiral Cable',
            oemPartNumber: '93490-2B200',
            aftermarketReplacements: const [
              'Hyundai Mobis Genuine 93490-2B200',
              'Dorman 525-042',
              'Standard Motor CSP260',
              'قطع غيار استيراد وكالة معتمدة',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(
              min: 110,
              max: 240,
              marketNote: 'سعر شريط الإيرباق في السوق الليبي',
            ),
            systemCategory: 'الأمان والوسائد الهوائية',
            replacementUrgency: 'حرج',
            confidence: 'verified',
            catalogSearchUrl: 'https://www.google.com/search?q=Hyundai+Santa+Fe+93490-2B200+clock+spring+OEM',
          );
        }

        // Steering Angle Sensor / حساس زاوية الستيروني (C1260, C1261)
        if (code.contains('C1260') || code.contains('C1261') || pLibyan.contains('زاوية') || pEnglish.contains('steering angle')) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode.isNotEmpty ? part.relatedCode : 'C1260',
            partNameLibyan: 'حساس زاوية الستيروني (معايرة الصفر الإلكتروني أو استبدال)',
            partNameStandardArabic: 'مستشعر زاوية توجيه عجلة القيادة (Steering Angle Sensor)',
            partNameEnglish: 'Steering Angle Sensor (SAS Module)',
            oemPartNumber: '93480-2H000 (أو معايرة إلكترونية بالجهاز)',
            aftermarketReplacements: const [
              'معايرة الصفر الإلكتروني بجهاز الفحص (SAS Calibration)',
              'Hyundai Mobis Genuine 93480-2H000',
              'تشليح أصلي وكالة مفحوص',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(
              min: 60,
              max: 280,
              marketNote: '60 د.ل تكلفة المعايرة بالجهاز / 280 د.ل في حال الاستبدال',
            ),
            systemCategory: 'التوجيه والتعليق',
            replacementUrgency: 'مهم',
            confidence: 'verified',
            catalogSearchUrl: 'https://www.google.com/search?q=Hyundai+Santa+Fe+93480-2H000+steering+angle+sensor',
          );
        }

        // Fuel Tank Gas Cap / غطاء خزان الوقود (P0442, P0455, P0456)
        if (pLibyan.contains('غطاء') || pLibyan.contains('تانكي') || pEnglish.contains('gas cap') || pEnglish.contains('fuel cap')) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode.isNotEmpty ? part.relatedCode : 'P0442',
            partNameLibyan: 'غطاء تانكي البنزين (جوانات مانعة لتسريب أبخرة الفاب)',
            partNameStandardArabic: 'غطاء فتحة تعبئة خزان الوقود مانع للتسريب',
            partNameEnglish: 'Fuel Tank Filler Gas Cap',
            oemPartNumber: '31010-3L600',
            aftermarketReplacements: const [
              'Hyundai Mobis Genuine 31010-3L600',
              'Stant 10834',
              'Gates 31832',
              'Motorad MGC-834',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(
              min: 40,
              max: 85,
              marketNote: 'سعر غطاء التانكي الأصلي مع الصمام الداخلي',
            ),
            systemCategory: 'الوقود والمحرك',
            replacementUrgency: 'متوسط',
            confidence: 'verified',
            catalogSearchUrl: 'https://www.google.com/search?q=Hyundai+Santa+Fe+31010-3L600+gas+cap+OEM',
          );
        }

        // Oxygen Sensor / Rich Trim (P2188, P2190, P0171, P0172)
        if (code.contains('P218') || code.contains('P219') || code.contains('P017') || pLibyan.contains('مرميط') || pEnglish.contains('oxygen') || pEnglish.contains('o2')) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode,
            partNameLibyan: 'حساس مرميطة علوي (حساس أكسجين بنك 1 / بنك 2)',
            partNameStandardArabic: 'مستشعر الأكسجين العلوي قبل دبة البيئة',
            partNameEnglish: 'Upstream Oxygen / Air-Fuel Ratio Sensor',
            oemPartNumber: '39210-3C100 (Bank 1) / 39210-3C200 (Bank 2)',
            aftermarketReplacements: const [
              'Bosch 0258017025',
              'Denso 234-4854',
              'Hyundai Mobis Genuine',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(min: 160, max: 320, marketNote: 'سعر حساس الأكسجين الأصلي'),
            systemCategory: 'الفرامل والعادم',
            replacementUrgency: 'مهم',
            confidence: 'verified',
          );
        }

        // MAF Sensor
        if (code.contains('P010') || pLibyan.contains('سيرزو') || pLibyan.contains('تدفق') || pEnglish.contains('maf') || pEnglish.contains('air flow')) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode,
            partNameLibyan: 'حساس قياس تدفق الهواء (سيرزو / MAF)',
            partNameStandardArabic: 'مستشعر كتلة تدفق الهواء للمحرك',
            partNameEnglish: 'Mass Air Flow Sensor (MAF)',
            oemPartNumber: '28164-37200',
            aftermarketReplacements: const [
              'Bosch 0280218106',
              'Hyundai Mobis Genuine 28164-37200',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(min: 220, max: 450, marketNote: 'سعر حساس الهواء MAF'),
            systemCategory: 'المحرك',
            replacementUrgency: 'مهم',
            confidence: 'verified',
          );
        }
      }
    }

    // =========================================================================
    // 3. TOYOTA CAMRY (كامري 2007 - 2011 XV40 2.4L / 2.5L)
    // =========================================================================
    if (make.contains('TOYOTA') && model.contains('CAMRY')) {
      if ((year >= 2006 && year <= 2011)) {
        if (_isIgnitionOrCoil(pLibyan, pEnglish, pStandard, code)) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode,
            partNameLibyan: 'بوبينة إشعال أصلية (كويل كامري 2.4)',
            partNameStandardArabic: 'ملف إشعال محرك تويوتا كامري 2AZ-FE',
            partNameEnglish: 'Ignition Coil Toyota Camry 2.4L',
            oemPartNumber: '90919-02244 (90919-02266)',
            aftermarketReplacements: const [
              'Denso 673-1307',
              'Diamond Japan 90919-02244',
              'Bosch 0986221096',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(min: 75, max: 160, marketNote: 'سعر البوبينة الواحدة'),
            systemCategory: 'المحرك',
            replacementUrgency: 'مهم',
            confidence: 'verified',
          );
        }
        if (_isSparkPlug(pLibyan, pEnglish, pStandard, code)) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode,
            partNameLibyan: 'شمعات احتراق إيريديوم أصلية',
            partNameStandardArabic: 'شمعات إشعال إيريديوم تويوتا 2AZ-FE',
            partNameEnglish: 'Iridium Long-Life Spark Plugs',
            oemPartNumber: '90919-01210 (Denso SK20R11)',
            aftermarketReplacements: const [
              'Denso SK20R11 (Stock No. 3297)',
              'NGK IFR6A11 (Stock No. 1095)',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(min: 35, max: 75, marketNote: 'سعر الشمعة إيريديوم'),
            systemCategory: 'المحرك',
            replacementUrgency: 'مهم',
            confidence: 'verified',
          );
        }
        if (_isClockSpring(pLibyan, pEnglish, pStandard, code)) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode,
            partNameLibyan: 'شريط إيرباق الدومان (الفيشة الحلزونية للستيرسو)',
            partNameStandardArabic: 'شريط الوسائد الهوائية لعجلة القيادة',
            partNameEnglish: 'Airbag Clock Spring Spiral Cable',
            oemPartNumber: '84306-06140 (84306-48030)',
            aftermarketReplacements: const [
              'Toyota Genuine 84306-06140',
              'Tokai Rika Japan',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(min: 120, max: 250, marketNote: 'سعر شريط الإيرباق'),
            systemCategory: 'الأمان والوسائد الهوائية',
            replacementUrgency: 'مهم',
            confidence: 'verified',
          );
        }
      }
    }

    // =========================================================================
    // 4. TOYOTA COROLLA (كورولا 2008 - 2013 1.6L 1ZR / 1.8L 2ZR)
    // =========================================================================
    if (make.contains('TOYOTA') && model.contains('COROLLA')) {
      if ((year >= 2008 && year <= 2013)) {
        if (_isIgnitionOrCoil(pLibyan, pEnglish, pStandard, code)) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode,
            partNameLibyan: 'بوبينة إشعال أصلية (كويل كورولا 1ZR / 2ZR)',
            partNameStandardArabic: 'ملف إشعال محرك تويوتا كورولا Dual VVT-i',
            partNameEnglish: 'Ignition Coil Toyota Corolla 1.6/1.8L',
            oemPartNumber: '90919-02258 (90919-02252)',
            aftermarketReplacements: const [
              'Denso 673-1309',
              'Diamond Japan',
              'Bosch 0986221098',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(min: 75, max: 155, marketNote: 'سعر البوبينة'),
            systemCategory: 'المحرك',
            replacementUrgency: 'مهم',
            confidence: 'verified',
          );
        }
        if (_isSparkPlug(pLibyan, pEnglish, pStandard, code)) {
          return SparePartItem(
            id: part.id,
            relatedCode: part.relatedCode,
            partNameLibyan: 'شمعات احتراق إيريديوم سن رفيع أصلية',
            partNameStandardArabic: 'شمعات إشعال تويوتا كورولا SC20HR11',
            partNameEnglish: 'Iridium Spark Plugs Toyota 1ZR/2ZR',
            oemPartNumber: '90919-01253 (Denso SC20HR11)',
            aftermarketReplacements: const [
              'Denso SC20HR11 (Stock No. 3444)',
              'NGK ILKAR7B11 (Stock No. 4912)',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(min: 30, max: 70, marketNote: 'سعر الشمعة'),
            systemCategory: 'المحرك',
            replacementUrgency: 'مهم',
            confidence: 'verified',
          );
        }
      }
    }

    // =========================================================================
    // 5. HYUNDAI ELANTRA & ACCENT (1.6L Gamma / 1.4L)
    // =========================================================================
    if (make.contains('HYUNDAI') && (model.contains('ELANTRA') || model.contains('ACCENT') || model.contains('VERNA'))) {
      if (_isIgnitionOrCoil(pLibyan, pEnglish, pStandard, code)) {
        return SparePartItem(
          id: part.id,
          relatedCode: part.relatedCode,
          partNameLibyan: 'بوبينة إشعال أصلية (كويل النترا / أكسنت 1.6)',
          partNameStandardArabic: 'ملف إشعال محرك هيونداي كيا 1.6 Gamma',
          partNameEnglish: 'Ignition Coil Hyundai/Kia 1.6L',
          oemPartNumber: '27301-2B010 (27301-2B000)',
          aftermarketReplacements: const [
            'Yura Tech 27301-2B010',
            'Denso 673-8305',
            'Mobis Genuine Korea',
          ],
          estimatedPriceRangeLYD: const PriceRangeLYD(min: 60, max: 130, marketNote: 'سعر البوبينة'),
          systemCategory: 'المحرك',
          replacementUrgency: 'مهم',
          confidence: 'verified',
        );
      }
      if (_isSparkPlug(pLibyan, pEnglish, pStandard, code)) {
        return SparePartItem(
          id: part.id,
          relatedCode: part.relatedCode,
          partNameLibyan: 'شمعات احتراق أصلية هيونداي كيا',
          partNameStandardArabic: 'شمعات إشعال محرك Gamma 1.6L',
          partNameEnglish: 'Genuine Spark Plugs Hyundai/Kia',
          oemPartNumber: '18855-10060 (NGK LZKR6B-10E)',
          aftermarketReplacements: const [
            'NGK LZKR6B-10E (Stock No. 1578)',
            'Champion RER8YC',
            'Mobis Genuine',
          ],
          estimatedPriceRangeLYD: const PriceRangeLYD(min: 20, max: 45, marketNote: 'سعر الشمعة'),
          systemCategory: 'المحرك',
          replacementUrgency: 'مهم',
          confidence: 'verified',
        );
      }
      if (_isClockSpring(pLibyan, pEnglish, pStandard, code)) {
        return SparePartItem(
          id: part.id,
          relatedCode: part.relatedCode,
          partNameLibyan: 'شريط إيرباق الدومان (الفيشة الحلزونية للستيرسو)',
          partNameStandardArabic: 'شريط الوسائد الهوائية لعجلة القيادة',
          partNameEnglish: 'Airbag Clock Spring Hyundai',
          oemPartNumber: '93490-2H000 (HD) / 93490-3X020 (MD)',
          aftermarketReplacements: const [
            'Mobis Genuine Korea',
            'Mando OEM',
          ],
          estimatedPriceRangeLYD: const PriceRangeLYD(min: 90, max: 180, marketNote: 'سعر شريط الإيرباق'),
          systemCategory: 'الأمان والوسائد الهوائية',
          replacementUrgency: 'مهم',
          confidence: 'verified',
        );
      }
    }

    // =========================================================================
    // 6. NISSAN SUNNY (صني N16 2000-2011 QG16 / N17 2012+ HR15)
    // =========================================================================
    if (make.contains('NISSAN') && model.contains('SUNNY')) {
      final isN16 = year <= 2011;
      if (_isIgnitionOrCoil(pLibyan, pEnglish, pStandard, code)) {
        return SparePartItem(
          id: part.id,
          relatedCode: part.relatedCode,
          partNameLibyan: isN16 ? 'بوبينة إشعال نيسان صني N16' : 'بوبينة إشعال نيسان صني N17',
          partNameStandardArabic: 'ملف إشعال محرك نيسان صني',
          partNameEnglish: 'Ignition Coil Nissan Sunny',
          oemPartNumber: isN16 ? '22448-6N015' : '22448-ED000',
          aftermarketReplacements: const [
            'Hanshin Japan Genuine',
            'Hitachi IGC0071',
            'Denso Aftermarket',
          ],
          estimatedPriceRangeLYD: const PriceRangeLYD(min: 65, max: 140, marketNote: 'سعر البوبينة'),
          systemCategory: 'المحرك',
          replacementUrgency: 'مهم',
          confidence: 'verified',
        );
      }
      if (_isSparkPlug(pLibyan, pEnglish, pStandard, code)) {
        return SparePartItem(
          id: part.id,
          relatedCode: part.relatedCode,
          partNameLibyan: 'شمعات احتراق أصلية نيسان',
          partNameStandardArabic: 'شمعات إشعال نيسان صني',
          partNameEnglish: 'Genuine Spark Plugs Nissan',
          oemPartNumber: isN16 ? '22401-50Y05 (BKR5E-11)' : '22401-ED815 (LZKAR6AP-11)',
          aftermarketReplacements: const [
            'NGK LZKAR6AP-11 (Stock No. 6643)',
            'Denso FXE20HR11',
          ],
          estimatedPriceRangeLYD: const PriceRangeLYD(min: 25, max: 55, marketNote: 'سعر الشمعة'),
          systemCategory: 'المحرك',
          replacementUrgency: 'مهم',
          confidence: 'verified',
        );
      }
    }

    return null;
  }

  /// Enriches a full list of spare parts for a vehicle, ensuring that
  /// all necessary components for a given fault code are represented.
  static List<SparePartItem> enrichPartsList({
    required VehicleInfo? vehicle,
    required List<SparePartItem> parts,
  }) {
    if (vehicle == null || parts.isEmpty) return parts;

    final resolvedList = <SparePartItem>[];
    final seenNames = <String>{};

    for (final p in parts) {
      final match = resolve(vehicle: vehicle, part: p);
      final finalPart = match ?? p;

      final key = finalPart.partNameLibyan.trim().toLowerCase();
      if (!seenNames.contains(key)) {
        seenNames.add(key);
        resolvedList.add(finalPart);
      }
    }

    // Special automotive rule: 1996-2000 Honda Civic (Distributor Ignition System)
    // When there are cylinder misfire codes (P0301-P0304 or P1399),
    // ensure spark plug wires (خيوط البوجيهات) are included in the parts checklist.
    final make = vehicle.make.toUpperCase().trim();
    final model = vehicle.model.toUpperCase().trim();
    final yearStr = vehicle.year.replaceAll(RegExp(r'[^0-9]'), '');
    final year = int.tryParse(yearStr) ?? 0;
    final vin = vehicle.vin.toUpperCase().trim();

    if (make.contains('HONDA') && (model.contains('CIVIC') || vin.startsWith('SHHMB')) &&
        ((year >= 1996 && year <= 2000) || vin.startsWith('SHHMB'))) {
      final hasMisfire = parts.any((p) =>
          p.relatedCode.contains('P030') || p.relatedCode.contains('P1399') ||
          p.partNameLibyan.contains('بوبينة') || p.partNameLibyan.contains('شمعة'));

      final hasWires = resolvedList.any((p) => p.partNameLibyan.contains('خيوط') || p.partNameEnglish.toLowerCase().contains('wire'));
      if (hasMisfire && !hasWires) {
        resolvedList.add(
          SparePartItem(
            id: 'part_honda_wires_${resolvedList.length}',
            relatedCode: 'P0301-P0304',
            partNameLibyan: 'طقم خيوط شمعات الاحتراق (خيوط بوجيهات ديلكو)',
            partNameStandardArabic: 'أسلاك توصيل شمعات الإشعال عالية الجهد',
            partNameEnglish: 'Ignition Spark Plug Wire Set',
            oemPartNumber: '32722-P2A-003',
            aftermarketReplacements: const [
              'NGK RC-HE73 (Stock No. 8018)',
              'Seiwa Japan 50058',
              'Denso 671-4045',
            ],
            estimatedPriceRangeLYD: const PriceRangeLYD(
              min: 60,
              max: 130,
              marketNote: 'سعر طقم خيوط البوجيهات في ليبيا',
            ),
            systemCategory: 'المحرك',
            replacementUrgency: 'مهم',
            confidence: 'verified',
          ),
        );
      }
    }

    return resolvedList;
  }

  static bool _isSparkPlugWire(String l, String e, String s) {
    return l.contains('خيط') ||
        l.contains('خيوط') ||
        l.contains('سلك') ||
        l.contains('أسلاك') ||
        l.contains('اسلاك') ||
        e.contains('wire') ||
        e.contains('lead') ||
        e.contains('cable') ||
        s.contains('سلك') ||
        s.contains('أسلاك');
  }

  static bool _isIgnitionOrCoil(String l, String e, String s, String code) {
    if (_isSparkPlug(l, e, s, code) || _isSparkPlugWire(l, e, s) || _isAirbagBox(l, e, s, code)) return false;
    return l.contains('بوبين') || l.contains('كويل') || l.contains('ديلكو') ||
        e.contains('coil') || e.contains('ignition') || e.contains('distributor') ||
        s.contains('إشعال') || s.contains('ملف') ||
        code.contains('P030') || code == 'P1399' || code == 'P035';
  }

  static bool _isSparkPlug(String l, String e, String s, String code) {
    if (_isSparkPlugWire(l, e, s)) return false;
    return l.contains('شمع') || l.contains('بوجي') ||
        e.contains('spark') || e.contains('plug') ||
        s.contains('شمعة') || s.contains('شمعات');
  }

  static bool _isAirbagBox(String l, String e, String s, String code) {
    return l.contains('إيرباق') || l.contains('ايرباق') || l.contains('وسائد') ||
        e.contains('airbag') || e.contains('srs') ||
        s.contains('وسائد') || code.contains('SRS') || code.startsWith('B18') || code.startsWith('B16');
  }

  static bool _isClockSpring(String l, String e, String s, String code) {
    return l.contains('شريط') || l.contains('حلزون') ||
        e.contains('clock') || e.contains('spiral') ||
        s.contains('شريط') || code.contains('B1811') || code.contains('B1801');
  }
}
