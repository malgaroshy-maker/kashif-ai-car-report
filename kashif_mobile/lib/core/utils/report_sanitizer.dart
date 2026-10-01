/// Utility to clean and sanitize any scanner device brand names (Ediag, Launch, etc.)
/// and standardize workshop terms before displaying to the client or exporting to PDF/WhatsApp.
class ReportSanitizer {
  static String clean(String? input) {
    if (input == null || input.isEmpty) return '';
    return input
        .replaceAll(
          RegExp(r'بواسطة\s+جهاز\s+(كشف|فحص)\s+[A-Za-z0-9_\-]+', caseSensitive: false),
          'عبر الفحص الإلكتروني الشامل',
        )
        .replaceAll(
          RegExp(r'بجهاز\s+(كشف|فحص)\s+[A-Za-z0-9_\-]+(\s+بدون\s+إنترنت)?', caseSensitive: false),
          'عبر الفحص الإلكتروني الشامل',
        )
        .replaceAll(
          RegExp(r'تقرير\s+جهاز\s+[A-Za-z0-9_\-]+', caseSensitive: false),
          'تقرير الفحص الإلكتروني',
        )
        .replaceAll(
          RegExp(r'جهاز\s+(كشف|فحص)\s+(Ediag|Launch|Autel|Thinkdiag|G-Scan|OBD)', caseSensitive: false),
          'جهاز الفحص',
        )
        .replaceAll(
          RegExp(r'\(Ediag\s+أو\s+ما\s+يعادله\)', caseSensitive: false),
          'بجهاز الفحص المعتمد',
        )
        .replaceAll(
          RegExp(r'Ediag|Thinkdiag|Autel|Launch', caseSensitive: false),
          '',
        )
        .replaceAll('تفتفة', 'فطفطة')
        .replaceAll(
          RegExp(r'خطوات\s+فحص\s+الأ?سطى\s+والورشة|خطوات\s+فحص\s+الأ?سطى|فحص\s+الأ?سطى', caseSensitive: false),
          'خطوات الفحص الفني والورشة',
        )
        .replaceAll(RegExp(r'الأ?سطى', caseSensitive: false), 'الفني')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }
}
