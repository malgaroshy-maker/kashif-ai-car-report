class KashifApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  KashifApiException(this.message, {this.statusCode, this.code});

  @override
  String toString() => message;

  factory KashifApiException.fromDioError(dynamic error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map && data['error'] != null) {
        final err = data['error'];
        if (err is Map && err['message'] != null) {
          return KashifApiException(
            err['message'].toString(),
            statusCode: error.response?.statusCode,
            code: err['code']?.toString(),
          );
        } else if (err is String) {
          return KashifApiException(
            err,
            statusCode: error.response?.statusCode,
          );
        }
      }
      return KashifApiException(
        'خطأ في الاتصال بالخادم (${error.response?.statusCode})',
        statusCode: error.response?.statusCode,
      );
    }
    return KashifApiException('تعذر الاتصال بالشبكة، تأكد من اتصال هاتفك بالإنترنت.');
  }
}
