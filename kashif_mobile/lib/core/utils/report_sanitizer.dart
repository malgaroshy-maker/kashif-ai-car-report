/// Utility to clean and sanitize any scanner device brand names (Ediag, Launch, etc.)
/// and strictly enforce authentic Libyan workshop terms across the entire app.
class ReportSanitizer {
  static String clean(String? input) {
    if (input == null || input.isEmpty) return '';

    String text = input
        .replaceAll(
          RegExp(r'بواسطة\s+جهاز\s+(كشف|فحص)\s+[A-Za-z0-9_\-]+', caseSensitive: false),
          'عبر الفحص الإلكتروني الشامل',
        )
        .replaceAll(
          RegExp(r'بجهاز\s+(كشف|فحص)\s+[A-Za-z0-9_\-]+(\s+بدون\s+إنترنت)?', caseSensitive: false),
          'عبر الفحص الإلكتروني الشامل',
        )
        .replaceAll(
          RegExp(r'تقرير\s+جهاز\s+[A-Za-z0-9_\-]+', caseSensitive: false),
          'تقرير الفحص الإلكتروني',
        )
        .replaceAll(
          RegExp(r'جهاز\s+(كشف|فحص)\s+(Ediag|Launch|Autel|Thinkdiag|G-Scan|OBD)', caseSensitive: false),
          'جهاز الفحص',
        )
        .replaceAll(
          RegExp(r'\(Ediag\s+أو\s+ما\s+يعادله\)', caseSensitive: false),
          'بجهاز الفحص المعتمد',
        )
        .replaceAll(
          RegExp(r'Ediag|Thinkdiag|Autel|Launch', caseSensitive: false),
          '',
        )
        .replaceAll('تفتفة', 'فطفطة')
        .replaceAll(
          RegExp(r'خطوات\s+فحص\s+الأ?سطى\s+والورشة|خطوات\s+فحص\s+الأ?سطى|فحص\s+الأ?سطى', caseSensitive: false),
          'خطوات الفحص الفني والورشة',
        )
        .replaceAll(RegExp(r'الأ?سطى', caseSensitive: false), 'الفني');

    // Arabic letter boundary helper:
    // (?<![\u0621-\u064A]) ensures not preceded by an Arabic letter
    // (?![\u0621-\u064A]) ensures not followed by an Arabic letter

    // 1. Transmission: قير / جير / فتيس / ناقل حركة -> كمبيو
    text = text
        .replaceAll(RegExp(r'ناقل\s+الحركة\s+الأوتوماتيكي?'), 'الكمبيو الأوتوماتيك')
        .replaceAll(RegExp(r'ناقل\s+الحركة\s+العادي?|ناقل\s+الحركة\s+اليدوي?'), 'الكمبيو العادي')
        .replaceAll(RegExp(r'ناقل\s+الحركة'), 'الكمبيو')
        .replaceAll(RegExp(r'ناقل\s+حركة'), 'كمبيو')
        .replaceAll(RegExp(r'طنجرة\s+(القير|الجير)'), 'طنجرة الكمبيو (الكونفيرتا)')
        .replaceAll(RegExp(r'عقل\s+(القير|الجير)|مخ\s+(القير|الجير)'), 'عقل الكمبيو (الفالف بدي)')
        .replaceAll(RegExp(r'زيت\s+(القير|الجير)'), 'زيت الكمبيو')
        .replaceAll(RegExp(r'فلتر\s+(القير|الجير)'), 'فيلترو الكمبيو')
        .replaceAll(RegExp(r'مبرد\s+(القير|الجير)'), 'مبرد الكمبيو')
        .replaceAll(RegExp(r'حساس\s+(القير|الجير)|حساسات\s+(القير|الجير)'), 'حساس الكمبيو')
        .replaceAll(RegExp(r'كمبيوتر\s+(القير|الجير)'), 'كمبيوتر الكمبيو (TCM)')
        .replaceAll(RegExp(r'عصا\s+(القير|الجير)|ذراع\s+(القير|الجير)'), 'مارشا')
        // Definite: القير / الجير / الفتيس
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)(قير|قاير|جير|فتيس)(?![\u0621-\u064A])'), r'$1كمبيو')
        // Plural: قيرات / جيرات
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)?(قيرات|جيرات)(?![\u0621-\u064A])'), 'كمبيوات')
        // Indefinite: قير / جير / فتيس
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(قير|قاير|جير|فتيس)(?![\u0621-\u064A])'), 'كمبيو');

    // 2. Fuel / Water / Oil Pump: طرمبة / طلمبة -> بومبة
    text = text
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)(طرمب|طلمب)(ة|ات)(?![\u0621-\u064A])'), r'$1بومب$3')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(طرمب|طلمب)ة(?![\u0621-\u064A])'), 'بومبة')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(طرمب|طلمب)ات(?![\u0621-\u064A])'), 'بومبات');

    // 3. Brake Pads: فحمات / قماشات / تيل فرامل -> باطنيات
    text = text
        .replaceAll(RegExp(r'تيل\s+الفرامل|أقمشة\s+الفرامل|فحمات\s+الفرامل'), 'باطنيات ديسكو')
        .replaceAll(RegExp(r'تيل\s+فرامل|أقمشة\s+فرامل|فحمات\s+فرامل'), 'باطنيات ديسكو')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)(فحمات|قماشات|أقمشة)(?![\u0621-\u064A])'), r'$1باطنيات')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(فحمات|قماشات|أقمشة)(?![\u0621-\u064A])'), 'باطنيات')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)(فحمة|قماشة)(?![\u0621-\u064A])'), r'$1باطني')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(فحمة|قماشة)(?![\u0621-\u064A])'), 'باطني');

    // 4. Control Arms: مقصات / مقص -> براتشوات / براتشو
    text = text
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)مقصات(?![\u0621-\u064A])'), r'$1براتشوات')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])مقصات(?![\u0621-\u064A])'), 'براتشوات')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)مقص(?![\u0621-\u064A])'), r'$1براتشو')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])مقص(?![\u0621-\u064A])'), 'براتشو');

    // 5. Shock Absorbers: مساعدين / مساعدات -> مزاطوريات
    text = text
        .replaceAll(RegExp(r'مساعدات\s+الصدمات|ممتصات\s+الصدمات|مساعدين\s+الصدمات'), 'مزاطوريات')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)(مساعدين|مساعدات)(?![\u0621-\u064A])'), r'$1مزاطوريات')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(مساعدين|مساعدات)(?![\u0621-\u064A])'), 'مزاطوريات')
        .replaceAll(RegExp(r'مساعد\s+(أمامي|خلفي|يمين|يسار)'), r'مزاطوري $1')
        .replaceAll(RegExp(r'المساعد\s+(الأمامي|الخلفي|الأيمن|الأيسر)'), r'المزاطوري $1');

    // 6. Axles / CV Joints: عكوس / عكس -> سمياصات / سمياص
    text = text
        .replaceAll(RegExp(r'جلدة\s+العكس|جلد\s+العكوس'), 'كرشيرة / قومة سمياص')
        .replaceAll(RegExp(r'رأس\s+العكس|رؤوس\s+العكوس'), 'رأس السمياص')
        .replaceAll(RegExp(r'عمود\s+العكس|أعمدة\s+العكوس'), 'عمود السمياص')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)عكوس(?![\u0621-\u064A])'), r'$1سمياصات')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])عكوس(?![\u0621-\u064A])'), 'سمياصات')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)عكس\s+(الأيمن|الأيسر|الأمامي|الخلفي|الداخلي|الخارجي)'), r'$1سمياص $2')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])عكس\s+(أيمن|أيسر|أمامي|خلفي|داخلي|خارجي)'), r'سمياص $1');

    // 7. Wheel Bearings: رمان بلي / صرة -> كوشينتي / موتسو
    text = text
        .replaceAll(RegExp(r'رمان\s+بلي\s+العجلة|رمان\s+بلي'), 'كوشينتي')
        .replaceAll(RegExp(r'الرمان\s+بلي'), 'الكوشينتي')
        .replaceAll(RegExp(r'صرة\s+العجلة'), 'موتسو العجلة');

    // 8. Timing Belt / Chain: سير تيمن / سير تايمن -> كاتينة
    text = text
        .replaceAll(RegExp(r'سير\s+(التا?يمن|التوقيت|الكاتينة)'), 'كاتينة')
        .replaceAll(RegExp(r'سير\s+(المحرك|المكينة|الدينمو)'), 'قايش المحرك');

    // 9. Exhaust: شكمان -> مرميطة
    text = text
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)شكمان(?![\u0621-\u064A])'), r'$1مرميطة')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])شكمان(?![\u0621-\u064A])'), 'مرميطة')
        .replaceAll(RegExp(r'دبة\s+التلوث|محول\s+حفاز|المحول\s+الحفاز'), 'علبة كربون المرميطة');

    // 10. Radiator: رديتر / ردياتير / راديتر -> رداتوري
    text = text
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)(راديتر|ردياتير|رديتر)(?![\u0621-\u064A])'), r'$1رداتوري')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(راديتر|ردياتير|رديتر)(?![\u0621-\u064A])'), 'رداتوري');

    // 11. Starter: سلف -> موتورينو (مارش)
    text = text
        .replaceAll(RegExp(r'سلف\s+التشغيل|مارش\s+التشغيل'), 'موتورينو التشغيل')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)سلف(?![\u0621-\u064A])'), r'$1موتورينو')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])سلف(?![\u0621-\u064A])'), 'موتورينو');

    // 12. Oil Pan: كرتير / كارتير -> ستاقوبا
    text = text
        .replaceAll(RegExp(r'كرتير\s+الزيت|كارتير\s+الزيت'), 'ستاقوبا الزيت')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)(كرتير|كارتير)(?![\u0621-\u064A])'), r'$1ستاقوبا')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(كرتير|كارتير)(?![\u0621-\u064A])'), 'ستاقوبا');

    // 13. Steering: دركسون / دركسيون -> ستيرسو / دومان
    text = text
        .replaceAll(RegExp(r'طارة\s+(الدركسون|الدركسيون)|عجلة\s+القيادة'), 'الدومان (الستيرسو)')
        .replaceAll(RegExp(r'دودة\s+(الدركسون|الدركسيون)|علبة\s+(الدركسون|الدركسيون)'), 'سكاتولة الستيرسو')
        .replaceAll(RegExp(r'زيت\s+(الدركسون|الدركسيون)'), 'زيت الستيرسو')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)(دركسون|دركسيون)(?![\u0621-\u064A])'), r'$1ستيرسو')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(دركسون|دركسيون)(?![\u0621-\u064A])'), 'ستيرسو');

    // 14. Spark Plugs: بواجي / بوجيه -> شمعات / شمعة
    text = text
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)(بواجي|بوجيهات)(?![\u0621-\u064A])'), r'$1شمعات')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(بواجي|بوجيهات)(?![\u0621-\u064A])'), 'شمعات')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)بوجيه(?![\u0621-\u064A])'), r'$1شمعة')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])بوجيه(?![\u0621-\u064A])'), 'شمعة');

    // 15. Ignition Coils: كويلات / كويل -> بوبينات / بوبينة
    text = text
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)كويلات(?![\u0621-\u064A])'), r'$1بوبينات')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])كويلات(?![\u0621-\u064A])'), 'بوبينات')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)كويل(?![\u0621-\u064A])'), r'$1بوبينة')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])كويل(?![\u0621-\u064A])'), 'بوبينة');

    // 16. Fuel Injectors: بخاخات / بخاخ -> رشاشات / رشاش
    text = text
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)بخاخات(?![\u0621-\u064A])'), r'$1رشاشات')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])بخاخات(?![\u0621-\u064A])'), 'رشاشات')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)بخاخ(?![\u0621-\u064A])'), r'$1رشاش')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])بخاخ(?![\u0621-\u064A])'), 'رشاش');

    // 17. Tires: كفرات -> قومّات
    text = text
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])(ال|بال|لل|فال|وال)كفرات(?![\u0621-\u064A])'), r'$1قومّات')
        .replaceAll(RegExp(r'(?<![\u0621-\u064A])كفرات(?![\u0621-\u064A])'), 'قومّات');

    // 18. Body: صدام -> براونطي, كبوت -> كوفنو
    text = text
        .replaceAll(RegExp(r'صدام\s+(أمامي|خلفي)'), r'براونطي $1')
        .replaceAll(RegExp(r'الصدام\s+(الأمامي|الخلفي)'), r'البراونطي $1')
        .replaceAll(RegExp(r'كبوت\s+السيارة|غطاء\s+المحرك'), 'كوفنو السيارة')
        .replaceAll(RegExp(r'شنطة\s+السيارة'), 'باقاج السيارة');

    return text.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
  }
}
