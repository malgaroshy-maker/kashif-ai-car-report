import 'dart:developer' as dev;
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';
import 'api_exceptions.dart';
import 'key_pool_manager.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/storage/hive_storage.dart';

class KashifApiClient {
  final Dio _dio;

  KashifApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: ApiConstants.connectTimeout,
              receiveTimeout: ApiConstants.receiveTimeout,
              headers: {
                'Accept': 'application/json',
                'User-Agent': 'KashifMobile/1.0 (Android; Mobile)',
              },
            ),
          );

  Map<String, dynamic> _buildHeaders(String? customApiKey, String? model) {
    final headers = <String, dynamic>{};
    if (customApiKey != null && customApiKey.trim().isNotEmpty) {
      headers['x-gemini-api-key'] = customApiKey.trim();
    }
    if (model != null && model.trim().isNotEmpty) {
      headers['x-gemini-model'] = model.trim();
    }
    return headers;
  }

  /// Executes request with automatic silent key rotation.
  /// If a key hits rate limit (429/503), it marks it in cooldown and seamlessly tries the next key.
  Future<T> _callWithRetryAndRotation<T>(
    Future<T> Function(String? key) requestFn, {
    String? explicitKey,
  }) async {
    final userKeys = KashifStorage.customApiKeys;

    // Build candidates: prioritize explicitKey or default stored key
    final cleanExp = (explicitKey != null && explicitKey.trim().isNotEmpty)
        ? explicitKey.trim()
        : KashifStorage.customApiKey;

    List<String?> candidateKeys;
    if (cleanExp != null && cleanExp.isNotEmpty) {
      final rest = userKeys.where((k) => k != cleanExp).toList();
      candidateKeys = KeyPoolManager.instance.getCandidateKeys([
        cleanExp,
        ...rest,
      ]);
    } else {
      candidateKeys = KeyPoolManager.instance.getCandidateKeys(userKeys);
    }

    dynamic lastError;
    for (int i = 0; i < candidateKeys.length; i++) {
      final key = candidateKeys[i];
      try {
        return await requestFn(key);
      } catch (e) {
        lastError = e;
        if (e is KashifApiException) {
          final isRateLimit =
              e.statusCode == 429 ||
              e.statusCode == 503 ||
              e.code == 'QUOTA_EXCEEDED' ||
              e.code == 'MODEL_UNAVAILABLE' ||
              e.message.contains('مشغولة') ||
              e.message.contains('غير متوفرة') ||
              e.message.contains('حصة') ||
              e.message.contains('Resource Exhausted');

          if (isRateLimit &&
              i < candidateKeys.length - 1 &&
              candidateKeys[i + 1] != null) {
            dev.log(
              '[ApiClient] Rate limit on candidate $i, rotating to next key...',
            );
            KeyPoolManager.instance.markCooldown(key);
            await Future.delayed(const Duration(milliseconds: 350));
            continue;
          }
        }
        rethrow;
      }
    }
    throw lastError ??
        KashifApiException('فشلت جميع المحاولات والمفاتيح المتاحة.');
  }

  /// Analyze a scanner report PDF file from bytes (works on Web & Mobile)
  Future<DiagnosticReport> analyzePdfBytes(
    Uint8List bytes,
    String fileName, {
    String? customApiKey,
    String? model,
  }) async {
    return _callWithRetryAndRotation((activeKey) async {
      try {
        final cleanName = fileName.split(RegExp(r'[/\\]')).last;
        final cleanKey = activeKey?.trim();
        final formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(
            bytes,
            filename: cleanName.isNotEmpty ? cleanName : 'scan_report.pdf',
            contentType: MediaType('application', 'pdf'),
          ),
          if (cleanKey != null && cleanKey.isNotEmpty) 'apiKey': cleanKey,
        });

        final response = await _dio.post(
          ApiConstants.analyzeEndpoint,
          data: formData,
          options: Options(headers: _buildHeaders(cleanKey, model)),
        );

        return _handleReportResponse(response);
      } catch (e) {
        throw KashifApiException.fromDioError(e);
      }
    }, explicitKey: customApiKey);
  }

  /// Analyze a camera screenshot or scanner screen image from bytes (works on Web & Mobile)
  Future<DiagnosticReport> analyzeImageBytes(
    Uint8List bytes,
    String fileName, {
    String? customApiKey,
    String? model,
  }) async {
    return _callWithRetryAndRotation((activeKey) async {
      try {
        final cleanName = fileName.split(RegExp(r'[/\\]')).last;
        final isPng = cleanName.toLowerCase().endsWith('.png');
        final cleanKey = activeKey?.trim();
        final formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(
            bytes,
            filename: cleanName.isNotEmpty ? cleanName : 'scanner_screen.jpg',
            contentType: MediaType('image', isPng ? 'png' : 'jpeg'),
          ),
          if (cleanKey != null && cleanKey.isNotEmpty) 'apiKey': cleanKey,
        });

        final response = await _dio.post(
          ApiConstants.analyzeEndpoint,
          data: formData,
          options: Options(headers: _buildHeaders(cleanKey, model)),
        );

        return _handleReportResponse(response);
      } catch (e) {
        throw KashifApiException.fromDioError(e);
      }
    }, explicitKey: customApiKey);
  }

  /// Backward-compatible wrapper for analyzePdf
  Future<DiagnosticReport> analyzePdf(
    dynamic fileOrBytes, {
    String fileName = 'report.pdf',
    String? customApiKey,
    String? model,
  }) async {
    if (fileOrBytes is Uint8List) {
      return analyzePdfBytes(
        fileOrBytes,
        fileName,
        customApiKey: customApiKey,
        model: model,
      );
    }
    final bytes = await fileOrBytes.readAsBytes();
    final name = fileOrBytes.path.toString().split(RegExp(r'[/\\]')).last;
    return analyzePdfBytes(
      bytes,
      name,
      customApiKey: customApiKey,
      model: model,
    );
  }

  /// Backward-compatible wrapper for analyzeImage
  Future<DiagnosticReport> analyzeImage(
    dynamic fileOrBytes, {
    String fileName = 'scanner_screen.jpg',
    String? customApiKey,
    String? model,
  }) async {
    if (fileOrBytes is Uint8List) {
      return analyzeImageBytes(
        fileOrBytes,
        fileName,
        customApiKey: customApiKey,
        model: model,
      );
    }
    final bytes = await fileOrBytes.readAsBytes();
    final name = fileOrBytes.path.toString().split(RegExp(r'[/\\]')).last;
    return analyzeImageBytes(
      bytes,
      name,
      customApiKey: customApiKey,
      model: model,
    );
  }

  /// Analyze manual DTC codes and optional VIN
  Future<DiagnosticReport> analyzeManual({
    required String codes,
    String? vin,
    String? customApiKey,
    String? model,
  }) async {
    return _callWithRetryAndRotation((activeKey) async {
      try {
        final cleanKey = activeKey?.trim();
        final data = {
          'manualCodes': codes,
          if (vin != null && vin.isNotEmpty) 'vehicleInfo': {'vin': vin},
          if (cleanKey != null && cleanKey.isNotEmpty) 'apiKey': cleanKey,
        };

        final response = await _dio.post(
          ApiConstants.analyzeEndpoint,
          data: data,
          options: Options(headers: _buildHeaders(cleanKey, model)),
        );

        return _handleReportResponse(response);
      } catch (e) {
        throw KashifApiException.fromDioError(e);
      }
    }, explicitKey: customApiKey);
  }

  /// Load demo pre-parsed report (BMW 528i or Toyota Corolla)
  Future<DiagnosticReport> loadDemoReport(String sampleId) async {
    try {
      final response = await _dio.post(
        ApiConstants.analyzeEndpoint,
        data: {'sampleId': sampleId},
      );

      return _handleReportResponse(response);
    } catch (e) {
      throw KashifApiException.fromDioError(e);
    }
  }

  /// Send message to the AI Mechanic Chat (المساعد الفني الذكي)
  Future<String> sendChatMessage({
    required String message,
    required Map<String, dynamic> reportContext,
    List<Map<String, dynamic>>? history,
    String? customApiKey,
  }) async {
    return _callWithRetryAndRotation((activeKey) async {
      try {
        final cleanKey = activeKey?.trim();
        final data = {
          'message': message,
          'question': message,
          'reportContext': reportContext,
          'report': reportContext,
          'history': history,
          if (cleanKey != null && cleanKey.isNotEmpty) 'apiKey': cleanKey,
        };

        final response = await _dio.post(
          ApiConstants.chatEndpoint,
          data: data,
          options: Options(headers: _buildHeaders(cleanKey, null)),
        );

        if (response.statusCode == 200 && response.data != null) {
          final resData = response.data;
          if (resData is Map && resData['reply'] != null) {
            return resData['reply'].toString();
          }
        }
        throw KashifApiException('لم يتم استلام رد مفهوم من المساعد الذكي.');
      } catch (e) {
        throw KashifApiException.fromDioError(e);
      }
    }, explicitKey: customApiKey);
  }

  /// Verifies an API key against the server/Gemini endpoint
  Future<Map<String, dynamic>> testApiKey(String apiKey) async {
    final clean = apiKey.trim().replaceAll('"', '').replaceAll("'", '');
    if (clean.isEmpty) {
      return {'success': false, 'message': 'يرجى إدخال المفتاح أولاً.'};
    }
    try {
      final response = await _dio.post(
        ApiConstants.analyzeEndpoint,
        data: {'manualCodes': 'P0100', 'apiKey': clean},
        options: Options(
          headers: {'x-gemini-api-key': clean},
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true) {
        return {
          'success': true,
          'message':
              'المفتاح يعمل بشكل ممتاز مع الذكاء الاصطناعي وجاهز للفحص! ✅',
        };
      }
      return {'success': false, 'message': 'استجابة غير متوقعة من الخادم'};
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['error'] != null) {
        return {'success': false, 'message': data['error'].toString()};
      }
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        return {
          'success': false,
          'message': 'المفتاح غير صالح أو مرفوض من Google.',
        };
      } else if (e.response?.statusCode == 429) {
        return {
          'success': false,
          'message': 'المفتاح صحيح لكنه في فترة انتظار مؤقتة (انتظر دقيقة).',
        };
      }
      return {
        'success': false,
        'message': 'تعذر الاتصال بالخادم للتحقق (${e.message})',
      };
    } catch (e) {
      return {'success': false, 'message': 'خطأ أثناء التحقق: $e'};
    }
  }

  DiagnosticReport _handleReportResponse(Response response) {
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data is Map && data['report'] != null) {
        final reportMap = Map<String, dynamic>.from(data['report'] as Map);
        return DiagnosticReport.fromJson(reportMap);
      }
    }
    throw KashifApiException(
      'استجابة غير صالحة من الخادم (كود: ${response.statusCode})',
      statusCode: response.statusCode,
    );
  }
}
