export interface DictionaryEntry {
  libyanTerm: string;
  standardArabic: string;
  english: string;
  category: string;
  /**
   * The English name to search an image archive with, when the gloss above is
   * not one.
   *
   * `english` is written for a person reading the glossary: "Gearbox /
   * transmission (cambio)" is exactly right there and useless as a query. The
   * two jobs were being done by one field, and the search got the worse half
   * of the bargain — "A/C Compressor (compressore)" was cut at its first slash
   * and searched for as "A".
   *
   * `null` means this term does not name a physical part at all. A third of
   * the general section is labour, diagnosis, a salvage yard or a service
   * interval; an archive searched for "Labor charge" answers with something,
   * and whatever it answers with is wrong.
   *
   * Omitted means the gloss is already a good query and is used as it stands.
   */
  partSearchTerm?: string | null;
}

export const LIBYAN_DICTIONARY: DictionaryEntry[] = [
  // 1. مصطلحات عامة وإدارية
  { libyanTerm: "اليد العاملة / يد عاملة", standardArabic: "أجرة العمل / تكلفة العمالة", english: "Labor charge / labor cost", category: "عام وإداري" , partSearchTerm: null},
  { libyanTerm: "صيانة دورية", standardArabic: "الصيانة الدورية المجدولة", english: "Scheduled/periodic maintenance", category: "عام وإداري" , partSearchTerm: null},
  { libyanTerm: "صيانة وقائية", standardArabic: "الصيانة الوقائية", english: "Preventive maintenance", category: "عام وإداري" , partSearchTerm: null},
  { libyanTerm: "كشف / كشف شامل", standardArabic: "الفحص أو التشخيص الشامل", english: "Diagnostic check / Inspection", category: "عام وإداري" , partSearchTerm: null},
  { libyanTerm: "سيرفيز / سيرفز", standardArabic: "خدمة أو صيانة عامة", english: "Service", category: "عام وإداري" , partSearchTerm: null},
  { libyanTerm: "خدمة صالة", standardArabic: "خدمة نظام التعليق والثبات", english: "Suspension system service", category: "عام وإداري" , partSearchTerm: null},
  { libyanTerm: "جهاز كشف", standardArabic: "جهاز تشخيص أعطال إلكتروني (OBD Scanner)", english: "Diagnostic tool / OBD scanner", category: "عام وإداري" , partSearchTerm: null},
  { libyanTerm: "تسريب", standardArabic: "تسرب سائل (زيت/ماء/غاز)", english: "Fluid leak", category: "عام وإداري" , partSearchTerm: null},
  { libyanTerm: "رابش / الرابش", standardArabic: "قطع غيار مستعملة أصلية (تشليح السيارات)", english: "Auto salvage yard / used OEM parts", category: "عام وإداري" , partSearchTerm: null},

  // 2. الهيكل والمقصورة
  { libyanTerm: "براونطي / باراوانطي", standardArabic: "الصدام الأمامي أو الخلفي", english: "Bumper (paraurti)", category: "الهيكل والمقصورة" },
  { libyanTerm: "كوفنو / كبوت", standardArabic: "غطاء المحرك الأمامي", english: "Hood / bonnet (cofano)", category: "الهيكل والمقصورة" },
  { libyanTerm: "رفرف", standardArabic: "الرفرف فوق العجلة", english: "Fender / wing (parafango)", category: "الهيكل والمقصورة" },
  { libyanTerm: "ديسكو", standardArabic: "قرص الفرامل أو قرص العجلة", english: "Brake disc / wheel disc", category: "الهيكل والمقصورة" },
  { libyanTerm: "باطني / باطنيات", standardArabic: "تيل الفرامل (فحمات الفرامل)", english: "Brake pads", category: "الهيكل والمقصورة" },
  { libyanTerm: "طبلون / تابلو", standardArabic: "لوحة القيادة (الداشبورد)", english: "Dashboard", category: "الهيكل والمقصورة" },
  { libyanTerm: "كوادرو", standardArabic: "لوحة العدادات", english: "Instrument cluster", category: "الهيكل والمقصورة" },
  { libyanTerm: "فنار", standardArabic: "المصباح الأمامي", english: "Headlight", category: "الهيكل والمقصورة" },
  { libyanTerm: "سطب / اسطب", standardArabic: "إشارة التوقف الخلفية", english: "Rear stop/tail light", category: "الهيكل والمقصورة" },
  { libyanTerm: "سكة مرش / محرك سكة مرش", standardArabic: "رافعة الزجاج ومحركها (ماكينة القزاز)", english: "Window regulator / motor", category: "الهيكل والمقصورة" },
  { libyanTerm: "شريط إيرباق", standardArabic: "ملف الساعة لعجلة القيادة والإيرباق", english: "Clock spring (airbag coil)", category: "الهيكل والمقصورة" },
  { libyanTerm: "سنتر لوك", standardArabic: "آلية قفل الأبواب المركزية", english: "Central door lock mechanism", category: "الهيكل والمقصورة" },

  // 3. المحرك ونقل الحركة
  { libyanTerm: "كاتينة", standardArabic: "سلسلة التوقيت (سير التيمن)", english: "Timing chain / belt (catena)", category: "المحرك ونقل الحركة" },
  { libyanTerm: "تستاتا", standardArabic: "رأس المحرك (السلندر هيد)", english: "Cylinder head (testata)", category: "المحرك ونقل الحركة" },
  { libyanTerm: "بسطوني", standardArabic: "المكبس (البستون)", english: "Piston (pistone)", category: "المحرك ونقل الحركة" },
  { libyanTerm: "شنابر", standardArabic: "حلقات المكبس (السنابر)", english: "Piston rings", category: "المحرك ونقل الحركة" },
  { libyanTerm: "بيّلا", standardArabic: "ذراع التوصيل (البيالة)", english: "Connecting rod (biella)", category: "المحرك ونقل الحركة" },
  { libyanTerm: "كمبيو / كامبيو", standardArabic: "علبة التروس (الفتيس/القير)", english: "Gearbox / transmission (cambio)", category: "المحرك ونقل الحركة" },
  { libyanTerm: "كونفيرتا / طنجرة الكمبيو", standardArabic: "محول العزم الهيدروليكي للقير", english: "Torque converter (convertitore)", category: "المحرك ونقل الحركة" },
  { libyanTerm: "عقل الكمبيو / الفالف بدي", standardArabic: "مجمع الصمامات الكهرومغناطيسية للقير", english: "Valve body / Mechatronic unit", category: "المحرك ونقل الحركة" },
  { libyanTerm: "صبورتوات المحرك والكمبيو", standardArabic: "كراسي وقواعد تثبيت المحرك والقير", english: "Engine & transmission mounts (supporti)", category: "المحرك ونقل الحركة" },
  { libyanTerm: "مارشا", standardArabic: "ذراع تعشيق السرعات", english: "Gear shift lever", category: "المحرك ونقل الحركة" },
  { libyanTerm: "عمود نقل الحركة", standardArabic: "عمود نقل الحركة (الكردان)", english: "Propeller / drive shaft", category: "المحرك ونقل الحركة" },
  { libyanTerm: "بومبة", standardArabic: "مضخة (بنزين / ماء / زيت)", english: "Pump", category: "المحرك ونقل الحركة" , partSearchTerm: null},
  { libyanTerm: "بومبة بنزين (قلب البومبة)", standardArabic: "مضخة الوقود / طرمبة البنزين", english: "Fuel pump module / core", category: "المحرك ونقل الحركة" },
  { libyanTerm: "دينمو", standardArabic: "المولد الكهربائي (شاحن البطارية)", english: "Alternator / generator", category: "المحرك ونقل الحركة" },
  { libyanTerm: "موتورينو", standardArabic: "مارش التشغيل (السلف)", english: "Starter motor (motorino)", category: "المحرك ونقل الحركة" },
  { libyanTerm: "رشاشات", standardArabic: "بخاخات (حاقنات) الوقود", english: "Fuel injectors", category: "المحرك ونقل الحركة" },
  { libyanTerm: "مسطرة الرشاشات", standardArabic: "مسطرة توزيع الوقود عالي الضغط", english: "Fuel rail", category: "المحرك ونقل الحركة" },
  { libyanTerm: "بوبينة / بوبينات", standardArabic: "ملف إشعال الشرارة (الكويل)", english: "Ignition coil", category: "المحرك ونقل الحركة" },
  { libyanTerm: "شمعات / شمعة", standardArabic: "شمعات الاحتراق (شمعات الإشعال)", english: "Spark plugs (candele)", category: "المحرك ونقل الحركة" },
  { libyanTerm: "طاقم فاصل / فرسيوني", standardArabic: "طقم القابض (الدبرياج)", english: "Clutch kit (frizione)", category: "المحرك ونقل الحركة" },
  { libyanTerm: "سمياص", standardArabic: "عمود الدفع الجانبي (العكس/نصف العمود)", english: "Axle shaft / CV axle", category: "المحرك ونقل الحركة" },
  { libyanTerm: "قومة سمياص / كرشيرة", standardArabic: "غطاء مطاطي لمفصل السرعة (جلدة العكس)", english: "CV boot", category: "المحرك ونقل الحركة" },
  { libyanTerm: "كولوا", standardArabic: "عمود المرفق (الكرنك شافت)", english: "Crankshaft", category: "المحرك ونقل الحركة" },
  { libyanTerm: "امبروكم", standardArabic: "عمود الكامات (الكامشافت)", english: "Camshaft (albero a camme)", category: "المحرك ونقل الحركة" },
  { libyanTerm: "قرسيوني كوبيركو", standardArabic: "حشية غطاء الصمامات (جوان غطاء البلوف)", english: "Valve cover gasket", category: "المحرك ونقل الحركة" },
  { libyanTerm: "ستاقوبا / ستاقوبة", standardArabic: "حوض / كرتير زيت المحرك", english: "Oil pan / sump (coppa dell'olio)", category: "المحرك ونقل الحركة" },
  { libyanTerm: "فيلترو نافطة", standardArabic: "فلتر الديزل (مرشح الوقود للديزل)", english: "Diesel fuel filter", category: "المحرك ونقل الحركة" },
  { libyanTerm: "فيلترو بنزين / زيت", standardArabic: "فلتر البنزين وفلتر الزيت", english: "Fuel / Oil filter", category: "المحرك ونقل الحركة" },

  // 4. الحساسات ومنظومات الفحص الإلكتروني (OBD-II Sensors)
  { libyanTerm: "حساس الماف / حساس الهواء", standardArabic: "مستشعر كتلة تدفق الهواء", english: "Mass Air Flow Sensor (MAF)", category: "الكهرباء والحساسات" },
  { libyanTerm: "حساس الماب", standardArabic: "مستشعر ضغط مجمع السحب", english: "Manifold Absolute Pressure (MAP)", category: "الكهرباء والحساسات" },
  { libyanTerm: "حساس الكولوا / حساس الكرنك", standardArabic: "مستشعر موضع عمود الكرنك", english: "Crankshaft Position Sensor (CKP)", category: "الكهرباء والحساسات" },
  { libyanTerm: "حساس الامبروكم / حساس الكامة", standardArabic: "مستشعر موضع عمود الكامات", english: "Camshaft Position Sensor (CMP)", category: "الكهرباء والحساسات" },
  { libyanTerm: "حساس مرميطة علوي (قبل علبة الكربون)", standardArabic: "مستشعر الأكسجين الأمامي (Bank 1 Sensor 1)", english: "Upstream Oxygen (O2) Sensor", category: "الكهرباء والحساسات" , partSearchTerm: "Oxygen sensor"},
  { libyanTerm: "حساس مرميطة سفلي (بعد علبة الكربون)", standardArabic: "مستشعر الأكسجين الخلفي (Bank 1 Sensor 2)", english: "Downstream Oxygen (O2) Sensor", category: "الكهرباء والحساسات" , partSearchTerm: "Oxygen sensor"},
  { libyanTerm: "بوابة / راس انجكشن", standardArabic: "وحدة بوابة الهواء الخانقة الإلكترونية (الثروتل)", english: "Electronic Throttle Body (corpo farfallato)", category: "الكهرباء والحساسات" },
  { libyanTerm: "سنسور راس الإنجكشن / حساس راس انجكشن (TPS)", standardArabic: "مستشعر موضع بوابة الهواء / دعسة البنزين", english: "Throttle Position Sensor (TPS)", category: "الكهرباء والحساسات" },
  { libyanTerm: "حساس هواء العجلات (سنسور التواير)", standardArabic: "مستشعر ضغط هواء الإطارات (TPMS)", english: "Tire Pressure Sensor (TPMS)", category: "الكهرباء والحساسات" },
  { libyanTerm: "حساس النوك / سنسور الصرقعة", standardArabic: "مستشعر صفع واهتزاز المحرك", english: "Knock Sensor", category: "الكهرباء والحساسات" },
  { libyanTerm: "حساس حرارة الميه / سنسور السخونة", standardArabic: "مستشعر حرارة سائل التبريد", english: "Coolant Temperature Sensor (ECT)", category: "الكهرباء والحساسات" },
  { libyanTerm: "حساس الـ ABS / حساس سرعة العجلة", standardArabic: "مستشعر سرعة دوران العجلات", english: "Wheel Speed Sensor (ABS)", category: "الكهرباء والحساسات" },
  { libyanTerm: "حساس زاوية الستيرسو (SAS)", standardArabic: "مستشعر زاوية دوران عجلة القيادة", english: "Steering Angle Sensor", category: "الكهرباء والحساسات" },
  { libyanTerm: "بيانتو", standardArabic: "شبكة الأسلاك والضفيرة الكهربائية", english: "Wiring harness (impianto)", category: "الكهرباء والحساسات" },
  { libyanTerm: "علبة الفيوزات", standardArabic: "علبة الفيوزات (المصهرات)", english: "Fuse box (scatola fusibili)", category: "الكهرباء والحساسات" },
  { libyanTerm: "فيوزات / فيوزيبيلي", standardArabic: "الفيوزات", english: "Fuses (fusibili)", category: "الكهرباء والحساسات" },
  { libyanTerm: "لامبة تشك (Check Engine) / لامبة المحرك", standardArabic: "مصباح تحذير فحص المحرك في الطبلون", english: "Check Engine Warning Light", category: "الكهرباء والحساسات" , partSearchTerm: null},
  { libyanTerm: "مورسيتي", standardArabic: "أطراف/قطبان البطارية", english: "Battery terminals (morsetti)", category: "الكهرباء والحساسات" },
  { libyanTerm: "تماتك المروحة", standardArabic: "وحدة تحكم تشغيل مروحة التبريد", english: "Fan controller module", category: "الكهرباء والحساسات" },

  // 5. التبريد والزيوت والتكييف
  { libyanTerm: "كمبريسوري", standardArabic: "ضاغط التكييف (الكمبروسر)", english: "A/C Compressor (compressore)", category: "التبريد والتكييف" , partSearchTerm: "Air conditioning compressor"},
  { libyanTerm: "رداتوري المكيف / رادياتير المكيف", standardArabic: "مكثف التكييف (رادياتير المكيف)", english: "A/C Condenser (condensatore)", category: "التبريد والتكييف" , partSearchTerm: "Air conditioning condenser"},
  { libyanTerm: "رداتوري / راداتوري", standardArabic: "المشعاع (رادياتير تبريد المحرك)", english: "Radiator (radiatore)", category: "التبريد والتكييف" },
  { libyanTerm: "مروحة الرداتوري", standardArabic: "مروحة تبريد المحرك الكهربائية", english: "Radiator cooling fan", category: "التبريد والتكييف" },
  { libyanTerm: "مناكوطي / توبو", standardArabic: "خرطوم الرادياتير المطاطي الموصل", english: "Radiator hose (manicotto / tubo)", category: "التبريد والتكييف" },
  { libyanTerm: "ثلاجة التكييف / المبخر الداخلي", standardArabic: "مبخر التكييف الداخلي تحت التابلو", english: "A/C evaporator core (evaporatore)", category: "التبريد والتكييف" , partSearchTerm: "Evaporator core"},
  { libyanTerm: "صمام انتشار", standardArabic: "صمام تمدد غاز التبريد (إكسبانشن فالف)", english: "A/C expansion valve", category: "التبريد والتكييف" , partSearchTerm: "Thermal expansion valve"},
  { libyanTerm: "بومبة ميه", standardArabic: "مضخة مياه التبريد", english: "Water pump (pompa acqua)", category: "التبريد والتكييف" },
  { libyanTerm: "قربة", standardArabic: "خزان توسعة سائل التبريد (مطارة الرداتوري)", english: "Coolant reservoir / expansion tank", category: "التبريد والتكييف" },
  { libyanTerm: "ترموستات", standardArabic: "منظم حرارة المحرك (بلف الحرارة)", english: "Thermostat", category: "التبريد والتكييف" },

  // 6. الفرامل والعادم
  { libyanTerm: "فرينو / فرامل", standardArabic: "المكابح (الفرامل)", english: "Brakes (freno)", category: "الفرامل والعادم" },
  { libyanTerm: "بومبة فرينو", standardArabic: "أسطوانة الفرامل الرئيسية (ماستر الفرامل)", english: "Brake master cylinder (pompa freno)", category: "الفرامل والعادم" },
  { libyanTerm: "باطني / باطنيات", standardArabic: "تيل الفرامل القرصية (الفحمات)", english: "Brake pads", category: "الفرامل والعادم" },
  { libyanTerm: "فرودي", standardArabic: "تيل الفرامل الخلفية الطبلية (القماشات)", english: "Brake shoes (ferodi)", category: "الفرامل والعادم" },
  { libyanTerm: "طنبور / طمبور", standardArabic: "أسطوانة الفرامل الخلفية", english: "Brake drum (tamburo)", category: "الفرامل والعادم" },
  { libyanTerm: "علبة كربون المرميطة", standardArabic: "محول الحفاز / دبة التلوث والبيئة (الكاتالايزر)", english: "Catalytic converter", category: "الفرامل والعادم" },
  { libyanTerm: "دبة الديزل / فيلترو DPF", standardArabic: "مرشح جسيمات عادم الديزل", english: "Diesel particulate filter (DPF)", category: "الفرامل والعادم" },
  { libyanTerm: "فالف الـ EGR", standardArabic: "صمام إعادة تدوير غازات العادم", english: "EGR valve", category: "الفرامل والعادم" },
  { libyanTerm: "قربة الفحم / فالف التبخير (EVAP)", standardArabic: "نظام تبخير غازات خزان الوقود", english: "EVAP canister & purge valve", category: "الفرامل والعادم" },
  { libyanTerm: "كاتم المرميطة / دبة الرنين", standardArabic: "كاتم صوت العادم الأوسط أو الخلفي", english: "Exhaust muffler / resonator", category: "الفرامل والعادم" },
  { libyanTerm: "مرميطة / مارميطا", standardArabic: "أنظمة ماسورة العادم بالكامل", english: "Exhaust system (marmitta)", category: "الفرامل والعادم" , partSearchTerm: "Muffler"},

  // 7. التعليق والتوجيه (الصالة)
  { libyanTerm: "مزطوري / مزاطوري", standardArabic: "ماص الصدمات (المساعد)", english: "Shock absorber (ammortizzatore)", category: "التعليق والصالة" },
  { libyanTerm: "المزاطوري الهوائي / بالونة الهواء", standardArabic: "المساعد الهوائي/الهيدروليكي", english: "Air suspension strut / airbag", category: "التعليق والصالة" },
  { libyanTerm: "كوشينتي / كوشينيتي", standardArabic: "محمل العجلة (البلي بيرنغ)", english: "Wheel bearing (cuscinetto)", category: "التعليق والصالة" },
  { libyanTerm: "كروتشيرة / كرشيرة", standardArabic: "الصليبة (مفصل الكردان أو العكس)", english: "Universal joint (crociera)", category: "التعليق والصالة" },
  { libyanTerm: "سكاتولا / سكاتلة", standardArabic: "علبة التوجيه (الدودة/الدركسيون)", english: "Steering rack / box (scatola guida)", category: "التعليق والصالة" },
  { libyanTerm: "ستيرسو / دومان", standardArabic: "عجلة القيادة وجهاز التوجيه", english: "Steering wheel (sterzo)", category: "التعليق والصالة" },
  { libyanTerm: "بومبة ستيرسو", standardArabic: "مضخة الدركسيون المعزز", english: "Power steering pump", category: "التعليق والصالة" },
  { libyanTerm: "براتشو / دراع", standardArabic: "ذراع التعليق (المقص)", english: "Control arm (braccio)", category: "التعليق والصالة" },
  { libyanTerm: "فوزيلي / فازيلي", standardArabic: "مفصل التعليق الكروي (الجوزة/الركبة)", english: "Ball joint (fusello)", category: "التعليق والصالة" },
  { libyanTerm: "نوتشي / نيوتشي", standardArabic: "رأس ذراع التوجيه (الطرف / أذرعة الدركسيون)", english: "Tie rod end (snodo / nocella)", category: "التعليق والصالة" },
  { libyanTerm: "مسمار ميزان", standardArabic: "وصلة قضيب التوازن (الاستابيلايزر)", english: "Sway bar link / stabilizer link", category: "التعليق والصالة" },
  { libyanTerm: "بوكلة / بوكلات (سيبورت الصالة)", standardArabic: "جلب ومشابك تثبيت قنطرة الشاسيه والصالة", english: "Subframe mounts / bushings / brackets", category: "التعليق والصالة" },
  { libyanTerm: "موتسو", standardArabic: "صرة/محور العجلة (الهب)", english: "Wheel hub (mozzo)", category: "التعليق والصالة" },
  { libyanTerm: "قوميني / جلب", standardArabic: "جلب مطاطية للمقصات والصالة (بوشات)", english: "Rubber bushings (gommini)", category: "التعليق والصالة" },

  // 8. سيارات الهايبرد والكهرباء
  { libyanTerm: "بطارية الهايبرد (الجهد العالي)", standardArabic: "بطارية الجر للسيارات الهجينة", english: "High Voltage Hybrid Battery", category: "المحرك ونقل الحركة" },
  { libyanTerm: "الانفرتر / محول كهرباء الهايبرد", standardArabic: "العاكس ومحول الطاقة الإلكتروني", english: "Inverter / Converter Assembly", category: "المحرك ونقل الحركة" },
  { libyanTerm: "بومبة ميه الانفرتر الكهربائية", standardArabic: "مضخة تبريد وحدة الهايبرد الكهربائية", english: "Inverter Electric Water Pump", category: "التبريد والتكييف" },

  // 9. عمليات وخدمات الورشة اليومية
  { libyanTerm: "تصفية محرك / تصفية شماعي وبخاخات", standardArabic: "صيانة وضبط أداء المحرك الشاملة", english: "Engine Tune-up", category: "عام وإداري" , partSearchTerm: null},
  { libyanTerm: "تسييخ رداتوري", standardArabic: "تنظيف وتسليك مجاري الرادياتير", english: "Radiator Rodding / Descaling", category: "التبريد والتكييف" },
  { libyanTerm: "خرط ديسكوات", standardArabic: "تسوية وتجليخ أقراص الفرامل", english: "Brake Rotor Resurfacing", category: "الفرامل والعادم" },
  { libyanTerm: "غسيل وتبديل زيت كمبيو (فلاش)", standardArabic: "استبدال زيت ناقل الحركة بالتدوير الكامل", english: "Transmission Fluid Flush", category: "المحرك ونقل الحركة" , partSearchTerm: null},
  { libyanTerm: "تنظيف وبرمجة راس انجكشن (كالبريشن)", standardArabic: "تنظيف ومعايرة بوابة الهواء الخانقة", english: "Throttle Body Cleaning & Re-learn", category: "المحرك ونقل الحركة" , partSearchTerm: null},
  { libyanTerm: "تصفير لامبة تشك / تصفير السيرفيز", standardArabic: "إعادة ضبط مؤشر الصيانة ومسح لمبة المحرك", english: "Check Engine / Service Reset", category: "عام وإداري" , partSearchTerm: null},
];

export function getDictionaryContextForPrompt(): string {
  return LIBYAN_DICTIONARY.map(
    (item) =>
      `- [${item.category}] المصطلح الدارج في ليبيا: "${item.libyanTerm}" = بالفصحى: "${item.standardArabic}" = بالإنجليزي: "${item.english}"`
  ).join("\n");
}

export function findMatchingTerm(query: string): DictionaryEntry | undefined {
  const q = query.toLowerCase().trim();
  return LIBYAN_DICTIONARY.find(
    (item) =>
      item.libyanTerm.toLowerCase().includes(q) ||
      item.standardArabic.toLowerCase().includes(q) ||
      item.english.toLowerCase().includes(q)
  );
}

/**
 * The English names for a Libyan part name.
 *
 * The photo lookup searches an English-language archive, but the report often
 * names a part only in Libyan — "براتشو", "مزاطوري", "قرسيوني كوبيركو" — and
 * an English archive has never heard of any of them. This walks the same
 * dictionary the app already shows the reader and turns the Libyan name into
 * something searchable.
 *
 * Matching runs the other way round from `findMatchingTerm`: there the query
 * is the fragment, here the part name is the haystack and the dictionary entry
 * is the fragment. Longest entries first, so "بومبة بنزين" wins over "بومبة".
 */
export function englishTermsFor(partName: string): string[] {
  const haystack = partName.trim();
  if (!haystack) return [];

  const found: { term: string; entry: DictionaryEntry }[] = [];
  for (const entry of LIBYAN_DICTIONARY) {
    // Entries list their spellings as "شمعات / شمعة"; any of them counts. Each is
    // also tried without its parenthetical, because the dictionary writes the
    // full disambiguated name and a report writes the short one: the entry
    // "حساس مرميطة علوي (قبل علبة الكربون)" never matched the "حساس مرميطة علوي" a scan
    // actually produces, so the only thing that matched was "مرميطة" and an
    // oxygen sensor was answered with a muffler.
    const variants = entry.libyanTerm.split("/").flatMap((variant) => {
      const full = variant.trim();
      const withoutAside = full.replace(/\s*\([^)]*\)\s*/g, " ").replace(/\s+/g, " ").trim();
      return withoutAside && withoutAside !== full ? [full, withoutAside] : [full];
    });

    // Longest first, so the most specific spelling is the one recorded.
    for (const term of variants.sort((a, b) => b.length - a.length)) {
      if (term.length >= 3 && haystack.includes(term)) {
        found.push({ term, entry });
        break;
      }
    }
  }

  found.sort((a, b) => b.term.length - a.term.length);

  /**
   * The gloss, reduced to something an archive can be searched with.
   *
   * It reads "Gearbox / transmission (cambio)" — written for a person, not for
   * a query — so the alternative spelling and the Italian original come off.
   *
   * The slash is only a separator when it separates words. Splitting on it
   * blindly turned "A/C Compressor (compressore)" into the letter "A", and
   * four of the air-conditioning entries searched for that. A bracket is only
   * a trailing aside when something is already in front of it: cutting at it
   * unconditionally reduced "Upstream Oxygen (O2) Sensor" to "Upstream
   * Oxygen", losing the word that named the component.
   */
  const clean = (english: string) => {
    const withoutAside = english.replace(/\s*[([][^)\]]*[)\]]\s*/g, " ");
    const firstAlternative = withoutAside.split(/\s+\/\s+|\s+or\s+/i)[0];
    return firstAlternative.replace(/\s+/g, " ").trim();
  };

  return [
    ...new Set(
      found
        // `null` says outright that this term is not a part. Labour, a
        // diagnosis, a service interval and a salvage yard are all in here,
        // and an image archive asked for any of them answers with something.
        .filter((f) => f.entry.partSearchTerm !== null)
        .map((f) => f.entry.partSearchTerm ?? clean(f.entry.english))
        .filter(Boolean)
    ),
  ];
}

