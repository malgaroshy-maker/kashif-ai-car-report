import '../models/car_fuse_box.dart';

class CarFuseRepository {
  static const List<CarVehicleModel> supportedCars = [
    // =========================================================================
    // 1. BMW 5 Series (E39) - 520i, 523i, 525i, 528i, 530i, 535i, 540i, M5
    // =========================================================================
    CarVehicleModel(
      id: 'bmw_5_series_e39',
      make: 'BMW',
      makeArabic: 'بي إم دبليو',
      model: '5 Series (E39)',
      modelArabic: 'الفئة الخامسة (5 Series E39)',
      yearRange: '1995 - 2004 (520i / 523i / 525i / 528i / 530i / 535i / 540i / M5)',
      bodyType: 'سيدان / تورينغ عريقة',
      obdLocation: 'تحت الطبلون جهة اليسار (السائق) بجانب مسند القدم، أو فيشة الفحص الدائرية 20-Pin بحوض المحرك لموديلات ما قبل 2001.',
      fuseBoxes: [
        // 1. Glove Compartment Drop-down Panel (Card OEM # 8 377 849 / E 6957.J)
        VehicleFuseBox(
          id: 'bmw_e39_glove_box',
          nameArabic: 'بطاقة فيوزات درج التابلوه الرسمية (Glove Box Fuse Card)',
          locationType: FuseBoxLocationType.cabin,
          detailedLocationArabic:
              'في سقف درج التابلوه (صندوق القفازات) أمام الراكب الأمامي، تنزل لأسفل بمفتاحين بلاستيك أبيضين.',
          accessInstructions:
              'افتح درج التابلوه، أدر المفتاحين الأبيضين ربع دورة (90 درجة) لتنزل لوحة الفيوزات بالكامل إلى الأسفل، واسحب كرت المخطط الأبيض من مكانه.',
          realisticCoverNote:
              'البطاقة الأصلية الرسمية لمصنع BMW (Part No. 8 377 849 / E 6957.J) مطبوعة ومترجمة بالكامل للعربية.',
          cardPartNumber: '8 377 849 / E 6957.J',
          hasPullTab: true,
          equipmentMappings: [
            EquipmentFuseMapping(
              equipmentEnglish: 'ABS diesel',
              equipmentArabic: 'نظام فرامل مانع الانغلاق ABS (محركات الديزل)',
              fuseNumbers: [17, 30],
              category: 'brakes',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'ABS gasoline',
              equipmentArabic: 'نظام فرامل مانع الانغلاق ABS (محركات البنزين)',
              fuseNumbers: [30, 31],
              category: 'brakes',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Air conditioner',
              equipmentArabic: 'مكيف الهواء والتبريد (A/C)',
              fuseNumbers: [9, 20],
              category: 'comfort',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Airbag',
              equipmentArabic: 'الوسائد الهوائية (الإيرباج SRS)',
              fuseNumbers: [40, 42],
              category: 'safety',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Anti-glare inside mirror',
              equipmentArabic: 'مرآة الرؤية الخلفية الداخلية ذات التعتيم التلقائي',
              fuseNumbers: [21],
              category: 'electrical',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Automatic stability control',
              equipmentArabic: 'نظام التحكم التلقائي في الثبات (ASC / مانع الانزلاق)',
              fuseNumbers: [8, 17, 31],
              category: 'brakes',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Auxiliary fan',
              equipmentArabic: 'مروحة التبريد الإضافية (المكيف والرديتر)',
              fuseNumbers: [7, 20, 22, 75],
              category: 'cooling',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Brake light',
              equipmentArabic: 'أضواء الفرامل الخلفية (الستوب)',
              fuseNumbers: [41],
              category: 'lighting',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Central locking system',
              equipmentArabic: 'نظام القفل المركزي للأبواب (السنترلوك)',
              fuseNumbers: [6, 27, 29],
              category: 'body',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Charging socket',
              equipmentArabic: 'مقبس الشحن وولاعة السجائر 12V',
              fuseNumbers: [39],
              category: 'electrical',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Courtesy mirror illumination',
              equipmentArabic: 'إضاءة مرايا الشماسات التجميلية',
              fuseNumbers: [39],
              category: 'lighting',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Diagnosis plug',
              equipmentArabic: 'فيشة الفحص وتشخيص الأعطال (OBD-II / 20-Pin)',
              fuseNumbers: [15, 38],
              category: 'diagnostics',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Driver seat adjustment',
              equipmentArabic: 'ضبط مقعد السائق الكهربائي وذاكرة الوضعيات',
              fuseNumbers: [13, 21],
              category: 'comfort',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Electric seat heating',
              equipmentArabic: 'تدفئة المقاعد الكهربائية',
              fuseNumbers: [32],
              category: 'comfort',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Engine control',
              equipmentArabic: 'كمبيوتر وإدارة المحرك (DME / DDE)',
              fuseNumbers: [14, 15],
              category: 'engine',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Fuel pump',
              equipmentArabic: 'مضخة الوقود (طلمبة / بومبة البنزين)',
              fuseNumbers: [17, 31],
              category: 'engine',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Garage door opener',
              equipmentArabic: 'وحدة فتح باب المرآب المدمجة',
              fuseNumbers: [21],
              category: 'convenience',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Headlight cleaning system',
              equipmentArabic: 'رشاشات وغسيل المصابيح الأمامية',
              fuseNumbers: [2],
              category: 'lighting',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Heated rear window',
              equipmentArabic: 'سخان الزجاج الخلفي لإزالة الضباب والجليد',
              fuseNumbers: [20],
              category: 'comfort',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Heated steering wheel',
              equipmentArabic: 'تدفئة مقود السيارة (عجلة القيادة)',
              fuseNumbers: [34],
              category: 'comfort',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Heated washer jets',
              equipmentArabic: 'سخانات رشاشات ماء المساحات',
              fuseNumbers: [9],
              category: 'comfort',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Heater',
              equipmentArabic: 'دفاية المقصورة الداخلية والتكييف',
              fuseNumbers: [20, 23],
              category: 'comfort',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Heater blower',
              equipmentArabic: 'مروحة ومنفاخ دفاية ومكيف المقصورة (القنفذ)',
              fuseNumbers: [76],
              category: 'comfort',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Horn',
              equipmentArabic: 'بوق ومنبه السيارة (الكلاكس / الهرن)',
              fuseNumbers: [3, 38],
              category: 'safety',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Immobilizer',
              equipmentArabic: 'نظام منع تشغيل المحرك والسرقة (EWS 3)',
              fuseNumbers: [12, 37],
              category: 'security',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Independent heater',
              equipmentArabic: 'نظام التدفئة المستقل (Webasto)',
              fuseNumbers: [23],
              category: 'comfort',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Instrument cluster',
              equipmentArabic: 'طبلون العدادات وشاشة المعلومات (IKE)',
              fuseNumbers: [18, 24, 40],
              category: 'dashboard',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Light module',
              equipmentArabic: 'وحدة التحكم المركزية بالإنارة (LCM)',
              fuseNumbers: [16, 41],
              category: 'lighting',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Multi-function steering wheel',
              equipmentArabic: 'أزرار التحكم بمقود السيارة (MFL)',
              fuseNumbers: [44],
              category: 'convenience',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Multi-information display',
              equipmentArabic: 'شاشة عرض المعلومات المركزية (MID)',
              fuseNumbers: [25, 44],
              category: 'dashboard',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'On-board monitor',
              equipmentArabic: 'شاشة العرض ونظام الملاحة والراديو',
              fuseNumbers: [43, 56, 58],
              category: 'infotainment',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Outside mirror adjustment',
              equipmentArabic: 'تعديل وطي المرايا الجانبية كهربائياً',
              fuseNumbers: [6, 29],
              category: 'body',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Park-Distance-Control',
              equipmentArabic: 'حساسات المساعدة على الاصطفاف والركن (PDC)',
              fuseNumbers: [21],
              category: 'safety',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Passenger comp./trunk lighting',
              equipmentArabic: 'إنارة المقصورة والصالون والشنطة الخلفية',
              fuseNumbers: [4],
              category: 'lighting',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Passenger seat adjustment',
              equipmentArabic: 'ضبط مقعد الراكب الأمامي كهربائياً',
              fuseNumbers: [10],
              category: 'comfort',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Radio',
              equipmentArabic: 'راديو ومنظومة الصوت بالسيارة',
              fuseNumbers: [25, 43, 44],
              category: 'infotainment',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Roller sun blind',
              equipmentArabic: 'ستارة الزجاج الخلفي الكهربائية',
              fuseNumbers: [45],
              category: 'comfort',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Servotronic',
              equipmentArabic: 'نظام التوجيه الهيدروليكي المؤازر (Servotronic)',
              fuseNumbers: [11],
              category: 'steering',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Shifting gate illumination',
              equipmentArabic: 'إنارة حارة عصا القير الأوتوماتيك',
              fuseNumbers: [24, 38],
              category: 'lighting',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Sliding/tilt roof',
              equipmentArabic: 'فتحة السقف الكهربائية (السلايدينغ)',
              fuseNumbers: [5],
              category: 'body',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Speed control',
              equipmentArabic: 'مثبت السرعة الإلكتروني (Cruise Control)',
              fuseNumbers: [41],
              category: 'engine',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Steering column adjustment',
              equipmentArabic: 'ضبط عمود التوجيه (الستيرنج) كهربائياً',
              fuseNumbers: [13],
              category: 'comfort',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Telephone',
              equipmentArabic: 'وحدة وتجهيز هاتف السيارة',
              fuseNumbers: [43, 44],
              category: 'communication',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Thermal sensor',
              equipmentArabic: 'الحساس الحراري ومستوى الزيت بالمحرك',
              fuseNumbers: [21],
              category: 'engine',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Tyre pressure control system',
              equipmentArabic: 'نظام مراقبة ضغط الإطارات (RDC)',
              fuseNumbers: [24],
              category: 'safety',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Window lift',
              equipmentArabic: 'زجاج النوافذ الكهربائية (الأبواب الأربعة)',
              fuseNumbers: [6, 27, 29],
              category: 'body',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Windscreen washer system',
              equipmentArabic: 'مضخة رش ماء مساحات الزجاج',
              fuseNumbers: [2, 4],
              category: 'visibility',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Windscreen wiper',
              equipmentArabic: 'محرك ومساحات الزجاج الأمامي',
              fuseNumbers: [1],
              category: 'visibility',
            ),
          ],
          slots: [
            // Row 1: F1 - F20 + F75, F76
            FuseSlot(
              slotId: 'F1',
              label: 'WIPER',
              nameArabic: 'فيوز مساحات الزجاج الأمامية',
              ratingAmps: 30,
              descriptionArabic: 'يغذي موتور مساحات الزجاج الأمامي وسرعات المسح العادية والسريعة.',
              symptoms: ['توقف مساحات الزجاج الأمامي عن العمل تماماً'],
              testingTip: 'افحص فيوز F1 أولاً عند توقف المساحات قبل استبدال ذراع التوجيه أو محرك المساحات.',
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F2',
              label: 'H-LP CLEAN',
              nameArabic: 'فيوز رشاشات وغسيل المصابيح الأمامية والمساحات',
              ratingAmps: 30,
              descriptionArabic: 'يغذي مضخة رش ماء تنظيف الفوانيس الأمامية والزجاج.',
              symptoms: ['عدم خروج الماء لكشافات الضباب والمصابيح عند السحب'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F3',
              label: 'HORN',
              nameArabic: 'فيوز بوق ومنبه السيارة (الكلاكس / الهرن)',
              ratingAmps: 15,
              descriptionArabic: 'يغذي بوق التنبيه الصوتي في واجهة السيارة.',
              symptoms: ['المنبه لا يصدر صوتاً نهائياً عند الضغط على وسط المقود'],
              gridRow: 0,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'F4',
              label: 'INT LT / WASH',
              nameArabic: 'فيوز إنارة المقصورة والشنطة ورشاشات الزجاج',
              ratingAmps: 20,
              descriptionArabic: 'يغذي لمبات السقف والشنطة الخلفية وطلمبة ماء الزجاج.',
              symptoms: ['انطفاء الإضاءة الترحيبية بالصالون وتعطل رشاشات ماء الزجاج'],
              gridRow: 0,
              gridCol: 3,
            ),
            FuseSlot(
              slotId: 'F5',
              label: 'SUNROOF',
              nameArabic: 'فيوز فتحة السقف الكهربائية (السلايدينغ)',
              ratingAmps: 20,
              descriptionArabic: 'يغذي محرك ومفتاح تحكم فتحة السقف الكهربائية.',
              symptoms: ['فتحة السقف لا تفتح ولا تقفل ولا تستجيب للزر'],
              gridRow: 0,
              gridCol: 4,
            ),
            FuseSlot(
              slotId: 'F6',
              label: 'CENTRAL / WIN',
              nameArabic: 'فيوز السنترلوك وضبط المرايا وزجاج النوافذ',
              ratingAmps: 30,
              descriptionArabic: 'يغذي وحدة التحكم بالأبواب العامة والقفل المركزي ومرايا الرؤية.',
              symptoms: ['تعطل أقفال الأبواب والمرايا الجانبية'],
              gridRow: 0,
              gridCol: 5,
            ),
            FuseSlot(
              slotId: 'F7',
              label: 'AUX FAN',
              nameArabic: 'فيوز مروحة التبريد الإضافية (المكيف والرديتر)',
              ratingAmps: 20,
              descriptionArabic: 'يغذي السرعة الأولى لمروحة التبريد الكهربائية أمام رديتر المكيف.',
              symptoms: [
                'ارتفاع حرارة المحرك عند تشغيل المكيف أو في الزحام',
                'ضعف تبريد مكيف الهواء وقت توقف السيارة',
              ],
              associatedDTCs: ['P0480'],
              gridRow: 0,
              gridCol: 6,
            ),
            FuseSlot(
              slotId: 'F8',
              label: 'ASC',
              nameArabic: 'فيوز نظام التحكم في الثبات (ASC / مانع الانزلاق)',
              ratingAmps: 30,
              descriptionArabic: 'يغذي صمامات ومضخة نظام التحكم في الجر والثبات ومنع الانزلاق.',
              symptoms: ['إضاءة لمبة المثلث الصفراء (ASC) في الطبلون باستمرار'],
              associatedDTCs: ['30', '31'],
              gridRow: 0,
              gridCol: 7,
            ),
            FuseSlot(
              slotId: 'F9',
              label: 'A/C / JETS',
              nameArabic: 'فيوز كلتش كمبروسر المكيف وسخانات رشاشات المساحات',
              ratingAmps: 15,
              descriptionArabic: 'يغذي الكلتش المغناطيسي لضاغط التكييف وسخانات رشاشات ماء الزجاج.',
              symptoms: ['المكيف يخرج هواء ساخناً فقط ولا يلقط الكمبروسر'],
              gridRow: 0,
              gridCol: 8,
            ),
            FuseSlot(
              slotId: 'F10',
              label: 'PASS SEAT',
              nameArabic: 'فيوز ضبط مقعد الراكب الأمامي كهربائياً',
              ratingAmps: 30,
              descriptionArabic: 'يغذي مواتير ضبط وضعيات كرسي الراكب في جميع الاتجاهات.',
              symptoms: ['مقعد الراكب لا يتحرك ولا يستجيب لأزرار التقديم والترجيع'],
              gridRow: 0,
              gridCol: 9,
            ),
            FuseSlot(
              slotId: 'F11',
              label: 'SERVOTRONIC',
              nameArabic: 'فيوز نظام مؤازرة التوجيه الهيدروليكي (Servotronic)',
              ratingAmps: 7,
              descriptionArabic: 'يتحكم في صمام مساعدة المقود الهيدروليكي لتنعيم حركة المقود عند السرعات المنخفضة.',
              symptoms: ['ثقل ملحوظ ومفاجئ في حركة مقود السيارة (الدركسيون) عند الركن'],
              gridRow: 0,
              gridCol: 10,
            ),
            FuseSlot(
              slotId: 'F12',
              label: 'EWS IMMO',
              nameArabic: 'فيوز نظام منع تشغيل المحرك والسرقة (EWS 3)',
              ratingAmps: 5,
              descriptionArabic: 'تغذية وحدة EWS المسؤولة عن مطابقة شفرة المفتاح وتشغيل السلف.',
              symptoms: [
                'السيارة لا تدور بالسلف نهائياً (السلف لا يلف والكونتاكت مفتوح)',
                'فقدان تطابق شفرة المفتاح مع كمبيوتر المحرك DME',
              ],
              associatedDTCs: ['EWS 3.3', '42'],
              gridRow: 0,
              gridCol: 11,
            ),
            FuseSlot(
              slotId: 'F13',
              label: 'DRV SEAT / COL',
              nameArabic: 'فيوز مقعد السائق الكهربائي وضبط عمود التوجيه',
              ratingAmps: 30,
              descriptionArabic: 'يغذي مواتير ضبط مقعد السائق مع الذاكرة وموتور تعديل الستيرنج.',
              symptoms: ['مقعد السائق وعمود التوجيه لا يستجيبان لأزرار الضبط والذاكرة'],
              gridRow: 0,
              gridCol: 12,
            ),
            FuseSlot(
              slotId: 'F14',
              label: 'DME / ENGINE',
              nameArabic: 'فيوز كمبيوتر إدارة المحرك (DME / DDE)',
              ratingAmps: 5,
              descriptionArabic: 'خط التغذية المنظم لكمبيوتر المحرك الرئيسي DME.',
              symptoms: ['المحرك يدور بالسلف ولكن قاطع بنزين ونار تماماً'],
              associatedDTCs: ['P0600', 'P0606'],
              gridRow: 0,
              gridCol: 13,
            ),
            FuseSlot(
              slotId: 'F15',
              label: 'OBD / DME',
              nameArabic: 'فيوز مدخل الفحص التشخيصي OBD-II ووصلة السكنر',
              ratingAmps: 7,
              descriptionArabic: 'تغذية الطرف رقم 16 في فيشة الفحص OBD بجهد 12V وخط إدارة المحرك.',
              symptoms: [
                'جهاز الفحص (Launch / Autel / INPA) لا يضيء نهائياً ولا يتصل',
                'رسالة No Communication With Vehicle',
              ],
              associatedDTCs: ['U0100'],
              testingTip: 'افحص النقطة 16 في فيشة الـ OBD، إذا كان الجهد صفراً فهذا الفيوز F15 مقطوع.',
              gridRow: 0,
              gridCol: 14,
            ),
            FuseSlot(
              slotId: 'F16',
              label: 'LCM LIGHT',
              nameArabic: 'فيوز وحدة التحكم المركزية بالإنارة (Light Module LCM)',
              ratingAmps: 5,
              descriptionArabic: 'تغذية كمبيوتر أضواء وفوانيس السيارة LCM.',
              symptoms: ['تعطل إشارات الانعطاف أو إضاءة المصابيح باستمرار بدون مفتاح'],
              gridRow: 0,
              gridCol: 15,
            ),
            FuseSlot(
              slotId: 'F17',
              label: 'ABS / PUMP',
              nameArabic: 'فيوز فرامل ABS (ديزل) ومضخة الوقود وتحكم الثبات',
              ratingAmps: 10,
              descriptionArabic: 'تغذية منظومة الفرامل ومضخة البنزين في طرازات محددة من E39.',
              symptoms: ['إضاءة لمبة ABS ومضخة الوقود لا تعمل'],
              gridRow: 0,
              gridCol: 16,
            ),
            FuseSlot(
              slotId: 'F18',
              label: 'IKE CLUSTER',
              nameArabic: 'فيوز عدادات الطبلون وشاشة المعلومات (IKE Cluster)',
              ratingAmps: 5,
              descriptionArabic: 'تغذية شاشات السرعة والـ RPM وشاشة البيانات الميكانيكية.',
              symptoms: ['انطفاء عدادات الطبلون وتعطل شاشة البكسلات في التابلوه'],
              gridRow: 0,
              gridCol: 17,
            ),
            FuseSlot(
              slotId: 'F19',
              label: 'SPARE',
              nameArabic: 'فيوز احتياطي لتجهيزات إضافية',
              ratingAmps: 5,
              descriptionArabic: 'موقع فيوز مخصص للتجهيزات الإضافية والاختيارية بالسيارة.',
              gridRow: 0,
              gridCol: 18,
            ),
            FuseSlot(
              slotId: 'F20',
              label: 'A/C / HEATER',
              nameArabic: 'فيوز مكيف الهواء ومروحة التبريد وسخان الزجاج والدفاية',
              ratingAmps: 7,
              descriptionArabic: 'يغذي دوائر التحكم بمكيف الهواء ودفاية المقصورة وسخان الزجاج الخلفي.',
              symptoms: ['تعطل تحكم سرعات المكيف وسخان الزجاج الخلفي'],
              gridRow: 0,
              gridCol: 19,
            ),
            FuseSlot(
              slotId: 'F75',
              label: 'AUX FAN MAXI',
              nameArabic: 'فيوز ماكسي مروحة التبريد الإضافية عالية القدرة (50A)',
              ratingAmps: 50,
              isSpecial: true,
              descriptionArabic: 'فيوز قدرة عالي لحماية دائرة محرك مروحة التبريد الكبرى أمام الردياتير.',
              symptoms: ['توقف المروحة الكهربائية واحتراق فيوز الـ 50A في الأجواء الحارة'],
              gridRow: 0,
              gridCol: 20,
            ),
            FuseSlot(
              slotId: 'F76',
              label: 'BLOWER MAXI',
              nameArabic: 'فيوز ماكسي منفاخ ومروحة دفع هواء الدفاية والمكيف (40A)',
              ratingAmps: 40,
              isSpecial: true,
              descriptionArabic: 'فيوز رئيسي لحماية موتور مروحة التكييف الداخلية ومقاومة السرعات الفاينل ستيج (القنفذ).',
              symptoms: ['مروحة المكيف متوقفة تماماً ولا يخرج أي هواء من الهوايات'],
              testingTip: 'في BMW E39، يترافق احتراق هذا الفيوز مع تلف مقاومة المكيف (Final Stage Unit).',
              gridRow: 0,
              gridCol: 21,
            ),

            // Row 2: F21 - F45
            FuseSlot(
              slotId: 'F21',
              label: 'MIRROR / PDC',
              nameArabic: 'فيوز مرايا التعتيم ومقعد السائق وحساسات الركن والحساس الحراري',
              ratingAmps: 5,
              descriptionArabic: 'تغذية وحدة حساسات الركن PDC والمرايا الإلكترونية وحساس الزيت والمقاعد.',
              symptoms: ['حساسات الاصطفاف تصدر صفيراً مستمراً أو لا تعمل'],
              gridRow: 1,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F22',
              label: 'AUX FAN HIGH',
              nameArabic: 'فيوز السرعة العالية لمروحة التبريد الإضافية',
              ratingAmps: 30,
              descriptionArabic: 'يغذي سرعة مروحة التبريد القصوى عند ارتفاع الحرارة أو تشغيل المكيف.',
              symptoms: ['ارتفاع حرارة المحرك في الصيف والوقوف التام'],
              gridRow: 1,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F23',
              label: 'HEATER / WEBASTO',
              nameArabic: 'فيوز دفاية المقصورة ومنظومة التدفئة المستقلة (Webasto)',
              ratingAmps: 10,
              descriptionArabic: 'تغذية صمامات المياه الساخنة ونظام التدفئة المستقلة.',
              symptoms: ['خروج هواء بارد فقط رغم تشغيل الدفاية'],
              gridRow: 1,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'F24',
              label: 'CLUSTER / RDC',
              nameArabic: 'فيوز العدادات وإنارة عصا القير ومراقبة ضغط الإطارات (RDC)',
              ratingAmps: 5,
              descriptionArabic: 'تغذية إنارة عصا الفتيس الأوتوماتيك وشاشة العدادات وحساسات الإطارات.',
              symptoms: ['انطفاء لمبات حارة القير (P R N D) في الكونسول'],
              gridRow: 1,
              gridCol: 3,
            ),
            FuseSlot(
              slotId: 'F25',
              label: 'MID / RADIO',
              nameArabic: 'فيوز شاشة عرض المعلومات (MID) وراديو السيارة',
              ratingAmps: 7,
              descriptionArabic: 'تغذية شاشة الراديو وأزرار الكونسول الأوسط وعرض بيانات الرحلة.',
              symptoms: ['انطفاء شاشة الراديو والساعة والكمبيوتر MID بالكونسول'],
              gridRow: 1,
              gridCol: 4,
            ),
            FuseSlot(
              slotId: 'F26',
              label: 'SPARE',
              nameArabic: 'موقع فيوز فارغ احتياطي',
              ratingAmps: 0,
              descriptionArabic: 'موقع غير مستخدم في هذا الطراز.',
              gridRow: 1,
              gridCol: 5,
            ),
            FuseSlot(
              slotId: 'F27',
              label: 'CENTRAL / WIN',
              nameArabic: 'فيوز السنترلوك وزجاج النوافذ الكهربائي',
              ratingAmps: 30,
              descriptionArabic: 'تغذية رفع وتنزيل زجاج الأبواب والقفل المركزي.',
              symptoms: ['النوافذ الكهربائية لا ترتفع ولا تنزل'],
              gridRow: 1,
              gridCol: 6,
            ),
            FuseSlot(
              slotId: 'F28',
              label: 'SPARE',
              nameArabic: 'موقع فيوز فارغ احتياطي',
              ratingAmps: 0,
              descriptionArabic: 'موقع غير مستخدم في هذا الطراز.',
              gridRow: 1,
              gridCol: 7,
            ),
            FuseSlot(
              slotId: 'F29',
              label: 'CENTRAL / MIR',
              nameArabic: 'فيوز القفل المركزي وضبط المرايا وزجاج الأبواب',
              ratingAmps: 30,
              descriptionArabic: 'تغذية مواتير السنتر لوك وزجاج الأبواب الخلفية وضبط المرايا.',
              symptoms: ['الأبواب الخلفية لا تفتح ولا تقفل كهربائياً'],
              gridRow: 1,
              gridCol: 8,
            ),
            FuseSlot(
              slotId: 'F30',
              label: 'ABS DIESEL/GAS',
              nameArabic: 'فيوز نظام فرامل ABS ومضخة الهيدروليك (ديزل وبنزين)',
              ratingAmps: 25,
              descriptionArabic: 'تغذية مضخة ABS الهيدروليكية ومنظومة التحكم بالفرامل.',
              symptoms: [
                'إضاءة لمبات ABS و Traction و Brake معاً في الطبلون (المثلث الأصفر)',
                'تعطل عداد السرعة ومؤشر استهلاك الوقود اللحظي',
              ],
              associatedDTCs: ['30', '31', '32'],
              gridRow: 1,
              gridCol: 9,
            ),
            FuseSlot(
              slotId: 'F31',
              label: 'FUEL PUMP / ASC',
              nameArabic: 'فيوز طلمبة (مضخة) البنزين ونظام منع الانزلاق (بنزين)',
              ratingAmps: 10,
              descriptionArabic: 'يغذي دائرة مضخة الوقود ومنظومة الثبات ASC في موديلات البنزين.',
              symptoms: [
                'المحرك يدور بالسلف ولكن قاطع بنزين ونار',
                'توقف مضخة البنزين عن العمل',
              ],
              associatedDTCs: ['P0087'],
              gridRow: 1,
              gridCol: 10,
            ),
            FuseSlot(
              slotId: 'F32',
              label: 'SEAT HEATER',
              nameArabic: 'فيوز تدفئة المقاعد الكهربائية',
              ratingAmps: 15,
              descriptionArabic: 'تغذية وسائد التدفئة الحرارية في المقاعد الأمامية.',
              symptoms: ['أزرار تدفئة الكراسي تومض وتنطفئ ولا تدفئ المقاعد'],
              gridRow: 1,
              gridCol: 11,
            ),
            FuseSlot(
              slotId: 'F33',
              label: 'SPARE',
              nameArabic: 'موقع فيوز فارغ احتياطي',
              ratingAmps: 0,
              descriptionArabic: 'موقع غير مستخدم.',
              gridRow: 1,
              gridCol: 12,
            ),
            FuseSlot(
              slotId: 'F34',
              label: 'HEATED STEER',
              nameArabic: 'فيوز تدفئة مقود السيارة (عجلة القيادة)',
              ratingAmps: 10,
              descriptionArabic: 'تغذية وشائع التسخين في طارة المقود.',
              symptoms: ['تدفئة طارة الدركسيون لا تعمل'],
              gridRow: 1,
              gridCol: 13,
            ),
            FuseSlot(
              slotId: 'F35',
              label: 'SPARE',
              nameArabic: 'موقع فيوز فارغ احتياطي',
              ratingAmps: 0,
              descriptionArabic: 'موقع غير مستخدم.',
              gridRow: 1,
              gridCol: 14,
            ),
            FuseSlot(
              slotId: 'F36',
              label: 'SPARE',
              nameArabic: 'موقع فيوز فارغ احتياطي',
              ratingAmps: 0,
              descriptionArabic: 'موقع غير مستخدم.',
              gridRow: 1,
              gridCol: 15,
            ),
            FuseSlot(
              slotId: 'F37',
              label: 'EWS IMMO 2',
              nameArabic: 'فيوز حماية نظام منع السرقة والمفتاح المشفر (EWS)',
              ratingAmps: 5,
              descriptionArabic: 'تغذية ثانوية لوحدة الإيموبلايزر EWS لمنع سرقة وتشغيل السيارة.',
              symptoms: ['المفتاح يدور لكن السلف لا يلف بتاتاً'],
              gridRow: 1,
              gridCol: 16,
            ),
            FuseSlot(
              slotId: 'F38',
              label: 'OBD / HORN / SHIFT',
              nameArabic: 'فيوز فيشة الفحص OBD والبوق وإنارة حارة القير',
              ratingAmps: 5,
              descriptionArabic: 'تغذية دائرة البوق وإنارة القير الأوتوماتيك وخط فحص الكومبيوتر.',
              symptoms: ['تعطل بوق السيارة أو انطفاء إضاءة عصا القير'],
              gridRow: 1,
              gridCol: 17,
            ),
            FuseSlot(
              slotId: 'F39',
              label: 'CIG / COURTESY',
              nameArabic: 'فيوز ولاعة السجائر والشحن وإضاءة مرايا الشماسات',
              ratingAmps: 7,
              descriptionArabic: 'تغذية مخرج الشحن 12V وولاعة السجائر ولمبات الشماسات التجميلية.',
              symptoms: ['شاحن الهاتف لا يعمل في ولاعة التابلوه وانطفاء لمبات الشماسات'],
              gridRow: 1,
              gridCol: 18,
            ),
            FuseSlot(
              slotId: 'F40',
              label: 'AIRBAG / CLUST',
              nameArabic: 'فيوز الوسائد الهوائية (الإيرباج SRS) وطبلون العدادات',
              ratingAmps: 5,
              descriptionArabic: 'تغذية وحدة تحكم الوسائد الهوائية وحساسات التصادم وعدادات الطبلون.',
              symptoms: ['إضاءة لمبة الإيرباج الحمراء SRS في الطبلون'],
              associatedDTCs: ['90', '91'],
              gridRow: 1,
              gridCol: 19,
            ),
            FuseSlot(
              slotId: 'F41',
              label: 'BRAKE LT / CRUISE',
              nameArabic: 'فيوز أضواء الفرامل الخلفية (الستوب) ومثبت السرعة ووحدة الإنارة',
              ratingAmps: 5,
              descriptionArabic: 'تغذية لمبات الفرامل الخلفية ومفتاح دواسة الفرامل ومثبت السرعة.',
              symptoms: ['لمبات الفرامل الخلفية لا تضيء عند الضغط على الدواسة وتعطل مثبت السرعة'],
              gridRow: 1,
              gridCol: 20,
            ),
            FuseSlot(
              slotId: 'F42',
              label: 'AIRBAG SRS',
              nameArabic: 'فيوز كمبيوتر الوسائد الهوائية (الإيرباج SRS)',
              ratingAmps: 5,
              descriptionArabic: 'تغذية كمبيوتر الإيرباج المركزي ووحدات استشعار المقاعد.',
              symptoms: ['إضاءة لمبة الإيرباج SRS الحمراء بشكل دائم'],
              associatedDTCs: ['90'],
              gridRow: 1,
              gridCol: 21,
            ),
            FuseSlot(
              slotId: 'F43',
              label: 'MONITOR / RADIO',
              nameArabic: 'فيوز شاشة العرض المركزية والراديو وهاتف السيارة',
              ratingAmps: 5,
              descriptionArabic: 'تغذية شاشة التابلوه ونظام الترفيه والراديو.',
              symptoms: ['شاشة الراديو والتلفزيون مطفأة بالكامل ولا تفتح'],
              gridRow: 1,
              gridCol: 22,
            ),
            FuseSlot(
              slotId: 'F44',
              label: 'MFL / MID / TEL',
              nameArabic: 'فيوز أزرار مقود السيارة المتعددة وشاشة MID والهاتف والراديو',
              ratingAmps: 5,
              descriptionArabic: 'تغذية أزرار المالتي في المقود وشاشة المعلومات المركزية.',
              symptoms: ['أزرار الصوت ومثبت السرعة على الطارة لا تستجيب'],
              gridRow: 1,
              gridCol: 23,
            ),
            FuseSlot(
              slotId: 'F45',
              label: 'SUN BLIND',
              nameArabic: 'فيوز ستارة الزجاج الخلفي الكهربائية',
              ratingAmps: 7,
              descriptionArabic: 'تغذية محرك رفع وخفض الستارة الشمسية الخلفية.',
              symptoms: ['الستارة الخلفية الكهربائية لا تصعد ولا تنزل'],
              gridRow: 1,
              gridCol: 24,
            ),
          ],
        ),

        // 2. Trunk Fuse Box (Above Battery)
        VehicleFuseBox(
          id: 'bmw_e39_trunk',
          nameArabic: 'علبة فيوزات الشنطة الخلفية فوق البطارية (Trunk Fuse Carrier)',
          locationType: FuseBoxLocationType.trunk,
          detailedLocationArabic:
              'في الشنطة الخلفية جهة اليمين، مباشرة فوق البطارية خلف غطاء الفرش المبطن.',
          accessInstructions:
              'أدر مقبض قفل بطانة الشنطة في الجانب الأيمن واسحب الغطاء، ستجد صينية الفيوزات البيضاء وصف الكتاوت فوق البطارية.',
          realisticCoverNote:
              'تحتوي هذه العلبة على فيوزات طرمبة الوقود وسخان الزجاج الخلفي والمقاعد والستارة الكهربائية (الفيوزات من F46 إلى F66).',
          cardPartNumber: 'Trunk Fuses F46-F66',
          equipmentMappings: [
            EquipmentFuseMapping(
              equipmentEnglish: 'Auxiliary heater',
              equipmentArabic: 'نظام التدفئة المستقل والإضافي (Webasto)',
              fuseNumbers: [46],
              category: 'comfort',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Cigarette lighter / Auxiliary socket (rear)',
              equipmentArabic: 'ولاعة السجائر ومقبس الطاقة الخلفي 12V',
              fuseNumbers: [47],
              category: 'electrical',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Heated rear window',
              equipmentArabic: 'سخان الزجاج الخلفي لإزالة الضباب',
              fuseNumbers: [48, 66],
              category: 'comfort',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Air suspension',
              equipmentArabic: 'نظام التعليق الهوائي والمساعدات (الهايدروليك)',
              fuseNumbers: [50],
              category: 'suspension',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Central locking (fuel filler flap)',
              equipmentArabic: 'قفل غطاء خزان الوقود والسنتر لوك الخلفي',
              fuseNumbers: [53],
              category: 'body',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Fuel pump',
              equipmentArabic: 'مضخة الوقود الكهربائية (طلمبة / بومبة البنزين)',
              fuseNumbers: [54],
              category: 'engine',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'CD changer / Navigation system',
              equipmentArabic: 'مشغل الأقراص المدمجة ونظام الملاحة GPS',
              fuseNumbers: [56],
              category: 'infotainment',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Telephone / TV',
              equipmentArabic: 'هاتف السيارة وتلفزيون الشاشة',
              fuseNumbers: [57],
              category: 'communication',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Radio / On-board monitor',
              equipmentArabic: 'راديو السيارة وشاشة المراقبة المركزية',
              fuseNumbers: [58],
              category: 'infotainment',
            ),
            EquipmentFuseMapping(
              equipmentEnglish: 'Rear seat adjustment / Trailer coupling',
              equipmentArabic: 'ضبط المقاعد الخلفية وتوصيلات المقطورة',
              fuseNumbers: [66],
              category: 'comfort',
            ),
          ],
          slots: [
            FuseSlot(
              slotId: 'F46',
              label: 'AUX HEATER',
              nameArabic: 'فيوز نظام التدفئة الإضافي والمستقل (Webasto)',
              ratingAmps: 30,
              descriptionArabic: 'يغذي وحدة التدفئة المستقلة في الشتاء.',
              symptoms: ['دفاية التدفئة المستقلة لا تعمل'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F47',
              label: 'REAR POWER',
              nameArabic: 'فيوز ولاعة السجائر الخلفية ومقبس الطاقة بالشنطة',
              ratingAmps: 20,
              descriptionArabic: 'يغذي مخرج الطاقة 12V الخلفي.',
              symptoms: ['مقبس الطاقة الخلفي لا يشحن'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F48',
              label: 'REAR DEF',
              nameArabic: 'فيوز مروحة وسخان الزجاج الخلفي',
              ratingAmps: 40,
              descriptionArabic: 'يغذي خط تدفئة الزجاج الخلفي.',
              symptoms: ['الزجاج الخلفي لا يزيل الضباب'],
              gridRow: 0,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'F50',
              label: 'AIR SUSP',
              nameArabic: 'فيوز نظام التعليق الهوائي والمساعدات (الهايدروليك)',
              ratingAmps: 5,
              descriptionArabic: 'يغذي كمبيوتر التحكم بالمساعدات الهيدروليكية الخلفية.',
              symptoms: ['هبوط مؤخرة السيارة وظهور خطأ Air Suspension'],
              gridRow: 0,
              gridCol: 3,
            ),
            FuseSlot(
              slotId: 'F53',
              label: 'CENTRAL LOCK',
              nameArabic: 'فيوز قفل الشنطة والسنتر لوك وغطاء البنزين',
              ratingAmps: 7,
              descriptionArabic: 'يغذي أقفال الأبواب وغطاء خزان الوقود وموتور قفل الشنطة.',
              symptoms: ['الشنطة لا تفتح بالريموت أو غطاء البنزين لا يقفل'],
              gridRow: 0,
              gridCol: 4,
            ),
            FuseSlot(
              slotId: 'F54',
              label: 'FUEL PUMP',
              nameArabic: 'فيوز طرمبة (بومبة) البنزين الرئيسية',
              ratingAmps: 15,
              descriptionArabic: 'التغذية الكهربائية المباشرة لمضخة الوقود الغاطسة داخل تانك البنزين.',
              symptoms: [
                'السيارة تدور بالسلف طويلاً دون تشغيل (قاطعة ضغط بنزين)',
                'انطفاء مفاجئ للمحرك أثناء السير دون تقطيع سابق',
                'عدم سماع صوت أزيز الطرمبة عند فتح السويتش',
              ],
              associatedDTCs: ['P0087', 'P0190'],
              testingTip: 'افحص هذا الفيوز فوراً مع ريلي طرمبة البنزين الأخضر المجاور له إذا كانت السيارة لا تعمل.',
              gridRow: 0,
              gridCol: 5,
            ),
            FuseSlot(
              slotId: 'F56',
              label: 'CD / NAVI',
              nameArabic: 'فيوز مشغل الأقراص المدمجة وجهاز الملاحة GPS',
              ratingAmps: 30,
              descriptionArabic: 'تغذية قارئ خرائط الملاحة ومشغل أسطوانات CD في الشنطة.',
              symptoms: ['شاشة الملاحة تطلب إدخال أسطوانة الـ GPS أو قارئ السيديهات لا يفتح'],
              gridRow: 1,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F57',
              label: 'PHONE / TV',
              nameArabic: 'فيوز وحدة الهاتف وتلفزيون الشاشة',
              ratingAmps: 10,
              descriptionArabic: 'يغذي موديول التلفزيون وهاتف السيارة بالشنطة.',
              symptoms: ['تعطل استقبال إشارة التلفزيون أو هاتف السيارة'],
              gridRow: 1,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F58',
              label: 'AUDIO / AMP',
              nameArabic: 'فيوز مضخم الصوت والراديو وشاشة الملاحة (DSP Amplifier)',
              ratingAmps: 10,
              descriptionArabic: 'يغذي أمبليفاير الصوت ونظام الراديو والتلفاز في الشنطة.',
              symptoms: ['انقطاع كامل لصوت السماعات والراديو بالرغم من تشغيل الشاشة'],
              gridRow: 1,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'F66',
              label: 'DEFROSTER',
              nameArabic: 'فيوز سخان الزجاج الخلفي وتعديل المقاعد الخلفية (ماكسي)',
              ratingAmps: 40,
              isSpecial: true,
              descriptionArabic: 'يغذي شبكة التسخين الحرارية لإزالة الضباب والجليد عن الزجاج الخلفي.',
              symptoms: ['عدم تدفئة الزجاج الخلفي وتراكم الضباب'],
              gridRow: 1,
              gridCol: 3,
            ),
            FuseSlot(
              slotId: 'R_FP',
              label: 'PUMP RLY',
              nameArabic: 'ريلي طرمبة البنزين الأخضر (Fuel Pump Relay)',
              ratingAmps: 30,
              isRelay: true,
              relayType: 'Light Green 4-Pin Relay',
              descriptionArabic: 'يقوم بتوصيل جهد البطارية إلى مضخة البنزين بأمر من كمبيوتر DME.',
              symptoms: [
                'عدم اشتغال المحرك بالرغم من سلامة الفيوز F54',
                'توقف مضخة الوقود عن ضخ البنزين للمسطرة',
              ],
              associatedDTCs: ['P0230'],
              gridRow: 2,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'R_DEF',
              label: 'DEF RLY',
              nameArabic: 'ريلي سخان الزجاج الخلفي الأسود',
              ratingAmps: 40,
              isRelay: true,
              relayType: 'Standard 4-Pin Relay',
              descriptionArabic: 'ريلي تشغيل خط تسخين زجاج الشنطة الخلفي.',
              symptoms: ['تعطل سخان الزجاج'],
              gridRow: 2,
              gridCol: 1,
            ),
          ],
        ),

        // 3. Engine Bay E-Box (Under Passenger Cabin Air Filter) - Special / Unique
        VehicleFuseBox(
          id: 'bmw_e39_ebox',
          nameArabic: 'صندوق إلكترونيات المحرك وحزمة فيوزات DME (Underhood E-Box)',
          locationType: FuseBoxLocationType.special,
          isSpecialLocation: true,
          specialBadgeText:
              'صندوق كمبيوتر المحرك DME أسفل فلتر مكيف الراكب: يحتوي على حزمة فيوزات المحرك الحساسة (Fuse Pack).',
          detailedLocationArabic:
              'تحت الكبوت من جهة اليمين (الراكب الأمامي)، أسفل قربة وفلتر تكييف الصالون البلاستيكي مباشرة.',
          accessInstructions:
              'انزع كلبس قربة فلتر هواء المكيف اليمين وافتح الغطاء، ثم فك مسامير ألين (Allen 5mm) الأربعة لغطاء الصندوق الأبيض المحكم ضد الماء.',
          realisticCoverNote:
              'تحتوي على حزمة الفيوزات الخماسية المدمجة (Fuse Pack) المغذية لبخاخات المحرك والكويلات وحساسات الأكسجين، إضافة لكتاوت المحرك الأزرق/السماوي وكتاوت الفانوس.',
          slots: [
            FuseSlot(
              slotId: 'EF1',
              label: 'DME PACK 1',
              nameArabic: 'فيوز كويلات الإشعال وبخاخات الوقود (حزمة E-Box)',
              ratingAmps: 30,
              isSpecial: true,
              descriptionArabic:
                  'يغذي جميع كويلات شمعات الإشعال ومساطر بخاخات البنزين للمحرك 6 أو 8 سلندر.',
              symptoms: [
                'المحرك يلف بالسلف طويلاً ولا يدور إطلاقاً (قاطع إشعال وحقن)',
                'انعدام الشرارة على جميع الكويلات',
              ],
              associatedDTCs: ['P0300', 'P0351', 'P0201'],
              testingTip:
                  'إذا تعطلت جميع الكويلات معاً ولم تعمل بوبينات السيارة، فهذا الفيوز EF1 محترق داخل صندوق الـ E-Box.',
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'EF2',
              label: 'DME PACK 2',
              nameArabic: 'فيوز حساسات الشكمان وحساس الكرنك والحرارة',
              ratingAmps: 30,
              isSpecial: true,
              descriptionArabic:
                  'تغذية حساسات الأكسجين الأربعة (سخانات اللامبدا) وحساسات حرارة الماء وهواء المحرك.',
              symptoms: [
                'إضاءة لمبة المحرك Check Engine وتسجيل أعطال سخانات حساسات العادم الأربعة معاً',
                'استهلاك بنزين مفرط ودخان أسود',
              ],
              associatedDTCs: ['P0135', 'P0141', 'P0155', 'P0161'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'EF3',
              label: 'DME PACK 3',
              nameArabic: 'فيوز صمامات الفانوس وصمام الهواء الإضافي (VANOS & ICV)',
              ratingAmps: 20,
              isSpecial: true,
              descriptionArabic:
                  'يغذي سولينويدات نظام توقيت الصمامات المتغير VANOS وصمام الـ Idle Control Valve.',
              symptoms: [
                'تذبذب واهتزاز شديد في سرعة السلانسيه (Idle RPM)',
                'ضعف عزم وتسارع السيارة وتكتيم في الدعسة',
              ],
              associatedDTCs: ['P0011', 'P0012', 'P0505'],
              gridRow: 0,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'EF4',
              label: 'DME PACK 4',
              nameArabic: 'فيوز كمبيوتر ناقل الحركة الأوتوماتيكي (AGS / EGS Transmission)',
              ratingAmps: 30,
              isSpecial: true,
              descriptionArabic:
                  'خط التغذية الرئيسي لكمبيوتر القير الأوتوماتيك وسولينويدات نقل الغيارات (Valves).',
              symptoms: [
                'دخول القير في وضع الطوارئ والتعليق على الغيار الثالث (Limp Home Mode)',
                'ظهور رسالة Trans. Failsafe Prog في شاشة الطبلون',
              ],
              associatedDTCs: ['P0700', 'P0705'],
              gridRow: 0,
              gridCol: 3,
            ),
            FuseSlot(
              slotId: 'EF5',
              label: 'DME PACK 5',
              nameArabic: 'فيوز ثرموستات الحرارة الكهربائي وحساس الماف (MAF Sensor)',
              ratingAmps: 30,
              isSpecial: true,
              descriptionArabic:
                  'تغذية سخان ثرموستات الكوع وحساس تدفق الهواء الشامل MAF وصمامات الشفط.',
              symptoms: [
                'سجل عطل Thermostat Characteristic Heating',
                'خروج قراءة غير طبيعية لحساس الماف وتقطيع بالمحرك',
              ],
              associatedDTCs: ['P0100', 'P0128'],
              gridRow: 0,
              gridCol: 4,
            ),
            FuseSlot(
              slotId: 'R_DME',
              label: 'DME MAIN RLY',
              nameArabic: 'ريلي كمبيوتر المحرك الرئيسي الأزرق السماوي (DME Main Relay)',
              ratingAmps: 40,
              isRelay: true,
              relayType: 'Light Blue 5-Pin Bosch Relay',
              descriptionArabic:
                  'الكتاوت الأساسي الذي يصحو عند فتح السويتش لتغذية كمبيوتر DME وكافة حساسات المحرك.',
              symptoms: [
                'المحرك يدور بالسلف ولا يشتغل نهائياً',
                'فقدان تام للاتصال بالكمبيوتر DME بجهاز الفحص (No Communication)',
                'عدم إضاءة لمبة EML في الطبلون',
              ],
              associatedDTCs: ['P0685', 'U0100'],
              gridRow: 1,
              gridCol: 0,
            ),
          ],
        ),

        // 4. Passenger Footwell Heavy-Duty Mega Fuses (Under Carpet) - Special
        VehicleFuseBox(
          id: 'bmw_e39_footwell_mega',
          nameArabic: 'صندوق فيوزات الطبلون الكبرى تحت أرضية الموكيت (Footwell Fuse Carrier)',
          locationType: FuseBoxLocationType.special,
          isSpecialLocation: true,
          specialBadgeText:
              'مصهرات أمبير فائقة (Mega Fuses 80A-100A) مخفية تحت موكيت كرسي الراكب لحماية خطوط التغذية الرئيسية.',
          detailedLocationArabic:
              'أسفل أرضية الراكب الأمامي، تحت موكيت السيارة مباشرة بجانب عتبة الباب.',
          accessInstructions:
              'فك مسامير عتبة الباب البلاستيكية وارفع طبقة الموكيت والإسفنج السميك، ستجد علبة سوداء معدنية مثبتة بمسامير كابلات 13mm.',
          realisticCoverNote:
              'مصهرات براغي نحاسية ضخمة تغذي لوحة التابلوه وصندوق التكييف ومروحة التبريد وموديول الإنارة LCM.',
          slots: [
            FuseSlot(
              slotId: 'F100',
              label: 'CABIN MAIN',
              nameArabic: 'فيوز التغذية الرئيسي لكابينة القيادة والتابلوه (200A)',
              ratingAmps: 200,
              isSpecial: true,
              descriptionArabic: 'يغذي لوحة فيوزات درج التابلوه العلوية بالكامل.',
              symptoms: ['انطفاء كامل لجميع أجهزة التابلوه والكونتاكت داخل المقصورة'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F101',
              label: 'IGN SWITCH',
              nameArabic: 'فيوز سويتش الكونتاكت ومفتاح التشغيل (80A)',
              ratingAmps: 80,
              isSpecial: true,
              descriptionArabic: 'تغذية قلب مفتاح التشغيل الكهربائي (Ignition Switch).',
              symptoms: ['فتح السويتش لا يشغل أي لمبة أو أنظمة في الطبلون'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F102',
              label: 'HEATER / A/C',
              nameArabic: 'فيوز مروحة ودفاية المقصورة والمكيف الرئيسي (80A)',
              ratingAmps: 80,
              isSpecial: true,
              descriptionArabic: 'يغذي خط الطاقة العالي لموتور مروحة التكييف والتدفئة.',
              symptoms: ['توقف كلي وتام لجميع أنظمة التكييف والمروحة الداخلية'],
              gridRow: 0,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'F104',
              label: 'AUX FAN FEED',
              nameArabic: 'فيوز خط تغذية مروحة التبريد الإضافية (100A)',
              ratingAmps: 100,
              isSpecial: true,
              descriptionArabic: 'التغذية المباشرة لكتاوت وسرعات مروحة الرديتر الكهربائية.',
              symptoms: ['انقطاع التيار التام عن مروحة المكيف الإضافية'],
              gridRow: 1,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F106',
              label: 'LCM FEED',
              nameArabic: 'فيوز تغذية وحدة التحكم المركزية بالأنوار والإنارة (80A)',
              ratingAmps: 80,
              isSpecial: true,
              descriptionArabic: 'التغذية المباشرة لموديول إنارة فوانيس السيارة LCM.',
              symptoms: ['انطفاء كافة المصابيح الخارجية والداخلية دفعة واحدة'],
              associatedDTCs: ['LCM 40'],
              gridRow: 1,
              gridCol: 1,
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    CarVehicleModel(
      id: 'toyota_corolla_2008_2013',
      make: 'Toyota',
      makeArabic: 'تويوتا',
      model: 'Corolla',
      modelArabic: 'كورولا (Corolla E140/E150)',
      yearRange: '2008 - 2013 (الجيل العاشر E140/E150)',
      bodyType: 'سيدان',
      obdLocation: 'تحت المقود مباشرة من جهة اليسار بجانب ذراع فتح الكبوت',
      fuseBoxes: [
        VehicleFuseBox(
          id: 'corolla_engine_bay',
          nameArabic: 'علبة فيوزات حوض المحرك الرئيسية (Engine Fuse Box)',
          locationType: FuseBoxLocationType.engineBay,
          detailedLocationArabic:
              'في الكبوت من جهة السائق (اليسار)، خلف المصباح الأمامي وبجانب البطارية وقربة ماء المساحات.',
          accessInstructions:
              'اضغط على ألسنة القفل الجانبية الثلاثة للغطاء البلاستيكي الأسود ثم ارفعه للأعلى برفق.',
          slots: [
            FuseSlot(
              slotId: 'F1',
              label: 'EFI MAIN',
              nameArabic: 'فيوز كمبيوتر المحرك الرئيسي ومنظومة الحقن',
              ratingAmps: 20,
              descriptionArabic: 'يغذي كمبيوتر إدارة المحرك (ECM) ورشاشات الوقود وحساسات العادم.',
              symptoms: [
                'المحرك يدور بالسلف (الموتورينو) لكن لا يعمل نهائياً',
                'عدم إضاءة لمبة فحص المحرك (Check Engine) في الطبلون عند فتح السويتش',
                'فقدان الاتصال بجهاز الفحص OBD-II',
              ],
              associatedDTCs: ['P0606', 'P0685', 'U0100'],
              testingTip: 'افحص النقطتين المعدنيتين للفيوز بلمبة الفحص مع فتح السويتش.',
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F2',
              label: 'H-LP CLR',
              nameArabic: 'فيوز غسيل ومساحات الكشافات الأمامية',
              ratingAmps: 30,
              descriptionArabic: 'دائرة مضخة رشاشات تنظيف المصابيح الأمامية.',
              symptoms: ['عدم خروج الماء لكشافات الضباب الأمامية'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F3',
              label: 'FAN MAIN',
              nameArabic: 'فيوز مروحة تبريد الرداتوري والمكيف',
              ratingAmps: 30,
              descriptionArabic: 'يغذي موتور مروحة التبريد الرئيسية خلف رديتر التبريد.',
              symptoms: [
                'ارتفاع سريع في حرارة المحرك في الزحام وعند الوقوف',
                'فصل كمبروسر المكيف بسبب ارتفاع حرارة غاز التبريد',
                'غليان الماء في القربة الاحتياطية',
              ],
              associatedDTCs: ['P0480', 'P0481', 'P0217'],
              testingTip: 'إذا احترق هذا الفيوز بشكل متكرر، تأكد من عدم ثقل أو حشر مروحة التبريد.',
              gridRow: 0,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'F4',
              label: 'H-LP MAIN',
              nameArabic: 'فيوز المصابيح الأمامية الرئيسية (كشافات الإضاءة)',
              ratingAmps: 20,
              descriptionArabic: 'يغذي دوائر الإنارة العالية والواطية للمصابيح الأمامية.',
              symptoms: [
                'انطفاء كامل للمصابيح الأمامية ليلاً مع عمل أنوار السكن الصغيرة',
                'تعطل الإضاءة العالية والواطية',
              ],
              gridRow: 1,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F5',
              label: 'HORN',
              nameArabic: 'فيوز منبه وبوق السيارة (الكلاكس / الهرن)',
              ratingAmps: 10,
              descriptionArabic: 'يغذي بوق التنبيه الصوتي في واجهة السيارة.',
              symptoms: ['المنبه لا يصدر صوتاً نهائياً عند الضغط على وسط المقود'],
              gridRow: 1,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F6',
              label: 'IGN',
              nameArabic: 'فيوز منظومة إشعال المحرك وحقن الوقود',
              ratingAmps: 10,
              descriptionArabic: 'يغذي كويلات الإشعال وبخاخات البنزين وحساس الكرنك.',
              symptoms: [
                'المحرك يدور بالسلف ولكن لا توجد شعلة إشعال (قاطع نار)',
                'تقطيع واهتزاز شديد ثم انطفاء المحرك فجأة',
              ],
              associatedDTCs: ['P0300', 'P0351', 'P0335'],
              gridRow: 1,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'R1',
              label: 'MAIN RLY',
              nameArabic: 'ريلي المحرك الرئيسي (EFI Main Relay)',
              ratingAmps: 40,
              isRelay: true,
              relayType: '4-Pin Micro Relay',
              descriptionArabic: 'يقوم بتوصيل التيار الرئيسي من البطارية إلى كمبيوتر المحرك.',
              symptoms: ['انقطاع كامل عن كمبيوتر المحرك وعدم دوران السيارة نهائياً'],
              associatedDTCs: ['P0685'],
              testingTip: 'تأكد من سماع صوت طقة الريلي عند فتح السويتش.',
              gridRow: 2,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'R2',
              label: 'FAN RLY',
              nameArabic: 'ريلي تشغيل سرعات مروحة الرداتوري',
              ratingAmps: 40,
              isRelay: true,
              relayType: '4-Pin Standard Relay',
              descriptionArabic: 'المرحل الكهربائي لتشغيل مروحة تبريد الرداتوري والمكيف.',
              symptoms: ['المروحة لا تعمل نهائياً أو تعمل بشكل مستمر ومباشر دون توقف'],
              associatedDTCs: ['P0480'],
              gridRow: 2,
              gridCol: 1,
            ),
          ],
        ),
        VehicleFuseBox(
          id: 'corolla_cabin',
          nameArabic: 'علبة فيوزات كابينة الركاب والمقصورة (تحت التابلوه)',
          locationType: FuseBoxLocationType.cabin,
          detailedLocationArabic:
              'تحت طبلون القيادة مباشرة من جهة السائق يساراً، بجانب دواسة القدم وذراع فتح غطاء المحرك.',
          accessInstructions:
              'انظر أسفل الطبلون جهة اليسار، ستجد غطاءً بلاستيكياً صغيراً؛ اسحبه بيدك للأسفل برفق.',
          slots: [
            FuseSlot(
              slotId: 'F15',
              label: 'OBD / DLC',
              nameArabic: 'فيوز مدخل الفحص التشخيصي OBD-II وذاكرة الطبلون',
              ratingAmps: 7,
              descriptionArabic: 'تغذية الطرف 16 في فيشة الفحص OBD-II بجهد 12 فولت الدائم.',
              symptoms: [
                'جهاز الفحص لا يصله كهرباء وشاشته لا تضيء عند ربطه بفيشة السيارة',
                'إعادة تصفير ساعة الطبلون والعداد الجزئي TRIP عند كل إطفاء للسيارة',
              ],
              associatedDTCs: ['U0100', 'U0155'],
              testingTip: 'افحص النقطة 16 في فيشة الفحص؛ إذا لم تجد 12 فولت فالفيوز F15 محترق.',
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F16',
              label: 'CIG',
              nameArabic: 'فيوز ولاعة السجائر ومخرج الشحن 12V',
              ratingAmps: 15,
              descriptionArabic: 'يغذي مقبس ولاعة السجائر وشواحن الهواتف في الكونسول.',
              symptoms: ['شاحن الهاتف لا يعمل ولا تخرج كهرباء من مخرج 12V'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F17',
              label: 'STOP',
              nameArabic: 'فيوز لمبات الفرامل الخلفية ومفتاح دعسة الفرامل',
              ratingAmps: 10,
              descriptionArabic: 'تغذية أنوار التوقف الخلفية وحساس دواسة الفرامل.',
              symptoms: [
                'عصا ناقل الحركة الأوتوماتيك (الكمبيو) معلقة ولا تتحرك من وضع الـ P',
                'عدم إضاءة أنوار الفرامل الخلفية عند الضغط على الدواسة',
              ],
              associatedDTCs: ['P0504', 'C1503'],
              testingTip: 'إذا علق القير في الـ P ولم تضئ لمبات الفرامل، افحص هذا الفيوز فوراً.',
              gridRow: 0,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'F18',
              label: 'WIPER',
              nameArabic: 'فيوز مساحات الزجاج الأمامي ومضخة غسيل الزجاج',
              ratingAmps: 25,
              descriptionArabic: 'يغذي موتور مساحات الزجاج الأمامي ومضخة رش الماء.',
              symptoms: ['توقف مساحات الزجاج الأمامي تماماً عن الحركة أو توقف رشاشات الماء'],
              gridRow: 1,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F19',
              label: 'PANEL',
              nameArabic: 'فيوز إضاءة لوحة العدادات وأزرار الكونسول الداخلي',
              ratingAmps: 10,
              descriptionArabic: 'يغذي لمبات إضاءة أزرار المكيف والراديو والطبلون ليلاً.',
              symptoms: ['ظلام في أزرار لوحة القيادة ليلاً رغم عمل المصابيح الخارجية'],
              gridRow: 1,
              gridCol: 1,
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    // 7. Toyota Camry (2007 - 2017) - XV40 / XV50,


    // =========================================================================
    // 1. Mercedes-Benz C-Class (W204 / W205) - C180, C200, C250, C300
    // =========================================================================
    CarVehicleModel(
      id: 'mercedes_c_class_w204',
      make: 'Mercedes-Benz',
      makeArabic: 'مرسيدس-بنز',
      model: 'C-Class (W204 / W205)',
      modelArabic: 'سي كلاس (C-Class W204/W205)',
      yearRange: '2007 - 2015 (C180 / C200 / C250 / C300)',
      bodyType: 'سيدان فاخرة',
      obdLocation: 'أسفل لوحة القيادة جهة السائق يساراً خلف غطاء بلاستيكي صغير بجانب مقبض فتح الكبوت.',
      fuseBoxes: [
        // 1.1 Front SAM (Engine Bay)
        VehicleFuseBox(
          id: 'w204_front_sam',
          nameArabic: 'علبة فيوزات وحدة سام الأمامية (Front SAM K40/2)',
          locationType: FuseBoxLocationType.engineBay,
          detailedLocationArabic:
              'في حوض المحرك جهة السائق (اليسار)، بجانب قاعدة مساحات الزجاج وتحت غطاء العزل البلاستيكي.',
          accessInstructions:
              'فك المشبكين المعدنيين على جانبي الصندوق الأسود المحكم وارفع الغطاء بحذر لحماية وحدة SAM من الرطوبة.',
          realisticCoverNote: 'وحدة SAM الأمامية تتحكم في دوائر المحرك والإنارة والإشعال ومساحات الزجاج.',
          slots: [
            FuseSlot(
              slotId: 'F3',
              label: 'EIS / EZS',
              nameArabic: 'فيوز سويتش ومفتاح التشغيل الإلكتروني (EZS/EIS)',
              ratingAmps: 7,
              descriptionArabic: 'يغذي مفتاح التشغيل الإلكتروني وقفل المقود الكهربائي (ESL).',
              symptoms: [
                'المفتاح لا يلف في السويتش نهائياً ولا يفتح كونتاكت',
                'المقود يظل مقفولاً ولا يستجيب لصوت فتح القفل (ESL Lock)',
                'انطفاء كامل لشاشة الطبلون',
              ],
              associatedDTCs: ['A25464', 'A25407', 'U0140'],
              testingTip: 'تأكد من سلامة هذا الفيوز أولاً قبل استبدال قفل الدركسيون ESL الشهير بالأعطال.',
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F4',
              label: 'SRS / AIRBAG',
              nameArabic: 'فيوز كمبيوتر الوسائد الهوائية (SRS / Airbag)',
              ratingAmps: 5,
              descriptionArabic: 'التغذية الكهربائية لوحدة التحكم في الوسائد الهوائية وحزام الأمان.',
              symptoms: [
                'إضاءة لمبة SRS / الإيرباق الحمراء في الطبلون باستمرار',
                'رسالة Restraint System Malfunction في شاشة العدادات',
              ],
              associatedDTCs: ['B1000', 'B1001'],
              testingTip: 'افصل البطارية وانتظر 10 دقائق قبل فك أو تبديل أي فيوز متعلق بالإيرباق.',
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F7',
              label: 'IGN / COILS',
              nameArabic: 'فيوز شمعات وبوبينات الإشعال ومسخنات الأكسجين',
              ratingAmps: 20,
              descriptionArabic: 'يغذي كويلات الإشعال ومسخنات حساسات الأكسجين O2 ومضخة الهواء الثانوية.',
              symptoms: [
                'تقطيع وفطفطة حادة في المحرك مع إضاءة لمبة Check Engine',
                'المحرك يرجف بشدة ويفقد العزم',
              ],
              associatedDTCs: ['P0300', 'P0351', 'P0135'],
              testingTip: 'افحص النقطتين بالمجس للتأكد من وصول 12V مع فتح السويتش.',
              gridRow: 0,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'F8',
              label: 'WIPER',
              nameArabic: 'فيوز محرك مساحات الزجاج الأمامي',
              ratingAmps: 30,
              descriptionArabic: 'موتور مساحات الزجاج الأمامي وحساس المطر.',
              symptoms: ['توقف مساحات الزجاج تماماً عن الحركة أثناء المطر'],
              gridRow: 0,
              gridCol: 3,
            ),
            FuseSlot(
              slotId: 'F9',
              label: 'STARTER',
              nameArabic: 'فيوز محرك بادئ الحركة (السلف / الموتورينو)',
              ratingAmps: 25,
              descriptionArabic: 'يغذي سيلينويد محرك السلف لبدء دوران المحرك.',
              symptoms: [
                'السيارة لا تدور نهائياً بالسلف (لا يوجد صوت دوران الموتورينو)',
                'سماع تكة خفيفة في الكبوت دون حركة المحرك',
              ],
              associatedDTCs: ['P0615', 'P0617'],
              testingTip: 'افحص الفيوز F9 وريلي السلف R_START المجاور له في وحدة SAM.',
              gridRow: 1,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F10',
              label: 'HORN',
              nameArabic: 'فيوز بوق ومنبه السيارة (الكلاكس / الهرن)',
              ratingAmps: 15,
              descriptionArabic: 'يغذي أبواق التنبيه الثنائية في الواجهة الأمامية.',
              symptoms: ['البوق والهرن لا يصدر أي صوت عند الضغط على المقود'],
              gridRow: 1,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F21',
              label: 'ME-SFI / ECU',
              nameArabic: 'فيوز كمبيوتر المحرك الرئيسي (Engine ECU)',
              ratingAmps: 20,
              descriptionArabic: 'تغذية وحدة التحكم الرئيسية في المحرك (ECM / ME).',
              symptoms: [
                'المحرك يدور بالسلف لكن قاطع ولا يشتغل إطلاقاً',
                'فقدان الاتصال بجهاز الفحص OBD-II مع كمبيوتر المحرك',
                'عدم إضاءة لمبة فحص المحرك عند فتح السويتش',
              ],
              associatedDTCs: ['P0606', 'P0685', 'U0100'],
              testingTip: 'تأكد من وجود جهد البطارية على طرفي الفيوز مع تشغيل الكونتاكت.',
              gridRow: 1,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'F22',
              label: 'MAF / O2',
              nameArabic: 'فيوز حساس تدفق الهواء (MAF) وحساسات العادم',
              ratingAmps: 15,
              descriptionArabic: 'يغذي حساس ساعة الهواء وحساسات الشكمان وصمامات الكامات.',
              symptoms: [
                'خروج دخان أسود واستهلاك مفرط للبنزين',
                'ضعف عزم السيارة ودخولها في طور الطوارئ (Limp Mode)',
              ],
              associatedDTCs: ['P0100', 'P0102', 'P0010'],
              gridRow: 1,
              gridCol: 3,
            ),
            FuseSlot(
              slotId: 'F24',
              label: 'FAN MAIN',
              nameArabic: 'فيوز مروحة تبريد الرداتوري الرئيسية (Electric Fan)',
              ratingAmps: 40,
              descriptionArabic: 'يغذي مروحة التبريد الكهربائية خلف رديتر المحرك.',
              symptoms: [
                'ارتفاع سريع وحرج في حرارة محرك المرسيدس وتنبيه أحمر في الطبلون',
                'توقف كمبروسر المكيف عن ضخ الهواء البارد',
              ],
              associatedDTCs: ['P0480', 'P0485'],
              testingTip: 'فيوز ماكسي كبير 40 أمبير برتقالي اللون، افحص مقبضه بإحكام.',
              gridRow: 2,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'R_START',
              label: 'STARTER RLY',
              nameArabic: 'ريلي بادئ الحركة وسلف التشغيل (Starter Relay)',
              ratingAmps: 40,
              isRelay: true,
              relayType: 'Mercedes 5-Pin Black Relay',
              descriptionArabic: 'المرحل الرئيسي لتوصيل تيار السلف من وحدة السام للموتورينو.',
              symptoms: ['المحرك قاطع سلف بالكامل بالرغم من سلامة البطارية'],
              gridRow: 2,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'R_WIPER',
              label: 'WIPER RLY',
              nameArabic: 'ريلي مساحات الزجاج الأمامي',
              ratingAmps: 30,
              isRelay: true,
              relayType: 'Standard Automotive Relay',
              descriptionArabic: 'التحكم بسرعات مساحات الزجاج.',
              symptoms: ['المساحات تعمل بسرعة واحدة أو تتوقف'],
              gridRow: 2,
              gridCol: 2,
            ),
          ],
        ),

        // 1.2 Rear SAM (Trunk)
        VehicleFuseBox(
          id: 'w204_rear_sam',
          nameArabic: 'علبة فيوزات وحدة سام الخلفية (Rear SAM Fuse Box)',
          locationType: FuseBoxLocationType.trunk,
          detailedLocationArabic:
              'في الشنطة الخلفية جهة اليمين، خلف البطانة القماشية للرفرف الأيمن بجانب مصباح الإيقاف.',
          accessInstructions:
              'اسحب المقبض البلاستيكي الدوار في بطانة الشنطة جهة اليمين نحو اليسار لكشف لوحة الفيوزات.',
          slots: [
            FuseSlot(
              slotId: 'F4',
              label: 'FUEL PUMP',
              nameArabic: 'فيوز طرمبة (بومبة) البنزين الغاطسة في الخزان',
              ratingAmps: 20,
              descriptionArabic: 'التغذية الكهربائية لمضخة الوقود الرئيسية في تانكي السيارة.',
              symptoms: [
                'السيارة تدور بالسلف دون تشغيل نهائياً',
                'انعدام صوت زنة مضخة البنزين عند فتح السويتش',
                'انعدام ضغط الوقود في مسطرة البخاخات',
              ],
              associatedDTCs: ['P0087', 'P0627', 'P2540'],
              testingTip: 'من أكثر الفيوزات شيوعاً في حالات تعطل مرسيدس C-Class المفاجئ.',
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F5',
              label: 'SUNROOF',
              nameArabic: 'فيوز فتحة السقف والبانوراما ومحرك الستارة',
              ratingAmps: 30,
              descriptionArabic: 'يغذي محرك فتحة السقف البانورامية والستارة الداخلية.',
              symptoms: ['فتحة السقف لا تفتح أو معلقة في وضع الفتح ولا تغلق'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F7',
              label: '12V OUTLET',
              nameArabic: 'فيوز ولاعة السجائر ومقابس الطاقة الخلفية 12V',
              ratingAmps: 15,
              descriptionArabic: 'تغذية شواحن الركاب ومقبس الطاقة في الكونسول الخلفي.',
              symptoms: ['مخرج الشاحن في الخلف لا يخرج كهرباء'],
              gridRow: 0,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'F8',
              label: 'AUDIO AMP',
              nameArabic: 'فيوز مضخم الصوت والنظام الصوتي (Harman Kardon)',
              ratingAmps: 30,
              descriptionArabic: 'يغذي أمبليفاير الصوت في الشنطة.',
              symptoms: ['اختفاء الصوت تماماً من سماعات السيارة رغم عمل الشاشة'],
              gridRow: 0,
              gridCol: 3,
            ),
            FuseSlot(
              slotId: 'F11',
              label: 'DEFROSTER',
              nameArabic: 'فيوز سخان الزجاج الخلفي لإزالة الضباب',
              ratingAmps: 40,
              descriptionArabic: 'خطوط التسخين الحرارية في الزجاج الخلفي.',
              symptoms: ['عدم تدفئة الزجاج الخلفي وبقاء الضباب متراكماً'],
              gridRow: 1,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'R_FP',
              label: 'PUMP RLY',
              nameArabic: 'ريلي طرمبة البنزين الخلفية',
              ratingAmps: 30,
              isRelay: true,
              relayType: 'Micro Relay',
              descriptionArabic: 'يقوم بتوصيل الكهرباء لطرمبة البنزين.',
              symptoms: ['المحرك قاطع بنزين بالرغم من سلامة الفيوز F4'],
              gridRow: 1,
              gridCol: 1,
            ),
          ],
        ),

        // 1.3 Dashboard Cockpit
        VehicleFuseBox(
          id: 'w204_cockpit',
          nameArabic: 'علبة فيوزات جانب الطبلون (Dashboard Side Fuse Box)',
          locationType: FuseBoxLocationType.cabin,
          detailedLocationArabic:
              'على الحافة الجانبية اليسرى للطبلون، تظهر فقط عند فتح باب السائق بالكامل.',
          accessInstructions:
              'استخدم أداة فك بلاستيكية عريضة لنزع الغطاء الجانبي للطبلون برفق دون تجريح الديكور.',
          slots: [
            FuseSlot(
              slotId: 'F21',
              label: 'LIGHT SW',
              nameArabic: 'فيوز مفتاح ومقبض الإنارة الرئيسي (Rotary Light Switch)',
              ratingAmps: 5,
              descriptionArabic: 'يغذي مفتاح الإضاءة والأنوار الدائري يسار المقود.',
              symptoms: ['الأنوار الأمامية تعمل دائماً بشكل إجباري ولا يمكن إطفاؤها'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F22',
              label: 'OBD-II / DLC',
              nameArabic: 'فيوز مدخل الفحص التشخيصي OBD-II ووصلة السكنر',
              ratingAmps: 7,
              descriptionArabic: 'تغذية الطرف رقم 16 في فيشة الفحص OBD بجهد 12V الدائم.',
              symptoms: [
                'جهاز الفحص (سكنر Launch / Autel / Star) لا يضيء نهائياً ولا يقلع',
                'رسالة Link Error وعدم استجابة منافذ التشخيص',
              ],
              associatedDTCs: ['U0100', 'U0140'],
              testingTip: 'افحص النقطة 16 في الفيشة، إذا لم تجد 12V فهذا الفيوز F22 محترق حتماً.',
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F23',
              label: 'CLUSTER',
              nameArabic: 'فيوز عدادات الطبلون والشاشة الوسطية',
              ratingAmps: 10,
              descriptionArabic: 'تغذية لوحة العدادات وشاشة المعلومات للسائق.',
              symptoms: ['شاشة الطبلون والعدادات مطفية تماماً والسيارة تعمل'],
              gridRow: 0,
              gridCol: 2,
            ),
          ],
        ),

        // 1.4 Unique Location: Battery Prefuse Box F32
        VehicleFuseBox(
          id: 'w204_prefuse_box',
          nameArabic: 'علبة التوزيع الرئيسية التمهيدية (Prefuse Box F32)',
          locationType: FuseBoxLocationType.special,
          isSpecialLocation: true,
          specialBadgeText: 'موقع فريد: فيوزات الطاقة العملاقة (Mega Fuses 80A-150A)',
          detailedLocationArabic:
              'في حوض المحرك جهة اليمين (الراكب)، ملاصقة مباشرة لقطب البطارية الموجب داخل غطاء بلاستيكي صلب.',
          accessInstructions:
              'تحذير أمان: افصل القطب السالب للبطارية أولاً قبل فتحها. اضغط على أقفال التثبيت الجانبية للعلبة التمهيدية.',
          realisticCoverNote:
              'تحتوي هذه العلبة على مصهرات رئيسية عملاقة (Mega Fuses) مثبّتة ببراغي. عند احتراق أحدها، تنقطع الكهرباء عن شبكات كاملة كالدينامو، باور الستيرنج، أو سام الأمامي.',
          slots: [
            FuseSlot(
              slotId: 'PF1',
              label: 'ALT FEED',
              nameArabic: 'فيوز خط تغذية دينامو الشحن العمومي (Alternator)',
              ratingAmps: 150,
              isSpecial: true,
              descriptionArabic: 'خط الشحن الرئيسي بين دينامو السيارة والبطارية.',
              symptoms: [
                'البطارية لا تشحن وظهور لمبة البطارية الحمراء فوراً',
                'تفريغ البطارية وتوقف السيارة أثناء السير',
              ],
              associatedDTCs: ['P0560', 'P0620'],
              testingTip: 'فيوز برغي نحاسي عملاق 150 أمبير، افحص فرق الجهد بين طرفيه.',
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'PF2',
              label: 'ESP / ABS',
              nameArabic: 'فيوز مضخة نظام الاستقرار والفرامل (ESP / ABS Pump)',
              ratingAmps: 100,
              isSpecial: true,
              descriptionArabic: 'يغذي موتور ومضخة الفرامل الهيدروليكية لنظام ABS وESP.',
              symptoms: [
                'ظهور تحذيرات ABS Inoperative و ESP Inoperative باللون الأصفر',
                'ثقل مفاجئ في دواسة الفرامل وتعطل نظام مانع الانزلاق',
              ],
              associatedDTCs: ['C1000', 'C1100'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'PF3',
              label: 'SAM FRONT',
              nameArabic: 'فيوز التغذية العمومية لوحدة سام الأمامية',
              ratingAmps: 80,
              isSpecial: true,
              descriptionArabic: 'الخط الرئيسي المغذي لكل فيوزات وريليهات الكبوت.',
              symptoms: ['انقطاع كامل وشامل لكهرباء حوض المحرك والإنارة وسلف التشغيل'],
              gridRow: 0,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'PF4',
              label: 'SAM REAR',
              nameArabic: 'فيوز التغذية العمومية لوحدة سام الخلفية بالشنطة',
              ratingAmps: 80,
              isSpecial: true,
              descriptionArabic: 'الخط الرئيسي المغذي لعلبة فيوزات الشنطة الخلفية.',
              symptoms: ['تعطل طرمبة البنزين وسنترلوك الأبواب والأنوار الخلفية دفعة واحدة'],
              gridRow: 1,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'PF5',
              label: 'EPS STEER',
              nameArabic: 'فيوز مضخة التوجيه المعزز الكهربائي (Electric Power Steering)',
              ratingAmps: 80,
              isSpecial: true,
              descriptionArabic: 'يغذي موتور الدودة الكهربائية للدركسيون.',
              symptoms: [
                'ثقل شديد جداً وحجر في مقود القيادة (الدركسيون متحجر كأنه مقفل)',
                'ظهور Power Steering Malfunction في الشاشة',
              ],
              associatedDTCs: ['C1500', 'U0131'],
              gridRow: 1,
              gridCol: 1,
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    // 2. Mercedes-Benz E-Class (W211 / W212) - E200, E240, E280, E350
    // =========================================================================
    CarVehicleModel(
      id: 'mercedes_e_class_w211_w212',
      make: 'Mercedes-Benz',
      makeArabic: 'مرسيدس-بنز',
      model: 'E-Class (W211 / W212)',
      modelArabic: 'إي كلاس (E-Class W211/W212)',
      yearRange: '2003 - 2016 (E200 / E240 / E280 / E350)',
      bodyType: 'سيدان تنفيذية فاخرة',
      obdLocation: 'تحت الطبلون جهة اليسار فوق دواسة فرامل اليد / البريك الأرضي.',
      fuseBoxes: [
        VehicleFuseBox(
          id: 'w212_front_sam',
          nameArabic: 'علبة فيوزات وحدة سام الأمامية (Engine Compartment SAM)',
          locationType: FuseBoxLocationType.engineBay,
          detailedLocationArabic:
              'في حوض المحرك جهة اليسار (السائق) بجانب مفصل الكبوت وقاعدة الفلتر.',
          accessInstructions:
              'ادفع المزلاجين البلاستيكيين للأمام ثم ارفع الغطاء الأسود للأعلى.',
          slots: [
            FuseSlot(
              slotId: 'F43',
              label: 'STARTER',
              nameArabic: 'فيوز سلف وموتورينو التشغيل',
              ratingAmps: 20,
              descriptionArabic: 'تغذية بادئ الحركة للمحرك.',
              symptoms: ['المحرك لا يلف بالسلف أبداً رغم شحن البطارية'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F48',
              label: 'WIPER',
              nameArabic: 'فيوز مساحات الزجاج الأمامية',
              ratingAmps: 30,
              descriptionArabic: 'محرك المساحات الأمامية.',
              symptoms: ['توقف المساحات عن العمل'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F53',
              label: 'ECU MAIN',
              nameArabic: 'فيوز كمبيوتر المحرك الرئيسي (Engine Control Module)',
              ratingAmps: 20,
              descriptionArabic: 'يغذي بوكس المحرك الرئيسي ووحدات الحقن.',
              symptoms: ['المحرك قاطع نهائياً', 'غياب الاتصال بجهاز الفحص OBD'],
              associatedDTCs: ['P0685', 'U0100'],
              gridRow: 0,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'F54',
              label: 'AIRMATIC',
              nameArabic: 'فيوز كمبروسر مساعدات الهيدروليك (Airmatic Compressor)',
              ratingAmps: 40,
              descriptionArabic: 'يغذي موتور ضاغط الهواء لنظام التعليق الهوائي Airmatic.',
              symptoms: [
                'نزول وهبوط السيارة من الخلف أو الأمام على الأرض',
                'رسالة Stop Vehicle Too Low في الطبلون',
              ],
              associatedDTCs: ['C1556', 'C1550'],
              testingTip: 'فيوز ماكسي برتقالي 40A، افحصه عند سماع ضغط غير طبيعي للكمبروسر.',
              gridRow: 1,
              gridCol: 0,
            ),
          ],
        ),
        VehicleFuseBox(
          id: 'w212_rear_sam',
          nameArabic: 'علبة فيوزات وحدة سام الخلفية (Luggage Bay SAM)',
          locationType: FuseBoxLocationType.trunk,
          detailedLocationArabic:
              'في الشنطة الخلفية جهة اليسار، خلف باب الديكور المبطن في الرفرف الأيسر.',
          accessInstructions:
              'أدر مقبض الفتح في بطانة الشنطة واسحب الديكور لتظهر لوحة الفيوزات.',
          slots: [
            FuseSlot(
              slotId: 'F15',
              label: 'FUEL PUMP',
              nameArabic: 'فيوز طرمبة (بومبة) البنزين الرئيسية',
              ratingAmps: 20,
              descriptionArabic: 'مضخة البنزين داخل خزان الوقود.',
              symptoms: ['السيارة تطحن بالسلف دون دوران المحرك'],
              associatedDTCs: ['P0087'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F20',
              label: 'REAR BLIND',
              nameArabic: 'فيوز الستارة الخلفية الكهربائية',
              ratingAmps: 15,
              descriptionArabic: 'موتور رفع وخفض ستارة الزجاج الخلفي.',
              symptoms: ['الستارة الخلفية لا تتحرك'],
              gridRow: 0,
              gridCol: 1,
            ),
          ],
        ),
        VehicleFuseBox(
          id: 'w211_special_sbc',
          nameArabic: 'علبة التوزيع التمهيدية والبطارية الاحتياطية (Auxiliary Box)',
          locationType: FuseBoxLocationType.special,
          isSpecialLocation: true,
          specialBadgeText: 'موقع فريد: نظام الفرامل الحساس SBC والبطارية المساعدة',
          detailedLocationArabic:
              'تحت فلتر التكييف في حوض المحرك جهة اليمين، بجانب البطارية الإضافية الصغيرة (Auxiliary Battery).',
          accessInstructions:
              'افتح غطاء فلتر المكيف لتصل إلى صينية البطارية المساعدة ومصهر الـ SBC الحساس.',
          realisticCoverNote:
              'هذا الموقع الحساس يغذي نظام فرامل الـ SBC الإلكتروني والبطارية المساعدة لضمان عمل الفرامل حتى لو فرغت البطارية الأساسية.',
          slots: [
            FuseSlot(
              slotId: 'F_SBC1',
              label: 'SBC PUMP 1',
              nameArabic: 'فيوز مضخة الفرامل الإلكترونية الحساسة (SBC Brake System)',
              ratingAmps: 50,
              isSpecial: true,
              descriptionArabic: 'التغذية الكهربائية الرئيسية لمضخة فرامل الـ SBC الشهيرة في مرسيدس E-Class.',
              symptoms: [
                'ظهور تحذير الفرامل الأحمر STOP BRAKE DEFECTIVE في الطبلون مع رنين متواصل',
                'تحجر دواسة الفرامل وضياع قدرة الإيقاف إلا بقوة ميكانيكية طارئة شديدة',
              ],
              associatedDTCs: ['C249F', 'C2130'],
              testingTip: 'احذر القيادة نهائياً في حال تلف هذا الفيوز؛ هذا النظام حيوي لسلامة الفرامل.',
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F_AUX_BATT',
              label: 'AUX BATT',
              nameArabic: 'فيوز مرحل شحن البطارية الإضافية المساعدة',
              ratingAmps: 15,
              isSpecial: true,
              descriptionArabic: 'دائرة شحن البطارية المساعدة المسؤولة عن أنظمة الأمان والكمبيوتر.',
              symptoms: [
                'رسالة Auxiliary Battery Malfunction في الشاشة',
                'فصل ميزات الترفيه وتدفئة المقاعد للحفاظ على الطاقة',
              ],
              gridRow: 0,
              gridCol: 1,
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    // 3. BMW 3 Series (E90 / E91 / E92 / F30) - 318i, 320i, 325i, 328i, 330i
    // =========================================================================
    CarVehicleModel(
      id: 'bmw_3_series_e90_f30',
      make: 'BMW',
      makeArabic: 'بي إم دبليو',
      model: '3 Series (E90 / F30)',
      modelArabic: 'الفئة الثالثة (3 Series E90/F30)',
      yearRange: '2005 - 2018 (318i / 320i / 325i / 328i / 330i)',
      bodyType: 'سيدان رياضية',
      obdLocation: 'أسفل لوحة القيادة جهة السائق يساراً، فوق مسند القدم اليسرى مباشرة داخل تجويف مخصص.',
      fuseBoxes: [
        // 3.1 Glove Compartment (JBE)
        VehicleFuseBox(
          id: 'bmw_e90_jbe',
          nameArabic: 'علبة فيوزات صندوق القفازات (Junction Box - JBE)',
          locationType: FuseBoxLocationType.cabin,
          detailedLocationArabic:
              'داخل المقصورة، خلف درج التابلوه (صندوق القفازات) مباشرة.',
          accessInstructions:
              'افتح درج التابلوه، أدر القفلين البلاستيكيين الأبيضين بزاوية 90 درجة واسحب اللوحة لأسفل. ستجد ملقط الفيوزات وخريطة الرموز ملتصقة بالغطاء.',
          realisticCoverNote:
              'هذه هي علبة الفيوزات المركزية لسيارات BMW الفئة الثالثة، وتحتوي على كمبيوتر الجانكشن بوكس JBE.',
          slots: [
            FuseSlot(
              slotId: 'F8',
              label: 'OBD-II / CAS',
              nameArabic: 'فيوز مدخل الفحص التشخيصي OBD ونظام تشغيل المفتاح (CAS)',
              ratingAmps: 15,
              descriptionArabic: 'يغذي فيشة OBD الطرف 16 ووحدة Car Access System المسؤولة عن المفتاح.',
              symptoms: [
                'أجهزة الفحص (السكنر) لا تتصل بالسيارة ومطفية',
                'السيارة لا تستجيب للضغط على زر Start/Stop Engine',
              ],
              associatedDTCs: ['A0B4', 'U0100'],
              testingTip: 'من أهم الفيوزات عند محاولة تشخيص سيارة BMW عبر فيشة الـ OBD.',
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F30',
              label: 'CIGAR / 12V',
              nameArabic: 'فيوز ولاعة السجائر ومخرج الطاقة والشاحن',
              ratingAmps: 20,
              descriptionArabic: 'تغذية مقبس الشاحن والولاعة في الكونسول الوسطي.',
              symptoms: ['شاحن الهاتف لا يعمل والولاعة لا تسخن'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F56',
              label: 'KOMBI',
              nameArabic: 'فيوز شاشة عدادات الطبلون (Instrument Cluster)',
              ratingAmps: 15,
              descriptionArabic: 'تغذية شاشات السرعة والـ RPM ومؤشرات البنزين والحرارة.',
              symptoms: ['طبلون السيارة مظلم تماماً والمؤشرات لا تتحرك'],
              gridRow: 0,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'F61',
              label: 'BLOWER',
              nameArabic: 'فيوز مروحة المكيف الداخلية (Blower Motor / Final Stage)',
              ratingAmps: 30,
              descriptionArabic: 'يغذي موتور دفع الهواء البارد داخل الكابينة ومقاومة المكيف.',
              symptoms: [
                'لا يخرج أي هواء من فتحات التكييف رغم سماع صوت الكمبروسر',
                'مروحة المكيف متوقفة نهائياً',
              ],
              gridRow: 1,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F73',
              label: 'WIPER / WASHER',
              nameArabic: 'فيوز مساحات الزجاج ورشاشات ماء الغسيل',
              ratingAmps: 30,
              descriptionArabic: 'موتور مساحات المطر الأمامية وطلمبة الرشاشات.',
              symptoms: ['مساحات الزجاج الأمامي لا تتحرك'],
              gridRow: 1,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F88',
              label: 'EKP / PUMP',
              nameArabic: 'فيوز وحدة مضخة الوقود الرئيسية (EKP Module / Fuel Pump)',
              ratingAmps: 20,
              descriptionArabic: 'يغذي وحدة التحكم الإلكترونية في طرمبة البنزين بمحركات N46/N52/N20/B48.',
              symptoms: [
                'المحرك يدور بالسلف دون تشغيل نهائياً',
                'رسالة Fuel Supply Malfunction في شاشة الـ iDrive',
              ],
              associatedDTCs: ['CED4', 'P0087'],
              testingTip: 'في موديلات E90، يرجى فحص وحدة الـ EKP فوق الرفرف الخلفي الأيمن أيضاً.',
              gridRow: 1,
              gridCol: 2,
            ),
          ],
        ),

        // 3.2 Engine Bay E-Box (Special / Unique)
        VehicleFuseBox(
          id: 'bmw_e90_ebox',
          nameArabic: 'صندوق إلكترونيات المحرك (Engine Bay E-Box)',
          locationType: FuseBoxLocationType.special,
          isSpecialLocation: true,
          specialBadgeText: 'موقع فريد: كمبيوتر DME ومحرك الفالفترونيك Valvetronic',
          detailedLocationArabic:
              'في حوض المحرك جهة اليمين (الراكب)، مخفي تحت فلتر تكييف المقصورة ومسار الهواء الأسود.',
          accessInstructions:
              'فك مسامير غطاء فلتر التكييف (مقاس 8 ملم) وأزل مجرى الهواء، ثم فك مشابك الغطاء الأبيض لصندوق الـ E-Box المحكم.',
          realisticCoverNote:
              'موقع استراتيجي وحساس يحتوي على كمبيوتر المحرك DME، ريلي الـ DME الأزرق الشهير، وفيوزات الفالفترونيك ومضخة الماء.',
          slots: [
            FuseSlot(
              slotId: 'F01',
              label: 'IGN COILS',
              nameArabic: 'فيوز شمعات وبوبينات الإشعال (Ignition Coils)',
              ratingAmps: 20,
              descriptionArabic: 'تغذية خط الـ 12V لكويلات الإشعال في سلندرات المحرك.',
              symptoms: [
                'رجفة واهتزاز شديد بالمحرك وانطفاء فوري',
                'تقطيع عند الضغط على دواسة البنزين',
              ],
              associatedDTCs: ['29CD', '29CE', 'P0300'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F02',
              label: 'VANOS / O2',
              nameArabic: 'فيوز صمامات الفانوس (VANOS) وسخانات حساس الأكسجين',
              ratingAmps: 30,
              descriptionArabic: 'يغذي بلوف الفانوس المتغيرة وسخانات حساسات الشكمان.',
              symptoms: [
                'ضعف عزم المحرك وعلو صوت الماكينة عند التسارع',
                'ظهور أكواد أعطال الفانوس 2A82 و 2A87',
              ],
              associatedDTCs: ['2A82', '2A87', 'P0012'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F03',
              label: 'VVT / VALVE',
              nameArabic: 'فيوز موتور نظام الفالفترونيك (Valvetronic Servomotor)',
              ratingAmps: 40,
              isSpecial: true,
              descriptionArabic: 'يغذي محرك التحكم في فتح وغلق صمامات السحب المتغير (VVT).',
              symptoms: [
                'دخول السيارة في طور الطوارئ وقفل سرعة السيارة (Limp Home Mode)',
                'عدم استجابة دواسة الوقود للمحرك وظهور علامة Engine Malfunction',
              ],
              associatedDTCs: ['2A67', '2A6B'],
              testingTip: 'فيوز ماكسي كبير 40 أمبير برتقالي اللون داخل علبة الـ E-Box.',
              gridRow: 1,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F04',
              label: 'WATER PUMP',
              nameArabic: 'فيوز مضخة الماء الكهربائية (Electric Water Pump)',
              ratingAmps: 50,
              isSpecial: true,
              descriptionArabic: 'يغذي طرمبة الماء الكهربائية الشهيرة في محركات بي إم دبليو 6 سلندر N52/N54/N55.',
              symptoms: [
                'ارتفاع حرج وفوري في حرارة محرك الـ BMW إلى اللون الأصفر ثم الأحمر',
                'دوران مروحة الرداتوري بأقصى سرعة وإزعاج شديد كحالة طوارئ',
              ],
              associatedDTCs: ['2E81', '2E82'],
              testingTip: 'فيوز أحمر ماكسي 50 أمبير. احذر قيادة السيارة إذا احترق هذا الفيوز لتفادي حرق جوان كولاس الرأس.',
              gridRow: 1,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'R_DME',
              label: 'DME RELAY',
              nameArabic: 'ريلي كمبيوتر المحرك الرئيسي الأزرق (DME Main Relay)',
              ratingAmps: 40,
              isRelay: true,
              relayType: 'BMW 4-Pin Sky Blue Relay',
              descriptionArabic: 'الريلي الأزرق الشهير المسؤول عن استيقاظ كمبيوتر المحرك DME.',
              symptoms: [
                'السيارة لا تشتغل نهائياً والمحرك يدور بالسلف دون شعلة أو حقن',
                'فقدان الاتصال بكمبيوتر المحرك تماماً عبر جهاز الفحص',
              ],
              associatedDTCs: ['2E8B', 'U0100'],
              gridRow: 1,
              gridCol: 2,
            ),
          ],
        ),

        // 3.3 Rear Power Distribution Box (Special / Unique)
        VehicleFuseBox(
          id: 'bmw_e90_battery_box',
          nameArabic: 'صندوق التوزيع وقاطع الحوادث فوق البطارية (Rear Power Box)',
          locationType: FuseBoxLocationType.trunk,
          isSpecialLocation: true,
          specialBadgeText: 'موقع فريد: قاطع الحوادث المتفجر وحساس البطارية الذكي IBS',
          detailedLocationArabic:
              'في الشنطة الخلفية جهة اليمين، مثبت مباشرة فوق القطب الموجب لبطارية السيارة.',
          accessInstructions:
              'افتح غطاء البطارية البلاستيكي في الجهة اليمنى للشنطة. الصندوق باللون الأحمر والأسود فوق البطارية.',
          realisticCoverNote:
              'هذا الصندوق يضم فيوزات الميجا الرئيسية لحماية شبكة بي إم دبليو من الحرائق عند الحوادث عبر كبسولة الـ BST.',
          slots: [
            FuseSlot(
              slotId: 'PF100',
              label: 'BATT MAIN',
              nameArabic: 'فيوز كابل السلف والدينامو العمومي ومفرقعة الأمان (BST)',
              ratingAmps: 250,
              isSpecial: true,
              descriptionArabic: 'كابل التغذية الفائق الممتد إلى مقدمة السيارة ومحرك السلف.',
              symptoms: [
                'انقطاع كامل لكهرباء بادئ الحركة بعد أي صدمة أو حادث (فصل كبسولة BST)',
                'المحرك لا يلف بالسلف نهائياً رغم إضاءة الطبلون',
              ],
              associatedDTCs: ['93B2'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'PF101',
              label: 'JBE FEED',
              nameArabic: 'فيوز تغذية علبة فيوزات التابلوه الرئيسية (JBE Feed)',
              ratingAmps: 100,
              isSpecial: true,
              descriptionArabic: 'كابل التغذية المغذي لصندوق فيوزات المقصورة.',
              symptoms: ['انقطاع كامل لكهرباء داخلية السيارة وسنترلوك الأبواب'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'PF103',
              label: 'IBS SENSOR',
              nameArabic: 'فيوز حساس البطارية الذكي (IBS Intelligent Battery Sensor)',
              ratingAmps: 5,
              isSpecial: true,
              descriptionArabic: 'يغذي حساس القطب السالب المسؤول عن مراقبة شحن وصحة بطارية BMW.',
              symptoms: [
                'رسالة High Battery Discharge عند الوقوف',
                'عدم انتظام شحن الدينامو ومسح ساعة وتاريخ الشاشة',
              ],
              associatedDTCs: ['299B', '2E8E'],
              gridRow: 0,
              gridCol: 2,
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    // BMW 5 Series (E39) - 520i, 523i, 525i, 528i, 530i, 535i, 540i, M5
    // =========================================================================
    // =========================================================================
    // 4. BMW 5 Series (E60 / F10) - 520i, 525i, 528i, 530i, 535i
    // =========================================================================
    CarVehicleModel(
      id: 'bmw_5_series_e60_f10',
      make: 'BMW',
      makeArabic: 'بي إم دبليو',
      model: '5 Series (E60 / F10)',
      modelArabic: 'الفئة الخامسة (5 Series E60/F10)',
      yearRange: '2004 - 2016 (520i / 525i / 528i / 530i / 535i)',
      bodyType: 'سيدان تنفيذية كبيرة',
      obdLocation: 'تحت الطبلون جهة اليسار بجانب ذراع فتح غطاء المحرك.',
      fuseBoxes: [
        VehicleFuseBox(
          id: 'bmw_f10_cabin',
          nameArabic: 'علبة فيوزات الطبلون (Glove Box Fuse Carrier)',
          locationType: FuseBoxLocationType.cabin,
          detailedLocationArabic:
              'خلف درج التابلوه، تنزل اللوحة بعد فك مسامير التثبيت البلاستيكية اليدوية.',
          accessInstructions:
              'أدر المفاتيح اليدوية وانزل اللوحة لأسفل لكشف صفوف الفيوزات الملونة.',
          slots: [
            FuseSlot(
              slotId: 'F2',
              label: 'OBD-II',
              nameArabic: 'فيوز فيشة الفحص وتشخيص الأعطال OBD-II',
              ratingAmps: 10,
              descriptionArabic: 'التغذية الكهربائية لمنفذ التشخيص.',
              symptoms: ['جهاز الفحص لا يعمل ولا يتعرف على كمبيوتر الفئة الخامسة'],
              associatedDTCs: ['U0100'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F24',
              label: 'CIGAR',
              nameArabic: 'فيوز ولاعة السجائر والشواحن',
              ratingAmps: 20,
              descriptionArabic: 'شواحن الهاتف الأمامية.',
              symptoms: ['الشاحن لا يعمل'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F40',
              label: 'CAS / KEY',
              nameArabic: 'فيوز نظام تشغيل ومستقبل المفتاح الذكي',
              ratingAmps: 15,
              descriptionArabic: 'التعرف على المفتاح وزر التشغيل.',
              symptoms: ['السيارة لا تستشعر المفتاح الذكي ولا تفتح كونتاكت'],
              gridRow: 0,
              gridCol: 2,
            ),
          ],
        ),
        VehicleFuseBox(
          id: 'bmw_f10_trunk',
          nameArabic: 'علبة فيوزات الشنطة الخلفية (Rear Luggage Fuse Carrier)',
          locationType: FuseBoxLocationType.trunk,
          detailedLocationArabic:
              'في الشنطة الخلفية جهة اليمين خلف الغطاء القماشي المبطن للرفرف.',
          accessInstructions:
              'انزع الغطاء الجانبي المبطن لتجد صينية الفيوزات الكبيرة مع ورقة المخطط الأصلية.',
          slots: [
            FuseSlot(
              slotId: 'F130',
              label: 'AIR SUSP',
              nameArabic: 'فيوز مساعدات وضواغط الهواء الخلفية (Air Suspension)',
              ratingAmps: 40,
              descriptionArabic: 'يغذي كمبروسر رفع خلفية السيارة في طرازات التورينغ والـ 5 Series.',
              symptoms: ['هبوط مؤخرة السيارة على العجلات'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F141',
              label: 'FUEL PUMP',
              nameArabic: 'فيوز طرمبة (بومبة) البنزين',
              ratingAmps: 20,
              descriptionArabic: 'مضخة البنزين الرئيسية في الخزان.',
              symptoms: ['المحرك يدور بالسلف دون اشتعال'],
              associatedDTCs: ['P0087'],
              gridRow: 0,
              gridCol: 1,
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    // 5. BMW X5 (E70 / F15) - xDrive30i, xDrive35i, xDrive50i
    // =========================================================================
    CarVehicleModel(
      id: 'bmw_x5_e70_f15',
      make: 'BMW',
      makeArabic: 'بي إم دبليو',
      model: 'X5 (E70 / F15)',
      modelArabic: 'إكس 5 (BMW X5 E70/F15)',
      yearRange: '2007 - 2018 (xDrive30i / 35i / 50i)',
      bodyType: 'دفع رباعي فاخرة (SAV)',
      obdLocation: 'تحت الطبلون جهة اليسار فوق دعسة القدم اليسرى مباشرة.',
      fuseBoxes: [
        VehicleFuseBox(
          id: 'bmw_x5_cabin',
          nameArabic: 'علبة فيوزات التابلوه الأمامية (JBE Front)',
          locationType: FuseBoxLocationType.cabin,
          detailedLocationArabic:
              'تحت درج التابلوه في مقصورة الركاب جهة اليمين.',
          accessInstructions:
              'افتح الغطاء السفلي لدرج التابلوه للوصول إلى صينية الفيوزات.',
          slots: [
            FuseSlot(
              slotId: 'F1',
              label: 'OBD / CAS',
              nameArabic: 'فيوز فيشة الفحص OBD ونظام المفتاح',
              ratingAmps: 15,
              descriptionArabic: 'تغذية الفحص وتشغيل الكونتاكت.',
              symptoms: ['تعذر فحص السيارة بالجهاز'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F20',
              label: '4WD / XDRIVE',
              nameArabic: 'فيوز محرك دبل الدفع الرباعي (Transfer Case Motor)',
              ratingAmps: 30,
              isSpecial: true,
              descriptionArabic: 'يغذي موتور ترانسفير كيس ونظام xDrive للدفع الرباعي.',
              symptoms: [
                'ظهور لمبة 4x4 الصفراء في الطبلون مع رنين تحذيري',
                'فصل الدفع الرباعي وتوقف المساعدة في الرمال أو الطرق الزلقة',
              ],
              associatedDTCs: ['5463', '5462'],
              gridRow: 0,
              gridCol: 1,
            ),
          ],
        ),
        VehicleFuseBox(
          id: 'bmw_x5_trunk',
          nameArabic: 'علبة فيوزات الشنطة الخلفية (Rear Power Distribution)',
          locationType: FuseBoxLocationType.trunk,
          detailedLocationArabic:
              'في الشنطة الخلفية تحت أرضية التحميل جهة اليمين بجانب البطارية الرئيسية.',
          accessInstructions:
              'ارفع أرضية الشنطة وانزع الغطاء الجانبي الأيمن.',
          slots: [
            FuseSlot(
              slotId: 'F100',
              label: 'AIR PUMP',
              nameArabic: 'فيوز منفاخ التعليق الهوائي الخلفي (Air Springs)',
              ratingAmps: 40,
              descriptionArabic: 'موتور هيدروليك المساعدات الخلفية.',
              symptoms: ['نزول خلفية الجيب X5 على الإطارات'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F104',
              label: 'FUEL PUMP',
              nameArabic: 'فيوز مضخة الوقود الرئيسية',
              ratingAmps: 20,
              descriptionArabic: 'تغذية طرمبة البنزين في الخزان.',
              symptoms: ['المحرك لا يشتغل إطلاقاً'],
              gridRow: 0,
              gridCol: 1,
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    // 6. Toyota Corolla (2008 - 2013) - الجيل العاشر الأكثر انتشاراً
    // =========================================================================
    CarVehicleModel(
      id: 'toyota_camry_2007_2017',
      make: 'Toyota',
      makeArabic: 'تويوتا',
      model: 'Camry',
      modelArabic: 'كامري (Camry XV40/XV50)',
      yearRange: '2007 - 2017 (XV40 / XV50)',
      bodyType: 'سيدان متوسطة',
      obdLocation: 'تحت الطبلون جهة السائق يساراً فوق دواسة الفرامل مباشرة.',
      fuseBoxes: [
        VehicleFuseBox(
          id: 'camry_engine_bay',
          nameArabic: 'علبة فيوزات حوض المحرك الرئيسية (Engine Bay)',
          locationType: FuseBoxLocationType.engineBay,
          detailedLocationArabic:
              'في حوض المحرك بجانب البطارية وفلتر الهواء من جهة السائق.',
          accessInstructions:
              'اضغط على الكلبسات البلاستيكية على حواف الغطاء وارفع الغطاء لأعلى.',
          slots: [
            FuseSlot(
              slotId: 'F1',
              label: 'EFI MAIN',
              nameArabic: 'فيوز منظومة الحقن وكمبيوتر المحرك',
              ratingAmps: 25,
              descriptionArabic: 'يغذي بوكس المحرك وحساسات الأكسجين والبخاخات.',
              symptoms: ['المحرك يدور بالسلف دون تشغيل', 'لمبة Check Engine لا تضيء عند فتح السويتش'],
              associatedDTCs: ['P0685', 'U0100'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F2',
              label: 'INJ',
              nameArabic: 'فيوز رشاشات الوقود والشمعات',
              ratingAmps: 10,
              descriptionArabic: 'تغذية بوبينات الإشعال ورشاشات البنزين.',
              symptoms: ['تقطيع واهتزاز شديد بالمحرك أو انطفاء فوري'],
              associatedDTCs: ['P0300'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F3',
              label: 'FAN MAIN',
              nameArabic: 'فيوز مروحة الرداتوري والتكييف',
              ratingAmps: 50,
              descriptionArabic: 'موتور مروحة تبريد الرديتر الرئيسية.',
              symptoms: ['حرارة عالية جداً في التوقف', 'توقف المكيف عن التبريد'],
              associatedDTCs: ['P0480'],
              gridRow: 0,
              gridCol: 2,
            ),
          ],
        ),
        VehicleFuseBox(
          id: 'camry_cabin',
          nameArabic: 'علبة فيوزات الطبلون الداخلية (Cabin)',
          locationType: FuseBoxLocationType.cabin,
          detailedLocationArabic:
              'تحت الطبلون أسفل المقود، بجانب مسند قدم السائق.',
          accessInstructions:
              'انزع الغطاء البلاستيكي بالشد الخفيف باتجاه المقعد.',
          slots: [
            FuseSlot(
              slotId: 'F11',
              label: 'OBD / D/C',
              nameArabic: 'فيوز فيشة الفحص OBD وشاشة الطبلون',
              ratingAmps: 10,
              descriptionArabic: 'تغذية الطرف رقم 16 في فيشة OBD-II والذاكرة.',
              symptoms: ['جهاز الفحص لا يصله كهرباء شاشة مطفية', 'تصفير العداد وساعة الطبلون'],
              associatedDTCs: ['U0100'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F12',
              label: 'CIG',
              nameArabic: 'فيوز ولاعة السجائر ومخرج الشحن 12V',
              ratingAmps: 15,
              descriptionArabic: 'تغذية شواحن الهاتف والولاعة.',
              symptoms: ['شاحن الهاتف لا يعمل'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F13',
              label: 'STOP',
              nameArabic: 'فيوز لمبات الفرامل ومفتاح دعسة البريك',
              ratingAmps: 10,
              descriptionArabic: 'تغذية لمبات الستوب ومفتاح دواسة البريك.',
              symptoms: ['عصا القير معلقة ولا تتحرك من الـ P', 'عدم إضاءة لمبات الفرامل'],
              gridRow: 0,
              gridCol: 2,
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    // 8. Hyundai Elantra (2011 - 2016) - MD
    // =========================================================================
    CarVehicleModel(
      id: 'hyundai_elantra_md_2011_2016',
      make: 'Hyundai',
      makeArabic: 'هيونداي',
      model: 'Elantra',
      modelArabic: 'إلنترا (Elantra MD/AD)',
      yearRange: '2011 - 2016 (الجيل الخامس MD)',
      bodyType: 'سيدان',
      obdLocation: 'خلف غطاء علبة الفيوزات الداخلية يسار المقود مباشرة تحت فتحة المكيف',
      fuseBoxes: [
        VehicleFuseBox(
          id: 'elantra_engine_bay',
          nameArabic: 'علبة فيوزات حوض المحرك (Engine Room Fuse & Relay Box)',
          locationType: FuseBoxLocationType.engineBay,
          detailedLocationArabic:
              'في حوض المحرك من جهة السائق (اليسار)، بجانب البطارية وعلبة فلتر الهواء.',
          accessInstructions:
              'اضغط على المشبكين البلاستيكيين في مقدمة ونهاية الغطاء ثم اسحبه للأعلى.',
          slots: [
            FuseSlot(
              slotId: 'F_B_PUMP',
              label: 'B/PUMP',
              nameArabic: 'فيوز طرمبة (بومبة) البنزين',
              ratingAmps: 15,
              descriptionArabic: 'يغذي مضخة الوقود الغاطسة داخل خزان البنزين.',
              symptoms: [
                'المحرك يدور بالسلف ولكن لا يشتغل نهائياً',
                'انعدام صوت زنة طرمبة البنزين عند فتح الكونتاكت',
              ],
              associatedDTCs: ['P0087', 'P0627'],
              testingTip: 'افحص وصول 12V للفيوز لثانيتين عند فتح السويتش.',
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F_ECU1',
              label: 'ECU 1',
              nameArabic: 'فيوز كمبيوتر إدارة المحرك وحساس الأكسجين',
              ratingAmps: 20,
              descriptionArabic: 'التغذية الكهربائية الرئيسية لكمبيوتر السيارة (PCM).',
              symptoms: [
                'انقطاع كامل عن بوكس السيارة ولا توجد إشارة فحص في الطبلون',
                'المحرك يلف بالسلف دون أي استجابة',
              ],
              associatedDTCs: ['P0685', 'U0100'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F_COOL_FAN',
              label: 'COOL FAN',
              nameArabic: 'فيوز مروحة تبريد الرداتوري الرئيسية',
              ratingAmps: 40,
              descriptionArabic: 'يغذي موتور مروحة التبريد خلف رديتر المحرك.',
              symptoms: ['ارتفاع حرارة المحرك وتوقف تبريد المكيف'],
              associatedDTCs: ['P0480'],
              gridRow: 0,
              gridCol: 2,
            ),
          ],
        ),
        VehicleFuseBox(
          id: 'elantra_cabin',
          nameArabic: 'علبة فيوزات المقصورة الداخلية (Smart Junction Box)',
          locationType: FuseBoxLocationType.cabin,
          detailedLocationArabic:
              'يسار المقود في لوحة القيادة، خلف الغطاء القابل للنزع أسفل فتحة مكيف السائق.',
          accessInstructions:
              'أدخل إصبعك في التجويف السفلي للغطاء واسحبه برفق باتجاهك لنزعه.',
          slots: [
            FuseSlot(
              slotId: 'F_CIGAR',
              label: 'C/LIGHTER',
              nameArabic: 'فيوز ولاعة السجائر ومخرج الطاقة 12V',
              ratingAmps: 20,
              descriptionArabic: 'يغذي مقبس الولاعة ومخارج شواحن الهواتف.',
              symptoms: ['شواحن الهاتف والولاعة لا تعمل'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F_CLUSTER',
              label: 'CLUSTER',
              nameArabic: 'فيوز عدادات الطبلون وشاشات القيادة',
              ratingAmps: 10,
              descriptionArabic: 'تغذية لوحة العدادات وشاشة الرحلات في الطبلون.',
              symptoms: ['انطفاء كامل لعدادات السرعة والـ RPM ومؤشرات الوقود'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F_OBD',
              label: 'OBD-II',
              nameArabic: 'فيوز مدخل الفحص والتشخيص OBD-II',
              ratingAmps: 10,
              descriptionArabic: 'تغذية الفولتية 12V لفيشة الفحص وأجهزة السكنر.',
              symptoms: ['جهاز الفحص لا يقلع ولا يقرأ أي كمبيوتر'],
              associatedDTCs: ['U0100'],
              gridRow: 0,
              gridCol: 2,
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    // 9. Hyundai Tucson / Kia Sportage (2010 - 2016)
    // =========================================================================
    CarVehicleModel(
      id: 'hyundai_tucson_sportage_2010_2016',
      make: 'Hyundai',
      makeArabic: 'هيونداي',
      model: 'Tucson / Sportage',
      modelArabic: 'توسان / سبورتاج (Tucson / Sportage)',
      yearRange: '2010 - 2016 (LM / SL)',
      bodyType: 'SUV / دفع رباعي',
      obdLocation: 'أسفل مقود القيادة جهة اليسار بجانب علبة الفيوزات الداخلية.',
      fuseBoxes: [
        VehicleFuseBox(
          id: 'tucson_engine_bay',
          nameArabic: 'علبة فيوزات الكبوت الرئيسية (Engine Room)',
          locationType: FuseBoxLocationType.engineBay,
          detailedLocationArabic:
              'في حوض المحرك بجانب البطارية وصندوق فلتر الهواء جهة السائق.',
          accessInstructions:
              'اضغط على القفلين الجانبيين للغطاء ثم ارفعه للأعلى.',
          slots: [
            FuseSlot(
              slotId: 'F_B_PUMP',
              label: 'B/PUMP',
              nameArabic: 'فيوز طرمبة (بومبة) البنزين',
              ratingAmps: 15,
              descriptionArabic: 'يغذي مضخة الوقود الغاطسة داخل خزان البنزين.',
              symptoms: ['المحرك يدور بالسلف دون تشغيل', 'لا يوجد صوت زنة لطرمبة البنزين'],
              associatedDTCs: ['P0087', 'P0627'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F_ECU1',
              label: 'ECU 1',
              nameArabic: 'فيوز كمبيوتر إدارة المحرك',
              ratingAmps: 20,
              descriptionArabic: 'التغذية الكهربائية الرئيسية لكمبيوتر المحرك.',
              symptoms: ['المحرك قاطع نهائياً', 'غياب إشارة Check Engine'],
              associatedDTCs: ['P0685', 'U0100'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F_COOL_FAN',
              label: 'COOL FAN',
              nameArabic: 'فيوز مروحة تبريد الرداتوري',
              ratingAmps: 40,
              descriptionArabic: 'موتور مروحة تبريد الرادياتير والمكيف.',
              symptoms: ['ارتفاع حرارة المحرك وتوقف تبريد المكيف'],
              associatedDTCs: ['P0480'],
              gridRow: 0,
              gridCol: 2,
            ),
          ],
        ),
        VehicleFuseBox(
          id: 'tucson_cabin',
          nameArabic: 'علبة فيوزات المقصورة الداخلية (Smart Junction Block)',
          locationType: FuseBoxLocationType.cabin,
          detailedLocationArabic:
              'يسار المقود خلف الغطاء البلاستيكي للوحة القيادة أسفل فتحة التهوية.',
          accessInstructions:
              'اسحب الغطاء من الفتحة المخصصة للأصابع إلى الخارج برفق.',
          slots: [
            FuseSlot(
              slotId: 'F_OBD',
              label: 'OBD-II',
              nameArabic: 'فيوز مدخل الفحص والتشخيص OBD-II',
              ratingAmps: 10,
              descriptionArabic: 'تغذية الفولتية 12V لفيشة الفحص وأجهزة السكنر.',
              symptoms: ['جهاز الفحص لا يقلع ولا يقرأ أي كمبيوتر'],
              associatedDTCs: ['U0100'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F_BRAKE',
              label: 'STOP LAMP',
              nameArabic: 'فيوز لمبات الفرامل ومفتاح الستوب',
              ratingAmps: 15,
              descriptionArabic: 'أنوار الفرامل وحساس دعسة الفرامل ونظام ABS.',
              symptoms: ['عصا القير الأوتوماتيك لا تتحرك من الـ P', 'أنوار الفرامل الخلفية لا تضيء'],
              associatedDTCs: ['C1503'],
              gridRow: 0,
              gridCol: 1,
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    // 10. Nissan Sunny (2012 - 2021) - N17
    // =========================================================================
    CarVehicleModel(
      id: 'nissan_sunny_n17',
      make: 'Nissan',
      makeArabic: 'نيسان',
      model: 'Sunny',
      modelArabic: 'صني (Sunny N17)',
      yearRange: '2012 - 2021 (N17 الشكل الهندي / التايلاندي)',
      bodyType: 'سيدان اقتصادية',
      obdLocation: 'تحت المقود مباشرة من جهة اليمين قليلاً بجانب كونسول القير.',
      fuseBoxes: [
        VehicleFuseBox(
          id: 'sunny_ipdm',
          nameArabic: 'علبة التوزيع الذكية بحوض المحرك (IPDM E/R)',
          locationType: FuseBoxLocationType.engineBay,
          detailedLocationArabic:
              'في حوض المحرك جهة السائق (اليسار) بجانب البطارية مباشرة.',
          accessInstructions:
              'اضغط على لسان التثبيت الأمامي والخلفي للغطاء الأسود ثم ارفعه للأعلى.',
          slots: [
            FuseSlot(
              slotId: 'F35',
              label: 'F/PUMP',
              nameArabic: 'فيوز طرمبة (بومبة) البنزين',
              ratingAmps: 15,
              descriptionArabic: 'يغذي مضخة الوقود الرئيسية في الخزان.',
              symptoms: ['المحرك يدور بالسلف دون دوران نهائياً'],
              associatedDTCs: ['P0087'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F36',
              label: 'ECM',
              nameArabic: 'فيوز كمبيوتر المحرك الرئيسي',
              ratingAmps: 20,
              descriptionArabic: 'التغذية الرئيسية لبوكس المحرك.',
              symptoms: ['المحرك قاطع تماماً وعدم استجابة السكنر'],
              associatedDTCs: ['P0685', 'U0100'],
              gridRow: 0,
              gridCol: 1,
            ),
          ],
        ),
        VehicleFuseBox(
          id: 'sunny_cabin',
          nameArabic: 'علبة فيوزات المقصورة (تحت المقود)',
          locationType: FuseBoxLocationType.cabin,
          detailedLocationArabic:
              'يسار المقود خلف درج حفظ الأغراض الصغير.',
          accessInstructions:
              'افتح الدرج الصغير واضغط على جانبيه لإنزاله تماماً.',
          slots: [
            FuseSlot(
              slotId: 'F10',
              label: 'ELEC PARTS',
              nameArabic: 'فيوز فيشة الفحص OBD والولاعة',
              ratingAmps: 10,
              descriptionArabic: 'يغذي فيشة OBD والأنظمة الإلكترونية.',
              symptoms: ['جهاز الفحص لا يضيء'],
              gridRow: 0,
              gridCol: 0,
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    // 11. Opel Astra-G (1998 - 2009)
    // =========================================================================
    CarVehicleModel(
      id: 'opel_astra_g',
      make: 'Opel',
      makeArabic: 'أوبل',
      model: 'Astra G',
      modelArabic: 'أسترا جي (Astra G)',
      yearRange: '1998 - 2009',
      bodyType: 'هاتشباك / سيدان',
      obdLocation: 'تحت غطاء فرامل اليد (الهاند بريك) في الكونسول الوسطي تماماً.',
      fuseBoxes: [
        VehicleFuseBox(
          id: 'opel_engine_bay',
          nameArabic: 'علبة فيوزات حوض المحرك (Engine Relay Box)',
          locationType: FuseBoxLocationType.engineBay,
          detailedLocationArabic:
              'في الكبوت أمام خزان سائل الفرامل (سيرفو) بجانب الجدار الناري.',
          accessInstructions:
              'ارفع مشبك الغطاء البلاستيكي للأعلى وافتحه باتجاه الزجاج الأمامي.',
          slots: [
            FuseSlot(
              slotId: 'FV1',
              label: 'COOL FAN',
              nameArabic: 'فيوز مروحة تبريد الرداتوري والمكيف',
              ratingAmps: 30,
              descriptionArabic: 'تغذية وحدة تبريد المحرك (Cooling Module).',
              symptoms: ['حرارة عالية للمحرك وظهور لمبة الرادياتير المربعة بالطبلون'],
              associatedDTCs: ['P1481', 'P1482'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'FV2',
              label: 'ABS PUMP',
              nameArabic: 'فيوز مضخة مانع انغلاق المكابح ABS',
              ratingAmps: 60,
              descriptionArabic: 'موتور ومضخة الـ ABS الهيدروليكية.',
              symptoms: ['إضاءة لمبة ABS الصفراء'],
              associatedDTCs: ['C0035'],
              gridRow: 0,
              gridCol: 1,
            ),
          ],
        ),
        VehicleFuseBox(
          id: 'opel_cabin',
          nameArabic: 'علبة فيوزات المقصورة الداخلية (خلف درج العملات)',
          locationType: FuseBoxLocationType.cabin,
          detailedLocationArabic:
              'يسار المقود، خلف درج العملات الصغير القابل للإمالة.',
          accessInstructions:
              'افتح الدرج الصغير واضغط على ألسنة الإيقاف الجانبية لإنزاله للأسفل تماماً.',
          slots: [
            FuseSlot(
              slotId: 'F22',
              label: 'DIAG / HAZARD',
              nameArabic: 'فيوز مدخل الفحص التشخيصي OBD وفليشر الانتظار',
              ratingAmps: 15,
              descriptionArabic: 'يغذي فيشة OBD تحت الهاند بريك ولمبات الفليشر.',
              symptoms: ['جهاز الفحص Ediag لا يتعرف على سيارة الأوبل ولا يتصل بكمبيوتر Simtec'],
              associatedDTCs: ['U2105'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F28',
              label: 'INSTRUMENT',
              nameArabic: 'فيوز عدادات الطبلون والشاشة الوسطية TID/MID',
              ratingAmps: 10,
              descriptionArabic: 'تغذية العدادات وشاشة عرض الساعة والحرارة.',
              symptoms: ['انطفاء عدادات الطبلون'],
              gridRow: 0,
              gridCol: 1,
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    // 12. Volkswagen Golf 6 / Golf 7 & Passat (2009 - 2019)
    // =========================================================================
    CarVehicleModel(
      id: 'vw_golf_6_7',
      make: 'Volkswagen',
      makeArabic: 'فولكس فاجن',
      model: 'Golf / Passat',
      modelArabic: 'جولف / باسات (Golf Mk6/Mk7 & Passat)',
      yearRange: '2009 - 2019 (Mk6 / Mk7)',
      bodyType: 'هاتشباك / سيدان ألمانية',
      obdLocation: 'أسفل لوحة القيادة يسار دواسة الفرامل باللون البنفسجي الشهير.',
      fuseBoxes: [
        VehicleFuseBox(
          id: 'vw_engine_bay',
          nameArabic: 'علبة فيوزات الكبوت الرئيسية (E-Box SB)',
          locationType: FuseBoxLocationType.engineBay,
          detailedLocationArabic:
              'في حوض المحرك جهة اليسار (الراكب) بجانب علبة فلتر الهواء والبطارية.',
          accessInstructions:
              'اسحب المزلاجين الجانبيين للغطاء للخلف ثم ارفع الغطاء للأعلى.',
          slots: [
            FuseSlot(
              slotId: 'SB20',
              label: 'MECHATRONIC',
              nameArabic: 'فيوز كمبيوتر قير الدبل كلاتش (DSG Mechatronic)',
              ratingAmps: 30,
              descriptionArabic: 'يغذي وحدة الميكاترونيك لقير الـ DSG الأوتوماتيكي.',
              symptoms: [
                'ظهور علامة المفتاح الإنجليزي في شاشة القير ووميض مؤشر الغيارات',
                'القير يفصل ولا ينقل الحركة نهائياً',
              ],
              associatedDTCs: ['P17BF', 'P189C'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'SB24',
              label: 'ECU MAIN',
              nameArabic: 'فيوز كمبيوتر المحرك الرئيسي',
              ratingAmps: 20,
              descriptionArabic: 'التغذية الكهربائية الرئيسية لكمبيوتر إدارة المحرك.',
              symptoms: ['المحرك يدور دون تشغيل نهائياً'],
              associatedDTCs: ['P0685'],
              gridRow: 0,
              gridCol: 1,
            ),
          ],
        ),
        VehicleFuseBox(
          id: 'vw_cabin',
          nameArabic: 'علبة فيوزات المقصورة الداخلية (Fuse Carrier SC)',
          locationType: FuseBoxLocationType.cabin,
          detailedLocationArabic:
              'يسار المقود، خلف درج حفظ الأغراض الصغير القابل للإمالة.',
          accessInstructions:
              'افتح الدرج واضغط على ألسنة الإيقاف الجانبية لإنزاله للأسفل تماماً.',
          slots: [
            FuseSlot(
              slotId: 'SC40',
              label: '12V / OBD',
              nameArabic: 'فيوز مخرج الولاعة ومدخل الفحص التشخيصي OBD',
              ratingAmps: 20,
              descriptionArabic: 'يغذي فيشة OBD ومخرج 12V.',
              symptoms: ['جهاز الفحص لا يتعرف على سيارة الجولف'],
              associatedDTCs: ['U0100'],
              gridRow: 0,
              gridCol: 0,
            ),
          ],
        ),
      ],
    ),
    // =========================================================================
    // 14. Honda Civic (1996 - 2005) - EK / EJ / MB4 / ES
    // =========================================================================
    CarVehicleModel(
      id: 'honda_civic_1996_2005',
      make: 'Honda',
      makeArabic: 'هوندا',
      model: 'Civic',
      modelArabic: 'سيفيك (Civic EK / MB4 / ES)',
      yearRange: '1996 - 2005 (Civic Aero / Sedan / Hatchback D14/D15/D16/D17)',
      bodyType: 'سيدان / هاتشباك / أيرو ستيشن',
      obdLocation: 'تحت لوحة القيادة جهة السائق يسار الدومان (فيشة OBD-II 16-Pin)، أو فيشة زرقاء 2-Pin/3-Pin بجانب قدم الراكب الأمامي لموديلات ما قبل 2001.',
      fuseBoxes: [
        VehicleFuseBox(
          id: 'honda_civic_engine_bay',
          nameArabic: 'علبة فيوزات وراميات حجرة المحرك (تحت الكوفنو)',
          locationType: FuseBoxLocationType.engineBay,
          detailedLocationArabic: 'في الجانب الأيمن الخلفي من حجرة المحرك، بجانب البطارية.',
          accessInstructions: 'افتح كوفنو السيارة، اضغط على الكلبس الجانبي لغطاء علبة الفيوزات السوداء واسحب الغطاء لأعلى. ستجد خريطة الفيوزات وملاقط السحب مطبوعة على باطن الغطاء.',
          realisticCoverNote: 'مخطط علبة فيوزات هوندا سيفيك الأصلية بحجرة المحرك مع ريلي بومبة البنزين والمكيف والمراوح.',
          slots: [
            FuseSlot(
              slotId: 'F41',
              label: 'BATTERY',
              nameArabic: 'الفيوز الرئيسي للبطارية (Battery Main)',
              ratingAmps: 80,
              descriptionArabic: 'يغذي كامل المنظومة الكهربائية وعموم علب الفيوزات من البطارية مباشرة.',
              symptoms: ['انقطاع كامل للكهرباء في السيارة مع عدم إضاءة الطبلون'],
              associatedDTCs: ['U0100', 'P0562'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F42',
              label: 'IGN SWITCH',
              nameArabic: 'فيوز سويتش الكونتاك الرئيسي (Ignition Switch)',
              ratingAmps: 50,
              descriptionArabic: 'يغذي مفتاح التشغيل والكونتاك وبوكس المحرك.',
              symptoms: ['المحرك لا يلف نهائياً ولا يستجيب للمفتاح'],
              associatedDTCs: ['P0685', 'U0100'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F43',
              label: 'HEADLIGHT',
              nameArabic: 'فيوز الفنارات الرئيسية',
              ratingAmps: 40,
              descriptionArabic: 'يغذي الفنارات الأمامية العالي والواطي.',
              symptoms: ['انطفاء الفنارات الأمامية بالكامل'],
              associatedDTCs: [],
              gridRow: 0,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'F44',
              label: 'RAD FAN',
              nameArabic: 'فيوز وريليه مروحة الرداتوري (Cooling Fan)',
              ratingAmps: 20,
              descriptionArabic: 'يغذي مروحة تبريد الرداتوري الرئيسية.',
              symptoms: ['ارتفاع حرارة المحرك أثناء الوقوف أو في الزحام'],
              associatedDTCs: ['P0117', 'P0118'],
              gridRow: 1,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F45',
              label: 'CONDENSER',
              nameArabic: 'فيوز مروحة كوندنسر المكيف (AC Fan)',
              ratingAmps: 20,
              descriptionArabic: 'يغذي مروحة مكيف السيارة والكوندنسر.',
              symptoms: ['ضعف تبريد المكيف وارتفاع ضغط الغاز عند التوقف'],
              associatedDTCs: [],
              gridRow: 1,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F46',
              label: 'BACK UP',
              nameArabic: 'فيوز ذاكرة بوكس المحرك والراديو (Back Up Clock)',
              ratingAmps: 7,
              descriptionArabic: 'يحافظ على ذاكرة بوكس المحرك ECU وساعة الطبلون وإعدادات الراديو.',
              symptoms: ['تصفير ساعة الطبلون ومسح ذاكرة التعلم لبوكس المحرك عند إطفاء السويتش'],
              associatedDTCs: ['P1607', 'U0100'],
              gridRow: 1,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'F47',
              label: 'HORN / STOP',
              nameArabic: 'فيوز كلاكس ولمبات الستوب الخلفية',
              ratingAmps: 20,
              descriptionArabic: 'يغذي بوق التنبيه ولمبات الفرامل الخلفية.',
              symptoms: ['تعطل الفلاكس وعدم إضاءة لمبات الفرامل الخلفية'],
              associatedDTCs: [],
              gridRow: 2,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F48',
              label: 'ABS MTR',
              nameArabic: 'فيوز بومبة منظومة مانع الانغلاق ABS',
              ratingAmps: 30,
              descriptionArabic: 'يغذي موتور وبومبة صمام ABS.',
              symptoms: ['إضاءة لمبة ABS في الطبلون وتوقف المنظومة'],
              associatedDTCs: ['ABS-51', 'ABS-53', 'C0020'],
              gridRow: 2,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'R1',
              label: 'AC CLUTCH',
              nameArabic: 'ريليه كمبروسر المكيف (A/C Clutch Relay)',
              ratingAmps: 20,
              descriptionArabic: 'ريلي تشغيل كلتش كمبروسر مكيف الهواء.',
              symptoms: ['المكيف يخرج هواء ساخناً وعدم دوران كلتش الكمبروسر'],
              associatedDTCs: [],
              isRelay: true,
              gridRow: 3,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'R2',
              label: 'FAN RELAY',
              nameArabic: 'ريليه مروحة الرداتوري (Fan Relay)',
              ratingAmps: 30,
              descriptionArabic: 'ريلي تشغيل مروحة تبريد الرداتوري بأمر من حساس الحرارة وبوكس المحرك.',
              symptoms: ['غليان مية الرداتوري وارتفاع مؤشر الحرارة'],
              associatedDTCs: ['P0117', 'P0217'],
              isRelay: true,
              gridRow: 3,
              gridCol: 1,
            ),
          ],
        ),
        VehicleFuseBox(
          id: 'honda_civic_cabin',
          nameArabic: 'علبة فيوزات الصالون (تحت الستيرسو / الدومان)',
          locationType: FuseBoxLocationType.cabin,
          detailedLocationArabic: 'تحت الطبلون من جهة السائق، فوق مسند القدم اليسار وخلف غطاء التخزين الصغير.',
          accessInstructions: 'افتح باب السائق، انظر تحت الدومان جهة اليسار، انزع الغطاء البلاستيكي الصغير لتصل إلى صفوف الفيوزات المرقمة.',
          realisticCoverNote: 'لوحة فيوزات الصالون الأصلية لهوندا سيفيك متضمنة فيوز بوبينة الديلكو وفيوز الإيرباق وبومبة البنزين.',
          slots: [
            FuseSlot(
              slotId: 'F31',
              label: 'COIL / IGN',
              nameArabic: 'فيوز بوبينة الديلكو والإشعال (Ignition Coil)',
              ratingAmps: 15,
              descriptionArabic: 'يغذي بوبينة الإشعال وموزع الشرارة (الديلكو) وأسلاك البوجيهات في محركات هوندا D15/D16/D17.',
              symptoms: [
                'انقطاع الشرارة تماماً وتوقف المحرك عن الدوران',
                'فطفطة حادة في بسطونات المحرك وضعف سحب شديد',
                'إضاءة لمبة Check Engine مع أكواد P0300 - P0304',
              ],
              associatedDTCs: ['P0300', 'P0301', 'P0302', 'P0303', 'P0304', 'P1399'],
              testingTip: 'افحص وصول 12V بالسويتش على فيشة الديلكو/البوبينة.',
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F42',
              label: 'SRS AIRBAG',
              nameArabic: 'فيوز بوكس الوسائد الهوائية (SRS Unit)',
              ratingAmps: 10,
              descriptionArabic: 'يغذي وحدة التحكم الإلكترونية للوسائد الهوائية (كمبيوتر SRS) وشريط الدومان.',
              symptoms: [
                'إضاءة لمبة SRS الإيرباق حمراء بشكل دائم في الطبلون',
                'عدم استجابة بوكس الإيرباق لجهاز الفحص أو تسجيل كود انقطاع تغذية',
              ],
              associatedDTCs: ['SRS-07-02', 'SRS-09-02', 'B1801', 'B1811', 'B1155'],
              testingTip: 'تأكد من سلامة الفيوز قبل الحكم على تلف كمبيوتر الوسائد الهوائية.',
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F24',
              label: 'FUEL PUMP',
              nameArabic: 'فيوز بومبة البنزين والريلي الرئيسي (PGM-FI)',
              ratingAmps: 15,
              descriptionArabic: 'يغذي مضخة الوقود (بومبة البنزين) والريلي الرئيسي PGM-FI Main Relay ورشاشات الوقود.',
              symptoms: [
                'المحرك يدور بالمارش (الموتورينو) لكن لا يشتغل نهائياً',
                'عدم سماع صوت زنّة بومبة البنزين عند فتح السويتش',
                'انقطاع ضغط البنزين عن مسطرة الرشاشات',
              ],
              associatedDTCs: ['P0171', 'P0087', 'P0685', 'P1399'],
              testingTip: 'عند فتح السويتش يجب أن تسمع طقة الريلي الرئيسي تحت التابلوه مع اشتغال البومبة ثانيتين.',
              gridRow: 0,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'F13',
              label: 'STARTER SIG',
              nameArabic: 'فيوز إشارة الموتورينو وبوكس المحرك (Starter Signal)',
              ratingAmps: 7,
              descriptionArabic: 'يرسل إشارة بدء التشغيل لبوكس المحرك وموتورينو السلف.',
              symptoms: ['الموتورينو لا يعمل ولا يعطي أي صوت عند تدوير المفتاح'],
              associatedDTCs: ['P0615'],
              gridRow: 1,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F15',
              label: 'ALT / VSS',
              nameArabic: 'فيوز الدينمو وحساس السرعة (Alternator / Speed Sensor)',
              ratingAmps: 7,
              descriptionArabic: 'يغذي دارة شحن الدينمو وحساس سرعة السيارة VSS.',
              symptoms: [
                'تذبذب عداد السرعة في الطبلون أو توقفه عن العمل',
                'إضاءة لمبة البطارية والدينمو لا يشحن بطارية السيارة',
              ],
              associatedDTCs: ['P0500', 'P0501', 'P0562'],
              gridRow: 1,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F25',
              label: 'METER',
              nameArabic: 'فيوز لوحة العدادات ومؤشرات الطبلون (Meter)',
              ratingAmps: 7,
              descriptionArabic: 'يغذي مؤشرات السرعة والحرارة والبنزين وإنارات الطبلون التحذيرية.',
              symptoms: ['انطفاء كامل لمؤشرات لوحة العدادات'],
              associatedDTCs: ['U0155'],
              gridRow: 1,
              gridCol: 2,
            ),
            FuseSlot(
              slotId: 'F45',
              label: 'WIPER',
              nameArabic: 'فيوز محرك المساحات وبومبة المية',
              ratingAmps: 20,
              descriptionArabic: 'يغذي موتور مساحات الزجاج الأمامي ومضخة غسيل الزجاج.',
              symptoms: ['توقف مساحات الزجاج الأمامي تماماً عن العمل'],
              associatedDTCs: [],
              gridRow: 2,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F44',
              label: 'CIGAR',
              nameArabic: 'فيوز مخرج ولاعة السجائر والشاحن 12V',
              ratingAmps: 15,
              descriptionArabic: 'يغذي مخرج شاحن الهاتف والولاعة.',
              symptoms: ['مخرج الشاحن لا يعمل'],
              associatedDTCs: [],
              gridRow: 2,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'R3',
              label: 'PGM-FI RELAY',
              nameArabic: 'الريلي الرئيسي للبومبة وبوكس المحرك (Main Relay)',
              ratingAmps: 30,
              descriptionArabic: 'الريلي الرئيسي المشهور في سيارات هوندا (PGM-FI Main Relay)، يتحكم في تشغيل بومبة البنزين والرشاشات وبوكس المحرك.',
              symptoms: [
                'السيارة لا تشتغل خصوصاً عندما تكون ساخنة أو متوقفة تحت الشمس',
                'الموتورينو يلف بسرعة لكن المحرك لا يدور لعدم وصول البنزين',
              ],
              associatedDTCs: ['P0685', 'P0171'],
              isRelay: true,
              gridRow: 3,
              gridCol: 0,
            ),
          ],
        ),
      ],
    ),
    // =========================================================================
    // 15. Hyundai Santa Fe (2006 - 2012) - CM
    // =========================================================================
    CarVehicleModel(
      id: 'hyundai_santa_fe_cm',
      make: 'Hyundai',
      makeArabic: 'هيونداي',
      model: 'Santa Fe',
      modelArabic: 'سنتافي (Santa Fe CM)',
      yearRange: '2006 - 2012 (CM 2.7L / 3.3L / 3.5L)',
      bodyType: 'SUV / فورويل',
      obdLocation: 'تحت لوحة القيادة جهة السائق يسار الدومان، خلف غطاء الفيوزات الصغير.',
      fuseBoxes: [
        VehicleFuseBox(
          id: 'santa_fe_engine_bay',
          nameArabic: 'علبة فيوزات وراميات حجرة المحرك',
          locationType: FuseBoxLocationType.engineBay,
          detailedLocationArabic: 'في الجهة اليسرى لحجرة المحرك بجانب البطارية وفلتر الهواء.',
          accessInstructions: 'افتح كوفنو السيارة، اضغط على ألسنة الغطاء الأسود من الجانبين وارفع الغطاء.',
          slots: [
            FuseSlot(
              slotId: 'F_IGN',
              label: 'IGN COIL',
              nameArabic: 'فيوز بوبينات الإشعال ومسخنات حساسات الأكسجين',
              ratingAmps: 20,
              descriptionArabic: 'يغذي كويلات وبوبينات الإشعال الستة ومسخنات حساسات المرميطة O2 وحساس الكام والكرنك.',
              symptoms: ['فطفطة قوية في المحرك وإضاءة لمبة Check Engine'],
              associatedDTCs: ['P0300', 'P0301', 'P0302', 'P0351', 'P0135', 'P0030'],
              gridRow: 0,
              gridCol: 0,
            ),
            FuseSlot(
              slotId: 'F_EVAP',
              label: 'SENSOR 2',
              nameArabic: 'فيوز صمام بخر البنزين (Purge Valve) وحساسات المحرك',
              ratingAmps: 15,
              descriptionArabic: 'يغذي صمام التحكم في تصريف أبخرة الوقود (EVAP Purge Solenoid) وحساسات الفاب.',
              symptoms: ['تسجيل أكواد تسريب أبخرة البنزين P0440 / P0442 / P0455 وصعوبة تشغيل بعد التزويد بالوقود'],
              associatedDTCs: ['P0440', 'P0442', 'P0455', 'P0441'],
              gridRow: 0,
              gridCol: 1,
            ),
            FuseSlot(
              slotId: 'F_B_PUMP',
              label: 'F/PUMP',
              nameArabic: 'فيوز بومبة البنزين (Fuel Pump)',
              ratingAmps: 15,
              descriptionArabic: 'يغذي مضخة الوقود داخل خزان البنزين.',
              symptoms: ['المحرك لا يشتغل لعدم وصول الوقود'],
              associatedDTCs: ['P0087', 'P0171'],
              gridRow: 0,
              gridCol: 2,
            ),
          ],
        ),
      ],
    ),
  ];

  /// Search cars by query (Brand, Model, Year, Body type, Code like W204, E90, F30)
  static List<CarVehicleModel> searchCars(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return supportedCars;
    return supportedCars.where((car) {
      return car.make.toLowerCase().contains(clean) ||
          car.makeArabic.toLowerCase().contains(clean) ||
          car.model.toLowerCase().contains(clean) ||
          car.modelArabic.toLowerCase().contains(clean) ||
          car.yearRange.toLowerCase().contains(clean) ||
          car.bodyType.toLowerCase().contains(clean) ||
          car.id.toLowerCase().contains(clean) ||
          car.fuseBoxes.any((box) =>
              box.nameArabic.toLowerCase().contains(clean) ||
              box.detailedLocationArabic.toLowerCase().contains(clean));
    }).toList();
  }

  /// Get list of all distinct car manufacturers
  static List<String> getMakes() {
    final makes = supportedCars.map((c) => c.make).toSet().toList();
    makes.sort();
    return makes;
  }

  /// Get list of distinct car manufacturers with Arabic names
  static List<Map<String, String>> getMakesWithArabic() {
    final map = <String, String>{};
    for (final c in supportedCars) {
      map[c.make] = c.makeArabic;
    }
    return map.entries
        .map((e) => {'make': e.key, 'makeArabic': e.value})
        .toList();
  }

  /// Get models for a specific manufacturer
  static List<CarVehicleModel> getModelsForMake(String make) {
    if (make.isEmpty || make == 'الكل' || make.toLowerCase() == 'all') {
      return supportedCars;
    }
    return supportedCars
        .where((c) =>
            c.make.toLowerCase() == make.toLowerCase() ||
            c.makeArabic == make)
        .toList();
  }

  /// Find a car by its unique ID
  static CarVehicleModel? getCarById(String id) {
    try {
      return supportedCars.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Auto-match car by vehicle make and model string (e.g. from report or scan)
  static CarVehicleModel? matchCar({String? make, String? model, String? year}) {
    if (make == null || make.isEmpty) return supportedCars.first;
    final cleanMake = make.trim().toLowerCase();
    final cleanModel = (model ?? '').trim().toLowerCase();

    // 1. Try exact or substring make and model match
    for (final c in supportedCars) {
      final cMake = c.make.toLowerCase();
      final cModel = c.model.toLowerCase();
      final isMakeMatch = cMake.contains(cleanMake) ||
          cleanMake.contains(cMake) ||
          c.makeArabic.toLowerCase().contains(cleanMake);
      if (isMakeMatch) {
        if (cleanModel.isNotEmpty &&
            (cModel.contains(cleanModel) ||
                cleanModel.contains(cModel) ||
                c.modelArabic.toLowerCase().contains(cleanModel))) {
          return c;
        }
      }
    }

    // 2. Tokenized word match on model (e.g. Civic Aero -> Civic, Santa Fe -> Santa Fe)
    final modelTokens = cleanModel
        .split(RegExp(r'[^a-zA-Z0-9]+'))
        .where((w) => w.length >= 3)
        .toList();

    for (final c in supportedCars) {
      final cMake = c.make.toLowerCase();
      final cModel = c.model.toLowerCase();
      final isMakeMatch = cMake.contains(cleanMake) ||
          cleanMake.contains(cMake) ||
          c.makeArabic.toLowerCase().contains(cleanMake);
      if (isMakeMatch && modelTokens.isNotEmpty) {
        for (final token in modelTokens) {
          if (cModel.contains(token) ||
              c.id.contains(token) ||
              c.yearRange.toLowerCase().contains(token)) {
            return c;
          }
        }
      }
    }

    // 3. Fallback: match by make only
    for (final c in supportedCars) {
      if (c.make.toLowerCase().contains(cleanMake) ||
          cleanMake.contains(c.make.toLowerCase()) ||
          c.makeArabic.toLowerCase().contains(cleanMake)) {
        return c;
      }
    }

    return supportedCars.first;
  }

  /// Search fuses within a specific car or across all cars
  static List<FuseSlot> searchFuses({
    required CarVehicleModel car,
    String? boxId,
    String query = '',
    bool? relaysOnly,
    String? dtcCode,
    List<String>? dtcCodes,
  }) {
    final cleanQuery = query.trim().toLowerCase();
    final cleanDtc = (dtcCode ?? '').trim().toUpperCase();
    final cleanDtcSet = (dtcCodes ?? [])
        .map((d) => d.trim().toUpperCase())
        .where((d) => d.isNotEmpty)
        .toSet();

    final List<FuseSlot> results = [];
    final boxesToSearch = (boxId != null && boxId.isNotEmpty)
        ? car.fuseBoxes.where((b) => b.id == boxId)
        : car.fuseBoxes;

    for (final box in boxesToSearch) {
      for (final slot in box.slots) {
        if (relaysOnly != null) {
          if (relaysOnly && !slot.isRelay) continue;
          if (!relaysOnly && slot.isRelay) continue;
        }

        if (cleanDtc.isNotEmpty) {
          if (!slot.associatedDTCs.any((d) => d.toUpperCase().contains(cleanDtc))) {
            continue;
          }
        }

        if (cleanDtcSet.isNotEmpty) {
          if (!slot.associatedDTCs.any((d) => cleanDtcSet.any((c) => d.toUpperCase().contains(c) || c.contains(d.toUpperCase())))) {
            continue;
          }
        }

        if (cleanQuery.isNotEmpty) {
          final matchSlot = slot.slotId.toLowerCase().contains(cleanQuery);
          final matchLabel = slot.label.toLowerCase().contains(cleanQuery);
          final matchName = slot.nameArabic.toLowerCase().contains(cleanQuery);
          final matchDesc = slot.descriptionArabic.toLowerCase().contains(cleanQuery);
          final matchSymp = slot.symptoms.any((s) => s.toLowerCase().contains(cleanQuery));

          if (!matchSlot && !matchLabel && !matchName && !matchDesc && !matchSymp) {
            continue;
          }
        }

        results.add(slot);
      }
    }

    return results;
  }
}
