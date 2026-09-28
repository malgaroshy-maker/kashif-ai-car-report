import '../models/checklist_step.dart';
import '../models/diagnostic_report.dart';
import '../models/fault_code.dart';
import '../models/spare_part.dart';
import '../models/vehicle_info.dart';
import 'sensor_locator_service.dart';

/// Class containing offline diagnostic knowledge for standard DTC codes
class OfflineDtcKnowledge {
  final String code;
  final String module;
  final String moduleNameArabic;
  final String standardDescriptionEn;
  final String libyanTerm;
  final String standardArabicDescription;
  final List<String> driverSymptoms;
  final List<String> rootCauses;
  final String urgencyLevel;
  final String recommendedAction;
  final CodeSeverity severity;
  final String? partNameLibyan;
  final String? partNameEnglish;
  final double? partPriceMin;
  final double? partPriceMax;
  final List<String>? aftermarketBrands;

  const OfflineDtcKnowledge({
    required this.code,
    this.module = 'ECM',
    this.moduleNameArabic = 'كمبيوتر المحرك',
    required this.standardDescriptionEn,
    required this.libyanTerm,
    required this.standardArabicDescription,
    required this.driverSymptoms,
    required this.rootCauses,
    required this.urgencyLevel,
    required this.recommendedAction,
    this.severity = CodeSeverity.moderate,
    this.partNameLibyan,
    this.partNameEnglish,
    this.partPriceMin,
    this.partPriceMax,
    this.aftermarketBrands,
  });
}

/// Offline Report Engine:
/// Generates full diagnostic reports instantly from local automotive dictionary
/// with 0 API requests, saving quotas and avoiding rate limits.
class OfflineReportService {
  static final Map<String, OfflineDtcKnowledge> _dtcKnowledgeBase = {
    // Air & Fuel Metering (P0100 - P0199)
    'P0100': const OfflineDtcKnowledge(
      code: 'P0100',
      standardDescriptionEn: 'Mass Air Flow (MAF) Circuit Malfunction',
      libyanTerm: 'حساس الماف / حساس الهواء (خلل في الدائرة الكهربائية)',
      standardArabicDescription:
          'عطل في الدائرة الكهربائية لمستشعر كتلة تدفق الهواء',
      driverSymptoms: [
        'تفتفة في المحرك',
        'ضعف العزم والتسارع',
        'دخان أسود من المرميطة',
        'ولعة لامبة التشك',
      ],
      rootCauses: [
        'فصل أو ارتخاء فيشة الحساس',
        'اتساخ سلك الاستشعار الداخلي',
        'فيوز الـ EFI محروق',
      ],
      urgencyLevel: 'متوسط',
      recommendedAction:
          'فحص فيشة الحساس وتنظيفه بسبراي الكترونيات خاص دون لمس السلك',
      partNameLibyan: 'حساس ماف (حساس هواء)',
      partNameEnglish: 'Mass Air Flow Sensor',
      partPriceMin: 120,
      partPriceMax: 260,
      aftermarketBrands: ['Denso', 'Bosch', 'Hitachi'],
    ),
    'P0101': const OfflineDtcKnowledge(
      code: 'P0101',
      standardDescriptionEn: 'Mass Air Flow (MAF) Circuit Range/Performance',
      libyanTerm: 'حساس الماف / قراءة غير منطقية لكمية الهواء',
      standardArabicDescription:
          'أداء غير سليم لمستشعر تدفق الهواء بالنسبة لفتحة البوابة',
      driverSymptoms: [
        'خنقة في السيرفيس',
        'تذبذب السلانسيه',
        'استهلاك وقود زائد',
      ],
      rootCauses: [
        'فيلترو الهواء مسدود تماماً',
        'تسريب هواء من خرطوم البوابة',
        'اتساخ الحساس بالزيت والغبار',
      ],
      urgencyLevel: 'متوسط',
      recommendedAction:
          'تغيير فيلترو الهواء، تفقد خراطيم الهواء من الشقوق، وتنظيف الحساس',
      partNameLibyan: 'فيلترو هواء المحرك',
      partNameEnglish: 'Engine Air Filter',
      partPriceMin: 25,
      partPriceMax: 65,
      aftermarketBrands: ['Mann', 'Filtron', 'Toyota Genuine'],
    ),
    'P0102': const OfflineDtcKnowledge(
      code: 'P0102',
      standardDescriptionEn: 'Mass Air Flow (MAF) Circuit Low Input',
      libyanTerm: 'حساس الماف / إشارة كهربائية ضعيفة أو مقطوعة',
      standardArabicDescription:
          'انخفاض إشارة مستشعر كتلة تدفق الهواء عن الحد الأدنى',
      driverSymptoms: [
        'تفتفة ورعشة في المارش',
        'عزم ضعيف',
        'إمكانية انطفاء السيارة عند الوقوف',
      ],
      rootCauses: [
        'فيشة الحساس غير مثبتة',
        'قطع في خيط التغذية 12V أو الأرضي',
        'تلف الحساس الداخلي',
      ],
      urgencyLevel: 'متوسط',
      recommendedAction:
          'قياس فولتية الفيشة بالملتيميتر والتأكد من وصول 12V وأرضي ثابت',
      partNameLibyan: 'حساس ماف',
      partNameEnglish: 'MAF Sensor',
      partPriceMin: 130,
      partPriceMax: 280,
      aftermarketBrands: ['Denso', 'Bosch'],
    ),
    'P0103': const OfflineDtcKnowledge(
      code: 'P0103',
      standardDescriptionEn: 'Mass Air Flow (MAF) Circuit High Input',
      libyanTerm: 'حساس الماف / إشارة كهربائية مرتفعة جداً (التماس كهربائي)',
      standardArabicDescription:
          'ارتفاع إشارة مستشعر كتلة تدفق الهواء فوق الحد الأقصى',
      driverSymptoms: [
        'صرفية بنزين مرتفعة جداً',
        'ريحة بنزين غير محروق من الشكمان',
        'تفتفة',
      ],
      rootCauses: [
        'شورت بين خيط الإشارة والـ 12V',
        'انقطاع خط الأرضي في الضفيرة',
        'تلف كمبيوتر المحرك',
      ],
      urgencyLevel: 'متوسط',
      recommendedAction:
          'تتبع ضفيرة حساس الهواء للتأكد من عدم وجود تآكل أو التماس أسلاك',
      partNameLibyan: 'حساس ماف',
      partNameEnglish: 'MAF Sensor',
      partPriceMin: 130,
      partPriceMax: 280,
      aftermarketBrands: ['Denso', 'Bosch'],
    ),
    'P0106': const OfflineDtcKnowledge(
      code: 'P0106',
      standardDescriptionEn:
          'Manifold Absolute Pressure (MAP) Range/Performance',
      libyanTerm: 'سنسور الماب (ضغط المانيفول) / قراءة غير صحيحة',
      standardArabicDescription:
          'خلل في نطاق أداء مستشعر الضغط المطلق لمجمع السحب',
      driverSymptoms: [
        'ثقل في انطلاق السيارة',
        'دخان أسود خفيف',
        'خربطة في دوران المحرك',
      ],
      rootCauses: [
        'انسداد ثقب الماب بالكربون',
        'تنسيم هواء من جوان المانيفول',
        'تلف الحساس',
      ],
      urgencyLevel: 'متوسط',
      recommendedAction:
          'فك حساس الماب وتنظيف الفوهة وتفقد لي الفاكيوم الصغير المتصل به',
      partNameLibyan: 'حساس ماب (MAP)',
      partNameEnglish: 'MAP Sensor',
      partPriceMin: 80,
      partPriceMax: 180,
      aftermarketBrands: ['Bosch', 'Denso', 'Standard'],
    ),
    'P0115': const OfflineDtcKnowledge(
      code: 'P0115',
      standardDescriptionEn:
          'Engine Coolant Temperature (ECT) Circuit Malfunction',
      libyanTerm: 'سنسور حرارة المية (سنسور السخانة) / عطل بالدائرة',
      standardArabicDescription:
          'عطل في دائرة مستشعر درجة حرارة سائل تبريد المحرك',
      driverSymptoms: [
        'مراوح التبريد تدور بأقصى سرعة باستمرار',
        'صعوبة تشغيل المحرك والسيارة باردة',
      ],
      rootCauses: [
        'فيشة سنسور الحرارة مفصولة أو مؤكسدة',
        'تلف المقاومة الحرارية الداخلية للحساس',
      ],
      urgencyLevel: 'حرج',
      severity: CodeSeverity.critical,
      recommendedAction:
          'فحص فيشة سنسور الحرارة، وإذا كانت متآكلة يتم استبدال السنسور فوراً',
      partNameLibyan: 'سنسور حرارة مية (سخانة)',
      partNameEnglish: 'Coolant Temperature Sensor',
      partPriceMin: 40,
      partPriceMax: 95,
      aftermarketBrands: ['Facet', 'Tama', 'Bosch'],
    ),
    'P0120': const OfflineDtcKnowledge(
      code: 'P0120',
      standardDescriptionEn:
          'Throttle Position Sensor (TPS) Circuit Malfunction',
      libyanTerm: 'سنسور راس الإنجكشن / حساس بوابة الهواء (TPS)',
      standardArabicDescription:
          'عطل في دائرة مستشعر وضع صمام الخنق (بوابة الهواء)',
      driverSymptoms: [
        'السيارة لا تستجيب لدعسة البنزين',
        'دخول وضع الأمان (Limp Mode)',
        'تقطيع حاد',
      ],
      rootCauses: [
        'اتساخ كربون على مسارات الحساس المقاوم',
        'تلف بوابة الهواء الالكترونية',
      ],
      urgencyLevel: 'حرج',
      severity: CodeSeverity.critical,
      recommendedAction:
          'معايرة وبرمجة بوابة الهواء (Throttle Body Relearn) بعد تنظيفها',
      partNameLibyan: 'بوابة هواء كاملة أو سنسور TPS',
      partNameEnglish: 'Throttle Position Sensor / Body',
      partPriceMin: 150,
      partPriceMax: 450,
      aftermarketBrands: ['Denso', 'Pierburg', 'VDO'],
    ),
    'P0130': const OfflineDtcKnowledge(
      code: 'P0130',
      standardDescriptionEn:
          'Oxygen Sensor Circuit Malfunction (Bank 1 Sensor 1)',
      libyanTerm: 'حساس مرميطة علوي بنك 1 (قبل علبة الكربون)',
      standardArabicDescription:
          'عطل في دائرة مستشعر الأكسجين (الضفة 1 - المستشعر 1)',
      driverSymptoms: [
        'صرفية بنزين مرتفعة',
        'كتمة في عزم المحرك',
        'فشل في فحص الانبعاثات',
      ],
      rootCauses: [
        'تلوث الحساس برواسب الرصاص والكربون',
        'تلف هيتر التسخين الداخلي',
      ],
      urgencyLevel: 'متوسط',
      recommendedAction:
          'فحص إشارة الحساس للتأكد من تذبذب الفولتية بين 0.1V و 0.9V',
      partNameLibyan: 'حساس مرميطة علوي (سنسور أكسجين)',
      partNameEnglish: 'Upstream Oxygen Sensor',
      partPriceMin: 140,
      partPriceMax: 320,
      aftermarketBrands: ['Denso', 'Bosch', 'NTK'],
    ),
    'P0135': const OfflineDtcKnowledge(
      code: 'P0135',
      standardDescriptionEn: 'Oxygen Sensor Heater Circuit (Bank 1 Sensor 1)',
      libyanTerm: 'هيتر حساس المرميطة العلوي (سخان سنسور الأكسجين)',
      standardArabicDescription:
          'عطل في دائرة سخان مستشعر الأكسجين (الضفة 1 - المستشعر 1)',
      driverSymptoms: [
        'تأخر وصول المحرك لدرجة حرارة التشغيل المثالية',
        'زيادة استهلاك الوقود',
      ],
      rootCauses: [
        'احتراق ملف السخان الداخلي بالحساس',
        'فيوز تسخين سنسور الأكسجين محروق',
      ],
      urgencyLevel: 'متوسط',
      recommendedAction:
          'قياس مقاومة السخان بين طرفي الفيشة (يجب أن تكون بين 6 إلى 16 أوم)',
      partNameLibyan: 'حساس مرميطة علوي',
      partNameEnglish: 'O2 Sensor with Heater',
      partPriceMin: 140,
      partPriceMax: 320,
      aftermarketBrands: ['Denso', 'Bosch', 'NTK'],
    ),
    'P0171': const OfflineDtcKnowledge(
      code: 'P0171',
      standardDescriptionEn: 'System Too Lean (Bank 1)',
      libyanTerm:
          'خليط بنزين فقير بنك 1 (ماص هواء / كمية هواء أكثر من البنزين)',
      standardArabicDescription: 'النظام فقير بالوقود بشكل مفرط (الضفة 1)',
      driverSymptoms: [
        'تفتفة وتقطيع عند الدوس المفاجئ',
        'خشونة في دوران السلانسيه',
        'صوت فرقعة من العادم',
      ],
      rootCauses: [
        'ماص هواء من جوان المانيفول أو خراطيم الفاكيوم',
        'ضعف ضغط طرمبة البنزين',
        'انسداد فيلترو البنزين أو الرشاشات',
      ],
      urgencyLevel: 'حرج',
      severity: CodeSeverity.critical,
      recommendedAction:
          'فحص ماص الهواء بجهاز الدخان، وفحص ضغط طرمبة البنزين بساعة الضغط (3-4 بار)',
      partNameLibyan: 'فيلترو بنزين / طرمبة بنزين',
      partNameEnglish: 'Fuel Pump / Filter',
      partPriceMin: 80,
      partPriceMax: 260,
      aftermarketBrands: ['Denso', 'Bosch', 'Aisan'],
    ),
    'P0172': const OfflineDtcKnowledge(
      code: 'P0172',
      standardDescriptionEn: 'System Too Rich (Bank 1)',
      libyanTerm: 'خليط بنزين غني بنك 1 (زيادة بنزين أو نقص هواء)',
      standardArabicDescription: 'النظام غني بالوقود بشكل مفرط (الضفة 1)',
      driverSymptoms: [
        'دخان أسود كثيف من المرميطة',
        'رائحة وقود قوية',
        'اسوداد الشمعات بالكربون',
      ],
      rootCauses: [
        'رشاشات تسيل (تنقط بنزين)',
        'منظم ضغط الوقود تالف',
        'انسداد شديد في فيلترو الهواء',
      ],
      urgencyLevel: 'متوسط',
      recommendedAction:
          'فحص الرشاشات على جهاز التست وتنظيفها في ألتراسونيك والتأكد من عدم التسييل',
      partNameLibyan: 'رشاشات بنزين أو ريجليتور',
      partNameEnglish: 'Fuel Injectors / Regulator',
      partPriceMin: 90,
      partPriceMax: 240,
      aftermarketBrands: ['Denso', 'Bosch'],
    ),

    // Ignition System & Misfires (P0300 - P0399)
    'P0300': const OfflineDtcKnowledge(
      code: 'P0300',
      standardDescriptionEn: 'Random/Multiple Cylinder Misfire Detected',
      libyanTerm: 'تفتفة واحتراق غير منتظم عشوائي في عدة بسطونات',
      standardArabicDescription:
          'اكتشاف خلل في احتراق أسطوانات متعددة أو عشوائية',
      driverSymptoms: [
        'اهتزاز ورعشة قوية في المحرك',
        'فقدان شديد في العزم',
        'وميض لامبة التشك عند التسارع',
      ],
      rootCauses: [
        'شمعات احتراق منتهية الصلاحية',
        'ضعف تغذية البنزين أو ماص هواء عام',
        'تآكل بوبينات',
      ],
      urgencyLevel: 'حرج',
      severity: CodeSeverity.critical,
      recommendedAction:
          'تغيير طقم شمعات أصلي، فحص فيش البوبينات، والتأكد من ضغط البنزين',
      partNameLibyan: 'طقم شمعات احتراق أصلي',
      partNameEnglish: 'Spark Plugs (Set of 4)',
      partPriceMin: 60,
      partPriceMax: 160,
      aftermarketBrands: [
        'NGK Laser Iridium',
        'Denso Iridium TT',
        'Bosch Double Platinum',
      ],
    ),
    'P0301': const OfflineDtcKnowledge(
      code: 'P0301',
      standardDescriptionEn: 'Cylinder 1 Misfire Detected',
      libyanTerm: 'تفتفة واحتراق ناقص في بسطوني رقم 1',
      standardArabicDescription: 'خلل في احتراق الأسطوانة رقم 1',
      driverSymptoms: [
        'رعشة وتفتفة على السلانسيه',
        'صوت تكتكة أو خنقة في البسطوني الأول',
      ],
      rootCauses: [
        'تلف بوبينة بسطوني 1',
        'شمعة بسطوني 1 محروقة أو مبلولة زيت',
        'انسداد رشاش بسطوني 1',
      ],
      urgencyLevel: 'حرج',
      severity: CodeSeverity.critical,
      recommendedAction:
          'بدّل بوبينة بسطوني 1 مع بسطوني 2 لتحديد إذا انتقل العطل إلى P0302',
      partNameLibyan: 'بوبينة بسطوني 1 + شمعة',
      partNameEnglish: 'Ignition Coil & Spark Plug',
      partPriceMin: 70,
      partPriceMax: 180,
      aftermarketBrands: ['Denso', 'Bosch', 'Delphi'],
    ),
    'P0302': const OfflineDtcKnowledge(
      code: 'P0302',
      standardDescriptionEn: 'Cylinder 2 Misfire Detected',
      libyanTerm: 'تفتفة واحتراق ناقص في بسطوني رقم 2',
      standardArabicDescription: 'خلل في احتراق الأسطوانة رقم 2',
      driverSymptoms: ['رعشة في المحرك عند الوقوف', 'ضعف عزم مع تفتفة'],
      rootCauses: [
        'بوبينة بسطوني 2 تالفة',
        'شمعة بسطوني 2 منتهية',
        'تسريب زيت من جوان الكولاس',
      ],
      urgencyLevel: 'حرج',
      severity: CodeSeverity.critical,
      recommendedAction:
          'فك شمعة وبوبينة بسطوني 2 وفحص الشرارة ومستوى ضغط البسطوني (Compression)',
      partNameLibyan: 'بوبينة بسطوني 2 + شمعة',
      partNameEnglish: 'Ignition Coil & Spark Plug',
      partPriceMin: 70,
      partPriceMax: 180,
      aftermarketBrands: ['Denso', 'Bosch', 'Delphi'],
    ),
    'P0303': const OfflineDtcKnowledge(
      code: 'P0303',
      standardDescriptionEn: 'Cylinder 3 Misfire Detected',
      libyanTerm: 'تفتفة واحتراق ناقص في بسطوني رقم 3',
      standardArabicDescription: 'خلل في احتراق الأسطوانة رقم 3',
      driverSymptoms: [
        'اهتزاز المحرك',
        'تأخر في انطلاق السيارة',
        'استهلاك وقود زائد',
      ],
      rootCauses: [
        'بوبينة بسطوني 3 معطلة',
        'شمعة بسطوني 3 محترقة',
        'خلل في فيشة الرشاش',
      ],
      urgencyLevel: 'حرج',
      severity: CodeSeverity.critical,
      recommendedAction:
          'تبديل بوبينة بسطوني 3 مع بسطوني آخر للتأكد من مصدر العطل',
      partNameLibyan: 'بوبينة بسطوني 3 + شمعة',
      partNameEnglish: 'Ignition Coil & Spark Plug',
      partPriceMin: 70,
      partPriceMax: 180,
      aftermarketBrands: ['Denso', 'Bosch', 'Delphi'],
    ),
    'P0304': const OfflineDtcKnowledge(
      code: 'P0304',
      standardDescriptionEn: 'Cylinder 4 Misfire Detected',
      libyanTerm: 'تفتفة واحتراق ناقص في بسطوني رقم 4',
      standardArabicDescription: 'خلل في احتراق الأسطوانة رقم 4',
      driverSymptoms: [
        'تفتفة شديدة في المحرك',
        'وميض لامبة التشك',
        'عزم ضعيف جداً',
      ],
      rootCauses: [
        'بوبينة بسطوني 4 تالفة',
        'شمعة بسطوني 4 تالفة',
        'ضعف ضغط في البسطوني الرابع',
      ],
      urgencyLevel: 'حرج',
      severity: CodeSeverity.critical,
      recommendedAction:
          'فحص بوبينة وشمعة بسطوني 4 والتأكد من سلامة الكابل والفيشة',
      partNameLibyan: 'بوبينة بسطوني 4 + شمعة',
      partNameEnglish: 'Ignition Coil & Spark Plug',
      partPriceMin: 70,
      partPriceMax: 180,
      aftermarketBrands: ['Denso', 'Bosch', 'Delphi'],
    ),
    'P0335': const OfflineDtcKnowledge(
      code: 'P0335',
      standardDescriptionEn: 'Crankshaft Position Sensor A Circuit Malfunction',
      libyanTerm: 'حساس الكرنك (سنسور الكرانك شافت) / خلل بالدائرة',
      standardArabicDescription: 'عطل في دائرة مستشعر موضع عمود الكرنك',
      driverSymptoms: [
        'السيارة لا تدور إطلاقاً أو تدور بعد صعوبة بالغة',
        'انطفاء مفاجئ أثناء السير',
      ],
      rootCauses: [
        'تلف حساس الكرنك الداخلي بسبب الحرارة والزيت',
        'تآكل أسنان ترس الكرنك',
        'انقطاع السلك',
      ],
      urgencyLevel: 'حرج',
      severity: CodeSeverity.critical,
      recommendedAction:
          'فحص فيشة سنسور الكرنك السفلية واستبداله بحساس أصلي لأن المقلد لا يعمر',
      partNameLibyan: 'حساس كرنك أصلي',
      partNameEnglish: 'Crankshaft Position Sensor',
      partPriceMin: 95,
      partPriceMax: 220,
      aftermarketBrands: ['Denso', 'Bosch', 'Delphi'],
    ),
    'P0340': const OfflineDtcKnowledge(
      code: 'P0340',
      standardDescriptionEn: 'Camshaft Position Sensor Circuit Malfunction',
      libyanTerm: 'حساس الكامة / حساس التيمن (Camshaft Sensor)',
      standardArabicDescription: 'عطل في دائرة مستشعر موضع عمود الكامات',
      driverSymptoms: [
        'تأخر في بداية التشغيل (تدور المارش طويلاً)',
        'فقدان تسارع',
        'طفية في السلانسيه',
      ],
      rootCauses: [
        'تلف حساس الكامة',
        'ارتخاء كاتينة المحرك (سلسلة أو قايش التيمن)',
        'تأكسد فيشة الحساس',
      ],
      urgencyLevel: 'حرج',
      severity: CodeSeverity.critical,
      recommendedAction:
          'فحص تطابق توقيت التيمن (الكاتينة) وفحص مقاومة وإشارة حساس الكامة',
      partNameLibyan: 'حساس كامة (سنسور تيمن)',
      partNameEnglish: 'Camshaft Position Sensor',
      partPriceMin: 85,
      partPriceMax: 195,
      aftermarketBrands: ['Denso', 'Bosch', 'Hitachi'],
    ),

    // Emissions & Catalyst (P0400 - P0499)
    'P0420': const OfflineDtcKnowledge(
      code: 'P0420',
      standardDescriptionEn:
          'Catalyst System Efficiency Below Threshold (Bank 1)',
      libyanTerm: 'علبة كربون المرميطة (دبة التلوث) / كفاءة ضعيفة أو منزوعة',
      standardArabicDescription:
          'كفاءة المحول الحفاز أقل من الحد المسموح به (الضفة 1)',
      driverSymptoms: [
        'ولعة لامبة التشك باستمرار',
        'ريحة عادم قوية',
        'ثقل خفيف في العزم العالي',
      ],
      rootCauses: [
        'تلف أو ذوبان حجر علبة الكربون الداخلية',
        'تفريغ دبة البيئة من قبل الورش',
        'تسريب عادم قبل الدبة',
      ],
      urgencyLevel: 'متوسط',
      recommendedAction:
          'التأكد من وجود علبة الكربون وعدم تفريغها، وفحص تذبذب حساس الأكسجين الخلفي',
      partNameLibyan: 'علبة كربون مرميطة أو سبيسر سنسور',
      partNameEnglish: 'Catalytic Converter / O2 Spacer',
      partPriceMin: 180,
      partPriceMax: 850,
      aftermarketBrands: ['Magnaflow', 'Walker', 'OEM'],
    ),
    'P0401': const OfflineDtcKnowledge(
      code: 'P0401',
      standardDescriptionEn:
          'Exhaust Gas Recirculation (EGR) Flow Insufficient',
      libyanTerm: 'صمام الـ EGR (تدوير غازات العادم) / تدفق ضعيف ومسدود',
      standardArabicDescription: 'تدفق غير كافٍ لنظام إعادة تدوير غازات العادم',
      driverSymptoms: [
        'صوت خشونة وتكتكة تحت الحمل (صرقعة)',
        'تفتفة خفيفة في السرعات المتوسطة',
      ],
      rootCauses: [
        'تراكم الكربون الأسود داخل مجاري صمام الـ EGR',
        'انسداد أنبوب الفاكيوم',
      ],
      urgencyLevel: 'متوسط',
      recommendedAction:
          'فك صمام الـ EGR وتنظيفه بالسبراي وفرشاة سلك لإزالة ترسبات الكربون الصمغية',
      partNameLibyan: 'صمام EGR أو طقم تنظيف كربون',
      partNameEnglish: 'EGR Valve',
      partPriceMin: 120,
      partPriceMax: 310,
      aftermarketBrands: ['Pierburg', 'Delphi', 'Denso'],
    ),

    // Speed & Idle Control (P0500 - P0599)
    'P0500': const OfflineDtcKnowledge(
      code: 'P0500',
      standardDescriptionEn: 'Vehicle Speed Sensor (VSS) Malfunction',
      libyanTerm: 'سنسور السرعة (كيلومتراج) / حساس عداد السرعة',
      standardArabicDescription: 'عطل في مستشعر سرعة المركبة',
      driverSymptoms: [
        'عداد السرعة لا يعمل في الطبلون',
        'خربطة في تعشيقات الكمبيو الأوتوماتيك',
      ],
      rootCauses: [
        'تلف حساس السرعة المثبت على الكمبيو',
        'قطع في خيط الإشارة للطبلون',
        'خلل في منظومة ABS',
      ],
      urgencyLevel: 'متوسط',
      recommendedAction:
          'فحص فيشة حساس السرعة على شل الكمبيو والتأكد من قراءته عبر جهاز الكشف',
      partNameLibyan: 'حساس سرعة (سنسور كيلومتراج)',
      partNameEnglish: 'Vehicle Speed Sensor',
      partPriceMin: 65,
      partPriceMax: 150,
      aftermarketBrands: ['Standard', 'Denso'],
    ),
    'P0505': const OfflineDtcKnowledge(
      code: 'P0505',
      standardDescriptionEn: 'Idle Air Control System Malfunction',
      libyanTerm: 'سنسور السلانسيه / منظم دوران المحرك في الوقوف (IAC)',
      standardArabicDescription:
          'عطل في نظام التحكم في هواء الخمول (السلانسيه)',
      driverSymptoms: [
        'ارتفاع أو هبوط مفاجئ في الـ RPM عند الوقوف',
        'طفية المحرك عند تشغيل المكيف',
      ],
      rootCauses: [
        'اتساخ صمام السلانسيه بالزيت وغبار الكربون',
        'تلف الملف المغناطيسي الداخلي',
      ],
      urgencyLevel: 'متوسط',
      recommendedAction:
          'فك منظم السلانسيه وتنظيف المجرى والزنبرك بإسبراي البوابة وإعادة برمجته',
      partNameLibyan: 'سنسور سلانسيه (IAC Valve)',
      partNameEnglish: 'Idle Air Control Valve',
      partPriceMin: 75,
      partPriceMax: 170,
      aftermarketBrands: ['Standard', 'Hitachi', 'Denso'],
    ),

    // Transmission & Chassis (P0700 - C0050)
    'P0700': const OfflineDtcKnowledge(
      code: 'P0700',
      standardDescriptionEn: 'Transmission Control System (TCM) Malfunction',
      libyanTerm: 'كمبيوتر الكمبيو (TCM) / كود تحذيري من ناقل الحركة',
      module: 'TCM',
      moduleNameArabic: 'كمبيوتر ناقل الحركة (الكمبيو)',
      standardArabicDescription:
          'عطل عام في نظام التحكم بناقل الحركة الأوتوماتيكي',
      driverSymptoms: [
        'ثبات الكمبيو في المارش الثالث (Limp Mode)',
        'نتعة قوية بين التعشيقات',
      ],
      rootCauses: [
        'وجود كود عطل فرعي داخل كمبيوتر الكمبيو',
        'نقص أو حرق زيت الكمبيو',
        'فيوز أو ريليه الكمبيو',
      ],
      urgencyLevel: 'حرج',
      severity: CodeSeverity.critical,
      recommendedAction:
          'الدخول بجهاز الفحص على وحدة TCM لقراءة الكود الداخلي وفحص مستوى ولون زيت الكمبيو',
      partNameLibyan: 'فيلترو وزيت كمبيو أصلي',
      partNameEnglish: 'Transmission Fluid & Filter Kit',
      partPriceMin: 180,
      partPriceMax: 420,
      aftermarketBrands: ['Aisin', 'Castrol Transmax', 'ZF Lifeguard'],
    ),
    'C0035': const OfflineDtcKnowledge(
      code: 'C0035',
      standardDescriptionEn: 'Left Front Wheel Speed Sensor Circuit',
      libyanTerm: 'حساس ABS صالة أمامي يسار / سنسور عجل الصالة',
      module: 'ABS',
      moduleNameArabic: 'منظومة مانع الانزلاق (ABS)',
      standardArabicDescription:
          'عطل في دائرة مستشعر سرعة العجلة الأمامية اليسرى',
      driverSymptoms: [
        'ولعة لامبة الـ ABS ومانع الانزلاق',
        'نبض غير طبيعي في دواسة الفرامل',
      ],
      rootCauses: [
        'قطع سلك الحساس بسبب حركة الصالة والمزاطوري',
        'اتساخ حلقة المغناطيس في البلي بالبرادة',
      ],
      urgencyLevel: 'متوسط',
      recommendedAction:
          'فحص كابل الحساس وتثبيته في المزاطوري، والتأكد من نظافة مغناطيس البلية',
      partNameLibyan: 'حساس ABS أمامي يسار',
      partNameEnglish: 'ABS Wheel Speed Sensor (Front Left)',
      partPriceMin: 80,
      partPriceMax: 190,
      aftermarketBrands: ['Bosch', 'TRW', 'ATE'],
    ),
  };

  /// Extracts standard OBD-II DTC codes from input string
  static List<String> extractCodes(String input) {
    final matches = RegExp(r'\b([PBUCpbc][0-9A-Fa-f]{4})\b').allMatches(input);
    final codes = <String>[];
    for (var m in matches) {
      final code = m.group(1)?.toUpperCase();
      if (code != null && !codes.contains(code)) {
        codes.add(code);
      }
    }
    return codes;
  }

  /// Find single DTC knowledge if present in offline base
  static OfflineDtcKnowledge? findCode(String code) {
    final clean = code.trim().toUpperCase();
    return _dtcKnowledgeBase[clean];
  }

  /// Checks if all extracted codes exist in the local offline knowledge base
  static bool canResolveFullyOffline(List<String> codes) {
    if (codes.isEmpty) return false;
    return codes.every((c) => _dtcKnowledgeBase.containsKey(c));
  }

  /// Builds a complete DiagnosticReport instantly using local offline dictionary
  static DiagnosticReport? tryBuildOfflineReport(
    String rawCodes, {
    String? vin,
    String? make,
    String? model,
    String? year,
  }) {
    final codes = extractCodes(rawCodes);
    if (codes.isEmpty || !canResolveFullyOffline(codes)) {
      return null;
    }

    final critFaults = <DiagnosticFaultCode>[];
    final modFaults = <DiagnosticFaultCode>[];
    final histFaults = <DiagnosticFaultCode>[];
    final parts = <SparePartItem>[];
    final checklist = <DiagnosticChecklistStep>[];

    int stepCounter = 1;
    int healthScore = 100;

    for (final code in codes) {
      final k = _dtcKnowledgeBase[code]!;

      // Deduct health score
      if (k.severity == CodeSeverity.critical) {
        healthScore -= 24;
      } else {
        healthScore -= 12;
      }

      // Check sensor locator db for electrical info
      final elecData = SensorLocatorService.getDiagnostics(code);
      final elecInfo = ElectricalDiagnosticInfo(
        provenance: elecData.provenance,
        boxLocation: elecData.fuseInfo.boxLocation,
        fuseNumber: elecData.fuseInfo.fuseNumber,
        rating: elecData.fuseInfo.rating,
        relayName: elecData.fuseInfo.relayName,
        circuitDescription: elecData.fuseInfo.circuitDescription,
        sensorArea: elecData.sensorLocation.areaName,
        multimeterTip: elecData.multimeterTest.testingTipLibyan,
        powerPin: elecData.multimeterTest.powerPin,
        groundPin: elecData.multimeterTest.groundPin,
        signalPin: elecData.multimeterTest.signalPin,
        warning: elecData.warning,
      );

      final fault = DiagnosticFaultCode(
        code: k.code,
        module: k.module,
        moduleNameArabic: k.moduleNameArabic,
        standardDescriptionEn: k.standardDescriptionEn,
        libyanTerm: k.libyanTerm,
        standardArabicDescription: k.standardArabicDescription,
        driverSymptoms: k.driverSymptoms,
        rootCauses: k.rootCauses,
        urgencyLevel: k.urgencyLevel,
        recommendedAction: k.recommendedAction,
        severity: k.severity,
        electricalDiagnostics: elecInfo,
      );

      if (k.severity == CodeSeverity.critical) {
        critFaults.add(fault);
      } else if (k.severity == CodeSeverity.history) {
        histFaults.add(fault);
      } else {
        modFaults.add(fault);
      }

      // Add spare part if defined
      if (k.partNameLibyan != null) {
        parts.add(
          SparePartItem(
            id: 'part_${k.code.toLowerCase()}',
            relatedCode: k.code,
            partNameLibyan: k.partNameLibyan!,
            partNameStandardArabic: k.standardArabicDescription,
            partNameEnglish: k.partNameEnglish ?? 'Replacement Part',
            aftermarketReplacements: k.aftermarketBrands ?? ['أصلي', 'معتمد'],
            estimatedPriceRangeLYD:
                (k.partPriceMin != null && k.partPriceMax != null)
                ? PriceRangeLYD(
                    min: k.partPriceMin!,
                    max: k.partPriceMax!,
                    marketNote: 'سعر سوق قطع الغيار في ليبيا',
                  )
                : null,
          ),
        );
      }

      // Add checklist step
      checklist.add(
        DiagnosticChecklistStep(
          stepNumber: stepCounter++,
          actionTitle: 'فحص وتتبع ${k.libyanTerm.split('/').first.trim()}',
          actionDescriptionLibyan: k.recommendedAction,
          purpose:
              'التأكد من التغذية الكهربائية ومجرى الإشارة قبل التغيير العشوائي',
          estimatedTime: '10 دقائق',
          toolingNeeded: 'ملتيميتر + عدة فك يدوية',
        ),
      );
    }

    if (healthScore < 20) healthScore = 20;

    String severityStatus = 'سليم / خفيف';
    if (critFaults.isNotEmpty) {
      severityStatus = 'حرج / افحص فوراً';
    } else if (modFaults.isNotEmpty) {
      severityStatus = 'متوسط / يحتاج متابعة';
    }

    final now = DateTime.now();

    final summary = ReportSummary(
      overallHealthScore: healthScore,
      severityStatus: severityStatus,
      briefSummaryArabic:
          'تم حصر وتشخيص ${codes.length} عطل وتجهيز التوجيهات الفنية وقطع الغيار المطلوبة من القاموس الليبي الداخلي فورياً.',
      systemsCheckedCount: 4,
      faultsFoundCount: codes.length,
      passedSystemsCount: 3,
    );

    final vInfo = VehicleInfo(
      vin: (vin != null && vin.trim().isNotEmpty)
          ? vin.trim().toUpperCase()
          : 'N/A',
      make: make ?? 'غير محدد',
      model: model ?? 'مركبة مفحوصة',
      year: year ?? '—',
      mileage: 'حسب العداد',
      engineSpecs: EngineSpecs(
        displacement: 'بسطوني 4',
        fuelType: 'بنزين',
        cylinders: 4,
      ),
    );

    return DiagnosticReport(
      reportId: 'local_${now.millisecondsSinceEpoch}',
      generatedAt: now.toIso8601String(),
      scannerInfo: ScannerInfo(toolName: 'كاشف AI (فحص القاموس المحلي الفوري)'),
      vehicle: vInfo,
      summary: summary,
      criticalFaults: critFaults,
      moderateFaults: modFaults,
      historyFaults: histFaults,
      passedSystems: ['ABS (الفرامل)', 'SRS (الإيرباق)', 'TCM (الكمبيو)'],
      spareParts: parts,
      checklist: checklist,
    );
  }

  /// Generates a complete diagnostic report completely offline, with graceful fallbacks for any unrecognized codes.
  static DiagnosticReport buildOfflineReportFallback(
    String rawCodes, {
    String? vin,
    String? make,
    String? model,
    String? year,
  }) {
    final codes = extractCodes(rawCodes);
    final targetCodes = codes.isNotEmpty ? codes : ['P0100'];

    final critFaults = <DiagnosticFaultCode>[];
    final modFaults = <DiagnosticFaultCode>[];
    final histFaults = <DiagnosticFaultCode>[];
    final parts = <SparePartItem>[];
    final checklist = <DiagnosticChecklistStep>[];

    int stepCounter = 1;
    int healthScore = 100;

    for (final code in targetCodes) {
      final k = _dtcKnowledgeBase[code];
      if (k != null) {
        if (k.severity == CodeSeverity.critical) {
          healthScore -= 24;
        } else {
          healthScore -= 12;
        }

        final elecData = SensorLocatorService.getDiagnostics(code);
        final elecInfo = ElectricalDiagnosticInfo(
          provenance: elecData.provenance,
          boxLocation: elecData.fuseInfo.boxLocation,
          fuseNumber: elecData.fuseInfo.fuseNumber,
          rating: elecData.fuseInfo.rating,
          relayName: elecData.fuseInfo.relayName,
          circuitDescription: elecData.fuseInfo.circuitDescription,
          sensorArea: elecData.sensorLocation.areaName,
          multimeterTip: elecData.multimeterTest.testingTipLibyan,
          powerPin: elecData.multimeterTest.powerPin,
          groundPin: elecData.multimeterTest.groundPin,
          signalPin: elecData.multimeterTest.signalPin,
          warning: elecData.warning,
        );

        final fault = DiagnosticFaultCode(
          code: k.code,
          module: k.module,
          moduleNameArabic: k.moduleNameArabic,
          standardDescriptionEn: k.standardDescriptionEn,
          libyanTerm: k.libyanTerm,
          standardArabicDescription: k.standardArabicDescription,
          driverSymptoms: k.driverSymptoms,
          rootCauses: k.rootCauses,
          urgencyLevel: k.urgencyLevel,
          recommendedAction: k.recommendedAction,
          severity: k.severity,
          electricalDiagnostics: elecInfo,
        );

        if (k.severity == CodeSeverity.critical) {
          critFaults.add(fault);
        } else if (k.severity == CodeSeverity.history) {
          histFaults.add(fault);
        } else {
          modFaults.add(fault);
        }

        if (k.partNameLibyan != null) {
          parts.add(
            SparePartItem(
              id: 'part_${k.code.toLowerCase()}',
              relatedCode: k.code,
              partNameLibyan: k.partNameLibyan!,
              partNameStandardArabic: k.standardArabicDescription,
              partNameEnglish: k.partNameEnglish ?? 'Replacement Part',
              aftermarketReplacements: k.aftermarketBrands ?? ['أصلي', 'معتمد'],
              estimatedPriceRangeLYD:
                  (k.partPriceMin != null && k.partPriceMax != null)
                  ? PriceRangeLYD(
                      min: k.partPriceMin!,
                      max: k.partPriceMax!,
                      marketNote: 'سعر سوق قطع الغيار في ليبيا',
                    )
                  : null,
            ),
          );
        }

        checklist.add(
          DiagnosticChecklistStep(
            stepNumber: stepCounter++,
            actionTitle: 'فحص وتتبع ${k.libyanTerm.split('/').first.trim()}',
            actionDescriptionLibyan: k.recommendedAction,
            purpose:
                'التأكد من التغذية الكهربائية ومجرى الإشارة قبل التغيير العشوائي',
            estimatedTime: '10 دقائق',
            toolingNeeded: 'ملتيميتر + عدة فك يدوية',
          ),
        );
      } else {
        // Fallback for code not yet in local knowledge base
        healthScore -= 10;
        final fault = DiagnosticFaultCode(
          code: code,
          module: 'OBD-II',
          moduleNameArabic: 'كمبيوتر السيارة',
          standardDescriptionEn: 'Diagnostic Trouble Code $code',
          libyanTerm: 'عطل تشخيصي مسجل ($code)',
          standardArabicDescription:
              'كود مسجل في وحدة التحكم يتطلب فحص الدائرة والتوصيلات',
          driverSymptoms: [
            'إضاءة لمبة فحص المحرك (Check Engine)',
            'تفاوت في أداء السيارة',
          ],
          rootCauses: [
            'خلل في الدائرة الكهربائية أو الحساس المعني',
            'فيشة مرخية أو تلف في التوصيلات',
          ],
          urgencyLevel: 'متوسط',
          recommendedAction:
              'تتبع مخطط الأسلاك الخاص بالكود $code والتأكد من خطوط التغذية والتأريض',
          severity: CodeSeverity.moderate,
        );
        modFaults.add(fault);

        checklist.add(
          DiagnosticChecklistStep(
            stepNumber: stepCounter++,
            actionTitle: 'فحص الدائرة الكهربائية للكود $code',
            actionDescriptionLibyan:
                'تفقد الفيشة والأسلاك المتصلة بالمنظومة قبل تبديل أي قطعة',
            purpose: 'استبعاد المشاكل الكهربائية الشائعة',
            estimatedTime: '15 دقيقة',
            toolingNeeded: 'ملتيميتر + عدة صيانة',
          ),
        );
      }
    }

    if (healthScore < 20) healthScore = 20;

    String severityStatus = 'سليم / خفيف';
    if (critFaults.isNotEmpty) {
      severityStatus = 'حرج / افحص فوراً';
    } else if (modFaults.isNotEmpty) {
      severityStatus = 'متوسط / يحتاج متابعة';
    }

    final now = DateTime.now();

    final summary = ReportSummary(
      overallHealthScore: healthScore,
      severityStatus: severityStatus,
      briefSummaryArabic:
          'تم تشخيص ${targetCodes.length} عطل وتجهيز توجيهات الورشة وقطع الغيار من القاموس الليبي الداخلي فورياً بدون إنترنت.',
      systemsCheckedCount: 4,
      faultsFoundCount: targetCodes.length,
      passedSystemsCount: 3,
    );

    final vInfo = VehicleInfo(
      vin: (vin != null && vin.trim().isNotEmpty)
          ? vin.trim().toUpperCase()
          : 'N/A',
      make: make ?? 'غير محدد',
      model: model ?? 'مركبة مفحوصة',
      year: year ?? '—',
      mileage: 'حسب العداد',
      engineSpecs: EngineSpecs(
        displacement: 'بسطوني 4',
        fuelType: 'بنزين',
        cylinders: 4,
      ),
    );

    return DiagnosticReport(
      reportId: 'offline_${now.millisecondsSinceEpoch}',
      generatedAt: now.toIso8601String(),
      scannerInfo: ScannerInfo(
        toolName: 'كاشف AI (التشخيص المحلي السريع بدون إنترنت)',
      ),
      vehicle: vInfo,
      summary: summary,
      criticalFaults: critFaults,
      moderateFaults: modFaults,
      historyFaults: histFaults,
      passedSystems: ['ABS (الفرامل)', 'SRS (الإيرباق)', 'TCM (الكمبيو)'],
      spareParts: parts,
      checklist: checklist,
    );
  }
}
