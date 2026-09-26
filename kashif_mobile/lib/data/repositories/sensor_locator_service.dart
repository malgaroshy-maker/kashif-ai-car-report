/// Service providing offline electrical diagnostics, engine bay coordinates,
/// fuse specifications, and multimeter testing guides for OBD-II codes.
class SensorLocationData {
  final String areaName;
  final String engineZone; // 'front-air', 'top-manifold', 'exhaust-downpipe', 'underbody-transmission', 'wheel-hub', 'cabin'
  final String accessTip;
  final double? coordinateX; // 0..100% width
  final double? coordinateY; // 0..100% height

  const SensorLocationData({
    required this.areaName,
    required this.engineZone,
    required this.accessTip,
    this.coordinateX,
    this.coordinateY,
  });
}

class FuseInfoData {
  final String boxLocation;
  final String fuseNumber;
  final String rating;
  final String? relayName;
  final String circuitDescription;

  const FuseInfoData({
    required this.boxLocation,
    required this.fuseNumber,
    required this.rating,
    this.relayName,
    required this.circuitDescription,
  });
}

class MultimeterTestData {
  final String powerPin;
  final String groundPin;
  final String signalPin;
  final String? referenceVoltage;
  final String testingTipLibyan;

  const MultimeterTestData({
    required this.powerPin,
    required this.groundPin,
    required this.signalPin,
    this.referenceVoltage,
    required this.testingTipLibyan,
  });
}

class ElectricalDiagnosticsResult {
  final String provenance;
  final FuseInfoData fuseInfo;
  final SensorLocationData sensorLocation;
  final MultimeterTestData multimeterTest;
  final String? warning;

  const ElectricalDiagnosticsResult({
    required this.provenance,
    required this.fuseInfo,
    required this.sensorLocation,
    required this.multimeterTest,
    this.warning,
  });
}

class SensorLocatorService {
  static final Map<String, ElectricalDiagnosticsResult> _db = {
    // MAF Mass Air Flow Sensors
    'P0100': const ElectricalDiagnosticsResult(
      provenance: 'factory',
      fuseInfo: FuseInfoData(
        boxLocation: 'علبة فيوزات حوض المحرك (بجانب البطارية / الفيلترو)',
        fuseNumber: 'F14 / EFI-15A',
        rating: '15A (أزرق)',
        relayName: 'كتاوت تغذية المحرك الرئيسية (EFI Relay)',
        circuitDescription: 'دائرة تغذية حساس كتلة تدفق الهواء (MAF) والكمبيوتر',
      ),
      sensorLocation: SensorLocationData(
        areaName: 'خرطوم مدخل الهواء بين علبة الفيلترو وبوابة راس الإنجكشن',
        engineZone: 'front-air',
        accessTip: 'مكانه واضح ومباشر في حوض المحرك، يُفك ببرغيين Torx بعد فصل الفيشة.',
        coordinateX: 30,
        coordinateY: 35,
      ),
      multimeterTest: MultimeterTestData(
        powerPin: '12V تغذية رئيسية مع فتح السويتش (Pin 1 أو B+)',
        groundPin: 'أقل من 0.05V خط الأرضي الشاسي والكمبيوتر (Pin 2)',
        signalPin: '0.8V إلى 1.2V عند السكون، يرتفع تدريجياً إلى 3.8V - 4.5V مع الدعسة (Pin 3)',
        referenceVoltage: '5.0V جهد مرجعي ثابت من كمبيوتر المحرك (Pin 4)',
        testingTipLibyan: 'حط الأفوميتر على V DC واشبك الأسود بالشاسي. قيس السلك الموجب مع فتح السويتش لازم 12V، وقيس سلك الإشارة مع الدعسة لازم يزيد تدريجياً وما يقطعش.',
      ),
    ),
    'P0101': const ElectricalDiagnosticsResult(
      provenance: 'factory',
      fuseInfo: FuseInfoData(
        boxLocation: 'علبة فيوزات حوض المحرك (الرئيسية)',
        fuseNumber: 'F14 / EFI-15A',
        rating: '15A (أزرق)',
        relayName: 'EFI Main Relay',
        circuitDescription: 'تغذية حساس تدفق الهواء والمحرك',
      ),
      sensorLocation: SensorLocationData(
        areaName: 'بين قربة الفيلترو وبوابة راس الإنجكشن (الثروتل)',
        engineZone: 'front-air',
        accessTip: 'افحص نظافة السلك الحراري (Hot Wire) داخل الحساس قبل الاستبدال.',
        coordinateX: 30,
        coordinateY: 35,
      ),
      multimeterTest: MultimeterTestData(
        powerPin: '12V خط الكهرباء (Pin 1)',
        groundPin: 'أقل من 0.05V خط الأرضي (Pin 2)',
        signalPin: '1.0V عند السكون (Idle) وحتى 4.2V عند التسارع الكامل',
        referenceVoltage: '5.0V مرجعي ثابت',
        testingTipLibyan: 'رش سلك الحساس بسبراي تنظيف حساسات هواء (CRC MAF Cleaner) وجرب قيس الإشارة هل انتظمت قبل التبديل.',
      ),
    ),
    'P0102': const ElectricalDiagnosticsResult(
      provenance: 'factory',
      fuseInfo: FuseInfoData(
        boxLocation: 'علبة فيوزات حوض المحرك',
        fuseNumber: 'F14 / ENG-15A',
        rating: '15A (أزرق)',
        circuitDescription: 'تغذية دائرة حساس الماف وبوابة الهواء',
      ),
      sensorLocation: SensorLocationData(
        areaName: 'خرطوم مدخل الهواء بعد علبة الفيلترو مباشرة',
        engineZone: 'front-air',
        accessTip: 'تأكد من إحكام فيشة الحساس (البيانتو) وعدم تآكل الكلبس البلاستيكي.',
        coordinateX: 28,
        coordinateY: 36,
      ),
      multimeterTest: MultimeterTestData(
        powerPin: '12V مع فتح السويتش (Pin 1)',
        groundPin: 'أقل من 0.05V خط الأرضي (Pin 2)',
        signalPin: 'جهد الإشارة منخفض جداً (< 0.5V)، يجب أن يكون بين 1.0V إلى 4.2V',
        referenceVoltage: '5.0V مرجعي من الـ ECM',
        testingTipLibyan: 'كود P0102 يعني إشارة ضعيفة (Low Input). افحص فيوز الـ 15A أولاً، ثم قيس هل السلك واصل فيه 12V أم الخيط مقطوع بالبيانتو.',
      ),
    ),

    // Throttle Position Sensor (TPS)
    'P0120': const ElectricalDiagnosticsResult(
      provenance: 'factory',
      fuseInfo: FuseInfoData(
        boxLocation: 'علبة فيوزات حوض المحرك',
        fuseNumber: 'F08 / ETCS-10A',
        rating: '10A (أحمر)',
        circuitDescription: 'تغذية بوابة الخنق الكهربائية وحساس الثروتل',
      ),
      sensorLocation: SensorLocationData(
        areaName: 'على جانب بوابة الهواء (الثروتل بدي) المتصل بمجمع السحب',
        engineZone: 'top-manifold',
        accessTip: 'مثبت في جسم البوابة، فكه يحتاج مفتاح ألن أو توركس دقيق.',
        coordinateX: 42,
        coordinateY: 38,
      ),
      multimeterTest: MultimeterTestData(
        powerPin: '5.0V جهد مرجعي ثابت من الكمبيوتر (VCC)',
        groundPin: 'أقل من 0.05V خط الأرضي (E2)',
        signalPin: '0.5V عند السكون ويرتفع بسلاسة إلى 4.5V عند الضغط الكامل على دواسة البنزين',
        referenceVoltage: '5.0V',
        testingTipLibyan: 'حط الطرف الأحمر على سلك الإشارة ودوس على دواسة البنزين ببطء، راقب الفولت لازم يزيد تدريجياً بدون أي قفزات أو هبوط مفاجئ (Dropouts).',
      ),
    ),

    // Coolant Temperature Sensor (ECT)
    'P0115': const ElectricalDiagnosticsResult(
      provenance: 'factory',
      fuseInfo: FuseInfoData(
        boxLocation: 'علبة فيوزات حوض المحرك',
        fuseNumber: 'F12 / SENS-7.5A',
        rating: '7.5A (بني)',
        circuitDescription: 'تغذية حساسات حرارة وضغط سائل التبريد',
      ),
      sensorLocation: SensorLocationData(
        areaName: 'على كوع المية (Thermostat Housing) بالقرب من رأس المحرك',
        engineZone: 'front-air',
        accessTip: 'لا تفك الحساس والمحرك ساخن أبداً لتجنب اندفاع مياه التبريد المغلية. استخدم حبة 19mm عميقة.',
        coordinateX: 48,
        coordinateY: 32,
      ),
      multimeterTest: MultimeterTestData(
        powerPin: '5.0V جهد مرجعي من كمبيوتر السيارة مع فتح السويتش',
        groundPin: 'أقل من 0.05V أرضي حساسات ECM',
        signalPin: 'مقاومة الحساس NTC: حوالي 2000 - 3000 أوم في البرودة، وتنخفض إلى 200 - 300 أوم عند حرارة التشغيل (90°C)',
        referenceVoltage: '5.0V',
        testingTipLibyan: 'قيس مقاومة الحساس على وضع الأوم والمحرك بارد، ثم شغل السيارة وراقب انخفاض المقاومة تدريجياً مع سخونة المحرك.',
      ),
    ),

    // Oxygen Sensors O2 / Lambda
    'P0130': const ElectricalDiagnosticsResult(
      provenance: 'factory',
      fuseInfo: FuseInfoData(
        boxLocation: 'علبة فيوزات حوض المحرك',
        fuseNumber: 'F06 / O2-HTR-15A',
        rating: '15A (أزرق)',
        relayName: 'كتاوت سخانات الحساسات',
        circuitDescription: 'تغذية سخان حساس الأكسجين (اللامبدا)',
      ),
      sensorLocation: SensorLocationData(
        areaName: 'على مجمع العادم (مانيفولد الشكمان) قبل دبة التلوث (الكاتالايزر)',
        engineZone: 'exhaust-downpipe',
        accessTip: 'الحساس في منطقة شديدة الحرارة، رشه بـ WD-40 وهو بارد واستخدم لقمة حساس شكمان مشقوقة 22mm.',
        coordinateX: 62,
        coordinateY: 52,
      ),
      multimeterTest: MultimeterTestData(
        powerPin: '12V لسخان الحساس (سلكين بلون واحد عادة أسود أو أبيض)',
        groundPin: 'أرضي الشاسي أو نبضات تأريض من الكمبيوتر',
        signalPin: 'يتأرجح بسرعة بين 0.1V (خليط فقير) و 0.9V (خليط غني) بمعدل مرتين على الأقل بالثانية',
        referenceVoltage: '0.45V مرجعي عند فصل الفيشة',
        testingTipLibyan: 'إذا كانت الفولتية ثابتة على 0.45V ولا تتأرجح بعد سخونة المحرك، فالحساس ميت أو خامل ويحتاج تغيير.',
      ),
    ),
    'P0135': const ElectricalDiagnosticsResult(
      provenance: 'factory',
      fuseInfo: FuseInfoData(
        boxLocation: 'علبة فيوزات حوض المحرك',
        fuseNumber: 'F06 / O2-HTR-15A',
        rating: '15A (أزرق)',
        circuitDescription: 'دائرة سخان حساس الأكسجين البنك 1 الحساس 1',
      ),
      sensorLocation: SensorLocationData(
        areaName: 'داون بيب العادم قبل الكاتالايزر (Bank 1 Sensor 1)',
        engineZone: 'exhaust-downpipe',
        accessTip: 'افصل الفيشة وقيس مقاومة السخان بين السلكين المتشابهين في اللون.',
        coordinateX: 60,
        coordinateY: 50,
      ),
      multimeterTest: MultimeterTestData(
        powerPin: '12V خط تغذية السخان (Pin 1)',
        groundPin: 'أرضي سخان الحساس (Pin 2)',
        signalPin: 'مقاومة السخان الداخلية يجب أن تكون بين 6 إلى 15 أوم في الحساس السليم',
        referenceVoltage: '12V تغذية السخان',
        testingTipLibyan: 'قيس بالأوم بين سلكي السخان بالفيشة، إذا أعطاك OL أو مقاومة مفتوحة فالسخان محروق من الداخل والقطعة تالفة.',
      ),
    ),
    'P0420': const ElectricalDiagnosticsResult(
      provenance: 'factory',
      fuseInfo: FuseInfoData(
        boxLocation: 'علبة فيوزات حوض المحرك',
        fuseNumber: 'F06 / O2-15A',
        rating: '15A (أزرق)',
        circuitDescription: 'حساسات الشكمان الأمامية والخلفية',
      ),
      sensorLocation: SensorLocationData(
        areaName: 'دبة التلوث (الكاتالايزر) أسفل السيارة بمجرى العادم',
        engineZone: 'exhaust-downpipe',
        accessTip: 'افحص قراءة الحساس الخلفي (Sensor 2) بعد الكاتالايزر للتأكد من كفاءة الدبة.',
        coordinateX: 68,
        coordinateY: 65,
      ),
      multimeterTest: MultimeterTestData(
        powerPin: '12V تغذية السخانات',
        groundPin: 'أرضي الحساس',
        signalPin: 'الحساس الخلفي السليم يجب أن تكون إشارته هادئة ومستقرة حول 0.6V إلى 0.7V',
        testingTipLibyan: 'إذا كانت إشارة الحساس الخلفي تتأرجح وتتحرك مثل الحساس الأمامي تماماً، فهذا يعني أن دبة التلوث فرغت أو مكسورة ولا تصفي الغازات.',
      ),
    ),

    // Misfire & Ignition Coils
    'P0300': const ElectricalDiagnosticsResult(
      provenance: 'factory',
      fuseInfo: FuseInfoData(
        boxLocation: 'علبة فيوزات المحرك (أو علبة كمبيوتر المحرك E-Box)',
        fuseNumber: 'F02 / IGN-20A',
        rating: '20A (أصفر) أو 30A (أخضر)',
        relayName: 'كتاوت الإشعال الرئيسي (Ignition Main Relay)',
        circuitDescription: 'تغذية كويلات الإشعال (البوبينات) والشمعات',
      ),
      sensorLocation: SensorLocationData(
        areaName: 'أعلى غطاء بلوك المحرك (فوق الشمعات مباشرة)',
        engineZone: 'top-manifold',
        accessTip: 'تُفك براغي غطاء المحرك البلاستيكي للوصول لجميع البوبينات (Coils) والفيش.',
        coordinateX: 50,
        coordinateY: 45,
      ),
      multimeterTest: MultimeterTestData(
        powerPin: '12V تغذية مستمرة مع السويتش على كل بوبينة (Pin 1 / B+)',
        groundPin: 'أقل من 0.1V أرضي المحرك والسلندر (Pin 2)',
        signalPin: 'نبضات إشارة سالبة/موجبة من كمبيوتر المحرك (Trigger Pulse 1V - 5V)',
        testingTipLibyan: 'افحص مقاومة البوبينة بالأوم، وإذا الشك في بوبينة معينة بدلها مع السلندر المجاور وشوف كود العطل وين ينتقل بجهاز الكشف.',
      ),
    ),
    'P0301': const ElectricalDiagnosticsResult(
      provenance: 'factory',
      fuseInfo: FuseInfoData(
        boxLocation: 'علبة فيوزات حوض المحرك',
        fuseNumber: 'F02 / IGN-20A',
        rating: '20A (أصفر)',
        circuitDescription: 'تغذية دائرة الإشعال والبوبينة رقم 1',
      ),
      sensorLocation: SensorLocationData(
        areaName: 'السلندر رقم 1 (الأقرب لسير الكاتينة / صدر المحرك)',
        engineZone: 'top-manifold',
        accessTip: 'افصل فيشة البوبينة رقم 1 وتأكد من عدم وجود زيت متسرب داخل تجويف الشمعة من جوان غطا التاكيهات.',
        coordinateX: 42,
        coordinateY: 42,
      ),
      multimeterTest: MultimeterTestData(
        powerPin: '12V مع فتح السويتش على الطرف الموجب',
        groundPin: 'أقل من 0.05V للأرضي',
        signalPin: 'نبضات إشعال منتظمة من الـ ECU',
        testingTipLibyan: 'فك شمعة السلندر 1 وافحص سنها: إذا مسودة كربون أو مبلولة بنزين المشكلة في شعلة البوبينة أو البخاخ.',
      ),
    ),
    'P0304': const ElectricalDiagnosticsResult(
      provenance: 'factory',
      fuseInfo: FuseInfoData(
        boxLocation: 'علبة فيوزات المحرك الرئيسية',
        fuseNumber: 'F02 / IGN-20A',
        rating: '20A (أصفر)',
        circuitDescription: 'دائرة الإشعال والبوبينة سلندر رقم 4',
      ),
      sensorLocation: SensorLocationData(
        areaName: 'السلندر رقم 4 (الأقرب للفولان وفلنجة الكمبيو)',
        engineZone: 'top-manifold',
        accessTip: 'مكانه في آخر المحرك من جهة صدر الكابينة. افحص فيشة البوبينة 4 والكلبس.',
        coordinateX: 58,
        coordinateY: 48,
      ),
      multimeterTest: MultimeterTestData(
        powerPin: '12V مع السويتش على السلك الموجب',
        groundPin: 'أقل من 0.05V أرضي',
        signalPin: 'إشارة قدح البوبينة',
        testingTipLibyan: 'بدل بوبينة 4 مع بوبينة 2، لو انتقل العطل إلى P0302 فالبوبينة تالفة، لو بقي على P0304 فالمشكلة في الشمعة أو البخاخ أو ضغط السلندر.',
      ),
    ),

    // Crankshaft & Camshaft Sensors (CKP / CMP)
    'P0335': const ElectricalDiagnosticsResult(
      provenance: 'factory',
      fuseInfo: FuseInfoData(
        boxLocation: 'علبة فيوزات المحرك',
        fuseNumber: 'F10 / ENG-SENS-10A',
        rating: '10A (أحمر)',
        circuitDescription: 'تغذية حساسات توقيت المحرك (الكرنك والكامات)',
      ),
      sensorLocation: SensorLocationData(
        areaName: 'أسفل بلوك المحرك بالقرب من طنبورة الكرنك أو بجانب الفولان والكمبيو',
        engineZone: 'front-air',
        accessTip: 'يتطلب فكه مفتاح حبة 10mm، وعادةً الوصول له من أسفل السيارة بعد فك صاجة الحماية.',
        coordinateX: 40,
        coordinateY: 60,
      ),
      multimeterTest: MultimeterTestData(
        powerPin: 'حساس هول (Hall): 5V أو 12V / حساس مغناطيسي (VR): لا يحتاج كهرباء تغذية',
        groundPin: 'أرضي الحساس المباشر',
        signalPin: 'موجة مربعة في حساس هول (0-5V) أو موجة جيبية مترددة AC تزيد مع الدوران (0.5V - 2.5V AC)',
        referenceVoltage: '5.0V في حساسات Hall',
        testingTipLibyan: 'قيس مقاومة الحساس إذا كان نوعه سلكين فقط: المقاومة السليمة بين 500 إلى 1500 أوم. إذا مفتوحة فالحساس مقطوع من الداخل ولن تشتغل السيارة نهائياً.',
      ),
    ),
    'P0340': const ElectricalDiagnosticsResult(
      provenance: 'factory',
      fuseInfo: FuseInfoData(
        boxLocation: 'علبة فيوزات حوض المحرك',
        fuseNumber: 'F10 / SENS-10A',
        rating: '10A (أحمر)',
        circuitDescription: 'تغذية حساس موضع عمود الكامات (الكامة)',
      ),
      sensorLocation: SensorLocationData(
        areaName: 'أعلى رأس المحرك في الخلف أو الأمام بجانب تروس الكامات',
        engineZone: 'top-manifold',
        accessTip: 'واضح ومثبت ببرغي 10mm، تأكد من الأورينج (O-ring) المطاطي لمنع تسريب الزيت بعد التركيب.',
        coordinateX: 52,
        coordinateY: 36,
      ),
      multimeterTest: MultimeterTestData(
        powerPin: '12V أو 5V جهد تشغيل الحساس (Pin 1)',
        groundPin: 'أقل من 0.05V خط الأرضي (Pin 2)',
        signalPin: 'نبضات جهد رقمية مربعة بين 0V و 5V مع دوران المحرك (Pin 3)',
        referenceVoltage: '5.0V',
        testingTipLibyan: 'قيس الفولت على سلك الإشارة مع تدوير المحرك بالمارش ببطء: لازم تلاحظ الفولت ينبض بين 5V و 0V بانتظام.',
      ),
    ),

    // Wheel Speed Sensors / ABS
    'C0035': const ElectricalDiagnosticsResult(
      provenance: 'factory',
      fuseInfo: FuseInfoData(
        boxLocation: 'علبة فيوزات حوض المحرك الرئيسية',
        fuseNumber: 'ABS-MTR-40A / ABS-VALVE-25A',
        rating: '40A ماكسي فيوز + 25A',
        circuitDescription: 'طلمبة وموديول مانع الانزلاق والانغلاق (ABS/ESP)',
      ),
      sensorLocation: SensorLocationData(
        areaName: 'خلف ديسك الفرامل بالعجلة الأمامية اليسرى (على الفوزيلي)',
        engineZone: 'wheel-hub',
        accessTip: 'ارفع السيارة وافحص مسار السلك الممتد من جسم السيارة حتى العجلة خشية انقطاعه أو احتكاكه بالجنط.',
        coordinateX: 18,
        coordinateY: 55,
      ),
      multimeterTest: MultimeterTestData(
        powerPin: '12V أو 8V من موديول الـ ABS',
        groundPin: 'أرضي موديول الفرامل',
        signalPin: 'تيار متغير أو تردد تيار متناوب AC عند تدوير العجلة باليد (حوالي 0.2V - 1.0V AC)',
        testingTipLibyan: 'افحص سنون طاسة الكوشينة أو الحلقة المغناطيسية من الصدى والرايش، ونظف فيشة الحساس بسبراي تلامس جاف.',
      ),
    ),
  };

  /// Returns electrical diagnostic info for a given fault code with smart fallbacks
  static ElectricalDiagnosticsResult getDiagnostics(
    String code, {
    String? vehicleMake,
    String? module,
  }) {
    final cleanCode = code.trim().toUpperCase();

    if (_db.containsKey(cleanCode)) {
      return _db[cleanCode]!;
    }

    // Smart heuristic based on code family
    if (cleanCode.startsWith('P01')) {
      return const ElectricalDiagnosticsResult(
        provenance: 'general',
        fuseInfo: FuseInfoData(
          boxLocation: 'علبة فيوزات حوض المحرك الرئيسية',
          fuseNumber: 'ENG-15A / SENS-10A',
          rating: '10A - 15A',
          circuitDescription: 'دائرة حساسات الهواء والوقود',
        ),
        sensorLocation: SensorLocationData(
          areaName: 'مسار سحب الهواء أو مجمع العادم',
          engineZone: 'front-air',
          accessTip: 'افحص فيش وحساسات دخول الهواء وفلتر الهواء قبل تغيير القطعة.',
          coordinateX: 35,
          coordinateY: 35,
        ),
        multimeterTest: MultimeterTestData(
          powerPin: '12V أو 5V جهد التغذية',
          groundPin: 'أقل من 0.05V خط الأرضي',
          signalPin: '0.5V إلى 4.5V إشارة تناظرية أو رقمية',
          referenceVoltage: '5.0V مرجعي ثابت',
          testingTipLibyan: 'تأكد من سلامة الخيوط بالفيشة وعدم وجود تمليح أو كربون قبل الحكم على الحساس.',
        ),
      );
    }

    if (cleanCode.startsWith('P03')) {
      return const ElectricalDiagnosticsResult(
        provenance: 'general',
        fuseInfo: FuseInfoData(
          boxLocation: 'علبة فيوزات المحرك',
          fuseNumber: 'IGN-20A',
          rating: '20A (أصفر)',
          circuitDescription: 'منظومة الإشعال والكويلات والشمعات',
        ),
        sensorLocation: SensorLocationData(
          areaName: 'أعلى غطاء المحرك (البوبينات والشمعات)',
          engineZone: 'top-manifold',
          accessTip: 'تأكد من سلامة أسلاك البوبينات وعدم وجود زيت في حفر الشمعات.',
          coordinateX: 50,
          coordinateY: 45,
        ),
        multimeterTest: MultimeterTestData(
          powerPin: '12V مع السويتش على أطراف الكويلات',
          groundPin: 'خط أرضي متصل بالشاسي أو البلوك',
          signalPin: 'نبضات إشارة إشعال من الـ ECU',
          testingTipLibyan: 'بدل الكويل أو الشمعة المشكوك فيها مع سلندر ثاني سليم ولاحظ هل ينتقل كود العطل.',
        ),
      );
    }

    if (cleanCode.startsWith('P07') || cleanCode.startsWith('P08')) {
      return const ElectricalDiagnosticsResult(
        provenance: 'general',
        fuseInfo: FuseInfoData(
          boxLocation: 'علبة فيوزات حوض المحرك أو أسفل الطبلون',
          fuseNumber: 'AT/CVT-15A',
          rating: '15A',
          circuitDescription: 'كمبيوتر وصمامات الكمبيو (Transmission Control Module)',
        ),
        sensorLocation: SensorLocationData(
          areaName: 'على جسم علبة السرعات (الكمبيو) أسفل السيارة',
          engineZone: 'underbody-transmission',
          accessTip: 'افحص فيشة الكمبيو الدائرية الكبيرة وتأكد من عدم تسرب زيت الفتيس داخل الفيشة.',
          coordinateX: 55,
          coordinateY: 65,
        ),
        multimeterTest: MultimeterTestData(
          powerPin: '12V تغذية موديول ناقل الحركة',
          groundPin: 'أقل من 0.1V للأرضي',
          signalPin: 'مقاومة صمامات السولينويد بين 10 إلى 25 أوم',
          testingTipLibyan: 'افحص مستوى ونظافة زيت الكمبيو أولاً، ثم قيس فيشة الحساس وتأكد من جفافها من الزيت.',
        ),
      );
    }

    if (cleanCode.startsWith('C')) {
      return const ElectricalDiagnosticsResult(
        provenance: 'general',
        fuseInfo: FuseInfoData(
          boxLocation: 'علبة فيوزات المحرك (قرب البطارية)',
          fuseNumber: 'ABS/ESP-30A / 40A',
          rating: '30A - 40A',
          circuitDescription: 'موديول الفرامل والاتزان ABS وحساسات العجلات',
        ),
        sensorLocation: SensorLocationData(
          areaName: 'خلف ديسك الفرامل عند العجلات أو عمود الدركسيون',
          engineZone: 'wheel-hub',
          accessTip: 'ارفع السيارة وافحص سلك الحساس عند الكوشينة، أغلب الأعطال سلك مقروض أو فيشة مملحة.',
          coordinateX: 20,
          coordinateY: 55,
        ),
        multimeterTest: MultimeterTestData(
          powerPin: '12V أو 8V من كمبيوتر ABS',
          groundPin: 'أقل من 0.05V خط الأرضي',
          signalPin: 'نبضات ترددية AC عند دوران العجلة',
          testingTipLibyan: 'قارن قراءة سرعة العجلات الأربع على شاشة جهاز الفحص الحية (Live Data) وأنت تدور العجلة باليد.',
        ),
      );
    }

    if (cleanCode.startsWith('B')) {
      final isAirbag = cleanCode.contains('10') || cleanCode.contains('11') || (module?.contains('SRS') ?? false);
      return ElectricalDiagnosticsResult(
        provenance: 'general',
        warning: isAirbag ? 'تحذير أمان: منظومة الوسائد الهوائية (الإيرباق) حساسة جداً. افصل البطارية وانتظر 10 دقائق قبل فك أي فيشة صفراء.' : null,
        fuseInfo: FuseInfoData(
          boxLocation: 'علبة فيوزات المقصورة الداخلية (تحت الطبلون)',
          fuseNumber: isAirbag ? 'SRS-10A' : 'BODY-15A',
          rating: isAirbag ? '10A (أحمر)' : '15A (أزرق)',
          circuitDescription: isAirbag ? 'كمبيوتر الوسائد الهوائية والأحزمة' : 'كمبيوتر البودي والإنارة BCM',
        ),
        sensorLocation: const SensorLocationData(
          areaName: 'داخل مقصورة الركاب أو حساسات الصدمة بالدعامات',
          engineZone: 'cabin',
          accessTip: 'جميع فيش منظومة الإيرباق تكون بلون أصفر فاقع مميز مع قفل أمان مزدوج.',
          coordinateX: 50,
          coordinateY: 85,
        ),
        multimeterTest: const MultimeterTestData(
          powerPin: '12V مع السويتش',
          groundPin: 'أقل من 0.05V أرضي صريح',
          signalPin: 'تعتمد على شبكة CAN أو مقاومة فيول الإيرباق (2.0 - 3.0 أوم)',
          testingTipLibyan: 'لا تقيس فيش الإيرباق بالأفوميتر العادي مباشرة لتجنب تفجير الوسادة. اعتمد على فحص الكلبسات والشريط الحلزوني (Clockspring).',
        ),
      );
    }

    // Default generic OBD-II profile
    return const ElectricalDiagnosticsResult(
      provenance: 'general',
      fuseInfo: FuseInfoData(
        boxLocation: 'راجع المخطط المطبوع خلف غطاء علبة الفيوزات في سيارتك',
        fuseNumber: 'غير محدد للكود',
        rating: '10A - 20A',
        circuitDescription: 'دائرة التغذية الكهربائية للمنظومة المعطلة',
      ),
      sensorLocation: SensorLocationData(
        areaName: 'حوض المحرك أو المنظومة التابعة لكود العطل',
        engineZone: 'top-manifold',
        accessTip: 'افحص الفيشة والتوصيلات الكهربائية (البيانتو) بحثاً عن كربون أو أسلاك مجروحة.',
        coordinateX: 50,
        coordinateY: 50,
      ),
      multimeterTest: MultimeterTestData(
        powerPin: '12V مع فتح السويتش',
        groundPin: 'أقل من 0.05V خط الأرضي',
        signalPin: 'حسب نوع الحساس أو المشغل',
        testingTipLibyan: 'افحص وصول 12V للفيشة وتأكد من سلامة خط الأرضي قبل شراء أو تبديل أي قطعة غيار.',
      ),
    );
  }
}
