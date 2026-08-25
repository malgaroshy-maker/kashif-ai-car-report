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
 * The wiring guidance for one fault code.
 *
 * Three outcomes, and the caller must show which one it got — see
 * `ElectricalProvenance`. This used to have only one outcome. When a code was
 * not in the table it *derived* a fuse box, a fuse number, an amperage, a
 * relay name, a position on the engine diagram and a full multimeter pinout
 * from the code's first three characters — `F03 / 15A`, `15A (أزرق)`,
 * `coordinatePct: { x: 50, y: 50 }`, `5.0V مرجعي ثابت`. Every one of those is a
 * claim about a specific car, and the reader acts on them physically: they
 * pull that fuse, and they put a probe where the marker is.
 *
 * What is left in the `general` branches is the part that was actually true —
 * which end of the engine bay a sensor family lives in, and how to check a
 * supply and a ground with a multimeter. That is workshop practice, not this
 * car's wiring diagram, and it is labelled as such.
 */
export function getElectricalDiagnosticsForCode(
  code: string,
  make?: string
): ElectricalDiagnosticInfo {
  const normalized = (code || "").toUpperCase().trim();
  const entry = ELECTRICAL_DATABASE[normalized];

  if (entry) {
    // A table hit used to be topped up with the same invented generics for any
    // sub-block it was missing. Now a missing block falls back to the general
    // guidance for the code family, and the whole record is marked accordingly
    // so nothing claims more precision than it has.
    const base = deriveGeneral(normalized, make);
    const complete = Boolean(
      entry.fuseInfo && entry.sensorLocation && entry.multimeterTest
    );
    return {
      provenance: complete ? "reference" : "general",
      fuseInfo: entry.fuseInfo ?? base.fuseInfo,
      sensorLocation: entry.sensorLocation ?? base.sensorLocation,
      multimeterTest: entry.multimeterTest ?? base.multimeterTest,
    };
  }

  return deriveGeneral(normalized, make);
}

/**
 * What can honestly be said about a code we do not have on file.
 *
 * No fuse number, no amperage, no relay name, no diagram coordinate: the
 * reader is pointed at the fuse box lid, which is where the real answer is
 * printed, and at the general area of the engine bay.
 */
function deriveGeneral(
  normalized: string,
  make?: string
): ElectricalDiagnosticInfo {
  const isBmw =
    (make || "").toLowerCase().includes("bmw") ||
    normalized === "02" ||
    normalized === "CB";

  const noFuseNumber = {
    fuseNumber: null,
    rating: null,
    relayName: null,
  } as const;

  // Air, fuel and temperature sensors.
  if (normalized.startsWith("P01") || normalized.startsWith("P00")) {
    return {
      provenance: "general",
      fuseInfo: {
        ...noFuseNumber,
        boxLocation: isBmw
          ? "عادةً علبة الـ DME (E-Box) في حوض المحرك"
          : "عادةً علبة فيوزات حوض المحرك",
        circuitDescription: `دائرة تغذية حساسات الهواء والوقود — الرمز (${normalized}) من عائلة حساسات السحب`,
      },
      sensorLocation: {
        areaName: "مجرى سحب الهواء بين علبة الفيلترو وبوابة راس الإنجكشن",
        engineZone: "front-air",
        accessTip:
          "حساسات هذه العائلة عادةً في متناول اليد من فوق، بفك فيشة وبرغيين. افحص الفيشة من الكربون والتمليح قبل ما تشري القطعة.",
        coordinatePct: null,
      },
      multimeterTest: {
        powerPin: "خط التغذية: 12V مع فتح السويتش",
        groundPin: "خط الأرضي: أقل من 0.1V على الشاسي",
        signalPin: "خط الإشارة: فولتية متغيرة تتبع تدفق الهواء أو الحرارة",
        referenceVoltage: null,
        testingTipLibyan:
          "قيس التغذية والأرضي أولاً بالأفوميتر على V DC. أغلب أعطال هذه العائلة بيانتو أو فيشة، مش الحساس نفسه.",
      },
    };
  }

  // Ignition and injection.
  if (normalized.startsWith("P02") || normalized.startsWith("P03")) {
    return {
      provenance: "general",
      fuseInfo: {
        ...noFuseNumber,
        boxLocation: "عادةً علبة فيوزات حوض المحرك (مسار الإشعال والرشاشات)",
        circuitDescription: `دائرة البوبينات والرشاشات — الرمز (${normalized}) من عائلة الإشعال والحقن`,
      },
      sensorLocation: {
        areaName: "أعلى بلوك المحرك: غطاء الصبابات ومسطرة الرشاشات",
        engineZone: "top-manifold",
        accessTip:
          "تُفك براغي غطاء الحماية للوصول للبوبينات والرشاشات. بدّل البوبينة مع سلندر ثاني وشوف هل العطل مشى معاها — أرخص من التبديل العشوائي.",
        coordinatePct: null,
      },
      multimeterTest: {
        powerPin: "خط التغذية: 12V واصلة للفيشة مع السويتش",
        groundPin: "الأرضي على البلوك",
        signalPin: "نبضة القدح تجي سالبة من الكمبيوتر",
        referenceVoltage: null,
        testingTipLibyan:
          "قيس مقاومة ملف البوبينة بالأوم وقارنها مع بوبينة سليمة من نفس المحرك. افحص الشمعة والكبل قبل الكويل.",
      },
    };
  }

  // Emissions, speed, cruise.
  if (normalized.startsWith("P04") || normalized.startsWith("P05")) {
    return {
      provenance: "general",
      fuseInfo: {
        ...noFuseNumber,
        boxLocation:
          "عادةً علبة فيوزات حوض المحرك، وأحياناً العلبة الداخلية تحت التابلو",
        circuitDescription: `دائرة الانبعاثات وسخانات الحساسات — الرمز (${normalized})`,
      },
      sensorLocation: {
        areaName: "خط العادم (الشكمان) وأسفل السيارة",
        engineZone: "exhaust-downpipe",
        accessTip:
          "الفحص من تحت السيارة عند خط الشكمان. الحساس عادةً مربوط بعزم عالي وساخن — سيّبه يبرد.",
        coordinatePct: null,
      },
      multimeterTest: {
        powerPin: "تغذية سخان الحساس مع السويتش",
        groundPin: "أرضي الحساس على الشاسي",
        signalPin: "إشارة حساس المرميطة تتذبذب باستمرار وما تثبتش",
        referenceVoltage: null,
        testingTipLibyan:
          "قيس مقاومة سلك السخان الداخلي بالأوم. حساس ثابت ما يتذبذبش يعني ميت حتى لو التغذية سليمة.",
      },
    };
  }

  // Anything else: network, chassis, body.
  return {
    provenance: "general",
    fuseInfo: {
      ...noFuseNumber,
      boxLocation:
        "مش محدد لهذا الرمز — راجع الرسم المطبوع على غطاء علبة الفيوزات في سيارتك",
      circuitDescription: `دائرة تغذية وحماية المنظومة المرتبطة بالرمز (${normalized})`,
    },
    sensorLocation: {
      areaName: "غير محدد لهذا الرمز",
      engineZone: "top-manifold",
      accessTip:
        "ابدأ من الفيشة وشبكة الأسلاك (البيانتو): كربون، تمليح، أو قفل مكسور. أغلب أعطال الشبكة توصيلة مش قطعة.",
      coordinatePct: null,
    },
    multimeterTest: {
      powerPin: "خط التغذية: 12V مع السويتش",
      groundPin: "خط الأرضي: أقل من 0.1V على الشاسي",
      signalPin: "غير محدد لهذا الرمز",
      referenceVoltage: null,
      testingTipLibyan:
        "تأكد من وصول 12V ومن سلامة الأرضي قبل تبديل أي قطعة. هذا الفحص عام وينطبق على أغلب الدوائر.",
    },
  };
}
