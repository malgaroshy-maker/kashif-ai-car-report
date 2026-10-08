import '../models/fuse_item.dart';

class FuseBoxRepository {
  static const List<FuseItem> allFuses = [
    FuseItem(
      id: 'obd_cig',
      nameArabic: 'فيوز مدخل الفحص OBD-II والولاعة',
      circuitEnglish: 'CIG / DLC / AUX 12V',
      location: FuseLocation.interior,
      ratingAmps: 15,
      standardColorName: 'أزرق (15A)',
      colorValue: 0xFF1E88E5,
      symptoms: [
        'جهاز كشف الأعطال OBD-II لا يعمل أو لا يستجيب',
        'شاشة الفاحص تظل مطفأة عند شبك الفيشة',
        'انقطاع شحن الهاتف من مخرج الولاعة 12V',
      ],
      associatedDTCs: ['U0100', 'U0001', 'U0155'],
      testingTip:
          'معظم السيارات (خاصة تويوتا وهيونداي وفورد) تغذي الطرف رقم 16 في فيشة OBD-II من فيوز الولاعة CIG. إذا انطفأ جهازك تأكد من هذا الفيوز أولاً!',
    ),
    FuseItem(
      id: 'fuel_pump',
      nameArabic: 'فيوز ومرحل بومبة الوقود (بومبة البنزين)',
      circuitEnglish: 'FUEL PUMP / EFI / FP',
      location: FuseLocation.engineBay,
      ratingAmps: 20,
      standardColorName: 'أصفر (20A)',
      colorValue: 0xFFFDD835,
      symptoms: [
        'المحرك يلف (كرنك) بدون تشغيل نهائياً',
        'عدم سماع صوت طنين بومبة الوقود عند فتح السويتش (ON)',
        'انعدام ضغط البنزين في مسطرة الرشاشات',
      ],
      associatedDTCs: ['P0087', 'P0230', 'P0231', 'P0232', 'P0088'],
      testingTip:
          'افحص النقطتين المعدنيتين أعلى الفيوز بلمبة الفحص مع فتح السويتش. إذا أضاءت في طرف واحد فقط فالفيوز محروق. إذا كان الفيوز سليماً، افحص ريليه (Relay) البومبة بتبديله مع ريليه البوق (Horn).',
    ),
    FuseItem(
      id: 'ecu_main',
      nameArabic: 'فيوز ومرحل كمبيوتر المحرك الرئيسي',
      circuitEnglish: 'ECU / ECM / PCM MAIN',
      location: FuseLocation.engineBay,
      ratingAmps: 20,
      standardColorName: 'أصفر (20A)',
      colorValue: 0xFFFDD835,
      symptoms: [
        'لمبة المحرك (Check Engine) لا تضيء أبداً عند فتح السويتش',
        'فقدان تام للاتصال بكمبيوتر السيارة عبر جهاز الكشف',
        'المحرك يدور ولكن لا توجد شرارة شمعات ولا فتح للرشاشات',
      ],
      associatedDTCs: ['P0606', 'P0685', 'U0100', 'P0689'],
      testingTip:
          'عند تلف هذا الفيوز، يتوقف الكمبيوتر عن العمل كلياً وتبدو السيارة وكأنها ميتة كهربائياً في منظومة الحقن والإشعال.',
    ),
    FuseItem(
      id: 'ign_inj',
      nameArabic: 'فيوز بوبينات الإشعال ورشاشات الوقود',
      circuitEnglish: 'IGN COIL / INJ / INJECTOR',
      location: FuseLocation.engineBay,
      ratingAmps: 15,
      standardColorName: 'أزرق (15A)',
      colorValue: 0xFF1E88E5,
      symptoms: [
        'فطفطة ورجفة شديدة في المحرك وانخفاض حاد في العزم',
        'توقف فوري لمحرك السيارة أثناء السير',
        'انقطاع التيار المغذي لفيش البوبينات أو الرشاشات',
      ],
      associatedDTCs: [
        'P0300',
        'P0351',
        'P0352',
        'P0353',
        'P0354',
        'P0201',
        'P0202',
      ],
      testingTip:
          'إذا احترق الفيوز فور تبديله بآخر جديد، فهذا يدل على وجود شورت (التماس أرضي) في أحد البوبينات أو ذوبان عازل سلك البوبينة واحتكاكه بجسم المحرك.',
    ),
    FuseItem(
      id: 'rad_fan',
      nameArabic: 'فيوز ومرحل مروحة تبريد الرداتوري',
      circuitEnglish: 'RAD FAN / COOLING FAN',
      location: FuseLocation.engineBay,
      ratingAmps: 30,
      standardColorName: 'أخضر (30A)',
      colorValue: 0xFF43A047,
      symptoms: [
        'ارتفاع سريع وخطير في حرارة المحرك عند التوقف في الإشارات والزحام',
        'المروحة لا تدور نهائياً حتى عند تشغيل التكييف',
        'غليان ماء الرداتوري وخروجه من القربة الاحتياطية',
      ],
      associatedDTCs: ['P0480', 'P0481', 'P0217', 'P0482'],
      testingTip:
          'فيوز المروحة يتعرض لحمل أمبير عالي (30A-40A). افحص قواعد الفيوز للتأكد من عدم وجود كربنة أو ذوبان للبلاستيك بسبب الحرارة والشد العالي.',
    ),
    FuseItem(
      id: 'o2_heater',
      nameArabic: 'فيوز سخان حساسات الأكسجين والعادم',
      circuitEnglish: 'O2 HEATER / SENSOR',
      location: FuseLocation.engineBay,
      ratingAmps: 10,
      standardColorName: 'أحمر (10A)',
      colorValue: 0xFFE53935,
      symptoms: [
        'إضاءة دائمة للمبة المحرك Check Engine',
        'زيادة ملحوظة في استهلاك الوقود ودخان أسود',
        'تأخر استجابة المحرك للوصول للحلقة المغلقة (Closed Loop)',
      ],
      associatedDTCs: ['P0135', 'P0141', 'P0030', 'P0036', 'P0130', 'P0136'],
      testingTip:
          'عند ظهور كود P0135 أو P0141، افحص هذا الفيوز قبل تغيير حساس المرميطة، لأن احتراق فيوز السخان يمنع تسخين الحساس ويعطي نفس الكود تماماً!',
    ),
    FuseItem(
      id: 'abs_brake',
      nameArabic: 'فيوز منظومة الفرامل ABS ومانع الانزلاق',
      circuitEnglish: 'ABS SOLENOID / MOTOR / ESP',
      location: FuseLocation.engineBay,
      ratingAmps: 40,
      standardColorName: 'برتقالي ماكسي (40A)',
      colorValue: 0xFFFB8C00,
      symptoms: [
        'إضاءة لمبة ABS ولمبة مانع التزحلق ESP/TCS في الطبلون',
        'تعطل ميزة منع انغلاق العجلات عند الفرملة الفجائية',
        'تحجر في دواسة الفرامل في بعض الأنظمة الهيدروليكية',
      ],
      associatedDTCs: ['C0035', 'C0040', 'C0045', 'C0050', 'C0245', 'C0550'],
      testingTip:
          'منظومة ABS تحتوي غالباً على فيوزين: فيوز صغير 10A/15A لكمبيوتر ABS، وفيوز عريض 30A-50A لمضخة موطور الـ ABS الهيدروليكي.',
    ),
    FuseItem(
      id: 'ac_comp',
      nameArabic: 'فيوز ومرحل كلتش كمبروسر المكيف',
      circuitEnglish: 'A/C CLUTCH / MAG CLUTCH',
      location: FuseLocation.engineBay,
      ratingAmps: 10,
      standardColorName: 'أحمر (10A)',
      colorValue: 0xFFE53935,
      symptoms: [
        'خروج هواء حار فقط من فتحات التكييف رغم ضغط زر A/C',
        'عدم لقط أو دوران بكرة كلتش الكمبروسر عند تشغيل المكيف',
        'سماع صوت تكتكة متكررة وسريعة دون استقرار التبريد',
      ],
      associatedDTCs: ['P0532', 'P0533', 'B1421'],
      testingTip:
          'إذا كان الغاز مشحوناً في الدورة ولكن الكلتش لا يعمل، افحص فيوز وريليه A/C CLUTCH أولاً قبل الحكم على تعطل الكمبروسر.',
    ),
    FuseItem(
      id: 'starter',
      nameArabic: 'فيوز ومرحل بادئ الحركة (الموتورينو)',
      circuitEnglish: 'STARTER / ST / IGN SWITCH',
      location: FuseLocation.engineBay,
      ratingAmps: 30,
      standardColorName: 'أخضر (30A)',
      colorValue: 0xFF43A047,
      symptoms: [
        'المحرك لا يدور نهائياً عند إدارة المفتاح لوضع Start',
        'انعدام صوت تكّة أوتوماتيك الموتورينو',
        'الأنوار والمسجل يعملان ولكن الموتورينو ميت كلياً',
      ],
      associatedDTCs: ['P0615', 'P0616', 'P0617'],
      testingTip:
          'تأكد من أن الكمبيو على وضع P أو N. إذا كان الكمبيو سليماً، فإن فيوز أو ريليه الموتورينو هو المسؤول عن إيصال إشارة التشغيل لأوتوماتيك الموتورينو.',
    ),
    FuseItem(
      id: 'wiper',
      nameArabic: 'فيوز محرك مساحات الزجاج',
      circuitEnglish: 'WIPER / WASHER',
      location: FuseLocation.interior,
      ratingAmps: 20,
      standardColorName: 'أصفر (20A)',
      colorValue: 0xFFFDD835,
      symptoms: [
        'توقف مساحات الزجاج الأمامي أو الخلفي فجأة',
        'تجمد المساحات في منتصف الزجاج وعدم رجوعها لنقطة الصفر',
        'عدم استجابة رشاشات ماء الزجاج',
      ],
      associatedDTCs: ['B2311', 'B2312'],
      testingTip:
          'غالباً ما يحترق هذا الفيوز في الشتاء عند تشغيل المساحات وهي ملتصقة بالزجاج بفعل الأتربة أو الجليد مما يسبب حمل تيار زائد على الموتور.',
    ),
    FuseItem(
      id: 'trans_tcm',
      nameArabic: 'فيوز كمبيوتر الكمبيو (TCM) الأوتوماتيك',
      circuitEnglish: 'TRANS / TCM / A/T CONTROL',
      location: FuseLocation.engineBay,
      ratingAmps: 15,
      standardColorName: 'أزرق (15A)',
      colorValue: 0xFF1E88E5,
      symptoms: [
        'دخول الكمبيو في وضع الأمان (Limp Mode) والتعليق على الغيار الثالث',
        'نتعة ورزعة قوية عند التعشيق بين R و D',
        'عدم إمكانية نقل مارشا إلا بالزر اليدوي (Shift Lock)',
      ],
      associatedDTCs: ['P0700', 'P0750', 'P0755', 'P0841', 'P0705'],
      testingTip:
          'فقدان التغذية الكهربائية لكمبيوتر الكمبيو (TCM) يجعله يفقد التحكم بالبلوف الهيدروليكية ويعلق على نمرة طوارئ لحماية الكلتشات.',
    ),
    FuseItem(
      id: 'airbag_srs',
      nameArabic: 'فيوز الوسائد الهوائية (الإيرباق)',
      circuitEnglish: 'SRS / AIRBAG / OCCUPANT',
      location: FuseLocation.interior,
      ratingAmps: 10,
      standardColorName: 'أحمر (10A)',
      colorValue: 0xFFE53935,
      symptoms: [
        'إضاءة دائمة أو وميض لمبة الإيرباق SRS في لوحة العدادات (الطبلون)',
        'تعطل منظومة شد أحزمة الأمان والوسائد في الحوادث',
      ],
      associatedDTCs: ['B0001', 'B0010', 'B0028', 'B1000'],
      testingTip:
          'تنبيه أمان: قبل فحص أو لمس أسلاك منظومة الإيرباق الصفراء، افصل أصبع البطارية السالب وانتظر 10 دقائق لتفريغ المكثفات تجنباً لخروج الوسائد عن طريق الخطأ.',
    ),
    FuseItem(
      id: 'eps_steering',
      nameArabic: 'فيوز التوجيه الكهربائي (الباور ستيرينج)',
      circuitEnglish: 'EPS / P/S / POWER STEERING',
      location: FuseLocation.engineBay,
      ratingAmps: 60,
      standardColorName: 'أصفر ماكسي (60A)',
      colorValue: 0xFFFDD835,
      symptoms: [
        'ثقل شديد وحجر في ستيرسو ومقود السيارة وكأنها شاحنة قديمة',
        'إضاءة لمبة EPS أو علامة المقود مع علامة التعجب في الطبلون',
      ],
      associatedDTCs: ['C1511', 'C1515', 'C1521'],
      testingTip:
          'فيوز الـ EPS هو فيوز عريض من نوع Bolt-on (مثبت ببرغيين داخل العلبة). افحص بالعين المجردة من خلال النافذة الشفافة للتأكد من عدم انقطاع شريحة النحاس الداخلية.',
    ),
    FuseItem(
      id: 'alt_charging',
      nameArabic: 'فيوز دينمو الشحن ونظام توليد الكهرباء',
      circuitEnglish: 'ALT / MAIN GENERATOR',
      location: FuseLocation.engineBay,
      ratingAmps: 100,
      standardColorName: 'فيوز رئيسي ماكسي (100A-140A)',
      colorValue: 0xFFD32F2F,
      symptoms: [
        'إضاءة لمبة البطارية الحمراء أثناء دوران المحرك',
        'تفريغ البطارية وتوقف السيارة فجأة بعد مسافة قصيرة',
        'ضعف عام في إضاءة الأنوار وعزم السيارة',
      ],
      associatedDTCs: ['P0562', 'P0620', 'P0622'],
      testingTip:
          'هذا هو الفيوز الرئيسي الحامي لمنظومة الشحن. يحترق فوراً في حال تركيب كوابل الاشتراك المعكوسة (الاشتراك الخاطئ بين سيارتين) لحماية كمبيوتر السيارة من الاحتراق.',
    ),
  ];

  /// Filters fuses by query and location
  static List<FuseItem> searchFuses({
    String query = '',
    FuseLocation? locationFilter,
    String? dtcCode,
  }) {
    final cleanQuery = query.trim().toLowerCase();
    final cleanDtc = dtcCode?.trim().toUpperCase();

    return allFuses.where((fuse) {
      if (locationFilter != null && fuse.location != locationFilter) {
        return false;
      }

      if (cleanDtc != null && cleanDtc.isNotEmpty) {
        final matchesDtc = fuse.associatedDTCs.any(
          (c) => c.toUpperCase().contains(cleanDtc),
        );
        if (matchesDtc) return true;
      }

      if (cleanQuery.isEmpty) return true;

      final matchName = fuse.nameArabic.toLowerCase().contains(cleanQuery);
      final matchCircuit = fuse.circuitEnglish.toLowerCase().contains(
        cleanQuery,
      );
      final matchAmps = fuse.ratingAmps.toString().contains(cleanQuery);
      final matchDtc = fuse.associatedDTCs.any(
        (c) => c.toLowerCase().contains(cleanQuery),
      );
      final matchSymptom = fuse.symptoms.any(
        (s) => s.toLowerCase().contains(cleanQuery),
      );

      return matchName || matchCircuit || matchAmps || matchDtc || matchSymptom;
    }).toList();
  }

  /// Finds fuses related to a specific DTC fault code
  static List<FuseItem> findFusesForDtc(String dtc) {
    final clean = dtc.trim().toUpperCase();
    if (clean.isEmpty) return [];
    return allFuses
        .where((f) => f.associatedDTCs.any((c) => c.toUpperCase() == clean))
        .toList();
  }
}
