import 'package:flutter/material.dart';
import '../models/dashboard_light.dart';

class DashboardLightsRepository {
  static const List<DashboardLightItem> allLights = [
    // 1. Front fog lights
    DashboardLightItem(
      number: 1,
      id: 'front_fog_lights',
      nameArabic: 'ضوء الضباب (أمامي)',
      nameEnglish: 'Front Fog Lights Active',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'FOG_FR',
      icon: Icons.wb_cloudy_rounded,
      meaningArabic:
          'مصابيح الضباب الأمامية قيد التشغيل لإنارة الطريق في الأجواء المغبرة والضباب.',
      commonCauses: ['تشغيل سويتش مصابيح الضباب يدوياً أو تلقائياً'],
      actionRequired:
          'حالة تشغيلية عادية. أطفئها عند وضوح الرؤية لتوفير استهلاك اللمبات والبطارية.',
      associatedDTCs: [],
      colorValue: 0xFF43A047,
    ),

    // 2. Power steering EPS
    DashboardLightItem(
      number: 2,
      id: 'steering_eps',
      nameArabic: 'ضوء تحذير التوجيه المعزز (دومان / ستيرنج EPS)',
      nameEnglish: 'Power Steering System Warning',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'EPS',
      icon: Icons.sports_motorsports_rounded,
      meaningArabic:
          'تعطل موطور المساعدة الكهربائية أو منظومة الهيدروليك في ستيرسو ودومان السيارة.',
      commonCauses: [
        'احتراق فيوز التوجيه الكهربائي العريض (EPS Fuse)',
        'عطل في حساس زاوية التوجيه (Steering Angle Sensor)',
        'نقص زيت هيدروليك الستيرنج أو عطل موطور الدومان الكهربائي',
      ],
      actionRequired:
          'الستيرسو سيصبح ثقيلاً ومتصلباً للغاية خصوصاً عند الوقوف. قد بحذر شديد وباليدين معاً وتوجه لورشة الصيانة الكهربائية.',
      associatedDTCs: ['C1511', 'C1515', 'C1521', 'U0131'],
      colorValue: 0xFFE53935,
    ),

    // 3. Rear fog light
    DashboardLightItem(
      number: 3,
      id: 'rear_fog_light',
      nameArabic: 'ضوء الضباب (خلفي)',
      nameEnglish: 'Rear Fog Light Active',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'FOG_RR',
      icon: Icons.cloud_outlined,
      meaningArabic:
          'مصباح الضباب الخلفي شديد التوهج قيد التشغيل لتنبيه السيارات القادمة من الخلف.',
      commonCauses: ['تشغيل زر ضباب الخلفي في الأجواء الصعبة'],
      actionRequired:
          'أطفئه فور تحسن الرؤية لمنع إبهار ومضايقة سائقي السيارات في الخلف.',
      associatedDTCs: [],
      colorValue: 0xFFFDD835,
    ),

    // 4. Washer fluid
    DashboardLightItem(
      number: 4,
      id: 'washer_fluid',
      nameArabic: 'انخفاض سائل مساحات الزجاج',
      nameEnglish: 'Low Washer Fluid Level',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'WASHER',
      icon: Icons.shower_rounded,
      meaningArabic:
          'انخفاض مستوى الماء في قربة رشاشات الزجاج الأمامي أو الخلفي.',
      commonCauses: ['نفاد ماء المساحات نتيجة الاستخدام المتكرر أو تسريب بالقربة'],
      actionRequired:
          'افتح الكبوت وأعد تعبئة قربة المساحات بالماء مع سائل تنظيف الزجاج.',
      associatedDTCs: [],
      colorValue: 0xFFFDD835,
    ),

    // 5. Brake pad wear
    DashboardLightItem(
      number: 5,
      id: 'brake_pads',
      nameArabic: 'تنبيه تآكل باطنيات ديسكو الفرامل',
      nameEnglish: 'Brake Pad Wear Warning',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'PAD_WEAR',
      icon: Icons.disc_full_rounded,
      meaningArabic:
          'سماكة باطنيات الفرامل وصلت للحد الأدنى واقتربت من ملامسة ديسكوات العجلات.',
      commonCauses: [
        'تآكل مادة الاحتكاك في باطنيات الديسكو',
        'انقطاع أو تلف سلك حساس التآكل المثبت على الباطنيات',
      ],
      actionRequired:
          'توجه لورشة الميكانيكا لتغيير باطنيات الديسكو وتفادي خدش وتلف ديسكوات الفرامل.',
      associatedDTCs: ['C1001', 'C1002'],
      colorValue: 0xFFFDD835,
    ),

    // 6. Cruise control
    DashboardLightItem(
      number: 6,
      id: 'cruise_control',
      nameArabic: 'مثبت السرعة نشط (Cruise Control)',
      nameEnglish: 'Cruise Control System Active',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'CRUISE',
      icon: Icons.speed_rounded,
      meaningArabic:
          'نظام تثبيت السرعة التلقائي قيد العمل ومضبوط على سرعة السير الحالية.',
      commonCauses: ['الضغط على زر SET / CRUISE في المقود'],
      actionRequired:
          'حالة تشغيلية طبيعية. يلغى التثبيت فور لمس دواسة الفرامل.',
      associatedDTCs: [],
      colorValue: 0xFF43A047,
    ),

    // 7. Turn signals
    DashboardLightItem(
      number: 7,
      id: 'turn_signals',
      nameArabic: 'إشارات الانعطاف (فليشر / كودرو)',
      nameEnglish: 'Turn Signals / Direction Indicators',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'TURN_SIG',
      icon: Icons.compare_arrows_rounded,
      meaningArabic:
          'إشارات تغيير الاتجاه أو الفليشر الرباعي في حالة تشغيل ووميض.',
      commonCauses: [
        'تحريك ذراع الإشارة يميناً أو يساراً، أو الضغط على زر الفليشر الرباعي',
      ],
      actionRequired:
          'إذا كانت اللمبة ترمش بسرعة غير معتادة فهذا دليل على احتراق إحدى لمبات الإشارة الخارجية.',
      associatedDTCs: [],
      colorValue: 0xFF43A047,
    ),

    // 8. Rain and light sensor
    DashboardLightItem(
      number: 8,
      id: 'rain_light_sensor',
      nameArabic: 'حساس المطر والضوء',
      nameEnglish: 'Rain and Light Sensor Fault',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'RAIN_LIGHT',
      icon: Icons.grain_rounded,
      meaningArabic:
          'خلل في حساس المطر والإضاءة التلقائية المثبت خلف المرآة الوسطية بالزجاج الأمامي.',
      commonCauses: [
        'اتساخ أو كسر الزجاج الأمامي في موضع الحساس',
        'فصل فيش الحساس أو فقاعات هواء في لاصق الجل الخاص به',
      ],
      actionRequired:
          'نظف الزجاج الأمامي وتأكد من إمكانية تشغيل المساحات والإنارة يدوياً.',
      associatedDTCs: ['B1052', 'B1053'],
      colorValue: 0xFFFDD835,
    ),

    // 9. Winter mode
    DashboardLightItem(
      number: 9,
      id: 'winter_mode',
      nameArabic: 'وضع الشتاء والطقس البارد (Winter Mode)',
      nameEnglish: 'Winter Mode / Low Traction Program',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'WINTER',
      icon: Icons.ac_unit_rounded,
      meaningArabic:
          'تم تفعيل برنامج الشتاء في كمبيو السيارة لتقليل عزم الانطلاق ومنع انزلاق العجلات على الجليد أو الطين.',
      commonCauses: [
        'الضغط على زر W بجانب عصا الكمبيو أو انخفاض درجة الحرارة الخارجية',
      ],
      actionRequired:
          'وضع تشغيلي خاص بالانزلاق يجعل انطلاق الكمبيو بالغيار الثاني أو الثالث.',
      associatedDTCs: [],
      colorValue: 0xFF1E88E5,
    ),

    // 10. Information message
    DashboardLightItem(
      number: 10,
      id: 'info_message',
      nameArabic: 'مؤشر معلومات الشاشة (Info Message)',
      nameEnglish: 'Information Message Indicator',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'INFO_MSG',
      icon: Icons.info_outline_rounded,
      meaningArabic:
          'توجد رسالة معلوماتية أو تنبيه في شاشة لوحة العدادات (مثل فتح خزان الوقود أو تذكير معين).',
      commonCauses: ['وجود رسالة نصية غير مقروءة بشاشة الطبلون'],
      actionRequired:
          'تصفح أزرار شاشة الطبلون من الستيرسو لقراءة نص التنبيه.',
      associatedDTCs: [],
      colorValue: 0xFF1E88E5,
    ),

    // 11. Diesel glow plug
    DashboardLightItem(
      number: 11,
      id: 'glow_dpf',
      nameArabic: 'شمعات تسخين الديزل (Glow Plug)',
      nameEnglish: 'Diesel Glow Plug Warning',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'GLOW_PLUG',
      icon: Icons.waves_rounded,
      meaningArabic:
          'شمعات التسخين لمحرك الديزل قيد الإحماء، أو وجود خلل في دائرة شمعات التسخين إذا استمرت بعد التشغيل.',
      commonCauses: [
        'انتظار إحماء غرف الاحتراق قبل تشغيل الموتورينو',
        'تلف إحدى شمعات تسخين الديزل أو ريليه التحكم الخاص بها',
      ],
      actionRequired:
          'انتظر حتى تنطفئ اللمبة قبل تدوير المارش. إذا ظلت تومض أثناء السير فافحص شمعات التسخين بجهاز الكشف.',
      associatedDTCs: ['P0380', 'P0381', 'P0670', 'P0671'],
      colorValue: 0xFFFDD835,
    ),

    // 12. Frost / icy road
    DashboardLightItem(
      number: 12,
      id: 'frost_warning',
      nameArabic: 'تحذير الجليد والحرارة المنخفضة',
      nameEnglish: 'Frost / Icy Road Warning',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'FROST',
      icon: Icons.severe_cold_rounded,
      meaningArabic:
          'درجة الحرارة الخارجية انخفضت تحت 4 درجات مئوية واحتمال وجود صقيع أو جليد بالطريق.',
      commonCauses: ['انخفاض حرارة الجو الخارجية المسجلة بحساس المرآة'],
      actionRequired:
          'قد بحذر وخفف السرعة في المنعطفات والجسور لتجنب انزلاق القومّات على الصقيع.',
      associatedDTCs: [],
      colorValue: 0xFFFDD835,
    ),

    // 13. Ignition key / immobilizer
    DashboardLightItem(
      number: 13,
      id: 'ignition_key_warning',
      nameArabic: 'مفتاح الإشعال / الإيموبلايزر (Immobilizer)',
      nameEnglish: 'Ignition Key / Immobilizer Warning',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'KEY_IMMO',
      icon: Icons.key_rounded,
      meaningArabic:
          'كمبيوتر السيارة لم يتعرف على شفرة مفتاح التشغيل أو وجود خلل بمنظومة الحماية ضد السرقة.',
      commonCauses: [
        'تلف شفرة المفتاح أو ضعف حلقة الهوائي بقفل السويتش',
        'عدم مطابقة كود المفتاح مع كمبيوتر المحرك (ECU)',
      ],
      actionRequired:
          'جرب المفتاح الاحتياطي، وإذا لم يدور المحرك فيجب إعادة برمجة شفرة المفتاح.',
      associatedDTCs: ['B3040', 'B3055', 'P1610', 'P1614'],
      colorValue: 0xFFFDD835,
    ),

    // 14. Key not detected
    DashboardLightItem(
      number: 14,
      id: 'key_not_detected',
      nameArabic: 'المفتاح الذكي غير موجود بالسيارة',
      nameEnglish: 'Smart Key Not Detected',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'KEY_ABSENT',
      icon: Icons.key_off_rounded,
      meaningArabic:
          'السيارة بنظام البصمة ولم يتم رصد ريموت المفتاح داخل المقصورة أثناء التشغيل أو القيادة.',
      commonCauses: [
        'المفتاح خارج السيارة أو في جيب شخص غادر المركبة',
        'نفاد حجر (بطارية) الريموت',
        'تشويش لاسلكي على حساسات الاستقبال الداخلية',
      ],
      actionRequired:
          'تأكد من وجود الريموت داخل المقصورة، أو قربه من زر التشغيل مباشرة للطوارئ.',
      associatedDTCs: ['B13D3', 'B1A56'],
      colorValue: 0xFFFDD835,
    ),

    // 15. Key fob battery low
    DashboardLightItem(
      number: 15,
      id: 'key_fob_battery',
      nameArabic: 'بطارية الريموت منخفضة',
      nameEnglish: 'Key Fob Battery Low',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'KEY_BATT',
      icon: Icons.battery_charging_full_rounded,
      meaningArabic:
          'حجر (بطارية) ريموت المفتاح الذكي ضعيفة وتوشك على النفاد.',
      commonCauses: ['استهلاك شحنة بطارية الريموت بعد فترة استخدام طويلة'],
      actionRequired:
          'قم بفتح الريموت واستبدال بطارية الزر (غالباً CR2032) لتفادي صعوبة فتح وتشغيل السيارة.',
      associatedDTCs: ['B13D5'],
      colorValue: 0xFFFDD835,
    ),

    // 16. Distance / radar collision warning
    DashboardLightItem(
      number: 16,
      id: 'distance_collision_warning',
      nameArabic: 'تحذير مسافة الأمان والرادار',
      nameEnglish: 'Distance Warning / Collision Alert',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'COLLISION',
      icon: Icons.car_crash_rounded,
      meaningArabic:
          'اقتراب خطر وسريع من السيارة التي أمامك، أو اتساخ رادار الصدام الأمامي.',
      commonCauses: [
        'عدم ترك مسافة أمان كافية مع المركبة الأمامية',
        'تراكم الطين أو الغبار على رادار الصدام الأمامي أو كاميرا الزجاج',
      ],
      actionRequired:
          'اضغط الفرامل فوراً وزد مسافة الأمان، ونظف حساس الرادار بالصدام الأمامي.',
      associatedDTCs: ['C1A14', 'C1A16'],
      colorValue: 0xFFE53935,
    ),

    // 17. Press clutch
    DashboardLightItem(
      number: 17,
      id: 'press_clutch',
      nameArabic: 'اضغط دواسة الدبرياج (الكلتش)',
      nameEnglish: 'Press Clutch Pedal Indicator',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'CLUTCH_PED',
      icon: Icons.do_not_step_rounded,
      meaningArabic:
          'تنبيه يطلب الضغط بالكامل على دواسة الدبرياج (الكلتش) ليسمح كمبيوتر السيارة بتشغيل المحرك.',
      commonCauses: ['نظام أمان يمنع دوران الموتورينو إلا عند فصل الكلتش'],
      actionRequired:
          'اضغط دواسة الكلتش حتى النهاية ثم اضغط زر أو سويتش التشغيل.',
      associatedDTCs: [],
      colorValue: 0xFF43A047,
    ),

    // 18. Press brake
    DashboardLightItem(
      number: 18,
      id: 'press_brake',
      nameArabic: 'اضغط دواسة الفرامل',
      nameEnglish: 'Press Brake Pedal Indicator',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'BRAKE_PED',
      icon: Icons.pan_tool_alt_rounded,
      meaningArabic:
          'مؤشر يطلب الضغط على دواسة الفرامل لتحرير عصا الكمبيو من وضع (P) أو لبدء التشغيل.',
      commonCauses: ['قفل أمان كمبيو الأوتوماتيك والتشغيل'],
      actionRequired:
          'اضغط على دواسة الفرامل قبل تحريك عصا الكمبيو أو الضغط على زر البصمة.',
      associatedDTCs: [],
      colorValue: 0xFF43A047,
    ),

    // 19. Steering lock
    DashboardLightItem(
      number: 19,
      id: 'steering_lock',
      nameArabic: 'قفل دومان / ستيرنج التوجيه',
      nameEnglish: 'Steering Column Lock Warning',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'STR_LOCK',
      icon: Icons.lock_rounded,
      meaningArabic:
          'خلل في قفل الستيرسو الكهربائي (ESL) أو صعوبة فك القفل الميكانيكي للمقود.',
      commonCauses: [
        'ضغط العجلات على الرصيف مما يشد قفل الستيرسو',
        'تلف موطور قفل عمود التوجيه الإلكتروني (ELV/ESL)',
      ],
      actionRequired:
          'حرك عجلة الستيرسو يميناً ويساراً مع الضغط على زر التشغيل لتحرير القفل الميكانيكي.',
      associatedDTCs: ['B1026', 'B2570', 'U0140'],
      colorValue: 0xFFFDD835,
    ),

    // 20. High beam
    DashboardLightItem(
      number: 20,
      id: 'high_beam',
      nameArabic: 'الضوء العالي (High Beam)',
      nameEnglish: 'High Beam Headlights Active',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'HIGH_BEAM',
      icon: Icons.highlight_rounded,
      meaningArabic:
          'الفنارات الأمامية للسيارة مشتغلة على وضع الضوء العالي الكاشف.',
      commonCauses: ['دفع ذراع الإضاءة بالستيرسو للأمام'],
      actionRequired:
          'قم بخفض الضوء للواطي عند وجود سيارات قادمة في الاتجاه المعاكس.',
      associatedDTCs: [],
      colorValue: 0xFF1E88E5,
    ),

    // 21. Tire pressure (TPMS)
    DashboardLightItem(
      number: 21,
      id: 'tpms_pressure',
      nameArabic: 'انخفاض ضغط هواء القومّات (TPMS)',
      nameEnglish: 'Tire Pressure Monitoring Warning',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'TPMS',
      icon: Icons.tire_repair_rounded,
      meaningArabic:
          'إحدى قومّات (عجلات) السيارة تعاني من نقص واضح في ضغط الهواء.',
      commonCauses: [
        'وجود مسمار أو تسريب بطيء بهواء القومة',
        'تغير درجة حرارة الجو أو ضعف بطارية حساس البلف الداخلي',
      ],
      actionRequired:
          'توجه لورشة القومّات (البيلكانو) واضبط الضغط على 32-35 PSI وتفقد السبير (العجلة الاحتياط).',
      associatedDTCs: ['C2111', 'C2112', 'C2113', 'C2114'],
      colorValue: 0xFFFDD835,
    ),

    // 22. Side lights
    DashboardLightItem(
      number: 22,
      id: 'side_lights',
      nameArabic: 'ضوء الموقف والأنوار الجانبية',
      nameEnglish: 'Side / Parking Lights Active',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'SIDE_LGT',
      icon: Icons.light_mode_rounded,
      meaningArabic:
          'أنوار الموقف والإنارة الصغيرة الجانبية (السمول لايت) قيد التشغيل.',
      commonCauses: ['تدوير مفتاح الإضاءة للتكة الأولى'],
      actionRequired:
          'حالة تشغيلية عادية. أطفئها عند ركن السيارة لمنع تفريغ شحن البطارية.',
      associatedDTCs: [],
      colorValue: 0xFF43A047,
    ),

    // 23. Bulb failure
    DashboardLightItem(
      number: 23,
      id: 'bulb_failure',
      nameArabic: 'عطل في أحد المصابيح الخارجية',
      nameEnglish: 'Exterior Light Bulb Failure',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'BULB_FAIL',
      icon: Icons.lightbulb_rounded,
      meaningArabic:
          'كمبيوتر الإضاءة رصد احتراق لمبة خارجية (فنار، إشارة، فرامل، أو لمبة اللوحة).',
      commonCauses: [
        'احتراق فتيلة إحدى اللمبات الخارجية',
        'تركيب لمبات LED تجارية بدون مقاومة كانباس (Canbus error)',
      ],
      actionRequired:
          'قم بجولة حول السيارة وتفقد جميع المصابيح واستبدل اللمبة المحترقة.',
      associatedDTCs: ['B3881', 'B3882', 'B3883'],
      colorValue: 0xFFFDD835,
    ),

    // 24. Brake system warning
    DashboardLightItem(
      number: 24,
      id: 'brake_system',
      nameArabic: 'تحذير منظومة الفرامل وزيت البريك (!)',
      nameEnglish: 'Brake System Warning',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.stopImmediately,
      symbolCode: 'BRAKE_SYS',
      icon: Icons.error_rounded,
      meaningArabic:
          'نقص حاد في مستوى زيت الفرامل أو هبوط الضغط الهيدروليكي بمنظومة الفرامل.',
      commonCauses: [
        'تسريب في أنابيب زيت الفرامل أو بستم العجلات',
        'تآكل باطنيات الديسكو لحد أفرغ مخزون العلبة',
        'عطل في سيرفو تعزيز الفرامل',
      ],
      actionRequired:
          '⛔ توقف فوراً ولا تقم بالقيادة إذا كانت الدواسة إسفنجية أو تهبط للأرضية! افحص علبة زيت الفرامل وتأكد من عدم وجود تسريب.',
      associatedDTCs: ['C0040', 'C0045', 'C0049'],
      colorValue: 0xFFE53935,
    ),

    // 25. DPF filter
    DashboardLightItem(
      number: 25,
      id: 'dpf_filter',
      nameArabic: 'فيلترو المرميطة DPF ديزل',
      nameEnglish: 'Diesel Particulate Filter (DPF) Warning',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'DPF_FILT',
      icon: Icons.filter_alt_rounded,
      meaningArabic:
          'انسداد أو تراكم السخام والكربون في فيلترو جزيئات المرميطة (DPF) بمحركات الديزل.',
      commonCauses: [
        'كثرة المشاوير القصيرة داخل المدينة دون إتاحة فرصة للتنظيف الذاتي',
        'خلل في حساس الضغط التفاضلي لمرميطة الديزل',
      ],
      actionRequired:
          'قم بالقيادة على طريق سريع بسرعة ثابتة (80-100 كم/س) لمدة 20 دقيقة لإكمال دورة الحرق التلقائي.',
      associatedDTCs: ['P2458', 'P2463', 'P242F'],
      colorValue: 0xFFFDD835,
    ),

    // 26. Trailer hitch
    DashboardLightItem(
      number: 26,
      id: 'trailer_hitch',
      nameArabic: 'قفل سحب المقطورة',
      nameEnglish: 'Trailer Hitch / Towbar Warning',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'TOW_HITCH',
      icon: Icons.rv_hookup_rounded,
      meaningArabic:
          'قفل وصلة سحب المقطورة الخلفية غير مغلق بإحكام أو وجود عطل في فيش توصيلات المقطورة الكهربائية.',
      commonCauses: [
        'عدم تثبيت هوك السحب الخلفي بالشكل الصحيح',
        'تماس أو خلل في فيشة إضاءة العربة المجرورة',
      ],
      actionRequired:
          'تأكد من إحكام إغلاق قفل هوك المقطورة وسلامة التوصيلات قبل التحرك.',
      associatedDTCs: ['B10E7'],
      colorValue: 0xFFFDD835,
    ),

    // 27. Air suspension
    DashboardLightItem(
      number: 27,
      id: 'air_suspension',
      nameArabic: 'عطل التعليق الهوائي / الهيدروليكي',
      nameEnglish: 'Air Suspension Fault',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'AIR_SUSP',
      icon: Icons.height_rounded,
      meaningArabic:
          'خلل في كمبروسر أو بالونات الهواء بمنظومة التعليق الهوائي وانخفاض مستوى ارتفاع السيارة.',
      commonCauses: [
        'تنسيم أو ثقب في بالونة الهواء الخاصة بالتعليق',
        'تلف كمبروسر الهواء أو بلف توزيع الارتفاع',
        'عطل في حساس مستوى الارتفاع المثبت بالمزاطوريات',
      ],
      actionRequired:
          'قد بحذر وتجنب المطبات العالية وتوجه لورشة متخصصة لفحص تسريب بالونات التعليق.',
      associatedDTCs: ['C1A20', 'C1A13', 'C1A30'],
      colorValue: 0xFFFDD835,
    ),

    // 28. Lane departure
    DashboardLightItem(
      number: 28,
      id: 'lane_departure',
      nameArabic: 'تحذير الخروج عن المسار',
      nameEnglish: 'Lane Departure Warning',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'LANE_DEP',
      icon: Icons.add_road_rounded,
      meaningArabic:
          'السيارة انحرفت عن مسار الطريق بدون تشغيل إشارة الانعطاف، أو تعطل كاميرا تتبع المسار.',
      commonCauses: [
        'تجاوز الخطوط البيضاء دون استخدام إشارة الستيرسو',
        'اتساخ كاميرا التتبع المثبتة أعلى الزجاج الأمامي',
      ],
      actionRequired:
          'انتبه لمسار الطريق، ونظف الزجاج الأمامي أمام الكاميرا.',
      associatedDTCs: ['C1A67', 'B12BE'],
      colorValue: 0xFFFDD835,
    ),

    // 29. Catalytic converter overheat
    DashboardLightItem(
      number: 29,
      id: 'catalytic_converter',
      nameArabic: 'سخونة علبة البيئة بالمرميطة',
      nameEnglish: 'Catalytic Converter Overheating',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.stopImmediately,
      symbolCode: 'CAT_CONV',
      icon: Icons.local_fire_department_rounded,
      meaningArabic:
          'ارتفاع خطير في حرارة علبة البيئة (دبة التلوث) بالمرميطة نتيجة وصول بنزين نيء غير محترق إليها.',
      commonCauses: [
        'فطفطة قوية في الشمعات أو البوبينات (Misfire) تسرب الوقود للمرميطة',
        'انسداد شديد في حجر البيئة وتجمع الكربون',
      ],
      actionRequired:
          '⛔ توقف فوراً وأطفئ المحرك! استمرار السير بهذا الوضع يؤدي لانصهار علبة البيئة واشتعال حريق أسفل السيارة.',
      associatedDTCs: ['P0420', 'P0421', 'P0430'],
      colorValue: 0xFFE53935,
    ),

    // 30. Seatbelt reminder
    DashboardLightItem(
      number: 30,
      id: 'seatbelt_warning',
      nameArabic: 'تذكير ربط حزام الأمان',
      nameEnglish: 'Seatbelt Reminder',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'SEATBELT',
      icon: Icons.airline_seat_recline_normal_rounded,
      meaningArabic:
          'السائق أو أحد الركاب لم يقم بربط حزام الأمان أثناء حركة السيارة.',
      commonCauses: [
        'عدم إدخال لسان حزام الأمان في القفل',
        'وضع حقائب أو حمولة ثقيلة على مقعد الراكب تحفز حساس الوزن',
      ],
      actionRequired: 'اربط حزام الأمان لسلامتك وتوقف جرس الإنذار.',
      associatedDTCs: ['B0050', 'B0052'],
      colorValue: 0xFFE53935,
    ),

    // 31. Parking brake applied
    DashboardLightItem(
      number: 31,
      id: 'parking_brake',
      nameArabic: 'فرملة اليد / الجلنط مشدودة',
      nameEnglish: 'Parking Brake Applied',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'PARK_BRK',
      icon: Icons.pause_circle_filled_rounded,
      meaningArabic:
          'فرملة اليد (الجلنط / البريك) مشدودة ومفعلة حالياً لمنع حركة السيارة.',
      commonCauses: [
        'فرملة اليد مرفوعة باليد أو مضغوطة بالقدم أو مفعلة إلكترونياً (EPB)',
        'عطل في حساس سويتش فرملة اليد يجعله عالقاً',
      ],
      actionRequired:
          'أنزل فرملة اليد بالكامل قبل الانطلاق لتفادي احتراق وتآكل باطنيات الفرامل الخلفية.',
      associatedDTCs: ['C1100'],
      colorValue: 0xFFE53935,
    ),

    // 32. Battery / Alternator charge
    DashboardLightItem(
      number: 32,
      id: 'battery_charge',
      nameArabic: 'عطل منظومة الشحن والدينمو والبطارية',
      nameEnglish: 'Alternator / Battery Charging Fault',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.stopImmediately,
      symbolCode: 'BATTERY',
      icon: Icons.battery_alert_rounded,
      meaningArabic:
          'دينمو الشحن لا يولد الكهرباء المطلوبة والمحرك والأنظمة تعمل على طاقة البطارية المخزونة فقط.',
      commonCauses: [
        'انقطاع أو ارتخاء قايش الدينمو والمحرك الخارجي',
        'تلف فحمات أو ريليه منظم شحن الدينمو',
        'ارتخاء أو كربنة كابلات وأصابع البطارية',
      ],
      actionRequired:
          'أطفئ المكيف والإنارة والراديو وتوجه لأقرب كهربائي سيارات، السيارة ستتوقف كلياً عند نفاد شحن البطارية.',
      associatedDTCs: ['P0562', 'P0620', 'P0622', 'P2503'],
      colorValue: 0xFFE53935,
    ),

    // 33. Parking sensors
    DashboardLightItem(
      number: 33,
      id: 'parking_sensors',
      nameArabic: 'حساسات ركن واصطفاف السيارة',
      nameEnglish: 'Parking Distance Sensors',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'PARK_SENS',
      icon: Icons.sensors_rounded,
      meaningArabic:
          'حساسات الصدام الخلفي أو الأمامي تعمل للمساعدة في صف وركن السيارة، أو معطلة إذا كانت ثابتة بإنذار.',
      commonCauses: [
        'الرجوع للخلف والاقتراب من عائق أو جدار',
        'تراكم الأوساخ أو الطين على أحد حساسات الصدام',
      ],
      actionRequired:
          'نظف الحساسات بالصدام وتأكد من عمل التنبيه الصوتي عند الاقتراب من الحواجز.',
      associatedDTCs: ['B1240', 'B1242'],
      colorValue: 0xFF43A047,
    ),

    // 34. Service due
    DashboardLightItem(
      number: 34,
      id: 'service_due',
      nameArabic: 'موعد السيرفيس والصيانة الدورية',
      nameEnglish: 'Service Due / Maintenance Required',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'SERVICE',
      icon: Icons.build_rounded,
      meaningArabic:
          'انتهت المسافة أو المدة المحددة لتبديل زيت المحرك والفلاتر وحان موعد الصيانة الدورية.',
      commonCauses: [
        'تجاوز المسافة المحددة للزيت المبرمجة بالكمبيوتر (مثل 5,000 أو 10,000 كم)',
      ],
      actionRequired:
          'قم بإجراء السيرفيس وتغيير الزيت وفيلترو الزيت ثم تصفير عداد الصيانة (Service Reset).',
      associatedDTCs: [],
      colorValue: 0xFFFDD835,
    ),

    // 35. Adaptive front lighting (AFS)
    DashboardLightItem(
      number: 35,
      id: 'adaptive_headlights',
      nameArabic: 'نظام الإضاءة التكيفي AFS',
      nameEnglish: 'Adaptive Front Lighting System (AFS)',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'AFS_LIGHT',
      icon: Icons.auto_awesome_rounded,
      meaningArabic:
          'عطل في موطور توجيه عدسات الفنارات التي تلتف مع حركة الدومان لإنارة المنعطفات.',
      commonCauses: [
        'عطل في موطور توجيه العدسة داخل الفنار',
        'خلل في حساس زاوية المقود أو حساس ميزان الإضاءة بالهيكل',
      ],
      actionRequired:
          'ستعمل المصابيح بشكل عادي ولكن بدون الالتفاف التلقائي بالمنعطفات.',
      associatedDTCs: ['B1081', 'B2580'],
      colorValue: 0xFFFDD835,
    ),

    // 36. Headlight leveling
    DashboardLightItem(
      number: 36,
      id: 'headlight_leveling',
      nameArabic: 'ميزان وزاوية ارتفاع الفنارات',
      nameEnglish: 'Headlight Range Control',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'HEAD_LVL',
      icon: Icons.swap_vert_rounded,
      meaningArabic:
          'عطل في موطور ضبط زاوية ارتفاع الضوء التلقائي حسب حمولة السيارة الخلفية.',
      commonCauses: [
        'عطل حساس ميزان الارتفاع المثبت على المزاطوريات الخلفية',
        'تلف موطور الميزان الكهربائي داخل جرم الفنار',
      ],
      actionRequired:
          'افحص فيش حساس ميزان الهيكل بالخلف ومحركات الفنارات.',
      associatedDTCs: ['B1090', 'B3410'],
      colorValue: 0xFFFDD835,
    ),

    // 37. Rear spoiler
    DashboardLightItem(
      number: 37,
      id: 'rear_spoiler',
      nameArabic: 'جناح / سبويلر خلفي معطل',
      nameEnglish: 'Rear Spoiler Warning',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'SPOILER',
      icon: Icons.flight_takeoff_rounded,
      meaningArabic:
          'الجناح (السبويلر) الخلفي الكهربائي المتحرك لم يفتح أو لم يغلق بالوضع الصحيح عند السرعات العالية.',
      commonCauses: [
        'عطل في موطور فتح وقفل السبويلر',
        'وجود تراب أو عائق ميكانيكي يمنع حركة الجناح الخلفي',
      ],
      actionRequired:
          'تجنب السرعات العالية جداً لأن الجناح مسؤول عن ثبات مؤخرة السيارة الهوائي.',
      associatedDTCs: ['B1320'],
      colorValue: 0xFFFDD835,
    ),

    // 38. Convertible roof
    DashboardLightItem(
      number: 38,
      id: 'convertible_roof',
      nameArabic: 'سقف الكابريوليه المتحرك',
      nameEnglish: 'Convertible Roof Warning',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'ROOF_OPEN',
      icon: Icons.roofing_rounded,
      meaningArabic:
          'سقف السيارة القابل للطي غير مقفل بإحكام أو واجه عطلاً أثناء الفتح والإغلاق.',
      commonCauses: [
        'عدم اكتمال دورة إغلاق وربط السقف بالزجاج الأمامي',
        'انخفاض ضغط بومبة هيدروليك السقف أو عطل ميكرو-سويتش الأمان',
      ],
      actionRequired:
          'توقف وأكمل إغلاق السقف بالكامل حتى تسمع صوت تكة التأمين وانطفاء اللمبة.',
      associatedDTCs: ['B1300', 'B1305'],
      colorValue: 0xFFFDD835,
    ),

    // 39. Airbag SRS fault
    DashboardLightItem(
      number: 39,
      id: 'airbag_srs',
      nameArabic: 'عطل الوسائد الهوائية (الإيرباق SRS)',
      nameEnglish: 'Airbag (SRS) Fault Warning',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'AIRBAG',
      icon: Icons.airline_seat_recline_extra_rounded,
      meaningArabic:
          'كمبيوتر الوسائد الهوائية رصد خللاً في الدائرة والوسائد لن تفتح عند وقوع حادث اصطدام.',
      commonCauses: [
        'تلف شريط الستيرسو الحلزوني (Clockspring)',
        'ارتخاء فيش الحساسات الموجودة تحت كراسي السائق والراكب',
        'عطل في مشدات أحزمة الأمان المتفجرة',
      ],
      actionRequired:
          'توجه لورشة فحص الـ OBD-II لإصلاح الخلل، منظومة الحماية من الحوادث معطلة حالياً.',
      associatedDTCs: ['B0001', 'B0010', 'B0028', 'B1000'],
      colorValue: 0xFFE53935,
    ),

    // 40. Electric handbrake fault
    DashboardLightItem(
      number: 40,
      id: 'handbrake_fault',
      nameArabic: 'عطل في فرملة اليد الكهربائية',
      nameEnglish: 'Electric Parking Brake Fault',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'EPB_FAULT',
      icon: Icons.handyman_rounded,
      meaningArabic:
          'خلل في موطورات أو كمبيوتر منظومة فرملة اليد الكهربائية (EPB).',
      commonCauses: [
        'عطل موطور كاليبر الفرامل الكهربائي في العجلات الخلفية',
        'عطل في زر سويتش البريك الكهربائي بالكونسول',
      ],
      actionRequired:
          'قد بحذر ولا تركن في منحدرات شديدة بدون وضع عصا الكمبيو على (P) وتثبيت العجلات بحجر.',
      associatedDTCs: ['C1555', 'C2200'],
      colorValue: 0xFFFDD835,
    ),

    // 41. Water in fuel filter
    DashboardLightItem(
      number: 41,
      id: 'water_in_fuel',
      nameArabic: 'وجود ماء في فيلترو الوقود',
      nameEnglish: 'Water in Fuel Filter Warning',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'WATER_FUEL',
      icon: Icons.water_drop_outlined,
      meaningArabic:
          'تراكم الماء المكثف في أسفل فيلترو المازوت (الديزل) أو البنزين وتجاوزه الحد المسموح.',
      commonCauses: [
        'تعبئة وقود رديء يحتوي على نسبة ماء من المحطة',
        'تكاثف الرطوبة داخل خزان الوقود في الشتاء',
      ],
      actionRequired:
          'افتح بلف تصريف الماء اليدوي أسفل فيلترو الوقود لتفريغ الماء، أو استبدل الفيلترو لتفادي تلف البخاخات وبومبة الديزل.',
      associatedDTCs: ['P2269', 'P2264'],
      colorValue: 0xFFFDD835,
    ),

    // 42. Passenger airbag deactivated
    DashboardLightItem(
      number: 42,
      id: 'passenger_airbag_off',
      nameArabic: 'إيقاف تشغيل وسادة الراكب الهوائية',
      nameEnglish: 'Passenger Airbag Deactivated',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'AIRBAG_OFF',
      icon: Icons.person_off_rounded,
      meaningArabic:
          'وسادة الهواء للراكب الأمامي مفصولة يدوياً بالمفتاح (مخصصة عند وضع كرسي أطفال بالجهة الأمامية).',
      commonCauses: [
        'إيقاف الوسادة عبر سويتش المفتاح الجانبي بباب الراكب أو الطبلون',
      ],
      actionRequired:
          'أعد تشغيلها بالمفتاح إذا كان يجلس شخص بالغ في المقعد الأمامي لضمان حمايته.',
      associatedDTCs: [],
      colorValue: 0xFFFDD835,
    ),

    // 43. General mechanical fault
    DashboardLightItem(
      number: 43,
      id: 'mechanical_fault',
      nameArabic: 'عطل ميكانيكي عام (مفتاح صيانة)',
      nameEnglish: 'General Mechanical / Powertrain Fault',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'MECH_FAULT',
      icon: Icons.construction_rounded,
      meaningArabic:
          'كمبيوتر السيارة رصد عطلاً عاماً في أحد أنظمة الحركة والميكانيكا يستدعي الفحص بجهاز التشخيص.',
      commonCauses: [
        'عطل في أحد حساسات المحرك أو كمبيو السيارة',
        'خلل كهربائي في دائرة التحكم الإلكتروني بالدواسة',
      ],
      actionRequired:
          'افحص السيارة بجهاز كشف الأعطال لمعرفة الكود الدقيق والخلل المسجل.',
      associatedDTCs: ['P0606', 'P1600'],
      colorValue: 0xFFFDD835,
    ),

    // 44. Low beam headlights
    DashboardLightItem(
      number: 44,
      id: 'low_beam',
      nameArabic: 'الضوء الواطي (الفنارات العادية)',
      nameEnglish: 'Low Beam Headlights Active',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'LOW_BEAM',
      icon: Icons.light_mode_outlined,
      meaningArabic:
          'الفنارات الأمامية بالضوء الواطي النظامي مشتغلة لإنارة الطريق العادية ليلاً.',
      commonCauses: [
        'تشغيل الإنارة يدوياً أو عبر الحساس التلقائي (AUTO)',
      ],
      actionRequired: 'حالة تشغيلية طبيعية وآمنة للقيادة الليلية.',
      associatedDTCs: [],
      colorValue: 0xFF43A047,
    ),

    // 45. Engine air filter clogged
    DashboardLightItem(
      number: 45,
      id: 'air_filter_clogged',
      nameArabic: 'انسداد فيلترو الهواء',
      nameEnglish: 'Engine Air Filter Clogged',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'AIR_FILT',
      icon: Icons.air_rounded,
      meaningArabic:
          'فيلترو هواء المحرك مشبع بالغبار والأتربة ويخنق تنفس واحتراق المحرك.',
      commonCauses: [
        'تراكم الغبار والرمال في فيلترو الهواء نتيجة السير في طرق ترابية',
        'انتهاء العمر الافتراضي لفيلترو الهواء',
      ],
      actionRequired:
          'افتح علبة الفيلترو ونظفه بضغط الهواء أو استبدله بآخر أصلي لتحسين سحب المحرك وتوفير الوقود.',
      associatedDTCs: ['P0101', 'P0171'],
      colorValue: 0xFFFDD835,
    ),

    // 46. Eco driving mode
    DashboardLightItem(
      number: 46,
      id: 'eco_mode',
      nameArabic: 'مؤشر وضع توفير الوقود (ECO)',
      nameEnglish: 'Eco Driving Mode',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'ECO',
      icon: Icons.eco_rounded,
      meaningArabic:
          'أسلوب القيادة الحالي اقتصادي ومثالي لتوفير استهلاك الوقود وحماية البيئة.',
      commonCauses: [
        'الضغط الهادئ والمتزن على دواسة البنزين وسلاسة تبديل الكمبيو',
      ],
      actionRequired:
          'حالة تشغيلية طبيعية ومثالية ولا تتطلب أي إجراء.',
      associatedDTCs: [],
      colorValue: 0xFF43A047,
    ),

    // 47. Hill descent control DAC
    DashboardLightItem(
      number: 47,
      id: 'hill_descent',
      nameArabic: 'نظام المساعدة على نزول المنحدرات (DAC)',
      nameEnglish: 'Hill Descent Control (DAC)',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'HDC_DAC',
      icon: Icons.downhill_skiing_rounded,
      meaningArabic:
          'نظام التحكم التلقائي بسرعة النزول في المنحدرات الشديدة قيد العمل عبر الفرملة الذاتية للعجلات.',
      commonCauses: [
        'الضغط على زر النزول من المنحدرات (DAC / HDC) عند النزول في عقبة أو منزلق',
      ],
      actionRequired:
          'اترك السيارة تتحكم بالفرملة تلقائياً وركز فقط على توجيه عجلة الستيرسو.',
      associatedDTCs: [],
      colorValue: 0xFF43A047,
    ),

    // 48. Engine coolant temperature high
    DashboardLightItem(
      number: 48,
      id: 'coolant_temp',
      nameArabic: 'ارتفاع حرارة المحرك وسائل التبريد',
      nameEnglish: 'Engine Coolant Temperature High',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.stopImmediately,
      symbolCode: 'TEMP_HIGH',
      icon: Icons.thermostat_rounded,
      meaningArabic:
          'سائل تبريد المحرك تجاوز درجة الغليان الآمنة والمحرك في حالة سخونة مفرطة.',
      commonCauses: [
        'تسريب مية الرداتوري أو انقطاع أحد المناكوطيات (التوبوات)',
        'توقف مروحة تبريد الرداتوري (فيوز أو موطور المروحة)',
        'تعطل بلف الحرارة (الثرموستات) في وضع الإغلاق',
        'تلف بومبة الماء أو انقطاع قايش المحرك',
      ],
      actionRequired:
          '⛔ توقف فوراً في مكان آمن وأطفئ المحرك! لا تفتح غطاء الرداتوري إطلاقاً وهو ساخن لتجنب انفجار البخار وحروق الوجه واليدين. انتظر 20 دقيقة حتى يبرد تماماً.',
      associatedDTCs: ['P0217', 'P0117', 'P0118', 'P0480'],
      colorValue: 0xFFE53935,
    ),

    // 49. ABS warning
    DashboardLightItem(
      number: 49,
      id: 'abs_system_red',
      nameArabic: 'عطل منظومة مانع انغلاق الفرامل (ABS)',
      nameEnglish: 'ABS Anti-Lock Braking System Warning',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'ABS',
      icon: Icons.car_crash_rounded,
      meaningArabic:
          'نظام الـ ABS لمنع انغلاق العجلات والتزحلق عند التوقف المفاجئ معطل كلياً.',
      commonCauses: [
        'تلف أو اتساخ حساس سرعة دوران العجلات (Wheel Speed Sensor)',
        'انقطاع أسلاك الحساس عند منطقة المزاطوريات والبراتشوات',
        'تلف حلقة الترس المسنن (ABS Tone Ring) بالهوب أو العكس',
        'عطل في بومبة أو بلوف الـ ABS الهيدروليكية',
      ],
      actionRequired:
          'الفرامل العادية ستعمل ولكن السيارة ستنزلق وتدور حول نفسها إذا ضغطت فرامل بقوة على طريق مبلل أو ترابي. حافظ على مسافة أمان مضاعفة.',
      associatedDTCs: ['C0035', 'C0040', 'C0045', 'C0050', 'C0245'],
      colorValue: 0xFFE53935,
    ),

    // 50. Fuel filter restriction
    DashboardLightItem(
      number: 50,
      id: 'fuel_filter_restriction',
      nameArabic: 'انسداد فيلترو الديزل / الوقود',
      nameEnglish: 'Fuel Filter Restriction / Clogged',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'FUEL_FILT',
      icon: Icons.filter_rounded,
      meaningArabic:
          'انسداد فيلترو الوقود يسبب تقطيعاً وضعفاً في وصول البنزين أو الديزل للبخاخات.',
      commonCauses: [
        'تراكم الشوائب والرواسب من وقود المحطات داخل الفيلترو',
        'عدم استبدال فيلترو الوقود منذ مسافة طويلة',
      ],
      actionRequired:
          'استبدل فيلترو الوقود لتجنب إجهاد بومبة الوقود وضعف عزم المحرك وتقطيعه.',
      associatedDTCs: ['P0087', 'P0191'],
      colorValue: 0xFFFDD835,
    ),

    // 51. Door ajar
    DashboardLightItem(
      number: 51,
      id: 'door_ajar',
      nameArabic: 'أحد أبواب السيارة مفتوح',
      nameEnglish: 'Door Ajar Warning',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'DOOR_OPEN',
      icon: Icons.sensor_door_rounded,
      meaningArabic:
          'أحد أبواب السيارة الجانبية غير محكم الإغلاق ويهدد بفتحه أثناء السير.',
      commonCauses: [
        'عدم إغلاق الباب بقوة كافية',
        'عطل في سويتش حساس قفل الباب الداخلي',
      ],
      actionRequired:
          'توقف وأحكم إغلاق جميع الأبواب لسلامة الركاب وخاصة الأطفال.',
      associatedDTCs: ['B1401', 'B1402'],
      colorValue: 0xFFE53935,
    ),

    // 52. Engine hood open
    DashboardLightItem(
      number: 52,
      id: 'hood_open',
      nameArabic: 'غطاء المحرك (الكبوت) مفتوح',
      nameEnglish: 'Engine Hood / Bonnet Open',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.stopImmediately,
      symbolCode: 'HOOD_OPEN',
      icon: Icons.directions_car_rounded,
      meaningArabic:
          'غطاء المحرك الأمامي (الكبوت) غير مقفل باللسان الثانوي ويهدد بالطيران على الزجاج.',
      commonCauses: [
        'نسيان إغلاق الكبوت بعد فحص الزيت أو الماء',
        'عطل أو ارتخاء سلك وسوستة قفل الكبوت',
      ],
      actionRequired:
          '⛔ توقف فوراً وأقفل الكبوت جيداً بالضغط عليه حتى يطق القفل لمنع تطايره على الزجاج الأمامي وانعدام الرؤية أثناء السير.',
      associatedDTCs: ['B1380'],
      colorValue: 0xFFE53935,
    ),

    // 53. Low fuel level
    DashboardLightItem(
      number: 53,
      id: 'low_fuel',
      nameArabic: 'انخفاض مستوى الوقود بالتانكي',
      nameEnglish: 'Low Fuel Level Warning',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'LOW_FUEL',
      icon: Icons.local_gas_station_rounded,
      meaningArabic:
          'الوقود في خزان السيارة وصل لمستوى الاحتياطي الأخير (أقل من 50 كم سير).',
      commonCauses: ['استهلاك الوقود والاقتراب من قاع التانكي'],
      actionRequired:
          'توجه لأقرب محطة وقود لتعبئة التانكي لتفادي سحب بومبة الوقود للرواسب وتسخينها في القاع.',
      associatedDTCs: [],
      colorValue: 0xFFFDD835,
    ),

    // 54. Automatic transmission fault
    DashboardLightItem(
      number: 54,
      id: 'trans_temp',
      nameArabic: 'عطل أو سخونة كمبيو الأوتوماتيك',
      nameEnglish: 'Automatic Transmission Warning',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.stopImmediately,
      symbolCode: 'AT_FAULT',
      icon: Icons.settings_rounded,
      meaningArabic:
          'ارتفاع حرارة زيت الكمبيو الأوتوماتيك أو رصد خلل في البلوف الكهربائية (Solenoids).',
      commonCauses: [
        'نقص أو اهتراء زيت الكمبيو وعدم تغييره مع الفيلترو',
        'سحب أحمال ثقيلة أو القيادة في رمال صحراوية شاقة',
        'عطل في صمامات تبديل الغيارات داخل مخ الكمبيو',
      ],
      actionRequired:
          '⛔ توقف في مكان آمن، ضع الكمبيو على (P) واترك المحرك شغّالاً في وضع السيلانتي لتدوير الزيت وتبريده. لا تطفئ المحرك مباشرة.',
      associatedDTCs: ['P0218', 'P0700', 'P0711', 'P0750'],
      colorValue: 0xFFE5A93C,
    ),

    // 55. Speed limiter
    DashboardLightItem(
      number: 55,
      id: 'speed_limiter',
      nameArabic: 'محدد السرعة القصوى نشط',
      nameEnglish: 'Speed Limiter Active',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'SPD_LIMIT',
      icon: Icons.speed_outlined,
      meaningArabic:
          'نظام تحديد السرعة (Speed Limiter) مفعل ويمنع تجاوز السرعة المضبوطة حتى لو ضغطت دواسة الوقود.',
      commonCauses: ['ضبط السرعة القصوى عبر أزرار عجلة القيادة'],
      actionRequired:
          'حالة عادية. لإلغاء التحديد اضغط زر LIM أو ادعس دواسة الوقود للآخر (Kick-down).',
      associatedDTCs: [],
      colorValue: 0xFF43A047,
    ),

    // 56. Suspension dampers
    DashboardLightItem(
      number: 56,
      id: 'suspension_dampers',
      nameArabic: 'عطل في المزاطوريات والتعليق',
      nameEnglish: 'Suspension Dampers Fault',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'DAMPERS',
      icon: Icons.airline_seat_legroom_extra_rounded,
      meaningArabic:
          'خلل في المنظومة الإلكترونية للتحكم في قساوة وليونة المزاطوريات (المساعدات).',
      commonCauses: [
        'عطل في بلوف المزاطوريات الإلكترونية التكيفية',
        'انقطاع سلك حساس اهتزاز هيكل المركبة',
      ],
      actionRequired:
          'قد بحذر وتجنب المنعطفات السريعة، نظام التحكم في توازن السيارة سيكون محدوداً.',
      associatedDTCs: ['C1020', 'C1030'],
      colorValue: 0xFFFDD835,
    ),

    // 57. Low oil pressure
    DashboardLightItem(
      number: 57,
      id: 'oil_pressure',
      nameArabic: 'انخفاض خطير في ضغط زيت المحرك (إبريق الزيت)',
      nameEnglish: 'Low Engine Oil Pressure',
      severity: LightSeverity.criticalRed,
      canDrive: CanDriveStatus.stopImmediately,
      symbolCode: 'OIL_PRESS',
      icon: Icons.water_drop_rounded,
      meaningArabic:
          'انخفاض شديد وخطير في ضغط الزيت اللازم لتزييت بساتين ومحاور وكامات المحرك.',
      commonCauses: [
        'نقص حاد في مستوى الزيت بسبب تسريب أو حرق داخلي',
        'تلف أو انكسار بومبة الزيت',
        'انسداد شخال الزيت السفلي بالستاقوبا بالرايش أو الكربون',
        'تلف حساس ضغط الزيت',
      ],
      actionRequired:
          '⛔ توقف فوراً وأطفئ المحرك خلال ثوانٍ معدودة! تشغيل المحرك بدون ضغط زيت يؤدي لتصلبه وتكييله وتلفه بالكامل في دقائق.',
      associatedDTCs: ['P0520', 'P0521', 'P0522', 'P0524'],
      colorValue: 0xFFE53935,
    ),

    // 58. Windshield defrost
    DashboardLightItem(
      number: 58,
      id: 'windshield_defrost',
      nameArabic: 'إزالة الضباب عن الزجاج الأمامي',
      nameEnglish: 'Windshield Defrost / Demist Active',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'DEFROST_F',
      icon: Icons.air_outlined,
      meaningArabic:
          'توجيه هواء المكيف بكامل قوته نحو الزجاج الأمامي لطرد البخار والضباب وتوضيح الرؤية.',
      commonCauses: ['الضغط على زر ديفروست الزجاج الأمامي بالمكيف'],
      actionRequired:
          'حالة طبيعية لتنقية الرؤية. يمكن إطفاؤه بعد جفاف الزجاج.',
      associatedDTCs: [],
      colorValue: 0xFF43A047,
    ),

    // 59. Trunk open
    DashboardLightItem(
      number: 59,
      id: 'trunk_open',
      nameArabic: 'الشنطة الخلفية مفتوحة',
      nameEnglish: 'Trunk / Boot Lid Open',
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'TRUNK_OPN',
      icon: Icons.lock_open_rounded,
      meaningArabic:
          'باب الشنطة الخلفية (صندوق الأمتعة) غير مقفل بإحكام.',
      commonCauses: [
        'عدم إغلاق باب الصندوق بالكامل',
        'عطل في حساس كالون قفل الشنطة الخلفية',
      ],
      actionRequired:
          'توقف وأقفل باب الشنطة لمنع سقوط الأمتعة أثناء السير.',
      associatedDTCs: ['B1370'],
      colorValue: 0xFFFDD835,
    ),

    // 60. ESP / TCS
    DashboardLightItem(
      number: 60,
      id: 'esp_tcs',
      nameArabic: 'عطل مانع الانزلاق والتماسك (ESP / TCS)',
      nameEnglish: 'Electronic Stability Program (ESP / TCS)',
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

    // 61. Rain sensor active
    DashboardLightItem(
      number: 61,
      id: 'rain_sensor',
      nameArabic: 'حساس المطر قيد التشغيل',
      nameEnglish: 'Rain Sensor Active',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'RAIN_ACT',
      icon: Icons.water_drop_rounded,
      meaningArabic:
          'نظام الاستشعار التلقائي للمطر على الزجاج الأمامي مشغل ويعمل بانتظام.',
      commonCauses: ['وضع ذراع المساحات على خيار التشغيل التلقائي (AUTO)'],
      actionRequired:
          'حالة تشغيلية عادية تؤكد استعداد المساحات للعمل فور هطول المطر.',
      associatedDTCs: [],
      colorValue: 0xFF43A047,
    ),

    // 62. Check engine / MIL
    DashboardLightItem(
      number: 62,
      id: 'check_engine',
      nameArabic: 'فحص المحرك (Check Engine / MIL)',
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

    // 63. Rear window defroster
    DashboardLightItem(
      number: 63,
      id: 'rear_defrost',
      nameArabic: 'نظام إزالة الضباب وتدفئة الزجاج الخلفي',
      nameEnglish: 'Rear Window Defroster Active',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'DEFROST_R',
      icon: Icons.waves_outlined,
      meaningArabic:
          'خطوط التدفئة الكهربائية بالزجاج الخلفي مشتعلة لإذابة الجليد والضباب.',
      commonCauses: ['الضغط على زر تسخين وتذويب ضباب الزجاج الخلفي'],
      actionRequired:
          'حالة طبيعية، يفضل إطفاؤه بعد صفاء الرؤية لتخفيف الحمل الكهربائي على الدينمو.',
      associatedDTCs: [],
      colorValue: 0xFF43A047,
    ),

    // 64. Automatic wipers
    DashboardLightItem(
      number: 64,
      id: 'auto_wipers',
      nameArabic: 'مساحات الزجاج التلقائية نشطة',
      nameEnglish: 'Automatic Windshield Wipers Active',
      severity: LightSeverity.infoGreenBlue,
      canDrive: CanDriveStatus.normal,
      symbolCode: 'AUTO_WIPE',
      icon: Icons.water_rounded,
      meaningArabic:
          'المساحات الأمامية تعمل تلقائياً بحسب كمية قطرات الماء المستشعرة على الزجاج.',
      commonCauses: ['هطول المطر وتفعيل وضع AUTO للمساحات'],
      actionRequired:
          'حالة تشغيلية طبيعية وآمنة تزيد وضوح الرؤية دون انشغال السائق.',
      associatedDTCs: [],
      colorValue: 0xFF43A047,
    ),
  ];

  /// Finds a light by its unique identifier or by number string
  static DashboardLightItem? getById(String id) {
    try {
      final clean = id.trim().toLowerCase();
      // Also match by number if query is like "57" or "#57"
      final numeric = int.tryParse(clean.replaceAll('#', ''));
      if (numeric != null) {
        final matchNum = allLights.where((l) => l.number == numeric);
        if (matchNum.isNotEmpty) return matchNum.first;
      }
      return allLights.firstWhere(
        (l) => l.id.toLowerCase() == clean,
      );
    } catch (_) {
      return null;
    }
  }

  /// Finds a light by its exact 1..64 number
  static DashboardLightItem? getByNumber(int number) {
    try {
      return allLights.firstWhere((l) => l.number == number);
    } catch (_) {
      return null;
    }
  }

  /// Searches lights by number (e.g. 57 or #57), name, meaning, or associated DTC
  static List<DashboardLightItem> searchLights({
    String query = '',
    LightSeverity? severityFilter,
    String? dtcCode,
  }) {
    final cleanQuery = query.trim().toLowerCase();
    final cleanDtc = dtcCode?.trim().toUpperCase();
    final queryNumber = int.tryParse(cleanQuery.replaceAll('#', ''));

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

      // Match by lamp number (1..64)
      if (queryNumber != null && l.number == queryNumber) {
        return true;
      }

      final matchName = l.nameArabic.toLowerCase().contains(cleanQuery);
      final matchEn = l.nameEnglish.toLowerCase().contains(cleanQuery);
      final matchMeaning = l.meaningArabic.toLowerCase().contains(cleanQuery);
      final matchCode = l.symbolCode.toLowerCase().contains(cleanQuery);
      final matchDtc = l.associatedDTCs.any(
        (c) => c.toLowerCase().contains(cleanQuery),
      );

      return matchName || matchEn || matchMeaning || matchCode || matchDtc;
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
