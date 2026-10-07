// One-off: rewrites Arabic terms in static data sources to Libyan workshop terms.
// Usage (from kashif_mobile/): dart run tool/libyanize_sources.dart <file>...
import 'dart:io';
import '../lib/core/utils/report_sanitizer.dart';

void main(List<String> args) {
  for (final path in args) {
    final f = File(path);
    final src = f.readAsStringSync();
    final out = ReportSanitizer.applyTerms(src);
    if (out != src) {
      f.writeAsStringSync(out);
      stdout.writeln('updated $path');
    } else {
      stdout.writeln('unchanged $path');
    }
  }
}
