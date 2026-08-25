import { ElectricalDiagnosticInfo } from "./types";

/**
 * Known electrical diagnostic database for OBD-II codes, fuses, and multimeter testing values
 */
const ELECTRICAL_DATABASE: Record<string, Partial<ElectricalDiagnosticInfo>> = {
  // MAF / Mass Air Flow Sensors
  P0100: {
    fuseInfo: {
      boxLocation: "علبة فيوزات حوض المحرك (بجانب البطارية / الفيلترو)",
      fuseNumber: "F14 / EFI-15A",
      rating: "15A (أزرق)",
      relayName: "كتاوت تغذية المحرك الرئيسية (EFI Main Relay)",
      circuitDescription: "دائرة تغذية حساس كتلة تدفق الهواء (MAF) والكمبيوتر",
    },
    sensorLocation: {
      areaName: "خرطوم مدخل الهواء بين علبة الفيلترو وبوابة راس الإنجكشن",
      engineZone: "front-air",
      accessTip: "مكانه واضح ومباشر في حوض المحرك، يُفك ببرغيين Torx أو فيليبس بعد فصل الفيشة.",
      coordinatePct: { x: 30, y: 35 },
    },
    multimeterTest: {
      powerPin: "12V تغذية رئيسية مع فتح السويتش (Pin 1 أو B+)",
      groundPin: "أقل من 0.05V خط الأرضي الشاسي والكمبيوتر (Pin 2 أو E2)",
      signalPin: "0.8V إلى 1.2V عند السكون، يرتفع تدريجياً إلى 3.8V - 4.5V مع الدعسة (Pin 3 أو VG)",
      referenceVoltage: "5.0V جهد مرجعي ثابت من كمبيوتر المحرك (Pin 4)",
      testingTipLibyan: "حط الأفوميتر على V DC واشبك الأسود بالشاسي. قيس السلك الموجب مع فتح السويتش لازم 12V، وقيس سلك الإشارة مع الدعسة لازم يزيد تدريجياً وما يقطعش.",
    },
  },
  P0101: {
    fuseInfo: {
      boxLocation: "علبة فيوزات حوض المحرك (الرئيسية)",
      fuseNumber: "F14 / EFI-15A",
      rating: "15A (أزرق)",
      relayName: "EFI Main Relay",
      circuitDescription: "تغذية حساس تدفق الهواء والمحرك",
    },
    sensorLocation: {
      areaName: "بين قربة الفيلترو وبوابة راس الإنجكشن",
      engineZone: "front-air",
      accessTip: "افحص نظافة السلك الحراري (Hot Wire) داخل الحساس قبل الاستبدال.",
      coordinatePct: { x: 30, y: 35 },
    },
    multimeterTest: {
      powerPin: "12V خط الكهرباء (Pin 1)",
      groundPin: "أقل من 0.05V خط الأرضي (Pin 2)",
      signalPin: "1.0V عند السكون (Idle) وحتى 4.2V عند التسارع الكامل",
      referenceVoltage: "5.0V مرجعي ثابت",
      testingTipLibyan: "رش سلك الحساس بسبراي تنظيف حساسات هواء (CRC MAF Cleaner) وجرب قيس الإشارة هل انتظمت.",
    },
  },
  P0102: {
    fuseInfo: {
      boxLocation: "علبة فيوزات حوض المحرك (Engine Fuse Box)",
      fuseNumber: "F14 / ENG-15A",
      rating: "15A (أزرق)",
      relayName: "كتاوت تغذية المحرك الرئيسية",
      circuitDescription: "تغذية دائرة حساس الماف وبوابة الهواء",
    },
    sensorLocation: {
      areaName: "خرطوم مدخل الهواء بعد علبة الفيلترو مباشرة",
      engineZone: "front-air",
      accessTip: "تأكد من إحكام فيشة الحساس (البيانتو) وعدم تآكل الكلبس البلاستيكي.",
      coordinatePct: { x: 28, y: 36 },
    },
    multimeterTest: {
      powerPin: "12V مع فتح السويتش (Pin 1)",
      groundPin: "أقل من 0.05V خط الأرضي (Pin 2)",
      signalPin: "جهد الإشارة منخفض جداً (< 0.5V)، يجب أن يكون بين 1.0V إلى 4.2V",
      referenceVoltage: "5.0V مرجعي من الـ ECM",
      testingTipLibyan: "كود P0102 يعني إشارة ضعيفة (Low Input). افحص فيوز الـ 15A أولاً، ثم قيس هل السلك واصل فيه 12V أم الخيط مقطوع بالبيانتو.",
    },
  },

  // Misfire & Ignition Coils
  P0300: {
    fuseInfo: {
      boxLocation: "علبة فيوزات المحرك (أو علبة كمبيوتر المحرك E-Box)",
      fuseNumber: "F02 / IGN-20A",
      rating: "20A (أصفر) أو 30A (أخضر)",
      relayName: "كتاوت الإشعال الرئيسي (Ignition Main Relay)",
      circuitDescription: "تغذية كويلات الإشعال (البوبينات) والشمعات",
    },
    sensorLocation: {
      areaName: "أعلى غطاء بلوك المحرك (فوق الشمعات مباشرة)",
      engineZone: "top-manifold",
      accessTip: "تُفك براغي غطاء المحرك البلاستيكي للوصول لجميع البوبينات (Coils) والفيش.",
      coordinatePct: { x: 50, y: 45 },
    },
    multimeterTest: {
      powerPin: "12V تغذية مستمرة مع السويتش على كل بوبينة (Pin 1 / B+)",
      groundPin: "أقل من 0.1V أرضي المحرك والسلندر (Pin 2)",
      signalPin: "نبضات إشارة سالبة/موجبة من كمبيوتر المحرك (Trigger Pulse 1V - 5V)",
      testingTipLibyan: "افحص مقاومة البوبينة بالأوم (Primary 0.5 - 1.5Ω)، وإذا الشك في بوبينة معينة بدلها مع السلندر المجاور وشوف كود العطل وين ينتقل.",
    },
  },
  P0301: {
    fuseInfo: {
      boxLocation: "علبة فيوزات حوض المحرك",
      fuseNumber: "F02 / IGN-20A",
      rating: "20A (أصفر)",
      relayName: "كتاوت الإشعال (Ignition Relay)",
      circuitDescription: "تغذية بوبينة السلندر رقم 1 والشمعات",
    },
    sensorLocation: {
      areaName: "السلندر رقم 1 (مقدمة المحرك جهة السيور)",
      engineZone: "top-manifold",
      accessTip: "السلندر الأول هو الأقرب لجهة سير الكاتينة / المروحة في معظم المحركات الطولية والعرضية.",
      coordinatePct: { x: 45, y: 38 },
    },
    multimeterTest: {
      powerPin: "12V كهرباء سويتش واصلة لفيشة البوبينة 1",
      groundPin: "أرضي شاسي ثابت 0V",
      signalPin: "نبضة قدح إشعال من الـ ECM مع دوران الموتوري",
      testingTipLibyan: "بدل بوبينة سلندر 1 مع بوبينة سلندر 2، وامسح العطل، لو ولى P0302 يعني البوبينة محروقة، لو قعد P0301 يعني الشمعة أو الرشاش أو الفيشة.",
    },
  },
  P0304: {
    fuseInfo: {
      boxLocation: "علبة فيوزات حوض المحرك (أو علبة الـ DME/E-Box)",
      fuseNumber: "F02 / IGN-30A",
      rating: "30A (أخضر)",
      relayName: "كتاوت منظومة الإشعال وحقن الوقود",
      circuitDescription: "تغذية مسار البوبينات ورشاشات الوقود",
    },
    sensorLocation: {
      areaName: "السلندر رقم 4 (الجهة الخلفية لغطاء المحرك)",
      engineZone: "top-manifold",
      accessTip: "في محركات 4 سلندر هو الأقرب لجهة صالة الفتيس، وفي 6 سلندر يتطلب فك مسطرة مجرى الهواء.",
      coordinatePct: { x: 55, y: 55 },
    },
    multimeterTest: {
      powerPin: "12V تغذية مع السويتش",
      groundPin: "أرضي سليم < 0.1V",
      signalPin: "نبضة قدح إشعال متزامنة",
      testingTipLibyan: "قيس جهد فيشة البوبينة 4 وتأكد من عدم وجود زيت داخل تجويف الشمعة (تسريب جوان غطاء التاكيهات).",
    },
  },

  // Oxygen & Catalytic Converter (حساس المرميطة وعلبة الكربون)
  P0420: {
    fuseInfo: {
      boxLocation: "علبة فيوزات حوض المحرك",
      fuseNumber: "F11 / O2-HEATER-15A",
      rating: "15A (أزرق)",
      relayName: "كتاوت سخانات حساسات العادم",
      circuitDescription: "دائرة سخانات حساسات المرميطة العلوية والسفلية (O2 Sensor Heaters)",
    },
    sensorLocation: {
      areaName: "ماسورة الشكمان (المرميطة) بعد علبة الكربون مباشرة (Downstream)",
      engineZone: "exhaust-downpipe",
      accessTip: "يتم الوصول إليه من أسفل السيارة أسفل مقصورة السائق/الراكب على خط أنبوب العادم.",
      coordinatePct: { x: 65, y: 65 },
    },
    multimeterTest: {
      powerPin: "12V خط سخان الحساس (السلكين البيض أو الأسود)",
      groundPin: "أرضي هيكل وسخان الحساس 0V",
      signalPin: "حساس بعد العلبة يجب أن يقرأ إشارة مستقرة (0.6V - 0.7V ثابتة تقريباً) إذا كانت العلبة سليمة",
      referenceVoltage: "0.45V جهد تعويم أولي",
      testingTipLibyan: "قيس مقاومة سخان الحساس (بين 5 إلى 15 أوم). إذا كان حساس المرميطة يقيس نفس تذبذب الحساس الأمامي (0.1V إلى 0.9V بسرعة) يعني علبة الكربون فرغت أو تلفت.",
    },
  },

  // Fuel Trim & Air-Fuel Ratio (صرفية البنزين وخليط الوقود)
  P0171: {
    fuseInfo: {
      boxLocation: "علبة فيوزات حوض المحرك أو تحت التابلو الداخلي",
      fuseNumber: "F08 / FUEL-PUMP-20A",
      rating: "20A (أصفر)",
      relayName: "كتاوت طرمبة البنزين (Fuel Pump Relay)",
      circuitDescription: "تغذية طرمبة البنزين ورشاشات الوقود (Injectors)",
    },
    sensorLocation: {
      areaName: "مسطرة الرشاشات + خراطيم الفاكيوم + طرمبة البنزين بالخزان",
      engineZone: "top-manifold",
      accessTip: "افحص خراطيم سحب الهواء (الفاكيوم) خلف بوابة المانيفولد بحثاً عن أي شرخ أو تنفيس.",
      coordinatePct: { x: 50, y: 40 },
    },
    multimeterTest: {
      powerPin: "12V تغذية الرشاشات وطرمبة البنزين",
      groundPin: "أرضي سليم",
      signalPin: "نبضات فتح الرشاشات (Injection Pulse 2.0ms - 3.5ms عند السكون)",
      testingTipLibyan: "كود P0171 يعني هواء زايد أو بنزين ناقص. رش سبراي تنظيف مكابح حول خراطيم المانيفولد وشوف لو تغير صوت الموتوري، وقيس ضغط طرمبة البنزين (لازم 3.5 إلى 4 بار).",
    },
  },

  // BMW E39 Specific Hex Codes
  "02": {
    fuseInfo: {
      boxLocation: "علبة كمبيوتر المحرك DME E-Box (تحت فلتر مكيف الراكب الأيمن)",
      fuseNumber: "F02 / DME-30A",
      rating: "30A (أخضر)",
      relayName: "DME Main Power Relay (كتاوت أزرق/أبيض)",
      circuitDescription: "تغذية كمبيوتر محرك BMW وكويلات الإشعال",
    },
    sensorLocation: {
      areaName: "كويل إشعال السلندر 4 في محرك M52/M54",
      engineZone: "top-manifold",
      accessTip: "تُفك أغطية المحرك البلاستيكية بمسامير 10mm، وتُرفع فيشة البوبينة بسحب الكلبس للأعلى.",
      coordinatePct: { x: 52, y: 48 },
    },
    multimeterTest: {
      powerPin: "12V بين Pin 15 والأرضي مع فتح السويتش",
      groundPin: "أقل من 0.05V على Pin 4b",
      signalPin: "إشارة قدح رقمية من كمبيوتر DME (Pin 1)",
      testingTipLibyan: "في البي إم E39 تأكد من عازل جلدة البوبينة (البيبة) ومن عدم وجود تسريب زيت من كولير غطاء الصبابات على الشمعة.",
    },
  },
  CB: {
    fuseInfo: {
      boxLocation: "علبة فيوزات المحرك E-Box",
      fuseNumber: "F01 / O2-15A",
      rating: "15A (أزرق)",
      relayName: "كتاوت سخانات الحساسات",
      circuitDescription: "تغذية حساسات الأكسجين Bank 2 في محرك M52/M54",
    },
    sensorLocation: {
      areaName: "منيفولد العادم لسلندرات 4-5-6 (Bank 2 قبل علبة الكربون)",
      engineZone: "exhaust-downpipe",
      accessTip: "يمكن رؤية الفيشة الدائرية فوق غطاء الصبابات بجانب منيفولد السحب.",
      coordinatePct: { x: 60, y: 55 },
    },
    multimeterTest: {
      powerPin: "12V تغذية السخان مع السويتش",
      groundPin: "أرضي سليم",
      signalPin: "تذبذب سريع بين 0.1V (فقير) و 0.9V (غني) بمعدل مرتين بالثانية",
      testingTipLibyan: "كود CB في البي إم يعني انحراف خليط الوقود (Fuel Trim Bank 2). افحص جلود المانيفولد وخراطيم بخار الزيت (CCV) أسفل الثلاجة.",
    },
  },
};

/**
 * Generates or retrieves complete electrical diagnostics for any given OBD fault code
 */
export function getElectricalDiagnosticsForCode(
  code: string,
  make?: string
): ElectricalDiagnosticInfo {
  const normalized = (code || "").toUpperCase().trim();

  // 1. Check exact database match
  if (ELECTRICAL_DATABASE[normalized]) {
    const data = ELECTRICAL_DATABASE[normalized];
    return {
      fuseInfo: data.fuseInfo || {
        boxLocation: "علبة فيوزات حوض المحرك الرئيسية",
        fuseNumber: "F15 / ENG-15A",
        rating: "15A (أزرق)",
        relayName: "كتاوت التغذية الرئيسية للمنظومة",
        circuitDescription: "تغذية حساسات المحرك ووحدة التحكم",
      },
      sensorLocation: data.sensorLocation || {
        areaName: "حوض المحرك الرئيسي",
        engineZone: "top-manifold",
        accessTip: "افحص الفيشة والتوصيلات السلكية (البيانتو) بحثاً عن أي تآكل أو رخاوة.",
        coordinatePct: { x: 50, y: 50 },
      },
      multimeterTest: data.multimeterTest || {
        powerPin: "12V جهد التغذية الأساسي مع فتح السويتش",
        groundPin: "أقل من 0.05V خط الأرضي الشاسي",
        signalPin: "إشارة تناظرية متغيرة بين 0.5V و 4.5V",
        referenceVoltage: "5.0V جهد مرجعي ثابت",
        testingTipLibyan: "حط الأفوميتر على وضع V DC واقرا الفولتية بين خط الأرضي والكهرباء مع فتح السويتش.",
      },
    };
  }

  // 2. Derive intelligently based on code prefix and module
  const isBmw = (make || "").toLowerCase().includes("bmw") || normalized === "02" || normalized === "CB";
  const isToyota = (make || "").toLowerCase().includes("toyota");

  if (normalized.startsWith("P01") || normalized.startsWith("P00")) {
    // Air / Fuel / Temperature Sensor
    return {
      fuseInfo: {
        boxLocation: isBmw ? "علبة DME E-Box تحت فلتر المكيف" : "علبة فيوزات حوض المحرك الرئيسية",
        fuseNumber: isToyota ? "EFI-15A / F14" : "F03 / 15A",
        rating: "15A (أزرق)",
        relayName: "كتاوت تغذية منظومة الوقود والهواء",
        circuitDescription: `دائرة التغذية الكهربائية لحساس (${normalized}) والمانيفولد`,
      },
      sensorLocation: {
        areaName: "مجرى سحب الهواء وثلاجة المحرك (Intake Manifold)",
        engineZone: "front-air",
        accessTip: "يمكن الوصول للحساس بسهولة بفك مسامير التثبيت بعد فصل مشبك الفيشة الكهربائية.",
        coordinatePct: { x: 35, y: 35 },
      },
      multimeterTest: {
        powerPin: "12V تغذية السويتش على السلك الرئيسي",
        groundPin: "أرضي شاسي نظيف أقل من 0.05V",
        signalPin: "إشارة حساسية متغيرة بين 0.5V إلى 4.5V تتناسب مع تدفق الهواء وحرارة المحرك",
        referenceVoltage: "5.0V مرجعي ثابت من كمبيوتر المحرك",
        testingTipLibyan: "قيس سلك التغذية الـ 12V وسلك الـ 5V المرجعي بالأفوميتر مع السويتش مفتوح بدون تشغيل الموتوري.",
      },
    };
  }

  if (normalized.startsWith("P03") || normalized.startsWith("P02")) {
    // Ignition & Fuel Injection
    return {
      fuseInfo: {
        boxLocation: "علبة فيوزات حوض المحرك (بجانب البطارية / البلوك)",
        fuseNumber: isBmw ? "F02 / IGN-30A" : "IGN-20A / INJ-15A",
        rating: "20A (أصفر) أو 30A (أخضر)",
        relayName: "كتاوت منظومة الإشعال والرشاشات الرئيسية",
        circuitDescription: `تغذية مسار كويلات الإشعال والرشاشات للرمز (${normalized})`,
      },
      sensorLocation: {
        areaName: "أعلى بلوك المحرك (غطاء الصبابات ومسطرة الرشاشات)",
        engineZone: "top-manifold",
        accessTip: "تُفك براغي غطاء الحماية للوصول المباشر للبوبينة أو الرشاش المعني.",
        coordinatePct: { x: 50, y: 45 },
      },
      multimeterTest: {
        powerPin: "12V كهرباء سويتش واصلة للفيشة",
        groundPin: "أرضي سليم متصل بالبلوك",
        signalPin: "نبضات قدح سالبة (Ground Trigger Pulse) من الـ ECM",
        testingTipLibyan: "تأكد من سلامة كتاوت الإشعال والفيوز، وقيس مقاومة الملف بالأوم مع فحص كبل التوصيل.",
      },
    };
  }

  if (normalized.startsWith("P04") || normalized.startsWith("P05")) {
    // Emissions / Speed / Cruise
    return {
      fuseInfo: {
        boxLocation: "علبة فيوزات حوض المحرك أو أسفل التابلو الداخلي",
        fuseNumber: "O2-HTR-15A / EMISS-10A",
        rating: "15A (أزرق) أو 10A (أحمر)",
        relayName: "كتاوت سخانات العادم والأنظمة المساندة",
        circuitDescription: `دائرة التحكم في الانبعاثات وسخانات الحساسات (${normalized})`,
      },
      sensorLocation: {
        areaName: "أنبوب العادم والمقصورة السفلية",
        engineZone: "exhaust-downpipe",
        accessTip: "يتم فحص الحساس من أسفل السيارة عند خط الشكمان أو حساسات السرعة بالعجلات.",
        coordinatePct: { x: 65, y: 65 },
      },
      multimeterTest: {
        powerPin: "12V تغذية سخان الحساس مع السويتش",
        groundPin: "أرضي الحساس والشاسي",
        signalPin: "تذبذب إشارة الفولتية بين 0.1V و 0.9V",
        testingTipLibyan: "قيس مقاومة سلك السخان الداخلي (5 - 15 أوم)، وافحص الفيوز قبل تغيير الحساس.",
      },
    };
  }

  // Generic OBD / Network / Chassis
  return {
    fuseInfo: {
      boxLocation: "علبة فيوزات حوض المحرك الرئيسية (Engine Fuse Center)",
      fuseNumber: "F10 / ECU-15A",
      rating: "15A (أزرق)",
      relayName: "كتاوت المنظومة العامة",
      circuitDescription: `دائرة تغذية وحماية منظومة (${normalized})`,
    },
    sensorLocation: {
      areaName: "حوض المحرك وشبكة الأسلاك (البيانتو)",
      engineZone: "top-manifold",
      accessTip: "افحص الفيشة الكهربائية للتأكد من عدم وجود كربون أو تمليح أو كسر في الأقفال.",
      coordinatePct: { x: 50, y: 50 },
    },
    multimeterTest: {
      powerPin: "12V تغذية خط السويتش",
      groundPin: "أرضي شاسي سليم (< 0.1V)",
      signalPin: "إشارة اتصال مستقرة مع وحدة التحكم",
      referenceVoltage: "5.0V مرجعي من وحدة التحكم",
      testingTipLibyan: "حط الأفوميتر على قياس الفولت DC وتأكد من وصول الكهرباء 12V والأرضي السليم قبل تبديل أي قطعة.",
    },
  };
}
