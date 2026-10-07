import 'package:flutter/material.dart';
import '../models/dashboard_light.dart';

class DashboardLightsRepository {
  static const List<DashboardLightItem> allLights = [
    // 1. Check Engine
    DashboardLightItem(
      id: 'check_engine',
      nameArabic: 'لمبة فحص المحرك (Check Engine / MIL)',
      nameEnglish: 'Check Engine / Malfunction Indicator Lamp',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'CHECK_ENG',
      icon: Icons.electric_bolt_rounded,
      meaningArabic:
          'كمبيوتر السيارة رصد خللاً في أحد أنظمة الاحتراق، الوقود، الحساسات، أو الانبعاثات.',
      commonCauses: [
        'عطل في حساس المرميطة (O2 Sensor) أو حساس الهواء (MAF)',
        'تلف بوبينات الإشعال أو الشمعات ووجود فطفطة (Misfire)',
        'انسداد في فيلترو البيئة وعلبة كربون المرميطة (Catalytic Converter)',
        'خلل في نظام بخ الوقود وتوزيع الشفط (Vacuum / EVAP)',
      ],
      actionRequired:
          'إذا كانت اللمبة ثابتة: يمكنك السير بحذر لأقرب ورشة للفحص بجهاز الـ OBD-II.\n⚠️ تنبيه خطير: إذا كانت اللمبة ترمش (تغمز بسرعة)، توقف فوراً لأن هناك بسطوني لا يحرق مما قد يؤدي لذوبان علبة كربون المرميطة واشتعالها!',
      associatedDTCs: [
        'P0300',
        'P0171',
        'P0420',
        'P0135',
        'P0101',
        'P0113',
        'P0455',
      ],
      colorValue: 0xFFFDD835,
    ),

    // 2. Oil Pressure
    DashboardLightItem(
      id: 'oil_pressure',
      nameArabic: 'لمبة ضغط زيت المحرك (إبريق الزيت)',
      nameEnglish: 'Engine Oil Pressure Warning',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.stopImmediately,
      symbolCode: 'OIL_PRESS',
      icon: Icons.water_drop_rounded,
      meaningArabic:
          'انخفاض خطير في ضغط الزيت الداخلي اللازم لتزييت الكولوا والسبايك والكامات.',
      commonCauses: [
        'نقص حاد في مستوى زيت المحرك نتيجة تسريب أو حرق داخلي',
        'تلف أو انكسار بومبة الزيت',
        'انسداد شخال الزيت السفلي بالرايش أو الرواسب الكربونية',
        'تلف حساس ضغط الزيت (Oil Pressure Switch)',
      ],
      actionRequired:
          '⛔ توقف فوراً على جانب الطريق وأطفئ المحرك خلال ثوانٍ معدودة! لا تعاود التشغيل إطلاقاً حتى يتم فحص مقياس الزيت. تشغيل المحرك بدون ضغط زيت كافٍ يؤدي لتصلب المحرك (تكييل) وتلفه بالكامل في دقائق.',
      associatedDTCs: ['P0520', 'P0521', 'P0522', 'P0524'],
      colorValue: 0xFFE53935,
    ),

    // 3. Coolant Temperature
    DashboardLightItem(
      id: 'coolant_temp',
      nameArabic: 'لمبة حرارة المحرك وسائل التبريد',
      nameEnglish: 'Engine Coolant Temperature High',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.stopImmediately,
      symbolCode: 'TEMP_HIGH',
      icon: Icons.thermostat_rounded,
      meaningArabic:
          'سائل التبريد تجاوز درجة الغليان الآمنة والمحرك في حالة سخونة مفرطة.',
      commonCauses: [
        'تسريب مية الرداتوري أو انقطاع أحد المناكوطيات (التوبوات)',
        'توقف مروحة تبريد الرداتوري (فيوز أو موطور)',
        'تعطل بلف الحرارة (الثرموستات) في وضع الإغلاق',
        'تلف بومبة الماء أو انقطاع قايش المحرك',
      ],
      actionRequired:
          '⛔ توقف فوراً في مكان آمن وأطفئ المحرك. لا تفتح غطاء الرداتوري إطلاقاً وهو ساخن لتجنب انفجار البخار وحروق الوجه واليدين. انتظر 20 دقيقة حتى يبرد المحرك تماماً قبل الفحص.',
      associatedDTCs: ['P0217', 'P0117', 'P0118', 'P0480'],
      colorValue: 0xFFE53935,
    ),

    // 4. Battery / Charging
    DashboardLightItem(
      id: 'battery_charge',
      nameArabic: 'لمبة شحن البطارية والدينمو',
      nameEnglish: 'Battery / Charging System Warning',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.stopImmediately,
      symbolCode: 'BATTERY',
      icon: Icons.battery_alert_rounded,
      meaningArabic:
          'دينمو الشحن لا يولد الكهرباء المطلوبة والسيارة تسير حالياً على طاقة البطارية فقط.',
      commonCauses: [
        'انقطاع أو ارتخاء قايش المحرك الخارجي',
        'تلف كاربونات أو ريليه منظم شحن الدينمو (Alternator Failure)',
        'ارتخاء أو كربنة أصابع وكابلات البطارية الرئيسية',
        'احتراق فيوز الدينمو الرئيسي (ALT Fuse)',
      ],
      actionRequired:
          'أطفئ المكيف والأنوار والراديو فوراً لتقليل استهلاك الكهرباء، وتوجه إلى أقرب ورشة كهربائي سيارات. السيارة ستتوقف تلقائياً خلال 10 إلى 20 دقيقة عند نفاد شحن البطارية.',
      associatedDTCs: ['P0562', 'P0620', 'P0622', 'P2503'],
      colorValue: 0xFFE53935,
    ),

    // 5. Brake System
    DashboardLightItem(
      id: 'brake_system',
      nameArabic: 'لمبة منظومة الفرامل وزيت البريك (!)',
      nameEnglish: 'Brake Warning System / Handbrake',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.stopImmediately,
      symbolCode: 'BRAKE_WARN',
      icon: Icons.error_rounded,
      meaningArabic:
          'إما أن فرملة اليد مرفوعة، أو أن هناك نقصاً خطيراً في زيت الفرامل أو ضغط المنظومة.',
      commonCauses: [
        'فرملة اليد (Handbrake) مشدودة أو غير منزلة بالكامل',
        'نقص حاد في زيت الفرامل نتيجة تسريب في الأنابيب أو البستن',
        'تآكل شديد في باطنيات الديسكو استهلك مخزون الزيت',
        'عطل في نظام تعزيز الفرامل (السيرفو / البوستر)',
      ],
      actionRequired:
          'تأكد من تنزيل فرملة اليد. إذا بقيت اللمبة مشتعلة، افحص علبة زيت الفرامل فوراً. لا تقم بالقيادة إذا كانت الدواسة تنزل للأسفل بدون مقاومة لتفادي حوادث الاصطدام!',
      associatedDTCs: ['C0040', 'C0045', 'C0049'],
      colorValue: 0xFFE53935,
    ),

    // 6. Airbag (SRS)
    DashboardLightItem(
      id: 'airbag_srs',
      nameArabic: 'لمبة الوسائد الهوائية (الإيرباق SRS)',
      nameEnglish: 'Airbag / Supplemental Restraint System (SRS)',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'AIRBAG',
      icon: Icons.airline_seat_recline_extra_rounded,
      meaningArabic:
          'وحدة التحكم في الوسائد الهوائية رصدت خللاً في المنظومة ولن تفتح الوسائد عند وقوع حادث.',
      commonCauses: [
        'تلف شريط الستيرسو الحلزوني (Clockspring)',
        'فصل أو ارتخاء فيش الحساسات الموجودة تحت مقاعد السائق والراكب',
        'عطل في مشدات أحزمة الأمان المتفجرة (Seatbelt Pretensioner)',
        'خلل في كمبيوتر الوسائد الهوائية بعد حادث سابق',
      ],
      actionRequired:
          'يمكنك القيادة، ولكن احذر أن منظومة السلامة معطلة كلياً ولن تحميك في حال التصادم. يجب فحص كود العطل بجهاز الـ OBD-II وإصلاح التوصيلات بأسرع وقت.',
      associatedDTCs: ['B0001', 'B0010', 'B0028', 'B1000'],
      colorValue: 0xFFE53935,
    ),

    // 7. Electric Power Steering (EPS)
    DashboardLightItem(
      id: 'steering_eps',
      nameArabic: 'لمبة التوجيه الكهربائي (المقود EPS)',
      nameEnglish: 'Electric Power Steering (EPS)',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'EPS',
      icon: Icons.sports_motorsports_rounded,
      meaningArabic: 'تعطل موطور المساعدة الكهربائية في ستيرسو ومقود السيارة.',
      commonCauses: [
        'احتراق فيوز التوجيه الكهربائي العريض (EPS 60A/80A)',
        'عطل في حساس زاوية التوجيه (Steering Angle Sensor)',
        'سخونة زائدة في موطور الستيرسو الكهربائي',
      ],
      actionRequired:
          'الستيرسو سيصبح ثقيلاً ومتصلباً للغاية خصوصاً عند الوقوف والسرعات المنخفضة. قم بالقيادة بحذر شديد وباليدين معاً وتوجه لورشة الصيانة الكهربائية.',
      associatedDTCs: ['C1511', 'C1515', 'C1521', 'U0131'],
      colorValue: 0xFFE53935,
    ),

    // 8. ABS (Anti-lock Braking)
    DashboardLightItem(
      id: 'abs_system',
      nameArabic: 'لمبة مانع انغلاق الفرامل (ABS)',
      nameEnglish: 'Anti-lock Braking System (ABS)',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'ABS',
      icon: Icons.car_crash_rounded,
      meaningArabic:
          'نظام الفرامل الهيدروليكي العادي يعمل، ولكن ميزة منع انغلاق العجلات والتزحلق عند التوقف المفاجئ معطلة.',
      commonCauses: [
        'تلف أو اتساخ حساس سرعة دوران العجلات (Wheel Speed Sensor)',
        'انقطاع أو تلف أسلاك الحساس عند منطقة المزاطوريات والبراتشوات',
        'تلف حلقة الترس المسنن (ABS Tone Ring) بالهوب أو العكس',
        'عطل في بومبة أو بلوف الـ ABS الهيدروليكية',
      ],
      actionRequired:
          'يمكنك القيادة بحذر. تذكر أن السيارة قد تنزلق إذا ضغطت فرامل بقوة على طريق مبلل أو ترابي. حافظ على مسافة أمان مضاعفة حتى إصلاح الحساس.',
      associatedDTCs: ['C0035', 'C0040', 'C0045', 'C0050', 'C0245'],
      colorValue: 0xFFFDD835,
    ),

    // 9. ESP / TCS (Traction Control)
    DashboardLightItem(
      id: 'esp_tcs',
      nameArabic: 'لمبة مانع الانزلاق والتوازن (ESP / TCS)',
      nameEnglish: 'Electronic Stability Program / Traction Control',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'ESP_TCS',
      icon: Icons.alt_route_rounded,
      meaningArabic:
          'نظام التحكم في تماسك الإطارات والثبات الإلكتروني للمركبة غير متاح حالياً.',
      commonCauses: [
        'عطل في أحد حساسات الـ ABS المرتبطة بالعجلات',
        'عدم معايرة حساس زاوية الدومان (الستيرسو) بعد وزن الأذرعة',
        'تم إيقاف النظام يدوياً عبر زر (TCS OFF / ESP OFF)',
      ],
      actionRequired:
          'تحقق من زر إلغاء مانع الانزلاق. إذا بقيت اللمبة مشتعلة، فالنظام معطل ولن يتدخل لمنع دوران العجلات في الفراغ أو الانزلاق بالمنحنيات.',
      associatedDTCs: ['C0245', 'C0035', 'C1515', 'P0121'],
      colorValue: 0xFFFDD835,
    ),

    // 10. TPMS (Tire Pressure)
    DashboardLightItem(
      id: 'tpms_pressure',
      nameArabic: 'لمبة ضغط هواء الإطارات (TPMS)',
      nameEnglish: 'Tire Pressure Monitoring System',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'TPMS',
      icon: Icons.tire_repair_rounded,
      meaningArabic:
          'أحد الإطارات يعاني من انخفاض ملحوظ في ضغط الهواء عن الحد الموصى به من المصنع.',
      commonCauses: [
        'مسمار أو ثقب في الإطار يسبب تنفيساً بطيئاً للهواء',
        'تغير درجة حرارة الجو الخارجية وانكماش الهواء في الشتاء',
        'نفاد بطارية حساس البلف الداخلي للإطار',
      ],
      actionRequired:
          'توقف عند أقرب ورشة تصليح قومّات (بيلكانو/عجلات) وضبط ضغط الإطارات الأربعة (غالباً 32-35 PSI حسب ملصق باب السائق)، ولا تنس فحص العجلة الاحتياط (السبير).',
      associatedDTCs: ['C2111', 'C2112', 'C2113', 'C2114'],
      colorValue: 0xFFFDD835,
    ),

    // 11. Transmission Oil Temp
    DashboardLightItem(
      id: 'trans_temp',
      nameArabic: 'لمبة حرارة زيت الكمبيو الأوتوماتيك (AT Oil Temp)',
      nameEnglish: 'Automatic Transmission Fluid Temperature High',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.stopImmediately,
      symbolCode: 'AT_TEMP',
      icon: Icons.settings_rounded,
      meaningArabic:
          'زيت الكمبيو الأوتوماتيك وصل لدرجة حرارة مفرطة تهدد باحتراق الكلتشات.',
      commonCauses: [
        'سحب مقطورة ثقيلة أو القيادة في رمال صحراوية صعبة',
        'نقص أو اهتراء زيت الكمبيو وعدم تبديله منذ فترة طويلة',
        'انسداد مبرد زيت الكمبيو الخارجي أو رداتوري التبريد',
      ],
      actionRequired:
          '⛔ توقف في مكان آمن، ضع الكمبيو على وضع الوقوف (P)، واترك المحرك يعمل في وضع السيلانتي (الحد الأدنى للدوران) لتدوير الزيت وتبريده. لا تطفئ المحرك مباشرة لأن إطفاءه يوقف بومبة التبريد!',
      associatedDTCs: ['P0218', 'P0711', 'P0712', 'P0713'],
      colorValue: 0xFFE5A93C,
    ),

    // 12. Glow Plug / DPF (Diesel)
    DashboardLightItem(
      id: 'glow_dpf',
      nameArabic: 'لمبة شمعات تسخين الديزل / فيلترو المرميطة DPF',
      nameEnglish: 'Diesel Glow Plug / Particulate Filter (DPF)',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'GLOW_DPF',
      icon: Icons.waves_rounded,
      meaningArabic:
          'في محركات الديزل: إما أن شمعات التسخين بحاجة لانتظار أو أن فيلترو الكربون (DPF) مشبع بالدخان.',
      commonCauses: [
        'تلف شمعة تسخين ديزل (Glow Plug)',
        'انسداد فيلترو جزيئات الديزل نتيجة القيادة داخل المدينة لمسافات قصيرة',
        'خلل في حساس فرق الضغط على جانبي فيلترو المرميطة',
      ],
      actionRequired:
          'إذا كانت اللمبة خاصة بـ DPF: قم بالقيادة على طريق سريع بسرعة 80-100 كم/س لمدة 20 دقيقة للسماح للكمبيوتر بتنفيذ دورة التجديد الذاتي وحرق الكربون.',
      associatedDTCs: ['P0380', 'P0381', 'P2458', 'P2463'],
      colorValue: 0xFFFDD835,
    ),

    // 13. Brake Pad Wear
    DashboardLightItem(
      id: 'brake_pads',
      nameArabic: 'لمبة تآكل باطنيات ديسكو الفرامل',
      nameEnglish: 'Brake Pad Wear Indicator',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'PAD_WEAR',
      icon: Icons.disc_full_rounded,
      meaningArabic:
          'سماكة باطنيات الفرامل وصلت للحد الأدنى وحان موعد استبدالها.',
      commonCauses: [
        'تآكل بطانة الباطنيات واقتراب الحديد من ديسكو الفرامل',
        'تلف أو انقطاع حساس التآكل المثبت على الباطنيات',
      ],
      actionRequired:
          'قم بجدولة تغيير الباطنيات وفحص الديسكوات خلال الأيام القادمة لتفادي تلف الديسكوات ودفع تكلفة مسح أو خرط إضافية.',
      associatedDTCs: ['C1001', 'C1002'],
      colorValue: 0xFFFDD835,
    ),

    // 14. Gas Cap / EVAP
    DashboardLightItem(
      id: 'fuel_cap',
      nameArabic: 'لمبة غطاء تانكي البنزين (Gas Cap)',
      nameEnglish: 'Fuel Tank Cap Loose / EVAP Leak',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'GAS_CAP',
      icon: Icons.local_gas_station_rounded,
      meaningArabic:
          'تسريب في بخار البنزين من فتحة خزان الوقود أو عدم إحكام إغلاق الغطاء.',
      commonCauses: [
        'نسيان إغلاق غطاء التانكي بعد التعبئة',
        'عدم إغلاق الغطاء حتى سماع طقة الأمان (Click)',
        'تآكل أو تشقق جلدة العزل المطاطية لغطاء الوقود',
      ],
      actionRequired:
          'انزل وأحكم إغلاق غطاء التانكي جيداً حتى تسمع صوت الطقة. قد تحتاج السيارة يومين أو ثلاث دورات تشغيل حتى تنطفئ اللمبة تلقائياً.',
      associatedDTCs: ['P0455', 'P0456', 'P0457', 'P0440'],
      colorValue: 0xFFFDD835,
    ),

    // 15. Washer Fluid
    DashboardLightItem(
      id: 'washer_fluid',
      nameArabic: 'لمبة سائل مساحات الزجاج',
      nameEnglish: 'Low Windshield Washer Fluid',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'WASHER',
      icon: Icons.shower_rounded,
      meaningArabic:
          'انخفاض مستوى الماء في قربة رشاشات الزجاج الأمامي أو الخلفي.',
      commonCauses: ['نفاد ماء المساحات نتيجة الاستخدام المتكرر'],
      actionRequired:
          'افتح الكبوت وأعد ملء القربة بماء نظيف مع إضافة سائل تنظيف الزجاج.',
      associatedDTCs: [],
      colorValue: 0xFFFDD835,
    ),

    // 16. ECO Mode
    DashboardLightItem(
      id: 'eco_mode',
      nameArabic: 'مؤشر الوضع الاقتصادي (ECO)',
      nameEnglish: 'ECO Driving Indicator',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'ECO',
      icon: Icons.eco_rounded,
      meaningArabic:
          'مؤشر يوضح أن أسلوب قيادتك الحالي اقتصادي ومثالي لتوفير استهلاك الوقود.',
      commonCauses: ['الضغط الهادئ والمتزن على دواسة الوقود'],
      actionRequired:
          'علامة تشغيلية ممتازة وطبيعية تماماً ولا تستدعي أي إجراء.',
      associatedDTCs: [],
      colorValue: 0xFF43A047,
    ),

    // 17. Cruise Control
    DashboardLightItem(
      id: 'cruise_control',
      nameArabic: 'مؤشر مثبت السرعة (Cruise Control)',
      nameEnglish: 'Cruise Control System Active',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'CRUISE',
      icon: Icons.speed_rounded,
      meaningArabic: 'نظام تثبيت السرعة التلقائي مشغل ومضبوط على سرعة محددة.',
      commonCauses: ['الضغط على زر SET / CRUISE في المقود'],
      actionRequired:
          'حالة تشغيلية طبيعية. يلغى التثبيت فور الضغط على دواسة الفرامل.',
      associatedDTCs: [],
      colorValue: 0xFF43A047,
    ),

    // 18. High Beam
    DashboardLightItem(
      id: 'high_beam',
      nameArabic: 'مؤشر الضوء العالي (High Beam)',
      nameEnglish: 'High Beam Headlights Active',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'HIGH_BEAM',
      icon: Icons.highlight_rounded,
      meaningArabic: 'أنوار السيارة الأمامية في وضع الضوء العالي.',
      commonCauses: ['دفع ذراع الإضاءة للأمام'],
      actionRequired:
          'يرجى خفض الضوء إلى الواطي عند مواجهة سيارات قادمة لتفادي إبهار بصر السائقين.',
      associatedDTCs: [],
      colorValue: 0xFF1E88E5,
    ),
  ];

  /// Finds a light by its unique identifier
  static DashboardLightItem? getById(String id) {
    try {
      return allLights.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Searches lights by name, meaning, or associated DTC
  static List<DashboardLightItem> searchLights({
    String query = '',
    LightSeverity? severityFilter,
    String? dtcCode,
  }) {
    final cleanQuery = query.trim().toLowerCase();
    final cleanDtc = dtcCode?.trim().toUpperCase();

    return allLights.where((l) {
      if (severityFilter != null && l.severity != severityFilter) {
        return false;
      }

      if (cleanDtc != null && cleanDtc.isNotEmpty) {
        if (l.associatedDTCs.any((c) => c.toUpperCase().contains(cleanDtc))) {
          return true;
        }
      }

      if (cleanQuery.isEmpty) return true;

      final matchName = l.nameArabic.toLowerCase().contains(cleanQuery);
      final matchEn = l.nameEnglish.toLowerCase().contains(cleanQuery);
      final matchMeaning = l.meaningArabic.toLowerCase().contains(cleanQuery);
      final matchDtc = l.associatedDTCs.any(
        (c) => c.toLowerCase().contains(cleanQuery),
      );

      return matchName || matchEn || matchMeaning || matchDtc;
    }).toList();
  }

  /// Finds lights corresponding to a list of DTC fault codes
  static List<DashboardLightItem> findLightsForDTCs(List<String> dtcCodes) {
    final cleanCodes = dtcCodes.map((c) => c.trim().toUpperCase()).toSet();
    final result = <DashboardLightItem>[];

    for (final l in allLights) {
      if (l.associatedDTCs.any((c) => cleanCodes.contains(c.toUpperCase()))) {
        result.add(l);
      }
    }
    return result;
  }
}
