import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/storage/hive_storage.dart';

class ApinexClient {
  static const String directBaseUrl = 'https://api.apinex.bond/v1';
  static const String defaultApiKey = 'sk-apx6963c3f6039e5c06788e4a6e7920707a1f17d36c90319db';
  static const String defaultModel = 'free/gpt-6-luna';

  static String get defaultBaseUrl {
    if (kIsWeb) {
      try {
        final origin = Uri.base.origin;
        if (origin.isNotEmpty && origin.startsWith('http')) {
          return '$origin/apinex-proxy';
        }
      } catch (_) {}
    }
    return directBaseUrl;
  }

  final Dio _dio;

  ApinexClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: defaultBaseUrl,
                connectTimeout: const Duration(seconds: 25),
                receiveTimeout: const Duration(seconds: 50),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  if (!kIsWeb)
                    'User-Agent':
                        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                },
              ),
            );

  String get _activeApiKey {
    final key = KashifStorage.apinexApiKey;
    return (key.isNotEmpty) ? key : defaultApiKey;
  }

  String get _activeModel {
    final model = KashifStorage.apinexModel;
    return (model.isNotEmpty) ? model : defaultModel;
  }

  static const String _systemInstruction = '''
أنت خبير كشف وتشخيص أعطال سيارات في ورش ليبيا (كاشف AI).
مهمتك إرجاع تقرير الفحص الفني بصيغة JSON حصراً، دون أي مقدمات أو كلام قبله أو بعده.

قواعد إلزامية وصارمة جداً:
1. استخراج بيانات المركبة (الشركة المصنعة Make، الموديل Model، سنة الصنع Year، رقم الهيكل VIN، قراءة العداد Mileage) بدقة 100% كما هي مذكورة في تقرير الفحص المرفق. ممنوع منعاً باتاً تخمين سيارة كامري أو غيرها إذا كانت السيارة BMW أو أي نوع آخر!
2. الاعتماد حصراً على أكواد الأعطال الحقيقية الواردة في التقرير الأصلي، وممنوع اختراع أكواد OBD عامة من عندك.
3. مصطلحات الورش الليبية المعتمدة (إلزامية):
   - دبة التلوث / علبة الكربون / الشكمانات (ممنوع منعاً باتاً استخدام كلمة "الخفّاز" أو أي ترجمة آلية غريبة).
   - بوبينة (Ignition Coil) / شمعات (Spark Plugs).
   - بومبة البنزين أو طرمبة البنزين / عوامة خزان الوقود (Fuel Pump / Level Sensor).
   - بسطوني (Piston / Cylinder) / فطفطة (Misfire).
   - كمبيو (Transmission / Gearbox).
   - ستاقوبا الزيت أو كرتير الزيت (Oil Pan / Sump).
   - كوادرو (Instrument Cluster) / فنارات (Headlights).
   - كوشينتي / موتسو العجلة (Wheel Bearing / Hub).
   - باور ستيرنج كهربائي EPS / عمود الستيرنج / كولونة التوجيه (Electric Power Steering).
   - حساس زاوية الستيرنج (Steering Angle Sensor) / حساس العزم (Torque Sensor) / معايرة وتصفير زاوية المقود (Calibration).
   - شريط الإيرباق / سبرنقة الستيرسو (Clock Spring / Spiral Cable).
   - طكاكة / قفل حزام الأمان (Seat Belt Buckle Switch).
   - بساط الكرسي / حساس وزن وقعدة الراكب (Occupant Classification Sensor) / محاكي إيرباق.
   - صالة ومقصات ومزاطوريات ودوزان وميزان رصاص (Suspension & Steering Alignment).
يجب أن يكون الرد متوافقاً تماماً مع الهيكل التالي:
{
  "reportId": "kashif-report-id",
  "generatedAt": "2026-09-30T00:00:00Z",
  "scannerInfo": {
    "toolName": "جهاز فحص كمبيوتر السيارات (APInex • GPT-6 Luna)",
    "serialNumber": "SN-ONLINE",
    "testTime": "2026-09-30"
  },
  "vehicle": {
    "make": "اسم الشركة",
    "model": "الموديل",
    "year": "السنة",
    "vin": "رقم الهيكل أو N/A",
    "mileage": "الممشى أو غير محدد"
  },
  "summary": {
    "overallHealthScore": 75,
    "severityStatus": "حرج / افحص فوراً أو متوسط / انتبه أو سليم / خفيف",
    "briefSummaryArabic": "ملخص فني شامل بلهجة الورش الليبية لحالة السيارة وما يجب فعله",
    "systemsCheckedCount": 4,
    "faultsFoundCount": 2,
    "passedSystemsCount": 2
  },
  "faultCategories": {
    "criticalFaults": [
      {
        "code": "رمز العطل",
        "module": "ECM أو ABS أو SRS",
        "moduleNameArabic": "اسم الوحدة بالعربي",
        "standardDescriptionEn": "الوصف بالإنجليزية",
        "libyanTerm": "اسم القطعة بلهجة الورش الليبية (مثال: بوبينة، شريط ستيرسو، حساس ماف)",
        "standardArabicDescription": "الشرح الفني بالعربي",
        "driverSymptoms": ["الأعراض التي يحس بها السائق"],
        "rootCauses": ["الأسباب المحتملة للعطل"],
        "urgencyLevel": "عالي جداً",
        "recommendedAction": "توجيهات الصيانة للورشة"
      }
    ],
    "moderateFaults": [],
    "minorOrHistoricalFaults": []
  },
  "passedSystems": ["كمبيوتر المحرك (ECM)", "منظومة الفرامل (ABS)"],
  "sparePartsRequired": [
    {
      "id": "part-1",
      "relatedCode": "رمز الكود",
      "partNameLibyan": "اسم القطعة بالليبي",
      "partNameStandardArabic": "الاسم الفصيح",
      "partNameEnglish": "Part Name",
      "aftermarketReplacements": ["أصلي", "تجاري معتمد"],
      "estimatedPriceRangeLYD": {
        "min": 50,
        "max": 150,
        "marketNote": "سعر سوق قطع الغيار في ليبيا"
      }
    }
  ],
  "workshopChecklist": [
    {
      "stepNumber": 1,
      "actionTitle": "عنوان خطوة الفحص",
      "actionDescriptionLibyan": "شرح الخطوة بالملتيميتر أو العدة اليدوية بالورشة",
      "purpose": "الهدف من الخطوة قبل التبديل العشوائي",
      "estimatedTime": "10 دقائق",
      "toolingNeeded": "ملتيميتر"
    }
  ]
}
''';

  Future<Response> _postRequest(dynamic data) async {
    try {
      return await _dio.post(
        '/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_activeApiKey',
            if (!kIsWeb)
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          },
        ),
        data: data,
      );
    } catch (e) {
      if (kIsWeb && _dio.options.baseUrl != directBaseUrl) {
        final directDio = Dio(
          BaseOptions(
            baseUrl: directBaseUrl,
            connectTimeout: const Duration(seconds: 25),
            receiveTimeout: const Duration(seconds: 50),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
        return await directDio.post(
          '/chat/completions',
          options: Options(
            headers: {'Authorization': 'Bearer $_activeApiKey'},
          ),
          data: data,
        );
      }
      rethrow;
    }
  }

  /// Detailed test returning success and error message
  Future<Map<String, dynamic>> testConnectionDetailed() async {
    try {
      final res = await _postRequest({
        'model': _activeModel,
        'messages': [
          {'role': 'user', 'content': 'قل متصل'}
        ],
        'max_tokens': 10,
      });
      if (res.statusCode == 200) {
        return {
          'success': true,
          'message': '✅ تم الاتصال بنجاح بـ APInex ($_activeModel)',
        };
      } else {
        return {
          'success': false,
          'message': '❌ رد السيرفر برمز: ${res.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '❌ خطأ في الاتصال: ${e.toString()}',
      };
    }
  }

  /// Test connection to APInex to verify API Key and model response
  Future<bool> testConnection() async {
    final res = await testConnectionDetailed();
    return res['success'] == true;
  }

  /// Analyze manual DTC codes and optional VIN
  Future<DiagnosticReport> analyzeManualCodes(
    String codes, {
    String? vin,
    String? make,
    String? model,
    String? year,
  }) async {
    final userPrompt = '''
بيانات الفحص اليدوي:
- أكواد الأعطال: $codes
- رقم الهيكل (VIN): ${vin ?? 'غير محدد'}
- المركبة: ${make ?? ''} ${model ?? ''} ${year ?? ''}
المطلوب: حلل الأعطال كاملة وجهز التقرير الفني الليبي الشامل بصيغة JSON.
''';

    return _executeChatCompletion(userPrompt);
  }

  /// Analyze raw text extracted from a scanner report
  Future<DiagnosticReport> analyzeTextReport(
    String textReport, {
    String? vin,
    String? make,
    String? model,
    String? year,
  }) async {
    final userPrompt = '''
تقرير جهاز الكشف المستخرج:
$textReport
- سيارة: ${make ?? ''} ${model ?? ''} ${year ?? ''}
المطلوب: قراءة كافة الأعطال والأنظمة السليمة واستخراج تقرير الفحص الشامل بصيغة JSON.
''';

    return _executeChatCompletion(userPrompt);
  }

  /// Analyze scanner screen / fault code photo via Vision
  Future<DiagnosticReport> analyzeImage(
    Uint8List imageBytes,
    String fileName,
  ) async {
    final base64Image = base64Encode(imageBytes);
    final ext = fileName.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';
    final dataUri = 'data:image/$ext;base64,$base64Image';

    final messages = [
      {'role': 'system', 'content': _systemInstruction},
      {
        'role': 'user',
        'content': [
          {
            'type': 'text',
            'text':
                'هذه صورة شاشة جهاز فحص السيارات. اقرأ جميع أكواد الأعطال والبيانات الظاهرة وحللها بالكامل وفق هيكل JSON المعتمد.',
          },
          {
            'type': 'image_url',
            'image_url': {'url': dataUri},
          },
        ],
      },
    ];

    return _sendRequestAndParse(messages);
  }

  Future<DiagnosticReport> _executeChatCompletion(String userContent) async {
    final messages = [
      {'role': 'system', 'content': _systemInstruction},
      {'role': 'user', 'content': userContent},
    ];
    return _sendRequestAndParse(messages);
  }

  Future<DiagnosticReport> _sendRequestAndParse(List<dynamic> messages) async {
    final res = await _postRequest({
      'model': _activeModel,
      'messages': messages,
      'temperature': 0.15,
    });

    if (res.statusCode != 200 || res.data == null) {
      throw Exception('فشل طلب الفحص من APInex (رمز: ${res.statusCode})');
    }

    final rawJson = res.data;
    final choices = rawJson['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw Exception('لم يُرجع نموذج الذكاء الاصطناعي أي رد.');
    }

    final content = choices[0]['message']?['content']?.toString() ?? '';
    return _parseReportContent(content);
  }

  DiagnosticReport _parseReportContent(String rawContent) {
    String clean = rawContent.trim();
    if (clean.contains('```json')) {
      final start = clean.indexOf('```json') + 7;
      final end = clean.indexOf('```', start);
      if (end != -1) {
        clean = clean.substring(start, end).trim();
      } else {
        clean = clean.substring(start).trim();
      }
    } else if (clean.contains('```')) {
      final start = clean.indexOf('```') + 3;
      final end = clean.indexOf('```', start);
      if (end != -1) {
        clean = clean.substring(start, end).trim();
      } else {
        clean = clean.substring(start).trim();
      }
    }

    try {
      final decoded = jsonDecode(clean);
      if (decoded is Map<String, dynamic>) {
        return DiagnosticReport.fromJson(decoded);
      } else if (decoded is Map) {
        return DiagnosticReport.fromJson(
          decoded.map((k, v) => MapEntry(k.toString(), v)),
        );
      }
    } catch (_) {}

    throw Exception('تعذر استخراج بيانات تقرير الفحص بصيغة صالحة من النموذج.');
  }
}
