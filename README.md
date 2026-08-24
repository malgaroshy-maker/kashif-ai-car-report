# 🚗 كاشف الذكي (Kashif AI)
### المساعد الذكي لتحليل تقارير أجهزة فحص السيارات بالمصطلحات الليبية المعتمدة
#### Automotive OBD-II Diagnostic AI Engine with Dual Runtime: Google Gemini 3.7 Flash & Antigravity CLI (`agy`)

[![Next.js 15](https://img.shields.io/badge/Next.js-15.3-black.svg?style=flat&logo=next.js)](https://nextjs.org/)
[![Google Gemini](https://img.shields.io/badge/AI-Gemini%203.7%20Flash-4285F4.svg?style=flat&logo=google)](https://ai.google.dev/)
[![Antigravity CLI](https://img.shields.io/badge/Agent-Antigravity%20(agy)-8B5CF6.svg?style=flat)](https://antigravity.google/)
[![Cloudflare Pages](https://img.shields.io/badge/Deploy-Cloudflare%20Pages-F38020.svg?style=flat&logo=cloudflare)](https://pages.cloudflare.com/)

---

## 🌟 المميزات الرئيسية (Key Features)

1. **قاموس صيانة السيارات الليبي المعتمد (200+ مصطلح):**
   - مطابقة دقيقة لأكواد الأعطال (DTCs) مع مصطلحات الورش الحقيقية (شمعات، بوبينات، مزاطوري، بيانتو، علبة الفيوزات، براتشو، كونفيرتا).
2. **محرك الذكاء الاصطناعي المزدوج (Dual AI Runtime):**
   - 🌐 **Google Gemini Cloud API:** نموذج `gemini-3.7-flash` فائق الدقة مع نماذج احتياطية سريعة (`gemini-3.5-flash-lite`).
   - 💻 **Antigravity CLI (`agy` Local Engine):** تشغيل محلي مع وكيل Antigravity الذكي.
3. **مخطط الحساسات وعلبة الفيوزات والأفوميتر (Component & Fuse Locator):**
   - رسم هندسي ثنائي الأبعاد لحوض المحرك بنبض مضيء.
   - مخطط تفاعلي لعلبة الفيوزات والكتاوت لتجنب شراء قطع بديلة عند احتراق الفيوز.
   - دليل قياس الفولتية والبيانتو بالأفوميتر (12V, Ground, Signal, 5V Ref).
4. **دليل قطع الغيار والبحث الحي عن صور الإنترنت:**
   - محرك بحث متقدم لجلب صور القطع الحقيقية وأرقام الـ OEM والبدائل المعتمدة (Denso, Bosch, NGK).
5. **تصدير ومشاركة شاملة:**
   - تقرير مستقل (Standalone HTML) بدون أي اعتمادات خارجية للعمل دون إنترنت.
   - مشاركة الملخص عبر WhatsApp وطباعة A4 PDF بختم المركز المعتمد.
6. **مساعد الأسطى كاشف التفاعلي:**
   - شات ذكي يقدم نصائح ميكانيكية وتوجيهات عملية فورية.

---

## 🚀 التشغيل المحلي (Local Development)

### 1. المتطلبات (Prerequisites)
- **Node.js:** الإصدار 18 أو أحدث (موصى بـ Node.js 20+).
- **مفتاح Google Gemini API:** مجاني من [Google AI Studio](https://aistudio.google.com/app/apikey).
- *(اختياري)* **Antigravity CLI (`agy`):** لتشغيل المحرك المحلي.

### 2. التثبيت والتشغيل (Installation & Setup)

```bash
# استنساخ المستودع
git clone https://github.com/masalhe/kashif-ai-car-report.git
cd kashif-ai-car-report

# تثبيت الحزم
npm install

# إعداد ملف البيئة
cp .env.example .env.local
# قم بإضافة مفتاحك: GEMINI_API_KEY=AIzaSy...

# تشغيل خادم التطوير
npm run dev
```

افتح [http://localhost:3000](http://localhost:3000) في المتصفح.

---

## ☁️ النشر على Cloudflare Pages (Cloudflare Deployment)

المشروع مهيأ بالكامل للنشر التلقائي عبر **GitHub Actions** و **Cloudflare Pages**:

1. اربط المستودع في لوحة تحكم [Cloudflare Pages](https://dash.cloudflare.com/).
2. أضف متغيرات البيئة في إعدادات Cloudflare Pages:
   - `GEMINI_API_KEY`: مفتاح Google Gemini الخاص بك.
   - `GEMINI_MODEL`: `gemini-3.7-flash`
   - `NEXT_PUBLIC_APP_NAME`: `Kashif AI - كاشف الذكي`
3. سيتم البناء والنشر التلقائي عند كل `git push` إلى الفرع `main`.

---

## 📁 هيكلية المشروع (Project Architecture)

```text
├── src/
│   ├── app/
│   │   ├── api/
│   │   │   ├── analyze/     # مسار تحليل ملفات PDF والصور والرموز
│   │   │   ├── chat/        # مسار مساعد الأسطى كاشف
│   │   │   ├── models/      # مسار فحص النماذج وحالة AGY CLI
│   │   │   └── parts-image/ # محرك البحث الحي عن صور القطع
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── components/
│   │   ├── Header.tsx                 # الشريط العلوي ومبدل المحرك والقواميس
│   │   ├── UploadDropzone.tsx         # منطقة رفع الملفات والإدخال اليدوي
│   │   ├── VehicleHealthCard.tsx      # بطاقة صحة المركبة والـ Gauge
│   │   ├── FaultPriorityMatrix.tsx    # مصفوفة تصنيف الأعطال
│   │   ├── FaultCodeCard.tsx          # بطاقة تفاصيل الكود الهندسي
│   │   ├── SensorFuseLocatorModal.tsx # مخطط الحساس والفيوز والأفوميتر
│   │   ├── SparePartsSection.tsx      # دليل قطع الغيار والصور
│   │   ├── DiagnosticChecklist.tsx    # قائمة مهام الورشة
│   │   ├── MechanicChatAssistant.tsx  # شات الأسطى كاشف
│   │   └── ExportActionBar.tsx        # أدوات التصدير والتقرير المستقل
│   └── lib/
│       ├── antigravity-cli.ts # وحدة الاتصال بمحرك Antigravity CLI
│       ├── dictionary.ts      # القاموس الفني الليبي المعتمد
│       ├── gemini.ts          # محرك Google Gemini 3.7 Flash
│       ├── parts-search.ts    # محرك جلب صور قطع الغيار من الإنترنت
│       ├── sensor-locator.ts  # قاعدة بيانات مواقع الحساسات والفيوزات
│       └── types.ts           # هياكل البيانات و TypeScript Types
├── .github/workflows/deploy-cloudflare.yml # سير عمل النشر التلقائي
├── wrangler.jsonc                         # إعدادات Cloudflare
├── PRD_KASHIF_AI.md                       # وثيقة متطلبات المنتج الكاملة
└── ROADMAP.md                             # خارطة طريق المشروع
```

---

## 📜 الترخيص (License)
هذا المشروع مرخص تحت رخصة **MIT License**.
