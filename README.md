# 🚗 كاشف الذكي (Kashif AI)
### المساعد الذكي لتحليل تقارير أجهزة فحص السيارات بالمصطلحات الليبية المعتمدة
#### Automotive OBD-II Diagnostic AI Engine with Dual Runtime: Google Gemini 3.7 Flash & Antigravity CLI (`agy`)

[![Live Demo](https://img.shields.io/badge/Live-kashif.malgaroshy.workers.dev-10B981.svg?style=flat&logo=cloudflare)](https://kashif.malgaroshy.workers.dev)
[![GitHub Repo](https://img.shields.io/badge/GitHub-malgaroshy--maker%2Fkashif--ai--car--report-black.svg?style=flat&logo=github)](https://github.com/malgaroshy-maker/kashif-ai-car-report)
[![Next.js 15](https://img.shields.io/badge/Next.js-15.3-black.svg?style=flat&logo=next.js)](https://nextjs.org/)
[![Google Gemini](https://img.shields.io/badge/AI-Gemini%203.7%20Flash-4285F4.svg?style=flat&logo=google)](https://ai.google.dev/)
[![Antigravity CLI](https://img.shields.io/badge/Agent-Antigravity%20(agy)-8B5CF6.svg?style=flat)](https://antigravity.google/)
[![Cloudflare Workers](https://img.shields.io/badge/Deploy-Cloudflare%20Workers-F38020.svg?style=flat&logo=cloudflare)](https://kashif.malgaroshy.workers.dev)

---

## 🌐 الرابط المباشر للإنتاج (Live Production App)
👉 **[https://kashif.malgaroshy.workers.dev](https://kashif.malgaroshy.workers.dev)**

---

## 🌟 المميزات الرئيسية (Key Features)

1. **قاموس صيانة السيارات الليبي المعتمد (200+ مصطلح):**
   - مطابقة دقيقة لأكواد الأعطال (DTCs) مع مصطلحات الورش الحقيقية: **شمعات** (بدون ذكر للبواجي)، **علبة الفيوزات** (بدون سكاتلة)، بوبينات، مزاطوري، بيانتو، براتشو، كونفيرتا، قرسيوني كوبيركو، ستاقوبا، باطنيات.
2. **محرك الذكاء الاصطناعي المزدوج (Dual AI Engine):**
   - 🌐 **Google Gemini Cloud API:** نموذج `gemini-3.7-flash` فائق الدقة مع نماذج احتياطية سريعة ودالة إصلاح تلقائي لنصوص الـ JSON.
   - 💻 **Antigravity CLI (`agy` Local Engine):** تشغيل محلي فائق السرعة عبر سطر الأوامر لأجهزة الورش.
3. **مخطط الحساسات وعلبة الفيوزات والأفوميتر (Component & Fuse Locator):**
   - رسم بياني تفاعلي ثنائي الأبعاد لموقع الحساس في حوض المحرك.
   - مخطط تفصيلي لرقم وقوة ولون ومكان **الفيوز** المخصص في علبة الفيوزات لمنع استبدال قطع سليمة.
   - إرشادات الفحص العملي بالفولتية والمقاومة عبر جهاز الملتيميتر (Pinout & Multimeter Test).
4. **محرك بحث حي متعدد الطبقات لصور قطع الغيار:**
   - معمارية بحث ثلاثية الطبقات (`DuckDuckGo` ➔ `Wikimedia Commons` ➔ `Curated Registry`).
   - تجاوز حظر الـ Hotlinking عبر خاصية `referrerPolicy="no-referrer"` مع إلزام روابط الـ `https://` المشفرة.
   - رسومات متجهة SVG عالية الدقة للعمل دون اتصال بالإنترنت مع تبديل تلقائي فوري.
5. **أدوات التصدير والمشاركة المعتمدة:**
   - تقرير مستقل (Standalone HTML) مدمج بالكامل مع خريطة الأعطال وختم الفحص وتوقيع الفاحص.
   - مشاركة الملخص بنقرة واحدة عبر WhatsApp والطباعة المباشرة لـ PDF بقياس A4.
6. **مساعد الأسطى كاشف التفاعلي (AI Mechanic Chat):**
   - شات ذكي يقدم نصائح ميكانيكية وخطوات فحص عملية باللهجة الليبية الفنية.

---

## 🚀 التشغيل المحلي (Local Development)

### 1. المتطلبات (Prerequisites)
- **Node.js:** الإصدار 18 أو أحدث (موصى بـ Node.js 20+).
- **مفتاح Google Gemini API:** مجاني من [Google AI Studio](https://aistudio.google.com/app/apikey).
- *(اختياري)* **Antigravity CLI (`agy`):** لتشغيل المحرك المحلي.

### 2. التثبيت والتشغيل (Installation & Setup)

```bash
# استنساخ المستودع
git clone https://github.com/malgaroshy-maker/kashif-ai-car-report.git
cd kashif-ai-car-report

# تثبيت الحزم
npm install

# إعداد ملف البيئة
cp .env.example .env.local
# أضف مفتاحك: GEMINI_API_KEY=AIzaSy...

# تشغيل خادم التطوير
npm run dev
```

افتح [http://localhost:3000](http://localhost:3000) في المتصفح.

---

## ☁️ النشر على Cloudflare Workers (Cloudflare Deployment)

المشروع مهيأ ومربوط بالكامل للنشر التلقائي عبر **Cloudflare Workers Assets** و **GitHub Actions**:

1. **معالج الحافة الطرفي ([src/worker.ts](file:///d:/projects/car%20report/src/worker.ts)):**
   - يتولى معالجة مسارات الـ API (`/api/analyze`, `/api/chat`, `/api/models`, `/api/parts-image`) مباشرة على خوادم Cloudflare Edge.
2. **سكربت تجهيز الأصول ([scripts/prepare-cloudflare.js](file:///d:/projects/car%20report/scripts/prepare-cloudflare.js)):**
   - يقوم تلقائياً بإنشاء روابط الـ HTML وملفات التنسيق `_next/static` في جذر حزمة النشر.
3. **ملف الإعدادات ([wrangler.jsonc](file:///d:/projects/car%20report/wrangler.jsonc)):**
   - يربط معالج الـ Worker مع مجلد الأصول الثابتة `.next` وقواعد الـ SPA Routing.

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
│   ├── lib/
│   │   ├── antigravity-cli.ts # وحدة الاتصال بمحرك Antigravity CLI
│   │   ├── dictionary.ts      # القاموس الفني الليبي المعتمد (200+ مصطلح)
│   │   ├── gemini.ts          # محرك Google Gemini 3.7 Flash مع الإصلاح الذاتي
│   │   ├── part-visuals.ts    # رسومات الـ SVG الهندسية لقطع الغيار
│   │   ├── parts-search.ts    # محرك جلب صور قطع الغيار متعدد الطبقات
│   │   ├── sample-data.ts     # نماذج الفحص الجاهزة (BMW E39 / Corolla)
│   │   ├── sensor-locator.ts  # قاعدة بيانات مواقع الحساسات والفيوزات
│   │   └── types.ts           # هياكل البيانات و TypeScript Types
│   └── worker.ts              # معالج Cloudflare Worker Edge
├── scripts/
│   └── prepare-cloudflare.js  # سكربت تجهيز مخرجات Cloudflare تلقائياً
├── .github/workflows/
│   └── deploy-cloudflare.yml  # سير عمل النشر التلقائي عبر GitHub Actions
├── wrangler.jsonc             # إعدادات Cloudflare Workers & Assets
├── PRD_KASHIF_AI.md           # وثيقة متطلبات المنتج الكاملة
└── ROADMAP.md                 # خارطة طريق وتوثيق المشروع
```

---

## 📜 الترخيص (License)
هذا المشروع مرخص تحت رخصة **MIT License**.
