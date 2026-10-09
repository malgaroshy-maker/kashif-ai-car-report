import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../constants/libyan_dictionary_prompt.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/storage/hive_storage.dart';

class ApinexClient {
  static const String directBaseUrl = 'https://api.apinex.bond/v1';
  static const String defaultApiKey = 'sk-apxa56a82ec7f5964869b99a471975271a85475e01e00cbf19';
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
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 90),
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

  String get masterInstruction {
    if (_activeModel.startsWith('free/') || KashifStorage.isTokenSaverEnabled) {
      return LibyanPromptConstants.getCompactSystemInstruction();
    }
    return LibyanPromptConstants.getMasterSystemInstruction();
  }

  Future<Response> _postRequest(dynamic data, {String? keyOverride}) async {
    final key = (keyOverride != null && keyOverride.isNotEmpty) ? keyOverride : _activeApiKey;
    try {
      return await _dio.post(
        '/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $key',
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
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 90),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
        return await directDio.post(
          '/chat/completions',
          options: Options(
            headers: {'Authorization': 'Bearer $key'},
          ),
          data: data,
        );
      }
      rethrow;
    }
  }

  /// Fetches available models from APInex GET /models
  Future<List<String>> fetchAvailableModels({String? keyOverride}) async {
    final key = (keyOverride != null && keyOverride.isNotEmpty) ? keyOverride : _activeApiKey;
    try {
      final res = await _dio.get(
        '/models',
        options: Options(
          headers: {
            'Authorization': 'Bearer $key',
            if (!kIsWeb)
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          },
        ),
      );
      if (res.statusCode == 200 && res.data is Map && res.data['data'] is List) {
        final list = res.data['data'] as List;
        return list
            .map((m) => m is Map ? m['id']?.toString() ?? '' : '')
            .where((id) => id.isNotEmpty)
            .toList();
      }
      return [];
    } catch (e) {
      if (kIsWeb && _dio.options.baseUrl != directBaseUrl) {
        final directDio = Dio(
          BaseOptions(
            baseUrl: directBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 25),
          ),
        );
        final res = await directDio.get(
          '/models',
          options: Options(headers: {'Authorization': 'Bearer $key'}),
        );
        if (res.statusCode == 200 && res.data is Map && res.data['data'] is List) {
          final list = res.data['data'] as List;
          return list
              .map((m) => m is Map ? m['id']?.toString() ?? '' : '')
              .where((id) => id.isNotEmpty)
              .toList();
        }
      }
      rethrow;
    }
  }

  /// Two-stage intelligent connection test:
  /// Stage 1: Validates API key and server connectivity via GET /models
  /// Stage 2: Tests selected model completion via POST /chat/completions
  Future<Map<String, dynamic>> testConnectionDetailed({
    String? keyOverride,
    String? modelOverride,
  }) async {
    final key = (keyOverride != null && keyOverride.isNotEmpty)
        ? keyOverride
        : _activeApiKey;
    final model = (modelOverride != null && modelOverride.isNotEmpty)
        ? modelOverride
        : _activeModel;

    List<String> availableModels = [];

    // Stage 1: Validate API key and connectivity
    try {
      availableModels = await fetchAvailableModels(keyOverride: key);
    } catch (e) {
      if (e is DioException) {
        final status = e.response?.statusCode;
        if (status == 401) {
          return {
            'success': false,
            'stage': 1,
            'message': '❌ مفتاح APInex غير صالح أو منتهي الصلاحية (رمز 401). تأكد من صحة المفتاح.',
            'availableModels': <String>[],
          };
        } else if (status == 403) {
          return {
            'success': false,
            'stage': 1,
            'message': '❌ تم حظر الوصول لمفتاح APInex (رمز 403).',
            'availableModels': <String>[],
          };
        }
      }
      return {
        'success': false,
        'stage': 1,
        'message': '❌ تعذر الوصول إلى سيرفر APInex. تأكد من اتصال هاتفك بالإنترنت.',
        'availableModels': <String>[],
      };
    }

    final modelInList = availableModels.isEmpty || availableModels.contains(model);

    // Stage 2: Test selected model with short prompt
    try {
      final res = await _postRequest({
        'model': model,
        'messages': [
          {'role': 'user', 'content': 'قل متصل'}
        ],
        'max_tokens': 10,
      }, keyOverride: key);

      if (res.statusCode == 200) {
        return {
          'success': true,
          'stage': 2,
          'message': '✅ تم الاتصال بنجاح! المفتاح متصل والنموذج ($model) جاهز ويعمل بكفاءة فائقة.',
          'availableModels': availableModels,
        };
      } else {
        return {
          'success': false,
          'stage': 2,
          'message': '❌ رد السيرفر برمز: ${res.statusCode}',
          'availableModels': availableModels,
        };
      }
    } catch (e) {
      if (e is DioException) {
        final status = e.response?.statusCode;
        final resData = e.response?.data;
        String? serverMsg;
        if (resData is Map && resData['error'] is Map) {
          serverMsg = resData['error']['message']?.toString();
        }

        if (status == 402) {
          return {
            'success': false,
            'stage': 2,
            'message':
                '⚠️ تم التحقق من المفتاح بنجاح! النماذج مجانية 100% ولا تتطلب أي دفع أو شحن رصيد إطلاقاً؛ كل ما تحتاجه هو تسجيل حضور يومي مجاني (Daily Check-in) بنقرة واحدة عبر الرابط: https://apinex.bond/airdrop?tab=quests لتفعيل النموذج فوراً.',
            'availableModels': availableModels,
          };
        } else if (status == 404 || !modelInList) {
          return {
            'success': false,
            'stage': 2,
            'message':
                '❌ النموذج المختار ($model) غير متوفر في قائمة السيرفر الحالية.',
            'availableModels': availableModels,
          };
        } else if (status == 429) {
          return {
            'success': false,
            'stage': 2,
            'message':
                '⏳ تم تجاوز معدل الطلبات المسموح به للنموذج ($model) حالياً (Rate Limit 429). يرجى الانتظار دقيقة وإعادة المحاولة.',
            'availableModels': availableModels,
          };
        } else if (serverMsg != null && serverMsg.isNotEmpty) {
          return {
            'success': false,
            'stage': 2,
            'message': '⚠️ استجابة سيرفر APInex: $serverMsg',
            'availableModels': availableModels,
          };
        }
      }

      return {
        'success': false,
        'stage': 2,
        'message': '❌ خطأ أثناء اختبار النموذج ($model): ${e.toString()}',
        'availableModels': availableModels,
      };
    }
  }

  /// Test connection returning simple boolean
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
بيانات الفحص اليدوي من ورشة صيانة السيارات:
- أكواد الأعطال (DTCs): $codes
- رقم الهيكل (VIN): ${vin ?? 'غير محدد'}
- بيانات المركبة: ${make ?? ''} ${model ?? ''} ${year ?? ''}
المطلوب:
1. حلل كافة أكواد الأعطال الواردة وقارنها بالقاموس الليبي الشامل.
2. لكل عطل أو قطعة تتطلب تبديلاً: ابحث وطابق كود القطعة الأصلي للوكالة (oemPartNumber) المطابق تماماً لبيانات وطراز وسنة ومحرك وهيكل السيارة (VIN) من كتالوجات قطع الغيار العالمية، واستخرج كودات قطع الغيار البديلة المعتمدة (aftermarketReplacements) من كبرى الشركات العالمية (مثل Denso, Bosch, TRW, Delphi, Aisin, NGK, Febi, Valeo) مرفقة بأرقامها وكوداتها الدقيقة. ممنوع تكرار نفس رقم القطعة لأكثر من قطعة مختلفة في نفس التقرير!
3. حدّد القطع التالفة بأسعار السوق في ليبيا، وقدّم خطوات فحص وعزل ذكية (Checklist) واضحة قبل التبديل.
4. أخرج كائن JSON الصالح حصراً وفق الهيكل المطلوب.

${LibyanPromptConstants.libyanMandatoryDirectives}
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
نص تقرير الفحص المستخرج من جهاز كشف السيارات (Launch / Autel / Ediag / ThinkDiag):
$textReport
- بيانات السيارة المعروفة: ${make ?? ''} ${model ?? ''} ${year ?? ''} - رقم الهيكل: ${vin ?? ''}
المطلوب:
1. استخراج بيانات السيارة (Make, Model, Year, VIN, Mileage) بدقة 100% من التقرير الأصلي.
2. حصر جميع أكواد الأعطال الحقيقية فقط دون اختراع أعطال إضافية.
3. مطابقة أسماء القطع بلهجة الورش الليبية (مثل: بوبينات، شمعات، حساس مرميطة، صالة، مزاطوري...).
4. ابحث وطابق كودات وأرقام القطع الأصلية للوكالة (oemPartNumber) المطابقة تماماً لرقم الهيكل والموديل والسنة والمحرك من كتالوجات ومواقع قطع الغيار العالمية، وكودات القطع البديلة المعتمدة (aftermarketReplacements) من الشركات العالمية المصنعة بأرقامها وكوداتها المحددة (ممنوع كتابة عبارة حسب رقم الهيكل أو كتابة شركات بدون أرقام، وممنوع تكرار نفس الكود لقطعتين مختلفتين).
5. تقديم أفكار عزل وفحص ذكية، وأسعار القطع بالدينار الليبي (LYD).
6. إخراج كائن JSON فقط.

${LibyanPromptConstants.libyanMandatoryDirectives}
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
      {'role': 'system', 'content': masterInstruction},
      {
        'role': 'user',
        'content': [
          {
            'type': 'text',
            'text':
                'هذه صورة شاشة جهاز فحص السيارات (Launch / Autel / Ediag / ThinkDiag / شاشة الطبلون). اقرأ جميع أكواد الأعطال الظاهرة (DTCs) وبيانات السيارة. لكل عطل أو قطعة تالفة: استخرج ووفر كود القطعة الأصلي للوكالة (oemPartNumber) المطابق لرقم الهيكل والموديل، وكودات القطع البديلة المعتمدة (aftermarketReplacements) بأرقامها الدقيقة، وحللها بالكامل وفق قاموس الورش الليبية وأخرج كائن JSON المعتمد.\n\n${LibyanPromptConstants.libyanMandatoryDirectives}',
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
      {'role': 'system', 'content': masterInstruction},
      {'role': 'user', 'content': userContent},
    ];
    return _sendRequestAndParse(messages);
  }

  Future<DiagnosticReport> _sendRequestAndParse(List<dynamic> messages) async {
    final res = await _postRequest({
      'model': _activeModel,
      'messages': messages,
      'temperature': 0.1,
      'max_tokens': 3500,
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
    if (choices[0]['finish_reason'] == 'length') {
      throw Exception(
        'انقطع رد النموذج قبل اكتمال التقرير (تجاوز الحد الأقصى). أعد المحاولة أو قلّل عدد الأكواد.',
      );
    }
    return _parseReportContent(content);
  }

  DiagnosticReport _parseReportContent(String rawContent) {
    String clean = rawContent.trim();

    // 1. Strip markdown code fences if present
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

    // 2. Locate first '{' and last '}' if extra preamble or postamble exists
    final firstBrace = clean.indexOf('{');
    final lastBrace = clean.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      clean = clean.substring(firstBrace, lastBrace + 1).trim();
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
    } catch (e) {
      // Attempt to clean escaped characters or formatting issues
      try {
        final sanitized = clean
            .replaceAll(RegExp(r',\s*}'), '}')
            .replaceAll(RegExp(r',\s*]'), ']');
        final decoded = jsonDecode(sanitized);
        if (decoded is Map) {
          return DiagnosticReport.fromJson(
            decoded.map((k, v) => MapEntry(k.toString(), v)),
          );
        }
      } catch (_) {}
    }

    throw Exception('تعذر استخراج بيانات تقرير الفحص بصيغة صالحة من النموذج.');
  }
}
