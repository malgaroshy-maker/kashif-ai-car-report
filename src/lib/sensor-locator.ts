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
  make?: string,
  /**
   * What the scan printed beside this code — the module it came out of and its
   * English description.
   *
   * A manufacturer-specific code number does not say which circuit it is:
   * C1290 is a steering torque sensor on one make and something else on
   * another. The words the scanner printed next to it do, and they are already
   * on the fault we are rendering. Optional, because a caller that has only a
   * code still gets the family-level answer it used to get.
   */
  context?: string
): ElectricalDiagnosticInfo {
  const normalized = (code || "").toUpperCase().trim();
  const entry = ELECTRICAL_DATABASE[normalized];

  if (entry) {
    // A table hit used to be topped up with the same invented generics for any
    // sub-block it was missing. Now a missing block falls back to the general
    // guidance for the code family, and the whole record is marked accordingly
    // so nothing claims more precision than it has.
    const base = deriveGeneral(normalized, make, context);
    const complete = Boolean(
      entry.fuseInfo && entry.sensorLocation && entry.multimeterTest
    );
    return {
      provenance: complete ? "reference" : "general",
      // A hazard belongs to the family, not to the table row: a B-code that
      // gains an entry here must not thereby lose the airbag warning.
      warning: entry.warning ?? base.warning,
      fuseInfo: entry.fuseInfo ?? base.fuseInfo,
      sensorLocation: entry.sensorLocation ?? base.sensorLocation,
      multimeterTest: entry.multimeterTest ?? base.multimeterTest,
    };
  }

  return deriveGeneral(normalized, make, context);
}

/**
 * The words the scanner printed beside a code, as one string.
 *
 * `getElectricalDiagnosticsForCode` uses it to tell apart circuits that share
 * a code letter — a steering fault from a wheel-speed fault, a bus timeout
 * from either. Both the on-screen sheet and the exported HTML build it the
 * same way, so they cannot disagree about which branch a fault lands in.
 */
export function scanContext(fault: {
  module?: string | null;
  moduleNameArabic?: string | null;
  standardDescriptionEn?: string | null;
  libyanTerm?: string | null;
}): string {
  return [
    fault.module,
    fault.moduleNameArabic,
    fault.standardDescriptionEn,
    fault.libyanTerm,
  ]
    .filter(Boolean)
    .join(" ");
}

/**
 * What is true of a module that stopped being heard from, whatever letter the
 * maker filed the code under.
 *
 * Shared by the `U` family and by any code whose printed description says it
 * is a bus timeout. Nothing here is a wiring diagram: the 60-ohm reading and
 * the two bus voltages are properties of CAN itself, not of this car.
 */
function networkGuidance(normalized: string): ElectricalDiagnosticInfo {
  return {
    provenance: "general",
    fuseInfo: {
      fuseNumber: null,
      rating: null,
      relayName: null,
      boxLocation: "مش فيوز واحد — كل كمبيوتر على الشبكة له تغذيته وفيوزه الخاص",
      circuitDescription: `عطل اتصال على شبكة الـ CAN — الرمز (${normalized}) يقول إن كمبيوتر ما وصلتش منه رسائل`,
    },
    sensorLocation: {
      areaName:
        "مش حساس: خطين بيانات (CAN High / CAN Low) ماشيين بين الكمبيوترات وفيشة الفحص OBD تحت التابلو",
      engineZone: "cabin",
      accessTip:
        "ابدأ من فيشة الفحص وتفرّع منها. أغلب أعطال الشبكة تغذية أو أرضي ناقص على كمبيوتر واحد، أو مية دخلت فيشة — مش الكمبيوتر نفسه محروق.",
      coordinatePct: null,
    },
    multimeterTest: {
      powerPin: "تغذية الكمبيوتر المفقود: 12V مع السويتش",
      groundPin: "أرضي الكمبيوتر: أقل من 0.1V على الشاسي",
      signalPin:
        "على فيشة الفحص والسويتش مفتوح: CAN High حوالي 2.5 إلى 3.5V، وCAN Low حوالي 1.5 إلى 2.5V. المقاومة بين الخطين والبطارية مفصولة حوالي 60 أوم (مقاومتين 120 على التوازي)",
      referenceVoltage: null,
      testingTipLibyan:
        "قيس 60 أوم بين خط 1 و2 من فيشة الفحص والسويتش مطفي: لو طلعت 120 يعني فرع من الشبكة مقطوع، ولو طلعت صفر يعني الخطين ملموسين في بعض. هذي القراءات عامة للـ CAN وما هيش مخطط سيارتك.",
    },
  };
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
  make?: string,
  context?: string
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
  //
  // P013x-P016x are excluded: those are the oxygen and air-fuel sensors and
  // their heaters, and they are screwed into the exhaust, not sitting in the
  // intake tract this branch describes. They join P0420 in the emissions
  // branch below, the same way the vapour codes were split out of it.
  if (
    (normalized.startsWith("P01") || normalized.startsWith("P00")) &&
    !/^P01[3-6]/.test(normalized)
  ) {
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

  // Fuel-vapour (EVAP) codes, which live at the tank end of the car.
  //
  // These used to fall into the emissions branch below and be answered with
  // "the exhaust line, underneath the car" and how to read an oxygen sensor's
  // heater resistance. A real Camry scan came back with P0453 — the vapour
  // pressure sensor, which sits on the charcoal canister behind the fuel tank.
  // The report's own checklist said so on one screen while the wiring sheet
  // sent the reader under the exhaust on the next. P044x-P046x is the vapour
  // side; P013x-P016x and the rest of P04/P05 are the exhaust side.
  if (/^P04[4-6]/.test(normalized)) {
    return {
      provenance: "general",
      fuseInfo: {
        ...noFuseNumber,
        boxLocation:
          "عادةً علبة فيوزات حوض المحرك — نفس مسار تغذية كمبيوتر المحرك وفالفات التبخير",
        circuitDescription: `دائرة منظومة تبخير الوقود (EVAP) — الرمز (${normalized}) من عائلة قربة الفحم وفالفاتها`,
      },
      sensorLocation: {
        areaName:
          "ناحية خزان البنزين: قربة الفحم (Canister) وحساس الضغط وفالف التنفيس، وغطا البنزين نفسه",
        engineZone: "fuel-tank",
        accessTip:
          "ابدأ من أرخص حاجة: غطا البنزين وجلدته. بعدها الخراطيم الماشية لقربة الفحم — هذه المنطقة تحت السيارة وتتملح وتتقرض. الحساس والفالف عادةً على القربة نفسها أو فوق الخزان.",
        coordinatePct: null,
      },
      multimeterTest: {
        powerPin: "خط التغذية لحساس الضغط: مع السويتش",
        groundPin: "خط الأرضي: أقل من 0.1V على الشاسي",
        signalPin:
          "إشارة حساس ضغط التبخير تتغير مع ضغط الخزان — تتقرا أوضح من جهاز الكشف (Live Data) وانت تفك غطا البنزين وتردّه",
        referenceVoltage: null,
        testingTipLibyan:
          "شوف قراءة الحساس على جهاز الكشف والغطا مقفول وبعدها مفتوح: لو ما تحركتش، الحساس أو سلكه. افحص الخراطيم والفيشة من التمليح قبل ما تشري القطعة — أغلب أعطال هذه العائلة تسريب أو خرطوم، مش الحساس.",
      },
    };
  }

  // Emissions, speed, cruise — and the oxygen sensors on the exhaust line.
  if (
    normalized.startsWith("P04") ||
    normalized.startsWith("P05") ||
    /^P01[3-6]/.test(normalized)
  ) {
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

  // Body codes — on most makes this is where the airbag system lives.
  //
  // Two reasons this family gets its own branch rather than the catch-all
  // below, and the first one is a safety matter:
  //
  // **The generic advice was dangerous here.** The catch-all tells the reader
  // to check for 12V and a good ground before replacing anything, and calls
  // that "فحص عام وينطبق على أغلب الدوائر". On a squib circuit — the igniter
  // in an airbag or a belt pretensioner — the meter's own test current can set
  // the charge off, into the hand holding the probe. A real Camry report put
  // that line on all seven of its faults, every one of them an SRS code.
  //
  // **The number cannot be looked up.** B-codes are manufacturer-specific:
  // the same B1650 is a different circuit on a Toyota than on a Ford, so a
  // table keyed on the number alone would be inventing. What is true across
  // makes is the family: where the fuse sits, that the wiring runs under the
  // seats and up the column, how to depower it, and what not to probe.
  if (normalized.startsWith("B")) {
    return {
      provenance: "general",
      warning:
        "خطر — منظومة وسائد هوائية: ما تقيسش دائرة كبسولة الإيرباق (Squib) ولا شداد الحزام بالأفوميتر. تيار الفحص اللي يطلع من الجهاز روحه يقدر يفجر الشحنة في وجهك. افصل طرف البطارية السالب واستنى على الأقل دقيقة إلى تلات دقايق قبل ما تفك أي فيشة صفراء، واشتغل بجهاز الكشف موش بالأفوميتر.",
      fuseInfo: {
        ...noFuseNumber,
        boxLocation:
          "عادةً العلبة الداخلية تحت التابلو — فيوز مكتوب عليه AIR BAG أو SRS على غطا العلبة",
        circuitDescription: `دائرة منظومة الهيكل والسلامة — الرمز (${normalized}) من أكواد الـ B الخاصة بكل شركة`,
      },
      sensorLocation: {
        areaName:
          "داخل المقصورة: عمود الدركسيون، تحت الكراسي، والعتبات تحت الفرش",
        engineZone: "cabin",
        accessTip:
          "أغلب أعطال الـ SRS فيشة صفراء ما هيش مقفولة تحت الكرسي، أو سلك انقطع من حركة الكرسي قدام وورا. افحصها قبل ما تشري أي قطعة — والبطارية مفصولة.",
        coordinatePct: null,
      },
      multimeterTest: {
        powerPin:
          "ما ينقاسش على دوائر الإيرباق — اقرا التحذير فوق",
        groundPin:
          "أرضي كمبيوتر الـ SRS على الشاسي — ينفحص بالنظر والربط، موش بالقياس على الدائرة",
        signalPin:
          "مقاومة دائرة الكبسولة تتقرا من جهاز الكشف (Live Data)، موش من الأفوميتر",
        referenceVoltage: null,
        testingTipLibyan:
          "الطريقة السليمة: افصل البطارية، استنى، فك الفيشة وشوفها بالعين (كربون، تمليح، قفل مكسور، سلك مقروض)، ركبها وامسح الكود بالجهاز، وشوف هل رجع. أكواد الـ B تختلف من شركة لشركة، فرقم الكود لوحده ما يدلش على نفس الدائرة في كل سيارة.",
      },
    };
  }

  // A bus timeout is a bus timeout whatever letter it was filed under.
  //
  // The U branch below holds what is true about a module that stopped being
  // heard from. Makers do not all file those codes under U: the Elantra scan
  // printed "C1611 CAN Time-Out EMS" — the EPS module saying it lost the
  // engine ECU — and the chassis branch answered it with wheel-speed sensors.
  // Nothing about that fault is at a wheel.
  if (
    !normalized.startsWith("U") &&
    /CAN|BUS|TIME.?OUT|COMMUNICAT|LOST COMM/i.test(context || "")
  ) {
    return networkGuidance(normalized);
  }

  // Chassis codes: the brakes, the stability system, and the steering.
  //
  // This branch used to answer every C-code with the wheel hubs: "the speed
  // sensor on the hub and its wire running with the bearing", lift the car,
  // compare the four wheel-speed readings. That is right for the ABS half of
  // the family and wrong for the other half, and C-codes are
  // manufacturer-specific, so the number alone does not say which.
  //
  // A real Elantra scan came back with four codes out of the electric power
  // steering module — C1259 and C1261 on the steering angle sensor, C1290 on
  // the torque sensor, C1611 a bus timeout. Every one of those parts is in the
  // steering column, and the sheet sent the reader under the car to the wheel
  // bearings. So the location is no longer asserted from the letter: the
  // module the code was read out of is what names the area, the way the B
  // branch already works.
  if (normalized.startsWith("C")) {
    const steering = /STEER|EPS|EPAS|MDPS|SAS|TORQUE/i.test(context || "");
    return {
      provenance: "general",
      fuseInfo: {
        ...noFuseNumber,
        boxLocation: steering
          ? "عادةً فيوز كبير مكتوب عليه EPS أو MDPS أو POWER STEERING — يكون في علبة حوض المحرك أو علبة خاصة قريبة من البطارية"
          : "عادةً علبة فيوزات حوض المحرك — فيوز مكتوب عليه ABS أو VSC على غطا العلبة",
        circuitDescription: steering
          ? `دائرة الستيرسو الكهربائي — الرمز (${normalized}) من أكواد الهيكل الخاصة بكل شركة`
          : `دائرة الفرامل والاتزان — الرمز (${normalized}) من أكواد الهيكل الخاصة بكل شركة`,
      },
      sensorLocation: steering
        ? {
            areaName:
              "عمود الدركسيون داخل المقصورة: حساس زاوية الستيرسو وحساس العزم وكمبيوتر الـ EPS — كلهم على العمود أو على علبة الدركسيون",
            engineZone: "cabin",
            accessTip:
              "حساس الزاوية وحساس العزم جوا عمود الدركسيون تحت غطا البلاستيك، وأغلبهم ما ينباعش لوحده. حساس الزاوية كثير يحتاج تصفير (Calibration) بجهاز الكشف بعد أي شغل في الصالة أو الميزان — جرب التصفير قبل ما تشري قطعة. لو في إيرباق في الدركسيون افصل البطارية واستنى قبل ما تفك.",
            coordinatePct: null,
          }
        : {
            areaName: "عند العجلات: حساس السرعة على القاعدة وسلكه الماشي مع الكوشينة",
            engineZone: "wheel-hub",
            accessTip:
              "ارفع السيارة على الكريك وافحص سلك الحساس عند الدوران — أغلب أعطال هذه العائلة سلك مقروض أو فيشة مملحة عند العجلة، مش الحساس.",
            coordinatePct: null,
          },
      multimeterTest: steering
        ? {
            powerPin: "خط التغذية: 12V مع السويتش على فيشة الكمبيوتر أو الحساس",
            groundPin: "خط الأرضي: أقل من 0.1V على الشاسي",
            signalPin:
              "حساس الزاوية وحساس العزم يمشيوا على الشبكة أو على خطين إشارة متعاكسين — القراءة الصحيحة تتاخذ من جهاز الكشف (Live Data) وانت تلف الدركسيون يمين ويسار، مش من الأفوميتر",
            referenceVoltage: null,
            testingTipLibyan:
              "لف الدركسيون من الآخر للآخر وراقب زاوية الستيرسو على جهاز الكشف: لازم تتحرك بانتظام وترجع صفر والعجلات مستقيمة. لو قفزت أو وقفت، ابدأ بالتصفير وبعدها بالفيشة تحت العمود. أكواد الـ C تختلف من شركة لشركة، فرقم الكود لوحده ما يدلش على نفس الدائرة في كل سيارة.",
          }
        : {
            powerPin: "خط التغذية: 12V مع السويتش على فيشة الحساس",
            groundPin: "خط الأرضي: أقل من 0.1V على الشاسي",
            signalPin:
              "حساس السرعة يعطي نبضة متغيرة مع دوران العجلة — تتقرا أوضح من جهاز الكشف (Live Data) وانت تدور العجلة باليد",
            referenceVoltage: null,
            testingTipLibyan:
              "قارن قراءة سرعة العجلات الأربع على جهاز الكشف والسيارة ماشية شوي: العجلة اللي قراءتها صفر أو تقفز هي المشكلة. نظف سن الطاسة (Reluctor Ring) من الصدى قبل ما تبدل الحساس. أكواد الـ C تختلف من شركة لشركة، فرقم الكود لوحده ما يدلش على نفس الدائرة في كل سيارة.",
          },
    };
  }

  // Network codes: modules that stopped hearing each other on the bus.
  if (normalized.startsWith("U")) return networkGuidance(normalized);

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
