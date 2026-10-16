// 64 Dashboard Warning Lights - Stamped Fuse Box & Cluster Spec
// Synchronized with Libyan automotive dictionary and ISO standards

export interface DashboardLightItem {
  number: number;
  id: string;
  nameArabic: string;
  nameEnglish: string;
  severity: "critical" | "warning" | "info";
  canDrive: "stopImmediately" | "driveCarefully" | "normal";
  symbolCode: string;
  meaningArabic: string;
  commonCauses: string[];
  actionRequired: string;
  associatedDTCs: string[];
  colorHex: string;
}

export const DASHBOARD_LIGHTS: DashboardLightItem[] = [
  {
    "number": 1,
    "id": "front_fog_lights",
    "nameArabic": "كشافات الضباب",
    "nameEnglish": "Front Fog Lights Active",
    "severity": "info",
    "canDrive": "normal",
    "symbolCode": "FOG_FR",
    "meaningArabic": "مصابيح وكشافات الضباب الأمامية قيد التشغيل لإنارة الطريق في الأجواء المغبرة والضباب.",
    "commonCauses": [
      "تشغيل سويتش مصابيح الضباب يدوياً أو تلقائياً"
    ],
    "actionRequired": "حالة تشغيلية عادية. أطفئها عند وضوح الرؤية لتوفير استهلاك اللمبات والبطارية.",
    "associatedDTCs": [],
    "colorHex": "#43A047"
  },
  {
    "number": 2,
    "id": "steering_eps",
    "nameArabic": "الباور ستيرنج",
    "nameEnglish": "Power Steering System Warning",
    "severity": "critical",
    "canDrive": "driveCarefully",
    "symbolCode": "EPS",
    "meaningArabic": "تعطل موطور المساعدة الكهربائية أو منظومة الهيدروليك في ستيرسو ودومان السيارة (الباور ستيرنج).",
    "commonCauses": [
      "احتراق فيوز التوجيه الكهربائي العريض (EPS Fuse)",
      "عطل في حساس زاوية التوجيه (Steering Angle Sensor)",
      "نقص زيت هيدروليك الستيرنج أو عطل موطور الدومان الكهربائي"
    ],
    "actionRequired": "الستيرسو سيصبح ثقيلاً ومتصلباً للغاية خصوصاً عند الوقوف. قد بحذر شديد وباليدين معاً وتوجه لورشة الصيانة الكهربائية.",
    "associatedDTCs": [
      "C1511",
      "C1515",
      "C1521",
      "U0131"
    ],
    "colorHex": "#E53935"
  },
  {
    "number": 3,
    "id": "rear_fog_light",
    "nameArabic": "ضوء الضباب الخلفي",
    "nameEnglish": "Rear Fog Light Active",
    "severity": "warning",
    "canDrive": "normal",
    "symbolCode": "FOG_RR",
    "meaningArabic": "مصباح الضباب الخلفي شديد التوهج قيد التشغيل لتنبيه السيارات القادمة من الخلف.",
    "commonCauses": [
      "تشغيل زر ضباب الخلفي في الأجواء الصعبة"
    ],
    "actionRequired": "أطفئه فور تحسن الرؤية لمنع إبهار ومضايقة سائقي السيارات في الخلف.",
    "associatedDTCs": [],
    "colorHex": "#FDD835"
  },
  {
    "number": 4,
    "id": "washer_fluid",
    "nameArabic": "ماء المساحات",
    "nameEnglish": "Low Washer Fluid Level",
    "severity": "warning",
    "canDrive": "normal",
    "symbolCode": "WASHER",
    "meaningArabic": "انخفاض مستوى ماء المساحات في قربة رشاشات الزجاج الأمامي أو الخلفي.",
    "commonCauses": [
      "نفاد ماء المساحات نتيجة الاستخدام المتكرر أو تسريب بالقربة"
    ],
    "actionRequired": "افتح الكبوت وأعد تعبئة قربة المساحات بالماء مع سائل تنظيف الزجاج.",
    "associatedDTCs": [],
    "colorHex": "#FDD835"
  },
  {
    "number": 5,
    "id": "brake_pads",
    "nameArabic": "ضوء المماشات يعني باطني (تآكل باطنيات الفرامل)",
    "nameEnglish": "Brake Pad Wear Warning",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "PAD_WEAR",
    "meaningArabic": "سماكة باطنيات (فحمات / قماشات) الفرامل وصلت للحد الأدنى واقتربت من ملامسة ديسكوات العجلات.",
    "commonCauses": [
      "تآكل مادة الاحتكاك في باطنيات الديسكو",
      "انقطاع أو تلف سلك حساس التآكل المثبت على الباطنيات"
    ],
    "actionRequired": "توجه لورشة الميكانيكا لتغيير باطنيات الديسكو وتفادي خدش وتلف ديسكوات الفرامل.",
    "associatedDTCs": [
      "C1001",
      "C1002"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 6,
    "id": "cruise_control",
    "nameArabic": "مثبت السرعة",
    "nameEnglish": "Cruise Control System Active",
    "severity": "info",
    "canDrive": "normal",
    "symbolCode": "CRUISE",
    "meaningArabic": "نظام تثبيت السرعة التلقائي (Cruise Control) قيد العمل ومضبوط على سرعة السير الحالية.",
    "commonCauses": [
      "الضغط على زر SET / CRUISE في المقود"
    ],
    "actionRequired": "حالة تشغيلية طبيعية. يلغى التثبيت فور لمس دواسة الفرامل.",
    "associatedDTCs": [],
    "colorHex": "#43A047"
  },
  {
    "number": 7,
    "id": "turn_signals",
    "nameArabic": "لمبة الاتجاهات (يمين / يسار)",
    "nameEnglish": "Turn Signals / Direction Indicators",
    "severity": "info",
    "canDrive": "normal",
    "symbolCode": "TURN_SIG",
    "meaningArabic": "إشارات وتنبيهات الاتجاهات (يمين / يسار) أو الفليشر الرباعي قيد الوميض.",
    "commonCauses": [
      "تحريك ذراع الإشارة يميناً أو يساراً، أو الضغط على زر الفليشر الرباعي"
    ],
    "actionRequired": "إذا كانت اللمبة ترمش بسرعة غير معتادة فهذا دليل على احتراق إحدى لمبات الإشارة الخارجية.",
    "associatedDTCs": [],
    "colorHex": "#43A047"
  },
  {
    "number": 8,
    "id": "rain_light_sensor",
    "nameArabic": "حساس المطر والضوء",
    "nameEnglish": "Rain and Light Sensor Fault",
    "severity": "warning",
    "canDrive": "normal",
    "symbolCode": "RAIN_LIGHT",
    "meaningArabic": "خلل في حساس المطر والإضاءة التلقائية المثبت خلف المرآة الوسطية بالزجاج الأمامي.",
    "commonCauses": [
      "اتساخ أو كسر الزجاج الأمامي في موضع الحساس",
      "فصل فيش الحساس أو فقاعات هواء في لاصق الجل الخاص به"
    ],
    "actionRequired": "نظف الزجاج الأمامي وتأكد من إمكانية تشغيل المساحات والإنارة يدوياً.",
    "associatedDTCs": [
      "B1052",
      "B1053"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 9,
    "id": "winter_mode",
    "nameArabic": "وضعية الشتاء",
    "nameEnglish": "Winter Mode / Low Traction Program",
    "severity": "info",
    "canDrive": "normal",
    "symbolCode": "WINTER",
    "meaningArabic": "وضعية وبرنامج الشتاء في كمبيو السيارة مفعلة لتقليل عزم الانطلاق ومنع انزلاق العجلات على الجليد أو الوحل.",
    "commonCauses": [
      "الضغط على زر W بجانب عصا الكمبيو أو انخفاض درجة الحرارة الخارجية"
    ],
    "actionRequired": "وضع تشغيلي خاص بالانزلاق يجعل انطلاق الكمبيو بالغيار الثاني أو الثالث.",
    "associatedDTCs": [],
    "colorHex": "#1E88E5"
  },
  {
    "number": 10,
    "id": "info_message",
    "nameArabic": "مؤشر المعلومات",
    "nameEnglish": "Information Message Indicator",
    "severity": "info",
    "canDrive": "normal",
    "symbolCode": "INFO_MSG",
    "meaningArabic": "توجد رسالة معلوماتية أو تنبيه في شاشة لوحة العدادات (مثل فتح خزان الوقود أو تذكير معين).",
    "commonCauses": [
      "وجود رسالة نصية غير مقروءة بشاشة الطبلون"
    ],
    "actionRequired": "تصفح أزرار شاشة الطبلون من الستيرسو لقراءة نص التنبيه.",
    "associatedDTCs": [],
    "colorHex": "#1E88E5"
  },
  {
    "number": 11,
    "id": "glow_dpf",
    "nameArabic": "مؤشر الاشعال / سيارات الديزل",
    "nameEnglish": "Diesel Glow Plug Warning",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "GLOW_PLUG",
    "meaningArabic": "شمعات الإشعال والتسخين لمحرك الديزل قيد الإحماء، أو وجود خلل في دائرة شمعات التسخين إذا استمرت بعد التشغيل.",
    "commonCauses": [
      "انتظار إحماء غرف الاحتراق قبل تشغيل الموتورينو",
      "تلف إحدى شمعات تسخين الديزل أو ريليه التحكم الخاص بها"
    ],
    "actionRequired": "انتظر حتى تنطفئ اللمبة قبل تدوير المارش. إذا ظلت تومض أثناء السير فافحص شمعات التسخين بجهاز الكشف.",
    "associatedDTCs": [
      "P0380",
      "P0381",
      "P0670",
      "P0671"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 12,
    "id": "frost_warning",
    "nameArabic": "مؤشر التجمد / الصفيح",
    "nameEnglish": "Frost / Icy Road Warning",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "FROST",
    "meaningArabic": "مؤشر انخفاض الحرارة واحتمال التجمد والصفيح أو الجليد على الطريق (أقل من 4 درجات مئوية).",
    "commonCauses": [
      "انخفاض حرارة الجو الخارجية المسجلة بحساس المرآة"
    ],
    "actionRequired": "قد بحذر وخفف السرعة في المنعطفات والجسور لتجنب انزلاق القومّات على الصقيع.",
    "associatedDTCs": [],
    "colorHex": "#FDD835"
  },
  {
    "number": 13,
    "id": "ignition_key_warning",
    "nameArabic": "مؤشر تحذيري لمفتاح التشغيل",
    "nameEnglish": "Ignition Key / Immobilizer Warning",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "KEY_IMMO",
    "meaningArabic": "مؤشر تحذيري لمفتاح التشغيل: كمبيوتر السيارة لم يتعرف على شفرة المفتاح أو وجود خلل بمنظومة الإيموبلايزر والحماية ضد السرقة.",
    "commonCauses": [
      "تلف شفرة المفتاح أو ضعف حلقة الهوائي بقفل السويتش",
      "عدم مطابقة كود المفتاح مع كمبيوتر المحرك (ECU)"
    ],
    "actionRequired": "جرب المفتاح الاحتياطي، وإذا لم يدور المحرك فيجب إعادة برمجة شفرة المفتاح.",
    "associatedDTCs": [
      "B3040",
      "B3055",
      "P1610",
      "P1614"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 14,
    "id": "key_not_detected",
    "nameArabic": "المفتاح غير موجود بالسيارة (السيارات المزودة بالبصمة)",
    "nameEnglish": "Smart Key Not Detected",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "KEY_ABSENT",
    "meaningArabic": "المفتاح غير موجود بالسيارة للسيارات المزودة بالبصمة (لم يتم رصد ريموت المفتاح داخل المقصورة أثناء التشغيل أو القيادة).",
    "commonCauses": [
      "المفتاح خارج السيارة أو في جيب شخص غادر المركبة",
      "نفاد حجر (بطارية) الريموت",
      "تشويش لاسلكي على حساسات الاستقبال الداخلية"
    ],
    "actionRequired": "تأكد من وجود الريموت داخل المقصورة، أو قربه من زر التشغيل مباشرة للطوارئ.",
    "associatedDTCs": [
      "B13D3",
      "B1A56"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 15,
    "id": "key_fob_battery",
    "nameArabic": "بطارية ضعيفة / مفتاح البصمة",
    "nameEnglish": "Key Fob Battery Low",
    "severity": "warning",
    "canDrive": "normal",
    "symbolCode": "KEY_BATT",
    "meaningArabic": "بطارية ضعيفة في مفتاح البصمة والريموت وتوشك على النفاد.",
    "commonCauses": [
      "استهلاك شحنة بطارية الريموت بعد فترة استخدام طويلة"
    ],
    "actionRequired": "قم بفتح الريموت واستبدال بطارية الزر (غالباً CR2032) لتفادي صعوبة فتح وتشغيل السيارة.",
    "associatedDTCs": [
      "B13D5"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 16,
    "id": "distance_collision_warning",
    "nameArabic": "مؤشر المسافة / السيارات المزودة بالرادار",
    "nameEnglish": "Distance Warning / Collision Alert",
    "severity": "critical",
    "canDrive": "driveCarefully",
    "symbolCode": "COLLISION",
    "meaningArabic": "مؤشر المسافة للسيارات المزودة بالرادار: اقتراب خطر وسريع من السيارة التي أمامك، أو اتساخ رادار الصدام الأمامي.",
    "commonCauses": [
      "عدم ترك مسافة أمان كافية مع المركبة الأمامية",
      "تراكم الطين أو الغبار على رادار الصدام الأمامي أو كاميرا الزجاج"
    ],
    "actionRequired": "اضغط الفرامل فوراً وزد مسافة الأمان، ونظف حساس الرادار بالصدام الأمامي.",
    "associatedDTCs": [
      "C1A14",
      "C1A16"
    ],
    "colorHex": "#E53935"
  },
  {
    "number": 17,
    "id": "press_clutch",
    "nameArabic": "دواسة الكلتش",
    "nameEnglish": "Press Clutch Pedal Indicator",
    "severity": "info",
    "canDrive": "normal",
    "symbolCode": "CLUTCH_PED",
    "meaningArabic": "تنبيه الضغط على دواسة الكلتش (الدبرياج) ليسمح كمبيوتر السيارة بتشغيل المحرك.",
    "commonCauses": [
      "نظام أمان يمنع دوران الموتورينو إلا عند فصل الكلتش"
    ],
    "actionRequired": "اضغط دواسة الكلتش حتى النهاية ثم اضغط زر أو سويتش التشغيل.",
    "associatedDTCs": [],
    "colorHex": "#43A047"
  },
  {
    "number": 18,
    "id": "press_brake",
    "nameArabic": "دواسة البريك",
    "nameEnglish": "Press Brake Pedal Indicator",
    "severity": "info",
    "canDrive": "normal",
    "symbolCode": "BRAKE_PED",
    "meaningArabic": "مؤشر وتنبيه الضغط على دواسة البريك (الفرامل) لتحرير عصا الكمبيو من وضع (P) أو لبدء التشغيل.",
    "commonCauses": [
      "قفل أمان كمبيو الأوتوماتيك والتشغيل"
    ],
    "actionRequired": "اضغط على دواسة الفرامل قبل تحريك عصا الكمبيو أو الضغط على زر البصمة.",
    "associatedDTCs": [],
    "colorHex": "#43A047"
  },
  {
    "number": 19,
    "id": "steering_lock",
    "nameArabic": "قفل الستيرنج",
    "nameEnglish": "Steering Column Lock Warning",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "STR_LOCK",
    "meaningArabic": "تحذير قفل الستيرنج (دومان التوجيه): خلل في قفل المقود الكهربائي (ESL) أو صعوبة فك القفل الميكانيكي للمقود.",
    "commonCauses": [
      "ضغط العجلات على الرصيف مما يشد قفل الستيرسو",
      "تلف موطور قفل عمود التوجيه الإلكتروني (ELV/ESL)"
    ],
    "actionRequired": "حرك عجلة الستيرسو يميناً ويساراً مع الضغط على زر التشغيل لتحرير القفل الميكانيكي.",
    "associatedDTCs": [
      "B1026",
      "B2570",
      "U0140"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 20,
    "id": "high_beam",
    "nameArabic": "الضوء العالي",
    "nameEnglish": "High Beam Headlights Active",
    "severity": "info",
    "canDrive": "normal",
    "symbolCode": "HIGH_BEAM",
    "meaningArabic": "الفنارات والمصابيح الأمامية للسيارة مشتغلة على وضع الضوء العالي الكاشف.",
    "commonCauses": [
      "دفع ذراع الإضاءة بالستيرسو للأمام"
    ],
    "actionRequired": "قم بخفض الضوء للواطي عند وجود سيارات قادمة في الاتجاه المعاكس.",
    "associatedDTCs": [],
    "colorHex": "#1E88E5"
  },
  {
    "number": 21,
    "id": "tpms_pressure",
    "nameArabic": "مؤشر ضغط الاطارات",
    "nameEnglish": "Tire Pressure Monitoring Warning",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "TPMS",
    "meaningArabic": "مؤشر ضغط الإطارات (TPMS): إحدى إطارات وقومّات السيارة تعاني من نقص واضح في ضغط الهواء.",
    "commonCauses": [
      "وجود مسمار أو تسريب بطيء بهواء القومة",
      "تغير درجة حرارة الجو أو ضعف بطارية حساس البلف الداخلي"
    ],
    "actionRequired": "توجه لورشة القومّات (البيلكانو) واضبط الضغط على 32-35 PSI وتفقد السبير (العجلة الاحتياط).",
    "associatedDTCs": [
      "C2111",
      "C2112",
      "C2113",
      "C2114"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 22,
    "id": "side_lights",
    "nameArabic": "مؤشر الاضاءة الجانبية",
    "nameEnglish": "Side / Parking Lights Active",
    "severity": "info",
    "canDrive": "normal",
    "symbolCode": "SIDE_LGT",
    "meaningArabic": "مؤشر الإضاءة الجانبية وأنوار الموقف (السمول لايت) قيد التشغيل.",
    "commonCauses": [
      "تدوير مفتاح الإضاءة للتكة الأولى"
    ],
    "actionRequired": "حالة تشغيلية عادية. أطفئها عند ركن السيارة لمنع تفريغ شحن البطارية.",
    "associatedDTCs": [],
    "colorHex": "#43A047"
  },
  {
    "number": 23,
    "id": "bulb_failure",
    "nameArabic": "فشل بالاضاءة الخارجية",
    "nameEnglish": "Exterior Light Bulb Failure",
    "severity": "warning",
    "canDrive": "normal",
    "symbolCode": "BULB_FAIL",
    "meaningArabic": "فشل واحتراق بالإضاءة الخارجية: كمبيوتر الإضاءة رصد احتراق لمبة خارجية (فنار، إشارة، فرامل، أو لوحة).",
    "commonCauses": [
      "احتراق فتيلة إحدى اللمبات الخارجية",
      "تركيب لمبات LED تجارية بدون مقاومة كانباس (Canbus error)"
    ],
    "actionRequired": "قم بجولة حول السيارة وتفقد جميع المصابيح واستبدل اللمبة المحترقة.",
    "associatedDTCs": [
      "B3881",
      "B3882",
      "B3883"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 24,
    "id": "brake_system",
    "nameArabic": "تحذير / لمبة البريك",
    "nameEnglish": "Brake System Warning",
    "severity": "critical",
    "canDrive": "stopImmediately",
    "symbolCode": "BRAKE_SYS",
    "meaningArabic": "تحذير لمبة البريك (!): نقص حاد في مستوى زيت الفرامل أو هبوط الضغط الهيدروليكي بمنظومة الفرامل.",
    "commonCauses": [
      "تسريب في أنابيب زيت الفرامل أو بستم العجلات",
      "تآكل باطنيات الديسكو لحد أفرغ مخزون العلبة",
      "عطل في سيرفو تعزيز الفرامل"
    ],
    "actionRequired": "⛔ توقف فوراً ولا تقم بالقيادة إذا كانت الدواسة إسفنجية أو تهبط للأرضية! افحص علبة زيت الفرامل وتأكد من عدم وجود تسريب.",
    "associatedDTCs": [
      "C0040",
      "C0045",
      "C0049"
    ],
    "colorHex": "#E53935"
  },
  {
    "number": 25,
    "id": "dpf_filter",
    "nameArabic": "تحذير / فلتر الديزل",
    "nameEnglish": "Diesel Particulate Filter (DPF) Warning",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "DPF_FILT",
    "meaningArabic": "تحذير فلتر الديزل (DPF): انسداد وتراكم السخام والكربون في فلتر جزيئات المرميطة بمحركات الديزل.",
    "commonCauses": [
      "كثرة المشاوير القصيرة داخل المدينة دون إتاحة فرصة للتنظيف الذاتي",
      "خلل في حساس الضغط التفاضلي لمرميطة الديزل"
    ],
    "actionRequired": "قم بالقيادة على طريق سريع بسرعة ثابتة (80-100 كم/س) لمدة 20 دقيقة لإكمال دورة الحرق التلقائي.",
    "associatedDTCs": [
      "P2458",
      "P2463",
      "P242F"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 26,
    "id": "trailer_hitch",
    "nameArabic": "نظام ربط المقطورة للشاحنات",
    "nameEnglish": "Trailer Hitch / Towbar Warning",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "TOW_HITCH",
    "meaningArabic": "نظام ربط المقطورة للشاحنات والسيارات: قفل وصلة سحب المقطورة الخلفية غير مقفل بإحكام أو عطل بتوصيلات المقطورة.",
    "commonCauses": [
      "عدم تثبيت هوك السحب الخلفي بالشكل الصحيح",
      "تماس أو خلل في فيشة إضاءة العربة المجرورة"
    ],
    "actionRequired": "تأكد من إحكام إغلاق قفل هوك المقطورة وسلامة التوصيلات قبل التحرك.",
    "associatedDTCs": [
      "B10E7"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 27,
    "id": "air_suspension",
    "nameArabic": "نظام الهيدروليك",
    "nameEnglish": "Air Suspension Fault",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "AIR_SUSP",
    "meaningArabic": "عطل نظام الهيدروليك والتعليق الهوائي: خلل في كمبروسر أو بالونات الهواء وانخفاض مستوى ارتفاع السيارة.",
    "commonCauses": [
      "تنسيم أو ثقب في بالونة الهواء الخاصة بالتعليق",
      "تلف كمبروسر الهواء أو بلف توزيع الارتفاع",
      "عطل في حساس مستوى الارتفاع المثبت بالمزاطوريات"
    ],
    "actionRequired": "قد بحذر وتجنب المطبات العالية وتوجه لورشة متخصصة لفحص تسريب بالونات التعليق.",
    "associatedDTCs": [
      "C1A20",
      "C1A13",
      "C1A30"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 28,
    "id": "lane_departure",
    "nameArabic": "نظام التوجيه - للمسارات",
    "nameEnglish": "Lane Departure Warning",
    "severity": "warning",
    "canDrive": "normal",
    "symbolCode": "LANE_DEP",
    "meaningArabic": "نظام التوجيه للمسارات وتحذير الخروج عن المسار: انحراف عن مسار الطريق دون تشغيل الإشارة أو تعطل كاميرا التتبع.",
    "commonCauses": [
      "تجاوز الخطوط البيضاء دون استخدام إشارة الستيرسو",
      "اتساخ كاميرا التتبع المثبتة أعلى الزجاج الأمامي"
    ],
    "actionRequired": "انتبه لمسار الطريق، ونظف الزجاج الأمامي أمام الكاميرا.",
    "associatedDTCs": [
      "C1A67",
      "B12BE"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 29,
    "id": "catalytic_converter",
    "nameArabic": "نظام تحويل التدفيل",
    "nameEnglish": "Catalytic Converter Overheating",
    "severity": "critical",
    "canDrive": "stopImmediately",
    "symbolCode": "CAT_CONV",
    "meaningArabic": "نظام تحويل التدفيل وسخونة علبة البيئة بالمرميطة: ارتفاع حرارة علبة التلوث نتيجة وصول وقود غير محترق إليها.",
    "commonCauses": [
      "فطفطة قوية في الشمعات أو البوبينات (Misfire) تسرب الوقود للمرميطة",
      "انسداد شديد في حجر البيئة وتجمع الكربون"
    ],
    "actionRequired": "⛔ توقف فوراً وأطفئ المحرك! استمرار السير بهذا الوضع يؤدي لانصهار علبة البيئة واشتعال حريق أسفل السيارة.",
    "associatedDTCs": [
      "P0420",
      "P0421",
      "P0430"
    ],
    "colorHex": "#E53935"
  },
  {
    "number": 30,
    "id": "seatbelt_warning",
    "nameArabic": "حزام الامان",
    "nameEnglish": "Seatbelt Reminder",
    "severity": "critical",
    "canDrive": "normal",
    "symbolCode": "SEATBELT",
    "meaningArabic": "تنبيه حزام الأمان: السائق أو أحد الركاب لم يقم بربط حزام الأمان أثناء حركة السيارة.",
    "commonCauses": [
      "عدم إدخال لسان حزام الأمان في القفل",
      "وضع حقائب أو حمولة ثقيلة على مقعد الراكب تحفز حساس الوزن"
    ],
    "actionRequired": "اربط حزام الأمان لسلامتك وتوقف جرس الإنذار.",
    "associatedDTCs": [
      "B0050",
      "B0052"
    ],
    "colorHex": "#E53935"
  },
  {
    "number": 31,
    "id": "parking_brake",
    "nameArabic": "لمبة البريك اليدوي / الجلنط",
    "nameEnglish": "Parking Brake Applied",
    "severity": "critical",
    "canDrive": "driveCarefully",
    "symbolCode": "PARK_BRK",
    "meaningArabic": "لمبة البريك اليدوي / الجلنط مشدودة ومفعلة حالياً لمنع حركة السيارة.",
    "commonCauses": [
      "فرملة اليد مرفوعة باليد أو مضغوطة بالقدم أو مفعلة إلكترونياً (EPB)",
      "عطل في حساس سويتش فرملة اليد يجعله عالقاً"
    ],
    "actionRequired": "أنزل فرملة اليد بالكامل قبل الانطلاق لتفادي احتراق وتآكل باطنيات الفرامل الخلفية.",
    "associatedDTCs": [
      "C1100"
    ],
    "colorHex": "#E53935"
  },
  {
    "number": 32,
    "id": "battery_charge",
    "nameArabic": "مؤشر البطارية",
    "nameEnglish": "Alternator / Battery Charging Fault",
    "severity": "critical",
    "canDrive": "stopImmediately",
    "symbolCode": "BATTERY",
    "meaningArabic": "مؤشر البطارية والدينمو: دينمو الشحن لا يولد الكهرباء المطلوبة والسيارة تعمل على البطارية فقط.",
    "commonCauses": [
      "انقطاع أو ارتخاء قايش الدينمو والمحرك الخارجي",
      "تلف فحمات أو ريليه منظم شحن الدينمو",
      "ارتخاء أو كربنة كابلات وأصابع البطارية"
    ],
    "actionRequired": "أطفئ المكيف والإنارة والراديو وتوجه لأقرب كهربائي سيارات، السيارة ستتوقف كلياً عند نفاد شحن البطارية.",
    "associatedDTCs": [
      "P0562",
      "P0620",
      "P0622",
      "P2503"
    ],
    "colorHex": "#E53935"
  },
  {
    "number": 33,
    "id": "parking_sensors",
    "nameArabic": "حساسات الاصطدام",
    "nameEnglish": "Parking Distance Sensors",
    "severity": "info",
    "canDrive": "normal",
    "symbolCode": "PARK_SENS",
    "meaningArabic": "حساسات الاصطدام والركن بالصدام تعمل للمساعدة في صف وركن وتفادي الحواجز، أو معطلة إذا كانت ثابتة بإنذار.",
    "commonCauses": [
      "الرجوع للخلف والاقتراب من عائق أو جدار",
      "تراكم الأوساخ أو الطين على أحد حساسات الصدام"
    ],
    "actionRequired": "نظف الحساسات بالصدام وتأكد من عمل التنبيه الصوتي عند الاقتراب من الحواجز.",
    "associatedDTCs": [
      "B1240",
      "B1242"
    ],
    "colorHex": "#43A047"
  },
  {
    "number": 34,
    "id": "service_due",
    "nameArabic": "مؤشر الخدمة والصيانة",
    "nameEnglish": "Service Due / Maintenance Required",
    "severity": "warning",
    "canDrive": "normal",
    "symbolCode": "SERVICE",
    "meaningArabic": "مؤشر الخدمة والصيانة: انتهت المسافة أو المدة المحددة لتبديل زيت المحرك والفلاتر وحان موعد السيرفيس الدوري.",
    "commonCauses": [
      "تجاوز المسافة المحددة للزيت المبرمجة بالكمبيوتر (مثل 5,000 أو 10,000 كم)"
    ],
    "actionRequired": "قم بإجراء السيرفيس وتغيير الزيت وفيلترو الزيت ثم تصفير عداد الصيانة (Service Reset).",
    "associatedDTCs": [],
    "colorHex": "#FDD835"
  },
  {
    "number": 35,
    "id": "adaptive_headlights",
    "nameArabic": "نظام تحريك الابوار (يمين - يسار)",
    "nameEnglish": "Adaptive Front Lighting System (AFS)",
    "severity": "warning",
    "canDrive": "normal",
    "symbolCode": "AFS_LIGHT",
    "meaningArabic": "نظام تحريك الأضواء (يمين - يسار): عطل في موطور توجيه عدسات الفنارات التي تلتف مع حركة الدومان لإنارة المنعطفات.",
    "commonCauses": [
      "عطل في موطور توجيه العدسة داخل الفنار",
      "خلل في حساس زاوية المقود أو حساس ميزان الإضاءة بالهيكل"
    ],
    "actionRequired": "ستعمل المصابيح بشكل عادي ولكن بدون الالتفاف التلقائي بالمنعطفات.",
    "associatedDTCs": [
      "B1081",
      "B2580"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 36,
    "id": "headlight_leveling",
    "nameArabic": "تحريك الدوار (أعلى - أسفل)",
    "nameEnglish": "Headlight Range Control",
    "severity": "warning",
    "canDrive": "normal",
    "symbolCode": "HEAD_LVL",
    "meaningArabic": "تحريك الأضواء والدوار (أعلى - أسفل): عطل في موطور ضبط زاوية ارتفاع الضوء التلقائي حسب حمولة السيارة الخلفية.",
    "commonCauses": [
      "عطل حساس ميزان الارتفاع المثبت على المزاطوريات الخلفية",
      "تلف موطور الميزان الكهربائي داخل جرم الفنار"
    ],
    "actionRequired": "افحص فيش حساس ميزان الهيكل بالخلف ومحركات الفنارات.",
    "associatedDTCs": [
      "B1090",
      "B3410"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 37,
    "id": "rear_spoiler",
    "nameArabic": "تنبيه اللحاج الخلفي / السبويلر",
    "nameEnglish": "Rear Spoiler Warning",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "SPOILER",
    "meaningArabic": "تنبيه الجناح الخلفي / السبويلر: الجناح الخلفي الكهربائي المتحرك لم يفتح أو لم يغلق بالوضع الصحيح عند السرعات العالية.",
    "commonCauses": [
      "عطل في موطور فتح وقفل السبويلر",
      "وجود تراب أو عائق ميكانيكي يمنع حركة الجناح الخلفي"
    ],
    "actionRequired": "تجنب السرعات العالية جداً لأن الجناح مسؤول عن ثبات مؤخرة السيارة الهوائي.",
    "associatedDTCs": [
      "B1320"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 38,
    "id": "convertible_roof",
    "nameArabic": "مؤشر السقف المتحرك",
    "nameEnglish": "Convertible Roof Warning",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "ROOF_OPEN",
    "meaningArabic": "مؤشر السقف المتحرك: سقف السيارة القابل للطي غير مقفل بإحكام أو واجه عطلاً أثناء الفتح والإغلاق.",
    "commonCauses": [
      "عدم اكتمال دورة إغلاق وربط السقف بالزجاج الأمامي",
      "انخفاض ضغط بومبة هيدروليك السقف أو عطل ميكرو-سويتش الأمان"
    ],
    "actionRequired": "توقف وأكمل إغلاق السقف بالكامل حتى تسمع صوت تكة التأمين وانطفاء اللمبة.",
    "associatedDTCs": [
      "B1300",
      "B1305"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 39,
    "id": "airbag_srs",
    "nameArabic": "لمبة الايرباق",
    "nameEnglish": "Airbag (SRS) Fault Warning",
    "severity": "critical",
    "canDrive": "driveCarefully",
    "symbolCode": "AIRBAG",
    "meaningArabic": "لمبة الإيرباق والوسائد الهوائية (SRS): رصد خلل في الدائرة والوسائد لن تفتح عند وقوع حادث اصطدام.",
    "commonCauses": [
      "تلف شريط الستيرسو الحلزوني (Clockspring)",
      "ارتخاء فيش الحساسات الموجودة تحت كراسي السائق والراكب",
      "عطل في مشدات أحزمة الأمان المتفجرة"
    ],
    "actionRequired": "توجه لورشة فحص الـ OBD-II لإصلاح الخلل، منظومة الحماية من الحوادث معطلة حالياً.",
    "associatedDTCs": [
      "B0001",
      "B0010",
      "B0028",
      "B1000"
    ],
    "colorHex": "#E53935"
  },
  {
    "number": 40,
    "id": "handbrake_fault",
    "nameArabic": "تحذيرية / الهاند بريك",
    "nameEnglish": "Electric Parking Brake Fault",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "EPB_FAULT",
    "meaningArabic": "تحذيرية الهاند بريك: خلل في موطورات أو كمبيوتر منظومة فرملة اليد الكهربائية (EPB).",
    "commonCauses": [
      "عطل موطور كاليبر الفرامل الكهربائي في العجلات الخلفية",
      "عطل في زر سويتش البريك الكهربائي بالكونسول"
    ],
    "actionRequired": "قد بحذر ولا تركن في منحدرات شديدة بدون وضع عصا الكمبيو على (P) وتثبيت العجلات بحجر.",
    "associatedDTCs": [
      "C1555",
      "C2200"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 41,
    "id": "water_in_fuel",
    "nameArabic": "تحذيرية - ماء في فلتر الوقود",
    "nameEnglish": "Water in Fuel Filter Warning",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "WATER_FUEL",
    "meaningArabic": "تحذيرية وجود ماء في فلتر الوقود: تراكم الماء المكثف في أسفل فلتر الديزل أو البنزين وتجاوزه الحد المسموح.",
    "commonCauses": [
      "تعبئة وقود رديء يحتوي على نسبة ماء من المحطة",
      "تكاثف الرطوبة داخل خزان الوقود في الشتاء"
    ],
    "actionRequired": "افتح بلف تصريف الماء اليدوي أسفل فيلترو الوقود لتفريغ الماء، أو استبدل الفيلترو لتفادي تلف البخاخات وبومبة الديزل.",
    "associatedDTCs": [
      "P2269",
      "P2264"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 42,
    "id": "passenger_airbag_off",
    "nameArabic": "لمبة تعطيل الايرباق",
    "nameEnglish": "Passenger Airbag Deactivated",
    "severity": "warning",
    "canDrive": "normal",
    "symbolCode": "AIRBAG_OFF",
    "meaningArabic": "لمبة تعطيل الإيرباق: وسادة الهواء للراكب الأمامي مفصولة يدوياً بالمفتاح (مخصصة عند وضع كرسي أطفال بالجهة الأمامية).",
    "commonCauses": [
      "إيقاف الوسادة عبر سويتش المفتاح الجانبي بباب الراكب أو الطبلون"
    ],
    "actionRequired": "أعد تشغيلها بالمفتاح إذا كان يجلس شخص بالغ في المقعد الأمامي لضمان حمايته.",
    "associatedDTCs": [],
    "colorHex": "#FDD835"
  },
  {
    "number": 43,
    "id": "mechanical_fault",
    "nameArabic": "لمبة اعطال ميكانيكية",
    "nameEnglish": "General Mechanical / Powertrain Fault",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "MECH_FAULT",
    "meaningArabic": "لمبة أعطال ميكانيكية عامة (مفتاح صيانة): كمبيوتر السيارة رصد خللاً في أحد أنظمة الحركة أو الميكانيكا.",
    "commonCauses": [
      "عطل في أحد حساسات المحرك أو كمبيو السيارة",
      "خلل كهربائي في دائرة التحكم الإلكتروني بالدواسة"
    ],
    "actionRequired": "افحص السيارة بجهاز كشف الأعطال لمعرفة الكود الدقيق والخلل المسجل.",
    "associatedDTCs": [
      "P0606",
      "P1600"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 44,
    "id": "low_beam",
    "nameArabic": "لمبة الكشافات",
    "nameEnglish": "Low Beam Headlights Active",
    "severity": "info",
    "canDrive": "normal",
    "symbolCode": "LOW_BEAM",
    "meaningArabic": "لمبة الكشافات والفنارات العادية (الضوء الواطي) مشتغلة لإنارة الطريق.",
    "commonCauses": [
      "تشغيل الإنارة يدوياً أو عبر الحساس التلقائي (AUTO)"
    ],
    "actionRequired": "حالة تشغيلية طبيعية وآمنة للقيادة الليلية.",
    "associatedDTCs": [],
    "colorHex": "#43A047"
  },
  {
    "number": 45,
    "id": "air_filter_clogged",
    "nameArabic": "لمبة فلتر هواء",
    "nameEnglish": "Engine Air Filter Clogged",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "AIR_FILT",
    "meaningArabic": "لمبة فلتر هواء المحرك: الفلتر مسدود ومشبع بالأتربة والغبار ويخنق تنفس واحتراق المحرك.",
    "commonCauses": [
      "تراكم الغبار والرمال في فيلترو الهواء نتيجة السير في طرق ترابية",
      "انتهاء العمر الافتراضي لفيلترو الهواء"
    ],
    "actionRequired": "افتح علبة الفيلترو ونظفه بضغط الهواء أو استبدله بآخر أصلي لتحسين سحب المحرك وتوفير الوقود.",
    "associatedDTCs": [
      "P0101",
      "P0171"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 46,
    "id": "eco_mode",
    "nameArabic": "مؤشر القيادة الاقتصادية",
    "nameEnglish": "Eco Driving Mode",
    "severity": "info",
    "canDrive": "normal",
    "symbolCode": "ECO",
    "meaningArabic": "مؤشر القيادة الاقتصادية (ECO): أسلوب القيادة الحالي اقتصادي ومثالي لتوفير استهلاك الوقود وحماية البيئة.",
    "commonCauses": [
      "الضغط الهادئ والمتزن على دواسة البنزين وسلاسة تبديل الكمبيو"
    ],
    "actionRequired": "حالة تشغيلية طبيعية ومثالية ولا تتطلب أي إجراء.",
    "associatedDTCs": [],
    "colorHex": "#43A047"
  },
  {
    "number": 47,
    "id": "hill_descent",
    "nameArabic": "النظام المساعد لنزول المرتفعات",
    "nameEnglish": "Hill Descent Control (DAC)",
    "severity": "info",
    "canDrive": "normal",
    "symbolCode": "HDC_DAC",
    "meaningArabic": "النظام المساعد لنزول المرتفعات والمنحدرات (DAC / HDC): نظام التحكم التلقائي بسرعة النزول قيد العمل عبر الفرملة الذاتية.",
    "commonCauses": [
      "الضغط على زر النزول من المنحدرات (DAC / HDC) عند النزول في عقبة أو منزلق"
    ],
    "actionRequired": "اترك السيارة تتحكم بالفرملة تلقائياً وركز فقط على توجيه عجلة الستيرسو.",
    "associatedDTCs": [],
    "colorHex": "#43A047"
  },
  {
    "number": 48,
    "id": "coolant_temp",
    "nameArabic": "لمبة تحذير الحرارة",
    "nameEnglish": "Engine Coolant Temperature High",
    "severity": "critical",
    "canDrive": "stopImmediately",
    "symbolCode": "TEMP_HIGH",
    "meaningArabic": "لمبة تحذير الحرارة: سائل تبريد المحرك تجاوز درجة الغليان الآمنة والمحرك في حالة سخونة مفرطة وخطيرة.",
    "commonCauses": [
      "تسريب مية الرداتوري أو انقطاع أحد المناكوطيات (التوبوات)",
      "توقف مروحة تبريد الرداتوري (فيوز أو موطور المروحة)",
      "تعطل بلف الحرارة (الثرموستات) في وضع الإغلاق",
      "تلف بومبة الماء أو انقطاع قايش المحرك"
    ],
    "actionRequired": "⛔ توقف فوراً في مكان آمن وأطفئ المحرك! لا تفتح غطاء الرداتوري إطلاقاً وهو ساخن لتجنب انفجار البخار وحروق الوجه واليدين. انتظر 20 دقيقة حتى يبرد تماماً.",
    "associatedDTCs": [
      "P0217",
      "P0117",
      "P0118",
      "P0480"
    ],
    "colorHex": "#E53935"
  },
  {
    "number": 49,
    "id": "abs_system_red",
    "nameArabic": "لمبة نظام ABS",
    "nameEnglish": "ABS Anti-Lock Braking System Warning",
    "severity": "critical",
    "canDrive": "driveCarefully",
    "symbolCode": "ABS",
    "meaningArabic": "لمبة نظام مانع انغلاق الفرامل (ABS): نظام الـ ABS لمنع انغلاق العجلات والتزحلق عند التوقف المفاجئ معطل كلياً.",
    "commonCauses": [
      "تلف أو اتساخ حساس سرعة دوران العجلات (Wheel Speed Sensor)",
      "انقطاع أسلاك الحساس عند منطقة المزاطوريات والبراتشوات",
      "تلف حلقة الترس المسنن (ABS Tone Ring) بالهوب أو العكس",
      "عطل في بومبة أو بلوف الـ ABS الهيدروليكية"
    ],
    "actionRequired": "الفرامل العادية ستعمل ولكن السيارة ستنزلق وتدور حول نفسها إذا ضغطت فرامل بقوة على طريق مبلل أو ترابي. حافظ على مسافة أمان مضاعفة.",
    "associatedDTCs": [
      "C0035",
      "C0040",
      "C0045",
      "C0050",
      "C0245"
    ],
    "colorHex": "#E53935"
  },
  {
    "number": 50,
    "id": "fuel_filter_restriction",
    "nameArabic": "لمبة فلتر البنزين",
    "nameEnglish": "Fuel Filter Restriction / Clogged",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "FUEL_FILT",
    "meaningArabic": "لمبة فلتر البنزين والوقود: انسداد فلتر الوقود يسبب تقطيعاً وضعفاً في وصول البنزين أو الديزل للبخاخات.",
    "commonCauses": [
      "تراكم الشوائب والرواسب من وقود المحطات داخل الفيلترو",
      "عدم استبدال فيلترو الوقود منذ مسافة طويلة"
    ],
    "actionRequired": "استبدل فيلترو الوقود لتجنب إجهاد بومبة الوقود وضعف عزم المحرك وتقطيعه.",
    "associatedDTCs": [
      "P0087",
      "P0191"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 51,
    "id": "door_ajar",
    "nameArabic": "لمبة أبواب السيارة",
    "nameEnglish": "Door Ajar Warning",
    "severity": "critical",
    "canDrive": "driveCarefully",
    "symbolCode": "DOOR_OPEN",
    "meaningArabic": "لمبة أبواب السيارة مفتوحة: أحد أبواب السيارة الجانبية غير محكم الإغلاق ويهدد بفتحه أثناء السير.",
    "commonCauses": [
      "عدم إغلاق الباب بقوة كافية",
      "عطل في سويتش حساس قفل الباب الداخلي"
    ],
    "actionRequired": "توقف وأحكم إغلاق جميع الأبواب لسلامة الركاب وخاصة الأطفال.",
    "associatedDTCs": [
      "B1401",
      "B1402"
    ],
    "colorHex": "#E53935"
  },
  {
    "number": 52,
    "id": "hood_open",
    "nameArabic": "لمبة غطاء المحرك",
    "nameEnglish": "Engine Hood / Bonnet Open",
    "severity": "critical",
    "canDrive": "stopImmediately",
    "symbolCode": "HOOD_OPEN",
    "meaningArabic": "لمبة غطاء المحرك (الكبوت مفتوح): غطاء المحرك الأمامي غير مقفل باللسان الثانوي ويهدد بالتطاير على الزجاج.",
    "commonCauses": [
      "نسيان إغلاق الكبوت بعد فحص الزيت أو الماء",
      "عطل أو ارتخاء سلك وسوستة قفل الكبوت"
    ],
    "actionRequired": "⛔ توقف فوراً وأقفل الكبوت جيداً بالضغط عليه حتى يطق القفل لمنع تطايره على الزجاج الأمامي وانعدام الرؤية أثناء السير.",
    "associatedDTCs": [
      "B1380"
    ],
    "colorHex": "#E53935"
  },
  {
    "number": 53,
    "id": "low_fuel",
    "nameArabic": "لمبة مستوى الوقود",
    "nameEnglish": "Low Fuel Level Warning",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "LOW_FUEL",
    "meaningArabic": "لمبة مستوى الوقود منخفض: الوقود في خزان السيارة وصل لمستوى الاحتياطي الأخير (أقل من 50 كم سير).",
    "commonCauses": [
      "استهلاك الوقود والاقتراب من قاع التانكي"
    ],
    "actionRequired": "توجه لأقرب محطة وقود لتعبئة التانكي لتفادي سحب بومبة الوقود للرواسب وتسخينها في القاع.",
    "associatedDTCs": [],
    "colorHex": "#FDD835"
  },
  {
    "number": 54,
    "id": "trans_temp",
    "nameArabic": "لمبة الكمبيو الأوتوماتيك",
    "nameEnglish": "Automatic Transmission Warning",
    "severity": "warning",
    "canDrive": "stopImmediately",
    "symbolCode": "AT_FAULT",
    "meaningArabic": "لمبة الكمبيو الأوتوماتيك (سخونة أو عطل الكمبيو): ارتفاع حرارة زيت الكمبيو أو رصد خلل في البلوف الكهربائية (Solenoids).",
    "commonCauses": [
      "نقص أو اهتراء زيت الكمبيو وعدم تغييره مع الفيلترو",
      "سحب أحمال ثقيلة أو القيادة في رمال صحراوية شاقة",
      "عطل في صمامات تبديل الغيارات داخل مخ الكمبيو"
    ],
    "actionRequired": "⛔ توقف في مكان آمن، ضع الكمبيو على (P) واترك المحرك شغّالاً في وضع السيلانتي لتدوير الزيت وتبريده. لا تطفئ المحرك مباشرة.",
    "associatedDTCs": [
      "P0218",
      "P0700",
      "P0711",
      "P0750"
    ],
    "colorHex": "#E5A93C"
  },
  {
    "number": 55,
    "id": "speed_limiter",
    "nameArabic": "لمبة محدد السرعة القصوى",
    "nameEnglish": "Speed Limiter Active",
    "severity": "info",
    "canDrive": "normal",
    "symbolCode": "SPD_LIMIT",
    "meaningArabic": "لمبة محدد السرعة القصوى: نظام تحديد السرعة (Speed Limiter) مفعل ويمنع تجاوز السرعة المضبوطة.",
    "commonCauses": [
      "ضبط السرعة القصوى عبر أزرار عجلة القيادة"
    ],
    "actionRequired": "حالة عادية. لإلغاء التحديد اضغط زر LIM أو ادعس دواسة الوقود للآخر (Kick-down).",
    "associatedDTCs": [],
    "colorHex": "#43A047"
  },
  {
    "number": 56,
    "id": "suspension_dampers",
    "nameArabic": "لمبة المساعدات",
    "nameEnglish": "Suspension Dampers Fault",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "DAMPERS",
    "meaningArabic": "لمبة المساعدات والمزاطوريات: خلل في المنظومة الإلكترونية للتحكم في قساوة وليونة المساعدات (المزاطوريات).",
    "commonCauses": [
      "عطل في بلوف المزاطوريات الإلكترونية التكيفية",
      "انقطاع سلك حساس اهتزاز هيكل المركبة"
    ],
    "actionRequired": "قد بحذر وتجنب المنعطفات السريعة، نظام التحكم في توازن السيارة سيكون محدوداً.",
    "associatedDTCs": [
      "C1020",
      "C1030"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 57,
    "id": "oil_pressure",
    "nameArabic": "مستوى الزيت منخفض",
    "nameEnglish": "Low Engine Oil Pressure",
    "severity": "critical",
    "canDrive": "stopImmediately",
    "symbolCode": "OIL_PRESS",
    "meaningArabic": "مستوى وضغط الزيت منخفض (إبريق الزيت): انخفاض شديد وخطير في ضغط الزيت اللازم لتزييت بساتين ومحاور وكامات المحرك.",
    "commonCauses": [
      "نقص حاد في مستوى الزيت بسبب تسريب أو حرق داخلي",
      "تلف أو انكسار بومبة الزيت",
      "انسداد شخال الزيت السفلي بالستاقوبا بالرايش أو الكربون",
      "تلف حساس ضغط الزيت"
    ],
    "actionRequired": "⛔ توقف فوراً وأطفئ المحرك خلال ثوانٍ معدودة! تشغيل المحرك بدون ضغط زيت يؤدي لتصلبه وتكييله وتلفه بالكامل في دقائق.",
    "associatedDTCs": [
      "P0520",
      "P0521",
      "P0522",
      "P0524"
    ],
    "colorHex": "#E53935"
  },
  {
    "number": 58,
    "id": "windshield_defrost",
    "nameArabic": "لمبة مانع الضباب والتجمد / زجاج أمامي",
    "nameEnglish": "Windshield Defrost / Demist Active",
    "severity": "info",
    "canDrive": "normal",
    "symbolCode": "DEFROST_F",
    "meaningArabic": "لمبة مانع الضباب والتجمد للزجاج الأمامي: توجيه هواء المكيف بكامل قوته لطرد البخار والجليد وتوضيح الرؤية.",
    "commonCauses": [
      "الضغط على زر ديفروست الزجاج الأمامي بالمكيف"
    ],
    "actionRequired": "حالة طبيعية لتنقية الرؤية. يمكن إطفاؤه بعد جفاف الزجاج.",
    "associatedDTCs": [],
    "colorHex": "#43A047"
  },
  {
    "number": 59,
    "id": "trunk_open",
    "nameArabic": "لمبة الصندوق الخلفي",
    "nameEnglish": "Trunk / Boot Lid Open",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "TRUNK_OPN",
    "meaningArabic": "لمبة الصندوق الخلفي والشنطة مفتوحة: باب صندوق الأمتعة غير مقفل بإحكام.",
    "commonCauses": [
      "عدم إغلاق باب الصندوق بالكامل",
      "عطل في حساس كالون قفل الشنطة الخلفية"
    ],
    "actionRequired": "توقف وأقفل باب الشنطة لمنع سقوط الأمتعة أثناء السير.",
    "associatedDTCs": [
      "B1370"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 60,
    "id": "esp_tcs",
    "nameArabic": "نظام مانع الانزلاق",
    "nameEnglish": "Electronic Stability Program (ESP / TCS)",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "ESP_TCS",
    "meaningArabic": "نظام مانع الانزلاق والثبات الإلكتروني (ESP / TCS): نظام التحكم في تماسك الإطارات غير متاح حالياً.",
    "commonCauses": [
      "عطل في أحد حساسات الـ ABS المرتبطة بالعجلات",
      "عدم معايرة حساس زاوية الدومان (الستيرسو) بعد وزن الأذرعة",
      "تم إيقاف النظام يدوياً عبر زر (TCS OFF / ESP OFF)"
    ],
    "actionRequired": "تحقق من زر إلغاء مانع الانزلاق. إذا بقيت اللمبة مشتعلة، فالنظام معطل ولن يتدخل لمنع دوران العجلات في الفراغ أو الانزلاق بالمنحنيات.",
    "associatedDTCs": [
      "C0245",
      "C0035",
      "C1515",
      "P0121"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 61,
    "id": "rain_sensor",
    "nameArabic": "حساس المطر",
    "nameEnglish": "Rain Sensor Active",
    "severity": "info",
    "canDrive": "normal",
    "symbolCode": "RAIN_ACT",
    "meaningArabic": "حساس المطر نشط: نظام الاستشعار التلقائي للمطر على الزجاج الأمامي مشغل ويعمل بانتظام.",
    "commonCauses": [
      "وضع ذراع المساحات على خيار التشغيل التلقائي (AUTO)"
    ],
    "actionRequired": "حالة تشغيلية عادية تؤكد استعداد المساحات للعمل فور هطول المطر.",
    "associatedDTCs": [],
    "colorHex": "#43A047"
  },
  {
    "number": 62,
    "id": "check_engine",
    "nameArabic": "لمبة المحرك / check engine",
    "nameEnglish": "Check Engine / Malfunction Indicator Lamp",
    "severity": "warning",
    "canDrive": "driveCarefully",
    "symbolCode": "CHECK_ENG",
    "meaningArabic": "لمبة المحرك / check engine: كمبيوتر السيارة رصد خللاً في أحد أنظمة الاحتراق، الوقود، الحساسات، أو الانبعاثات.",
    "commonCauses": [
      "عطل في حساس المرميطة (O2 Sensor) أو حساس الهواء (MAF)",
      "تلف بوبينات الإشعال أو الشمعات ووجود فطفطة (Misfire)",
      "انسداد في فيلترو البيئة وعلبة كربون المرميطة (Catalytic Converter)",
      "خلل في نظام بخ الوقود وتوزيع الشفط (Vacuum / EVAP)"
    ],
    "actionRequired": "إذا كانت اللمبة ثابتة: يمكنك السير بحذر لأقرب ورشة للفحص بجهاز الـ OBD-II.\\n⚠️ تنبيه خطير: إذا كانت اللمبة ترمش (تغمز بسرعة)، توقف فوراً لأن هناك بسطوني لا يحرق مما قد يؤدي لذوبان علبة كربون المرميطة واشتعالها!",
    "associatedDTCs": [
      "P0300",
      "P0171",
      "P0420",
      "P0135",
      "P0101",
      "P0113",
      "P0455"
    ],
    "colorHex": "#FDD835"
  },
  {
    "number": 63,
    "id": "rear_defrost",
    "nameArabic": "إزالة الضباب والمقيع ( الشباك الخلفي )",
    "nameEnglish": "Rear Window Defroster Active",
    "severity": "info",
    "canDrive": "normal",
    "symbolCode": "DEFROST_R",
    "meaningArabic": "إزالة الضباب والمقيع (الشباك الخلفي): خطوط التدفئة الكهربائية بالزجاج الخلفي مشتعلة لإذابة الجليد والضباب.",
    "commonCauses": [
      "الضغط على زر تسخين وتذويب ضباب الزجاج الخلفي"
    ],
    "actionRequired": "حالة طبيعية، يفضل إطفاؤه بعد صفاء الرؤية لتخفيف الحمل الكهربائي على الدينمو.",
    "associatedDTCs": [],
    "colorHex": "#43A047"
  },
  {
    "number": 64,
    "id": "auto_wipers",
    "nameArabic": "نظام تشغيل المساحات الاتوماتيكي",
    "nameEnglish": "Automatic Windshield Wipers Active",
    "severity": "info",
    "canDrive": "normal",
    "symbolCode": "AUTO_WIPE",
    "meaningArabic": "نظام تشغيل المساحات الأوتوماتيكي: المساحات الأمامية تعمل تلقائياً بحسب كمية قطرات الماء المستشعرة على الزجاج.",
    "commonCauses": [
      "هطول المطر وتفعيل وضع AUTO للمساحات"
    ],
    "actionRequired": "حالة تشغيلية طبيعية وآمنة تزيد وضوح الرؤية دون انشغال السائق.",
    "associatedDTCs": [],
    "colorHex": "#43A047"
  }
];
