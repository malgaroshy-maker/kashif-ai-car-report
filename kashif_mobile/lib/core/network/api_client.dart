import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';
import 'api_exceptions.dart';
import '../../data/models/diagnostic_report.dart';

class KashifApiClient {
  final Dio _dio;

  KashifApiClient({Dio? dio})
      : _dio = dio ??
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

  /// Analyze a scanner report PDF file
  Future<DiagnosticReport> analyzePdf(
    File pdfFile, {
    String? customApiKey,
    String? model,
  }) async {
    try {
      final fileName = pdfFile.path.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          pdfFile.path,
          filename: fileName,
          contentType: MediaType('application', 'pdf'),
        ),
      });

      final response = await _dio.post(
        ApiConstants.analyzeEndpoint,
        data: formData,
        options: Options(headers: _buildHeaders(customApiKey, model)),
      );

      return _handleReportResponse(response);
    } catch (e) {
      throw KashifApiException.fromDioError(e);
    }
  }

  /// Analyze a camera screenshot or scanner screen image
  Future<DiagnosticReport> analyzeImage(
    File imageFile, {
    String? customApiKey,
    String? model,
  }) async {
    try {
      final fileName = imageFile.path.split(Platform.pathSeparator).last;
      final isPng = fileName.toLowerCase().endsWith('.png');
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType('image', isPng ? 'png' : 'jpeg'),
        ),
      });

      final response = await _dio.post(
        ApiConstants.analyzeEndpoint,
        data: formData,
        options: Options(headers: _buildHeaders(customApiKey, model)),
      );

      return _handleReportResponse(response);
    } catch (e) {
      throw KashifApiException.fromDioError(e);
    }
  }

  /// Analyze manual DTC codes and optional VIN
  Future<DiagnosticReport> analyzeManual({
    required String codes,
    String? vin,
    String? customApiKey,
    String? model,
  }) async {
    try {
      final data = {
        'manualCodes': codes,
        'vehicleInfo': {
          'vin': vin ?? '',
        },
      };

      final response = await _dio.post(
        ApiConstants.analyzeEndpoint,
        data: data,
        options: Options(headers: _buildHeaders(customApiKey, model)),
      );

      return _handleReportResponse(response);
    } catch (e) {
      throw KashifApiException.fromDioError(e);
    }
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

  /// Send message to the AI Mechanic Chat (الأسطى الذكي)
  Future<String> sendChatMessage({
    required String message,
    required Map<String, dynamic> reportContext,
    List<Map<String, dynamic>>? history,
    String? customApiKey,
  }) async {
    try {
      final data = {
        'message': message,
        'reportContext': reportContext,
        'history': ?history,
      };

      final response = await _dio.post(
        ApiConstants.chatEndpoint,
        data: data,
        options: Options(headers: _buildHeaders(customApiKey, null)),
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
  }

  DiagnosticReport _handleReportResponse(Response response) {
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data is Map && data['report'] != null) {
        final reportMap = Map<String, dynamic>.from(data['report'] as Map);
        return DiagnosticReport.fromJson(reportMap);
      }
    }
    throw KashifApiException('استجابة غير صالحة من خادم التحليل.');
  }
}
