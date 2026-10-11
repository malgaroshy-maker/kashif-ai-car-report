# 📚 التوثيق الهندسي والتشغيلي لتطبيق كاشف موبايل (Kashif Mobile Documentation Index)

مرحباً بك في المركز التوثيقي الشامل لتطبيق **Flow Cars — كاشف للهواتف الذكية (Kashif Mobile)**. تم بناء التطبيق بأحدث تقنيات Flutter لخدمة ورش صيانة السيارات وفنيي التشخيص ومشتري السيارات المستعملة في ليبيا والعالم العربي.

---

## 🗺️ خريطة الأدلة التوثيقية (Documentation Map)

| الدليل | الملف | الوصف والجمهور المستهدف |
| :--- | :--- | :--- |
| 🚀 **دليل الأسطى السريع** | [WORKSHOP_QUICK_START.md](file:///d:/projects/car%20report/kashif_mobile/docs/WORKSHOP_QUICK_START.md) | دليل عملي مبسط لفني الورشة والأسطى: الفحص بالكاميرا، مراجعة الأعطال، استخراج أرقام القطع، ومشاركة التقرير مع الزبون عبر واتساب و QR. |
| 🏗️ **المعمارية البرمجية** | [ARCHITECTURE.md](file:///d:/projects/car%20report/kashif_mobile/docs/ARCHITECTURE.md) | التصميم الهندسي الكامل: هيكل الطبقات، إدارة الحالة (Riverpod)، التخزين المحلي (Hive NoSQL)، تكامل بوابات الذكاء الاصطناعي، ومحرك توليد الـ PDF. |
| ⚙️ **محرك أرقام قطع الغيار الشامل** | [PART_NUMBER_RESOLVER.md](file:///d:/projects/car%20report/kashif_mobile/docs/PART_NUMBER_RESOLVER.md) | شرح الخوارزمية العامة لتوليد أرقام قطع الغيار الأصلية (OEM) لجميع صانعي السيارات (Toyota, Hyundai, BMW, Mercedes...) وروابط الكتالوجات العالمية. |
| 📱 **دليل البناء والنشر وأجهزة Poco** | [BUILD_AND_DEPLOYMENT.md](file:///d:/projects/car%20report/kashif_mobile/docs/BUILD_AND_DEPLOYMENT.md) | خطوات بناء ملف الـ APK، حل مشكلة الشاشة السوداء في HyperOS / Impeller، إعدادات المعمارية 64-bit، والتثبيت المباشر عبر ADB. |
| 🇱🇾 **محرك اللهجة الليبية والتشغيل غير المتصل** | [LIBYAN_TERMS_AND_OFFLINE_ENGINE.md](file:///d:/projects/car%20report/kashif_mobile/docs/LIBYAN_TERMS_AND_OFFLINE_ENGINE.md) | محرك `ReportSanitizer`، قاموس ورش ليبيا (112+ مصطلح)، فك تشفير تقارير الفحص (Ediag/Launch ZLib)، والتشغيل 100% بدون إنترنت. |

---

## 📌 نبذة سريعة عن المنظومة

- **اللغة والمنصة الأساسية:** Dart 3.13+ / Flutter 3.47+ (Material 3).
- **التخزين المحلي:** Hive NoSQL مع استرداد تلقائي عند تلف الملفات (`Safe Box Recovery`).
- **بوابات الذكاء الاصطناعي:**
  - بوابة APInex المجانية السريعة (`api.apinex.bond`) المتوافقة مع نماذج Gemini 2.5 Flash و DeepSeek و GPT-4o-mini.
  - تكامل مباشر مع Google Gemini SDK (`gemini-2.5-flash`).
  - سيرفر كاشف السحابي الافتراضي عبر Cloudflare Workers.
- **التوافق العتادي:** تم تحسين وضبط الأداء والتوافق خصيصاً لمعالجات MediaTek Dimensity (مثل Dimensity 8400-Ultra في هاتف Poco X7 Pro) وأنظمة Xiaomi HyperOS لتفادي أي تعليق أو شاشة سوداء.

---

## 🔗 الروابط السريعة
- [المستودع الرئيسي للمشروع (Root Repository)](file:///d:/projects/car%20report/README.md)
- [دليل تطبيق الهاتف في جذر المشروع](file:///d:/projects/car%20report/%D8%AA%D8%B7%D8%A8%D9%8A%D9%82%20%D8%A7%D9%84%D8%A8%D8%B1%D9%86%D8%A7%D9%85%D8%AC%20%D8%B9%D9%84%D9%8A%20%D8%A7%D9%84%D9%87%D8%A7%D8%AA%D9%81.md)
- [قاموس مصطلحات السيارات الليبية](file:///d:/projects/car%20report/%D9%82%D8%A7%D9%85%D9%88%D8%B3_%D9%85%D8%B5%D8%B7%D9%84%D8%AD%D8%A7%D8%AA_%D8%B5%D9%8A%D8%A7%D9%86%D8%A9_%D8%A7%D9%84%D8%B3%D9%8A%D8%A7%D8%B1%D8%A7%D8%AA_%D8%A7%D9%84%D9%84%D9%8A%D8%A8%D9%8A%D8%A9.md)
