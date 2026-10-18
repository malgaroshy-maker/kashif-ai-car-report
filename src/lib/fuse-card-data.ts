export interface EquipmentMapping {
  equipmentEnglish: string;
  equipmentArabic: string;
  fuses: number[];
  category?: string;
}

export interface FuseSlotDetail {
  id: string; // e.g. "F1"
  number: number;
  label: string;
  nameArabic: string;
  ratingAmps: number;
  descriptionArabic: string;
  colorName: string;
  hexColor: string;
  symptoms: string[];
  associatedDTCs?: string[];
  testingTip?: string;
}

/**
 * بيانات صورة خريطة فيوزات حقيقية
 */
export interface FuseMapImage {
  /** رابط الصورة الكامل (URL خارجي) */
  url: string;
  /** عنوان الصورة بالعربي (يظهر تحت الصورة) */
  titleArabic: string;
  /** وصف مختصر بالعربي */
  descriptionArabic?: string;
  /** نوع الصورة - لتصنيف الصور في الكاروسيل */
  type: "card" | "layout" | "location";
  /** عرض الصورة الأصلي بالبكسل (اختياري - للـ aspect ratio) */
  width?: number;
  /** ارتفاع الصورة الأصلي بالبكسل (اختياري) */
  height?: number;
}

export interface VehicleFuseCard {
  boxId: string;
  boxNameArabic: string;
  locationArabic: string;
  accessInstructionsArabic: string;
  cardPartNumber?: string;
  hasPullTab?: boolean;
  row1: number[];
  row1Special?: number[];
  row2: number[];
  amperesMap: Record<number, number>;
  equipmentList: EquipmentMapping[];
  slots: Record<number, FuseSlotDetail>;
  /** صور خرائط الفيوزات الحقيقية لهذا الصندوق */
  fuseMapImages?: FuseMapImage[];
}

export interface CarFuseModelData {
  id: string;
  make: string;
  makeArabic: string;
  model: string;
  modelArabic: string;
  yearRange: string;
  boxes: VehicleFuseCard[];
}

export function getFuseColor(amps: number): { hex: string; name: string } {
  switch (amps) {
    case 5:
      return { hex: "#FF9800", name: "برتقالي (5A)" };
    case 7.5:
    case 7:
    case 8:
      return { hex: "#8D6E63", name: "بني (7.5A)" };
    case 10:
      return { hex: "#E53935", name: "أحمر (10A)" };
    case 15:
      return { hex: "#1E88E5", name: "أزرق (15A)" };
    case 20:
      return { hex: "#FDD835", name: "أصفر (20A)" };
    case 25:
      return { hex: "#E0E0E0", name: "أبيض شفاف (25A)" };
    case 30:
      return { hex: "#43A047", name: "أخضر (30A)" };
    case 40:
      return { hex: "#FB8C00", name: "برتقالي ماكسي (40A)" };
    case 50:
      return { hex: "#D32F2F", name: "أحمر ماكسي (50A)" };
    default:
      return { hex: "#94A3B8", name: `${amps}A` };
  }
}

export const CAR_FUSE_CARDS_DATA: CarFuseModelData[] = [
  // =========================================================================
  // 1. BMW 5-Series E39 (Official Card Part # 8 377 849 / E 6957.J)
  // =========================================================================
  {
    id: "bmw_e39",
    make: "BMW",
    makeArabic: "بي إم دبليو",
    model: "5 Series (E39)",
    modelArabic: "الفئة الخامسة (5 Series E39)",
    yearRange: "1995 - 2004",
    boxes: [
      {
        boxId: "glovebox",
        boxNameArabic: "بطاقة فيوزات درج التابلوه الرسمية (Glove Box)",
        locationArabic: "في سقف درج التابلوه أمام الراكب الأمامي",
        accessInstructionsArabic:
          "افتح درج التابلوه، أدر المفتاحين الأبيضين ربع دورة (90 درجة) لتنزل اللوحة بالكامل، واسحب الكرت الأبيض من مكانه المخصص.",
        cardPartNumber: "8 377 849 / E 6957.J",
        hasPullTab: true,
        row1: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
        row1Special: [75, 76],
        row2: [
          21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
          31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
          41, 42, 43, 44, 45,
        ],
        amperesMap: {
          1: 30, 2: 30, 3: 15, 4: 20, 5: 20, 6: 30, 7: 20, 8: 30, 9: 15, 10: 30,
          11: 7.5, 12: 5, 13: 30, 14: 5, 15: 7.5, 16: 5, 17: 10, 18: 5, 19: 5, 20: 7.5,
          75: 50, 76: 40,
          21: 5, 22: 30, 23: 10, 24: 5, 25: 7.5, 26: 0, 27: 30, 28: 0, 29: 30, 30: 25,
          31: 10, 32: 15, 33: 0, 34: 10, 35: 0, 36: 0, 37: 5, 38: 5, 39: 7.5, 40: 5,
          41: 5, 42: 5, 43: 5, 44: 5, 45: 7.5,
        },
        equipmentList: [
          { equipmentEnglish: "ABS diesel", equipmentArabic: "نظام فرامل مانع الانغلاق ABS (محركات الديزل)", fuses: [17, 30] },
          { equipmentEnglish: "ABS gasoline", equipmentArabic: "نظام فرامل مانع الانغلاق ABS (محركات البنزين)", fuses: [30, 31] },
          { equipmentEnglish: "Air conditioner", equipmentArabic: "مكيف الهواء والتبريد (A/C)", fuses: [9, 20] },
          { equipmentEnglish: "Airbag", equipmentArabic: "الوسائد الهوائية (الإيرباج SRS)", fuses: [40, 42] },
          { equipmentEnglish: "Anti-glare inside mirror", equipmentArabic: "مرآة الرؤية الخلفية الداخلية ذات التعتيم التلقائي", fuses: [21] },
          { equipmentEnglish: "Automatic stability control", equipmentArabic: "نظام التحكم التلقائي في الثبات (ASC / مانع الانزلاق)", fuses: [8, 17, 31] },
          { equipmentEnglish: "Auxiliary fan", equipmentArabic: "مروحة التبريد الإضافية (المكيف والرديتر)", fuses: [7, 20, 22, 75] },
          { equipmentEnglish: "Brake light", equipmentArabic: "أضواء الفرامل الخلفية (الستوب)", fuses: [41] },
          { equipmentEnglish: "Central locking system", equipmentArabic: "نظام القفل المركزي للأبواب (السنترلوك)", fuses: [6, 27, 29] },
          { equipmentEnglish: "Charging socket", equipmentArabic: "مقبس الشحن وولاعة السجائر 12V", fuses: [39] },
          { equipmentEnglish: "Courtesy mirror illumination", equipmentArabic: "إضاءة مرايا الشماسات التجميلية", fuses: [39] },
          { equipmentEnglish: "Diagnosis plug", equipmentArabic: "فيشة الفحص وتشخيص الأعطال (OBD-II / 20-Pin)", fuses: [15, 38] },
          { equipmentEnglish: "Driver seat adjustment", equipmentArabic: "ضبط مقعد السائق الكهربائي وذاكرة الوضعيات", fuses: [13, 21] },
          { equipmentEnglish: "Electric seat heating", equipmentArabic: "تدفئة المقاعد الكهربائية", fuses: [32] },
          { equipmentEnglish: "Engine control", equipmentArabic: "كمبيوتر وإدارة المحرك (DME / DDE)", fuses: [14, 15] },
          { equipmentEnglish: "Fuel pump", equipmentArabic: "مضخة الوقود (طلمبة / بومبة البنزين)", fuses: [17, 31] },
          { equipmentEnglish: "Garage door opener", equipmentArabic: "وحدة فتح باب المرآب المدمجة", fuses: [21] },
          { equipmentEnglish: "Headlight cleaning system", equipmentArabic: "رشاشات وغسيل المصابيح الأمامية", fuses: [2] },
          { equipmentEnglish: "Heated rear window", equipmentArabic: "سخان الزجاج الخلفي لإزالة الضباب والجليد", fuses: [20] },
          { equipmentEnglish: "Heated steering wheel", equipmentArabic: "تدفئة مقود السيارة (عجلة القيادة)", fuses: [34] },
          { equipmentEnglish: "Heated washer jets", equipmentArabic: "سخانات رشاشات ماء المساحات", fuses: [9] },
          { equipmentEnglish: "Heater", equipmentArabic: "دفاية المقصورة الداخلية والتكييف", fuses: [20, 23] },
          { equipmentEnglish: "Heater blower", equipmentArabic: "مروحة ومنفاخ دفاية ومكيف المقصورة (القنفذ)", fuses: [76] },
          { equipmentEnglish: "Horn", equipmentArabic: "بوق ومنبه السيارة (الكلاكس / الهرن)", fuses: [3, 38] },
          { equipmentEnglish: "Immobilizer", equipmentArabic: "نظام منع تشغيل المحرك والسرقة (EWS 3)", fuses: [12, 37] },
          { equipmentEnglish: "Independent heater", equipmentArabic: "نظام التدفئة المستقل (Webasto)", fuses: [23] },
          { equipmentEnglish: "Instrument cluster", equipmentArabic: "طبلون العدادات وشاشة المعلومات (IKE)", fuses: [18, 24, 40] },
          { equipmentEnglish: "Light module", equipmentArabic: "وحدة التحكم المركزية بالإنارة (LCM)", fuses: [16, 41] },
          { equipmentEnglish: "Multi-function steering wheel", equipmentArabic: "أزرار التحكم بمقود السيارة (MFL)", fuses: [44] },
          { equipmentEnglish: "Multi-information display", equipmentArabic: "شاشة عرض المعلومات المركزية (MID)", fuses: [25, 44] },
          { equipmentEnglish: "On-board monitor", equipmentArabic: "شاشة العرض ونظام الملاحة والراديو", fuses: [43, 56, 58] },
          { equipmentEnglish: "Outside mirror adjustment", equipmentArabic: "تعديل وطي المرايا الجانبية كهربائياً", fuses: [6, 29] },
          { equipmentEnglish: "Park-Distance-Control", equipmentArabic: "حساسات المساعدة على الاصطفاف والركن (PDC)", fuses: [21] },
          { equipmentEnglish: "Passenger comp./trunk lighting", equipmentArabic: "إنارة المقصورة والصالون والشنطة الخلفية", fuses: [4] },
          { equipmentEnglish: "Passenger seat adjustment", equipmentArabic: "ضبط مقعد الراكب الأمامي كهربائياً", fuses: [10] },
          { equipmentEnglish: "Radio", equipmentArabic: "راديو ومنظومة الصوت بالسيارة", fuses: [25, 43, 44] },
          { equipmentEnglish: "Roller sun blind", equipmentArabic: "ستارة الزجاج الخلفي الكهربائية", fuses: [45] },
          { equipmentEnglish: "Servotronic", equipmentArabic: "نظام التوجيه الهيدروليكي المؤازر (Servotronic)", fuses: [11] },
          { equipmentEnglish: "Shifting gate illumination", equipmentArabic: "إنارة حارة عصا القير الأوتوماتيك", fuses: [24, 38] },
          { equipmentEnglish: "Sliding/tilt roof", equipmentArabic: "فتحة السقف الكهربائية (السلايدينغ)", fuses: [5] },
          { equipmentEnglish: "Speed control", equipmentArabic: "مثبت السرعة الإلكتروني (Cruise Control)", fuses: [41] },
          { equipmentEnglish: "Steering column adjustment", equipmentArabic: "ضبط عمود التوجيه (الستيرنج) كهربائياً", fuses: [13] },
          { equipmentEnglish: "Telephone", equipmentArabic: "وحدة وتجهيز هاتف السيارة", fuses: [43, 44] },
          { equipmentEnglish: "Thermal sensor", equipmentArabic: "الحساس الحراري ومستوى الزيت بالمحرك", fuses: [21] },
          { equipmentEnglish: "Tyre pressure control system", equipmentArabic: "نظام مراقبة ضغط الإطارات (RDC)", fuses: [24] },
          { equipmentEnglish: "Window lift", equipmentArabic: "زجاج النوافذ الكهربائية (الأبواب الأربعة)", fuses: [6, 27, 29] },
          { equipmentEnglish: "Windscreen washer system", equipmentArabic: "مضخة رش ماء مساحات الزجاج", fuses: [2, 4] },
          { equipmentEnglish: "Windscreen wiper", equipmentArabic: "محرك ومساحات الزجاج الأمامي", fuses: [1] },
        ],
        slots: {
          1: {
            id: "F1",
            number: 1,
            label: "WIPER",
            nameArabic: "فيوز مساحات الزجاج الأمامية",
            ratingAmps: 30,
            descriptionArabic: "يغذي موتور مساحات الزجاج الأمامي وسرعات المسح.",
            colorName: "أخضر (30A)",
            hexColor: "#43A047",
            symptoms: ["توقف مساحات الزجاج الأمامي عن العمل تماماً"],
          },
          3: {
            id: "F3",
            number: 3,
            label: "HORN",
            nameArabic: "فيوز بوق ومنبه السيارة (الكلاكس / الهرن)",
            ratingAmps: 15,
            descriptionArabic: "يغذي بوق التنبيه الصوتي في واجهة السيارة.",
            colorName: "أزرق (15A)",
            hexColor: "#1E88E5",
            symptoms: ["المنبه لا يصدر صوتاً نهائياً عند الضغط على وسط المقود"],
          },
          15: {
            id: "F15",
            number: 15,
            label: "OBD / DIAG",
            nameArabic: "فيوز مدخل الفحص التشخيصي OBD-II ووصلة السكنر",
            ratingAmps: 7.5,
            descriptionArabic: "تغذية الطرف رقم 16 في فيشة الفحص OBD بجهد 12V.",
            colorName: "بني (7.5A)",
            hexColor: "#8D6E63",
            symptoms: ["أجهزة الفحص (Launch / Autel / INPA) لا تضيء نهائياً ولا تتصل"],
            associatedDTCs: ["U0100"],
            testingTip: "افحص النقطة 16 في فيشة الفحص OBD، إذا كان الجهد صفراً فهذا الفيوز F15 مقطوع.",
          },
          17: {
            id: "F17",
            number: 17,
            label: "ABS / PUMP",
            nameArabic: "فيوز فرامل ABS ديزل ومضخة الوقود وتحكم الثبات",
            ratingAmps: 10,
            descriptionArabic: "تغذية منظومة الفرامل ومضخة البنزين في طرازات محددة من E39.",
            colorName: "أحمر (10A)",
            hexColor: "#E53935",
            symptoms: ["إضاءة لمبة ABS وتوقف مضخة الوقود"],
          },
          31: {
            id: "F31",
            number: 31,
            label: "FUEL PUMP / ASC",
            nameArabic: "فيوز طلمبة (مضخة) البنزين ونظام منع الانزلاق (بنزين)",
            ratingAmps: 10,
            descriptionArabic: "يغذي دائرة مضخة الوقود ومنظومة الثبات ASC في موديلات البنزين.",
            colorName: "أحمر (10A)",
            hexColor: "#E53935",
            symptoms: ["المحرك يدور بالسلف ولكن قاطع بنزين ونار", "توقف مضخة البنزين عن العمل"],
            associatedDTCs: ["P0087"],
            testingTip: "قيس وصول 12V عند مخرج هذا الفيوز مع فتح السويتش مباشرة.",
          },
          75: {
            id: "F75",
            number: 75,
            label: "AUX FAN MAXI",
            nameArabic: "فيوز ماكسي مروحة التبريد الإضافية (50A)",
            ratingAmps: 50,
            descriptionArabic: "فيوز قدرة عالي لحماية دائرة محرك مروحة التبريد الكبرى أمام الردياتير.",
            colorName: "أحمر ماكسي (50A)",
            hexColor: "#D32F2F",
            symptoms: ["توقف المروحة الكهربائية وارتفاع حرارة المحرك في الصيف"],
          },
          76: {
            id: "F76",
            number: 76,
            label: "BLOWER MAXI",
            nameArabic: "فيوز ماكسي منفاخ ومروحة دفع هواء المكيف والدفاية (40A)",
            ratingAmps: 40,
            descriptionArabic: "فيوز رئيسي لموتور مروحة التكييف ومقاومة السرعات الفاينل ستيج (القنفذ).",
            colorName: "برتقالي ماكسي (40A)",
            hexColor: "#FB8C00",
            symptoms: ["مروحة المكيف متوقفة تماماً ولا يخرج أي هواء من الهوايات"],
            testingTip: "في BMW E39، يترافق احتراق هذا الفيوز مع تلف مقاومة المكيف (Final Stage Unit).",
          },
        },
      },
      {
        boxId: "trunk",
        boxNameArabic: "علبة فيوزات الشنطة الخلفية فوق البطارية (Trunk)",
        locationArabic: "في الشنطة الخلفية جهة اليمين، مباشرة فوق البطارية",
        accessInstructionsArabic: "أدر مقبض قفل بطانة الشنطة في الجانب الأيمن واسحب الغطاء للوصول لصينية الفيوزات.",
        cardPartNumber: "Trunk Fuses F46-F66",
        hasPullTab: false,
        row1: [46, 47, 48, 50, 53, 54],
        row2: [56, 57, 58, 66],
        amperesMap: {
          46: 30, 47: 20, 48: 40, 50: 5, 53: 7.5, 54: 15,
          56: 30, 57: 10, 58: 10, 66: 40,
        },
        equipmentList: [
          { equipmentEnglish: "Auxiliary heater", equipmentArabic: "نظام التدفئة المستقل والإضافي (Webasto)", fuses: [46] },
          { equipmentEnglish: "Cigarette lighter rear", equipmentArabic: "ولاعة السجائر ومقبس الطاقة الخلفي 12V", fuses: [47] },
          { equipmentEnglish: "Heated rear window", equipmentArabic: "سخان الزجاج الخلفي لإزالة الضباب", fuses: [48, 66] },
          { equipmentEnglish: "Air suspension", equipmentArabic: "نظام التعليق الهوائي والمساعدات (الهايدروليك)", fuses: [50] },
          { equipmentEnglish: "Central locking (fuel flap)", equipmentArabic: "قفل غطاء خزان الوقود والسنتر لوك الخلفي", fuses: [53] },
          { equipmentEnglish: "Fuel pump", equipmentArabic: "مضخة الوقود الكهربائية الرئيسية في التانك", fuses: [54] },
          { equipmentEnglish: "CD changer / Navigation", equipmentArabic: "مشغل الأقراص المدمجة ونظام الملاحة GPS", fuses: [56] },
          { equipmentEnglish: "Telephone / TV", equipmentArabic: "هاتف السيارة وتلفزيون الشاشة", fuses: [57] },
          { equipmentEnglish: "Radio / On-board monitor", equipmentArabic: "راديو السيارة وشاشة المراقبة المركزية", fuses: [58] },
          { equipmentEnglish: "Rear seat adjustment", equipmentArabic: "ضبط المقاعد الخلفية وتوصيلات المقطورة", fuses: [66] },
        ],
        slots: {
          54: {
            id: "F54",
            number: 54,
            label: "FUEL PUMP",
            nameArabic: "فيوز طرمبة (بومبة) البنزين الرئيسية في خزان الوقود",
            ratingAmps: 15,
            descriptionArabic: "التغذية المباشرة لمضخة الوقود الغاطسة داخل تانك البنزين.",
            colorName: "أزرق (15A)",
            hexColor: "#1E88E5",
            symptoms: [
              "السيارة تدور بالسلف طويلاً دون تشغيل (قاطعة ضغط بنزين)",
              "عدم سماع صوت أزيز الطرمبة عند فتح السويتش",
            ],
            associatedDTCs: ["P0087", "P0190"],
            testingTip: "افحص هذا الفيوز فوراً مع ريلي طرمبة البنزين الأخضر المجاور له إذا كانت السيارة لا تعمل.",
          },
        },
      },
    ],
  },

  // =========================================================================
  // 2. Toyota Corolla (E140 / E150)
  // =========================================================================
  {
    id: "toyota_corolla",
    make: "Toyota",
    makeArabic: "تويوتا",
    model: "Corolla",
    modelArabic: "كورولا (Corolla E140/E150)",
    yearRange: "2008 - 2013",
    boxes: [
      {
        boxId: "engine",
        boxNameArabic: "علبة فيوزات حوض المحرك الرئيسية",
        locationArabic: "في الكبوت من جهة السائق (اليسار)، بجانب البطارية وقربة ماء المساحات",
        accessInstructionsArabic: "اضغط على ألسنة القفل الجانبية الثلاثة للغطاء الأسود ثم ارفعه للأعلى.",
        cardPartNumber: "Toyota Genuine Relay & Fuse Lid",
        row1: [1, 2, 3, 4, 5, 6, 7, 8],
        row2: [9, 10, 11, 12, 13, 14, 15, 16],
        amperesMap: {
          1: 20, 2: 30, 3: 30, 4: 20, 5: 10, 6: 10, 7: 15, 8: 10,
          9: 15, 10: 10, 11: 7.5, 12: 15, 13: 20, 14: 10, 15: 30, 16: 10,
        },
        equipmentList: [
          { equipmentEnglish: "EFI MAIN", equipmentArabic: "كمبيوتر المحرك ومنظومة الحقن الإلكتروني", fuses: [1] },
          { equipmentEnglish: "FAN MAIN", equipmentArabic: "مروحة تبريد الرداتوري والمكيف الرئيسية", fuses: [3] },
          { equipmentEnglish: "HORN", equipmentArabic: "بوق ومنبه السيارة (الكلاكس / الهرن)", fuses: [5] },
          { equipmentEnglish: "IGN", equipmentArabic: "منظومة إشعال المحرك وكويلات البوبينات", fuses: [6] },
          { equipmentEnglish: "A/C COMP", equipmentArabic: "كلتش ضاغط التكييف (كمبروسر المكيف)", fuses: [8] },
          { equipmentEnglish: "H-LP MAIN", equipmentArabic: "المصابيح والكشافات الأمامية الرئيسية", fuses: [4] },
          { equipmentEnglish: "EFI 2", equipmentArabic: "حساسات الشكمان وحساس تدفق الهواء MAF", fuses: [7] },
          { equipmentEnglish: "ABS NO. 1", equipmentArabic: "مضخة ووحدة فرامل مانع الانغلاق ABS", fuses: [15] },
        ],
        slots: {
          1: {
            id: "F1",
            number: 1,
            label: "EFI MAIN",
            nameArabic: "فيوز كمبيوتر المحرك الرئيسي ومنظومة الحقن",
            ratingAmps: 20,
            descriptionArabic: "يغذي كمبيوتر إدارة المحرك (ECM) ورشاشات الوقود وحساسات العادم.",
            colorName: "أصفر (20A)",
            hexColor: "#FDD835",
            symptoms: [
              "المحرك يدور بالسلف (الموتورينو) لكن لا يعمل نهائياً",
              "عدم إضاءة لمبة فحص المحرك (Check Engine) في الطبلون عند فتح السويتش",
            ],
            associatedDTCs: ["P0606", "P0685", "U0100"],
          },
        },
      },
    ],
  },
];
