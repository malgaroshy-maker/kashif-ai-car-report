# 📱 دليل بناء ونشر التطبيق وأجهزة Poco X7 Pro (Build & Deployment Guide)

يوثق هذا الدليل المتطلبات والخطوات الهندسية اللازمة لترجمة وبناء حزمة الـ Android APK لتطبيق **كاشف موبايل (Kashif Mobile)**، مع تفصيل كامل للحلول التي تم تطبيقها لحل مشكلة الشاشة السوداء وضمان التوافق المطلق مع أجهزة **Poco X7 Pro** ونظام **Xiaomi HyperOS**.

---

## 🛠️ المتطلبات الأساسية للبيئة (Prerequisites)

- **Flutter SDK**: الإصدار 3.47.6 أو أحدث.
- **Dart SDK**: الإصدار 3.13.0 أو أحدث.
- **Java Development Kit (JDK)**: JDK 17 (الموصى به لـ Gradle 8.x).
- **Android SDK**: منصات Android API 34 أو API 35 مع أدوات البناء `build-tools` الحديثة.
- **معمارية المعالج المستهدفة**: ARM64-v8a (64-bit).

---

## 🛑 حل مشكلة الشاشة السوداء على هواتف Poco و HyperOS

### 1. السبب الجذري الأول: تعارض محرك Impeller مع معالجات MediaTek Dimensity
- **المشكلة:** بدءاً من إصدارات Flutter الحديثة، يتم تفعيل محرك الرندرة الجديد **Impeller (Vulkan)** بشكل افتراضي على معمارية 64-bit. في هواتف **Poco X7 Pro** المزودة بمعالج **MediaTek Dimensity 8400-Ultra** ووحدة رسوميات Mali، يعاني تعريف الـ Vulkan الخاص بنظام HyperOS من خلل في إدارة قنوات العرض (Vulkan Swapchain)، مما يجعل خادم العرض `SurfaceFlinger` يعجز عن استلام أي إطارات رسومية، فيتجمد التطبيق على شاشة سوداء صامتة دون أي خطأ ظاهر في الكونسول.
- **الحل الجذري:** تم إلزام التطبيق بالعمل عبر محرك **Skia / OpenGL ES** عالي الاستقرار والمجرب على ملايين الأجهزة عبر إضافة الإعداد التالي في ملف [AndroidManifest.xml](file:///d:/projects/car%20report/kashif_mobile/android/app/src/main/AndroidManifest.xml):
  ```xml
  <meta-data
      android:name="io.flutter.embedding.android.EnableImpeller"
      android:value="false" />
  ```

### 2. السبب الجذري الثاني: انهيار تهيئة قواعد بيانات Hive القديمة
- **المشكلة:** عند تثبيت تحديث أو إعادة بناء التطبيق، يحتفظ أندرويد في المسار `/data/data/...` بصناديق Hive السابقة. في حال تغير نوع الصندوق أو حدث إغلاق قسري قديم، كانت الدالة `Hive.openBox` ترمي استثناءً غير معالج يوقف تنفيذ الدالة `main()` قبل الوصول إلى استدعاء `runApp()`.
- **الحل:** تم تطبيق نظام فتح واسترداد آمن (`_safeOpenBox`) في [hive_storage.dart](file:///d:/projects/car%20report/kashif_mobile/lib/data/storage/hive_storage.dart) يقوم باكتشاف أي تلف وإعادة ضبط الصندوق تلقائياً ومواصلة الإقلاع بسلاسة، مع تغليف التهيئة داخل `try-catch` في `main.dart`.

### 3. السبب الجذري الثالث: خلفية الإقلاع المعتمة
- **المشكلة:** كانت ثيمات أندرويد الأصلية (`LaunchTheme` في الوضع الليلي) تستخدم خلفية سوداء نقية `#000000` بدون أي شعار أثناء تجهيز المحرك.
- **الحل:** تم إدراج لون هوية كاشف الليلية الكحلي الفاخر (`#070E1E`) وشعار التطبيق المتمركز (`@mipmap/ic_launcher`) في [styles.xml](file:///d:/projects/car%20report/kashif_mobile/android/app/src/main/res/values/styles.xml) و [launch_background.xml](file:///d:/projects/car%20report/kashif_mobile/android/app/src/main/res/drawable/launch_background.xml) ليظهر شعار كاشف فور لمس الأيقونة.

---

## ⚡ سكريبتات البناء الآلية السريعة (Automated Build Scripts)

تم تزويد المشروع بسكريبتات دفعية ذكية تنفذ خطوات البناء وتتحقق من بيئة العمل تلقائياً:

### 1. البناء السريع المخصص لهاتف Poco X7 Pro (مُوصى به)
```cmd
# من مجلد kashif_mobile:
build_poco_apk.bat --arm64
```
أو من المجلد الرئيسي للمشروع عبر السكريبت العربي:
```cmd
بناء_تطبيق_بوكو_Poco_X7_Pro.bat
```
- يقوم ببناء حزمة مخصصة لمعمارية **ARM64-v8a** فائقة الخفة (~24 ميجابايت) ومتوافقة بنسبة 100% مع معالجات Dimensity و Snapdragon الحديثة.
- ينسخ ملف الـ APK النهائي تلقائياً إلى:
  ```text
  d:\projects\car report\APK_OUTPUT\kashif_poco_x7_pro.apk
  ```

### 2. بناء حزمة شاملة لجميع الأجهزة (Universal APK)
```cmd
build_poco_apk.bat --universal
```
- تتضمن كافة المعماريات (`arm64-v8a`, `armeabi-v7a`, `x86_64`) لتعمل على أي هاتف أندرويد قديم أو حديث.

### 3. التثبيت المباشر عبر كابل USB وأداة ADB
```cmd
build_poco_apk.bat --install
```
أو من جذر المشروع:
```cmd
تثبيت_التطبيق_على_الهاتف.bat
```

---

## 📲 خطوات التثبيت على هواتف Poco / Xiaomi (HyperOS)

1. **تفعيل خيارات المطور (Developer Options):**
   - افتح **الإعدادات (Settings)** -> **حول الهاتف (About Phone)**.
   - اضغط على **إصدار OS (OS Version)** 7 مرات متتالية حتى تظهر رسالة "أنت الآن مطور برامج".
2. **تفعيل تصحيح الأخطاء (USB Debugging):**
   - اذهب إلى **الإعدادات الإضافية (Additional Settings)** -> **خيارات المطور (Developer Options)**.
   - فعّل خيار **تصحيح أخطاء USB (USB Debugging)**.
   - فعّل خيار **التثبيت عبر USB (Install via USB)** في حال رغبت في استخدام التثبيت السريع عبر الحاسوب.
3. **تثبيت ملف الـ APK:**
   - انقل ملف `kashif_poco_x7_pro.apk` إلى الهاتف.
   - افتح تطبيق **مدير الملفات (File Manager)** واضغط على ملف الـ APK.
   - وافق على شاشة التحذير الخاصة بالمصادر غير المعروفة بالضغط على "أنا على علم بالمخاطر" ثم "موافق".

---

## 🧪 التحقق والاختبار قبل التوزيع (Pre-Release Checklist)

قبل تصدير أي نسخة رسمية جديدة، ينبغي تشغيل فحص الجودة التالي:

```cmd
cd kashif_mobile

# 1. التحليل الساكن ومراجعة الأكواد
flutter analyze

# 2. تشغيل حزمة الاختبارات الشاملة (49 اختباراً)
flutter test
```
يجب أن ينتهي الفحص بنتيجة: `No issues found!` و `All tests passed!`.
