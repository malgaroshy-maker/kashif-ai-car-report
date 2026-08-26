# 🚗 كاشف الذكي (Kashif AI)
### المساعد الذكي لتحليل تقارير أجهزة فحص السيارات بالمصطلحات الليبية المعتمدة
#### Automotive OBD-II Diagnostic AI Engine — Google Gemini 3.7 Flash (bring your own key)

[![Live Demo](https://img.shields.io/badge/Live-kashif.malgaroshy.workers.dev-10B981.svg?style=flat&logo=cloudflare)](https://kashif.malgaroshy.workers.dev)
[![GitHub Repo](https://img.shields.io/badge/GitHub-malgaroshy--maker%2Fkashif--ai--car--report-black.svg?style=flat&logo=github)](https://github.com/malgaroshy-maker/kashif-ai-car-report)
[![Next.js 16](https://img.shields.io/badge/Next.js-16.3-black.svg?style=flat&logo=next.js)](https://nextjs.org/)
[![Google Gemini](https://img.shields.io/badge/AI-Gemini%203.7%20Flash-4285F4.svg?style=flat&logo=google)](https://ai.google.dev/)
[![Cloudflare Workers](https://img.shields.io/badge/Deploy-Cloudflare%20Workers-F38020.svg?style=flat&logo=cloudflare)](https://kashif.malgaroshy.workers.dev)
[![Design system](https://img.shields.io/badge/Design-The%20Fuse--Box%20Lid-2e7fc4.svg?style=flat)](DESIGN.md)

---

## 🌐 الرابط المباشر للإنتاج (Live Production App)
👉 **[https://kashif.malgaroshy.workers.dev](https://kashif.malgaroshy.workers.dev)**

---

## 🌟 المميزات الرئيسية (Key Features)

1. **قاموس صيانة السيارات الليبي المعتمد (200+ مصطلح):**
   - مطابقة دقيقة لأكواد الأعطال (DTCs) مع مصطلحات الورش الحقيقية: **شمعات** (بدون ذكر للبواجي)، **علبة الفيوزات** (بدون سكاتلة)، بوبينات، مزاطوري، بيانتو، براتشو، كونفيرتا، قرسيوني كوبيركو، ستاقوبا، باطنيات.
2. **محرك التحليل (Google Gemini):**
   - 🌐 نموذج `gemini-3.7-flash` مع سلسلة نماذج احتياطية عند الضغط أو تجاوز الحصة.
   - 🔑 **مفتاحك أنت:** التطبيق ما يشحنش مفتاح مشترك — كل مستخدم يحط مفتاح Google AI Studio حقّه في الإعدادات، ويتخزّن في متصفحه فقط.
   - 💻 محرك **Antigravity CLI (`agy`)** المحلي متاح في بيئة التطوير فقط.
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

### الأوامر

| الأمر | يسوي شنو |
|---|---|
| `npm run dev` | خادم التطوير |
| `npm test` | اختبارات الوحدة (Vitest) — 43 اختبار |
| `npm run test:e2e` | اختبارات الطرف للطرف (Playwright) على الـ Worker المبني — 28 اختبار |
| `npm run lint` | ESLint — صفر أخطاء مطلوبة |
| `npm run cf:build` | بناء حزمة Cloudflare |
| `npm run cf:preview` | تشغيل الحزمة محلياً على وقت تشغيل Workers الحقيقي |
| `npm run og` | إعادة توليد `public/og.png` من `og.svg` بعد أي تعديل على الشعار |

**اختبارات الطرف للطرف تبني وتشغّل الـ Worker الحقيقي، مش `next dev`.** كل خلل
انكشف عند حدود النشر في هذا المشروع كان مخفي في بيئة التطوير وواضح في
`cf:preview`.

⚠️ لو البناء علق بخطأ `EPERM` على مجلد `.open-next`، السبب غالباً خادم
`next dev` شغّال في الخلفية: `initOpenNextCloudflareForDev` يشغّل عملية
`workerd` تمسك المجلد. اقتل عملية `next dev` نفسها — الـ `workerd` يرجع لو
قتلته وحده.

---

## ☁️ النشر على Cloudflare Workers (Cloudflare Deployment)

المشروع ينشر عبر المحوّل الرسمي **[@opennextjs/cloudflare](https://opennext.js.org/cloudflare)**، وهو يشغّل تطبيق Next.js كامل على Cloudflare Workers — نفس مسارات الـ API في `src/app/api/*`، بدون نسخة ثانية منها.

```bash
# بناء حزمة Cloudflare
npm run cf:build

# تجربتها محلياً على وقت تشغيل Workers الحقيقي
npm run cf:preview

# النشر
npm run cf:deploy
```

**الإعدادات:**

| الملف | الدور |
|---|---|
| `wrangler.jsonc` | اسم الـ Worker، ومجلد الأصول `.open-next/assets` فقط |
| `open-next.config.ts` | إعدادات المحوّل (بدون تخزين مؤقت — التطبيق ما يحتاجش ISR) |
| `.dev.vars` | متغيرات محلية (انسخ من `.dev.vars.example`) |
| `.github/workflows/deploy-cloudflare.yml` | فحص فقط (نوع، lint، اختبارات، بناء، e2e). **ما ينشرش.** |

**المفتاح على الخادم (اختياري):** التطبيق مبني على مبدأ "مفتاحك أنت"، لكن لو حبيت تحط مفتاحاً على الـ Worker:

```bash
npx wrangler secret put GEMINI_API_KEY
```

لا تضعه أبداً في `wrangler.jsonc` — الملف مرفوع على Git بنص واضح.

### مين اللي ينشر فعلياً

**Cloudflare Workers Builds**، مربوط بالمستودع من لوحة تحكم Cloudflare مباشرة — مش GitHub Actions. سير عمل GitHub يفحص فقط ويقف، لأن نظامين ينشرو نفس الـ Worker يعني سباق.

⚠️ **إعدادات البناء موجودة في لوحة تحكم Cloudflare، مش في هذا المستودع** — ولهذا بالضبط انحرفت عن الكود بدون ما ينتبه حد. القيم الصحيحة:

`Workers & Pages → kashif → Settings → Build`

| الحقل | القيمة الصحيحة |
|---|---|
| Build command | `npm run cf:build` |
| Deploy command | `npx opennextjs-cloudflare deploy` |
| Version command | `npx opennextjs-cloudflare upload` |
| Root directory | `/` |
| Production branch | `main` |

🚨 **لا تضيف `--assets=.next` أبداً.** هذا الخيار ينشر مجلد البناء كامل كملفات عامة — بما فيه `.next/server/**` وتعليمات النظام اللي جواه — ويتجاوز `assets.directory` المضبوط في `wrangler.jsonc`، لأن خيار سطر الأوامر يغلب ملف الإعدادات. مجلد الأصول الصحيح معرّف في `wrangler.jsonc` وما يحتاجش خيار.

**تحذير مهم:** لو صلّحت `Build command` وحده وخلّيت `--assets=.next` في أمر النشر، البناء بينجح **والتسريب يرجع**. غيّر الثلاثة مع بعض.

---

## 📁 هيكلية المشروع (Project Architecture)

```text
├── src/
│   ├── app/
│   │   ├── api/
│   │   │   ├── analyze/     # مسار تحليل ملفات PDF والصور والرموز
│   │   │   ├── chat/        # مسار مساعد الأسطى كاشف
│   │   │   ├── models/      # قائمة النماذج المتاحة
│   │   │   └── parts-image/ # محرك البحث الحي عن صور القطع
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── components/
│   │   ├── ui/                # أوليّات نظام التصميم (لوحة الفيوزات)
│   │   │   ├── primitives.tsx     # Cell / CodePlate / BankRule / Field / Button
│   │   │   ├── SeverityMark.tsx   # أشكال الخطورة المرسومة والفيوز في مقعده
│   │   │   ├── Sheet.tsx          # اللوحة المنزلقة (حصر التركيز، Escape)
│   │   │   └── ThemeToggle.tsx    # مبدّل الوضع النهاري/الليلي
│   │   └── report/            # شاشات التقرير
│   │       ├── Masthead.tsx       # لوحة الاسم العلوية
│   │       ├── Intake.tsx         # اللوحة الفارغة: رفع، أكواد يدوية، نماذج
│   │       ├── VehiclePlate.tsx   # لوحة المركبة ومؤشر الجاهزية
│   │       ├── FaultBoard.tsx     # بنوك الأعطال مرتّبة بالخطورة
│   │       ├── FaultCell.tsx      # خلية عطل واحد
│   │       ├── WiringSheet.tsx    # الفيوز والفيشة وقياس الأفوميتر
│   │       ├── Checklist.tsx      # ترتيب الفحص قبل الشراء
│   │       ├── PartsBank.tsx      # قطع الغيار وأرقام الوكالة
│   │       ├── ReportActions.tsx  # تنزيل / طباعة / واتساب
│   │       ├── HistoryBank.tsx    # الفحوصات المحفوظة على الجهاز
│   │       ├── SettingsPanel.tsx  # المفتاح والنموذج
│   │       ├── DictionaryPanel.tsx# قاموس الورشة
│   │       └── AssistantPanel.tsx # اسأل عن التقرير
│   ├── lib/
│   │   ├── design/severity.ts # مرجع الخطورة الوحيد (ألوان الفيوزات وأشكالها)
│   │   ├── api-client.ts      # جانب المتصفح من الـ API (مهلات، إلغاء)
│   │   ├── local-store.ts     # قراءة localStorage أثناء العرض بأمان
│   │   ├── report-schema.ts   # تحقق Zod من مخرجات النموذج
│   │   ├── export-report.ts   # مولّد التقرير المستقل (يشتغل بدون إنترنت)
│   │   ├── part-image-hosts.ts# قائمة المصادر المسموح بها لصور القطع
│   │   ├── antigravity-cli.ts # محرك Antigravity CLI (بيئة التطوير فقط)
│   │   ├── agy.ts             # بوابة تمنع تحميل agy في الإنتاج
│   │   ├── errors.ts          # أخطاء مصنّفة برسائل عربية
│   │   ├── models.ts          # المصدر الوحيد لأسماء نماذج Gemini
│   │   ├── html-escape.ts     # تهريب HTML لتقرير التصدير المستقل
│   │   ├── dictionary.ts      # القاموس الفني الليبي المعتمد
│   │   ├── gemini.ts          # محرك Google Gemini 3.7 Flash
│   │   ├── part-visuals.ts    # رسومات الـ SVG الهندسية لقطع الغيار
│   │   ├── parts-search.ts    # جلب صور القطع (مرجع منسّق + ويكيميديا)
│   │   ├── sample-data.ts     # نماذج الفحص الجاهزة (BMW E39 / Corolla)
│   │   ├── sensor-locator.ts  # مرجع مواقع الحساسات والفيوزات
│   │   └── types.ts           # هياكل البيانات و TypeScript Types
├── public/
│   ├── logo.svg               # الشعار الكامل (فولاذ)
│   ├── logo-flat.svg          # النسخة المسطّحة — اللي يستعملها التطبيق
│   ├── icon.svg               # أيقونة التطبيق
│   ├── icon-maskable.svg      # أيقونة أندرويد (المنطقة الآمنة 80%)
│   └── og.svg → og.png        # كرت المشاركة (واتساب يبي PNG مش SVG)
├── scripts/
│   └── render-og.mjs          # يحوّل og.svg إلى og.png (`npm run og`)
├── tests/                     # اختبارات الوحدة (Vitest)
├── e2e/                       # اختبارات الطرف للطرف (Playwright)
├── .github/workflows/
│   └── deploy-cloudflare.yml  # فحص فقط — النشر من لوحة Cloudflare
├── wrangler.jsonc             # إعدادات Cloudflare Workers & Assets
├── open-next.config.ts        # إعدادات محوّل OpenNext
├── PRODUCT.md                 # حقائق المنتج الثابتة
├── DESIGN.md                  # نظام التصميم والهوية (لوحة الفيوزات)
├── plan.md                    # خطة إعادة البناء والمراجعة الهندسية
├── PRD_KASHIF_AI.md           # وثيقة متطلبات المنتج الكاملة
└── ROADMAP.md                 # خارطة طريق وتوثيق المشروع
```

---

## 📜 الترخيص (License)
هذا المشروع مرخص تحت رخصة **MIT License**.
