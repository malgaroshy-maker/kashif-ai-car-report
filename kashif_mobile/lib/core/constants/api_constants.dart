class ApiConstants {
  static const String baseUrl = 'https://kashif.malgaroshy.workers.dev';
  static const String analyzeEndpoint = '$baseUrl/api/analyze';
  static const String chatEndpoint = '$baseUrl/api/chat';
  static const String modelsEndpoint = '$baseUrl/api/models';
  static const String partsImageEndpoint = '$baseUrl/api/parts-image';
  static const String partPhotoEndpoint = '$baseUrl/api/part-photo';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 90);
}
