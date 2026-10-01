import '../../core/utils/report_sanitizer.dart';

class VehicleInfo {
  final String vin;
  final String make;
  final String model;
  final String year;
  final String mileage;
  final EngineSpecs? engineSpecs;

  VehicleInfo({
    required this.vin,
    required this.make,
    required this.model,
    required this.year,
    this.mileage = '',
    this.engineSpecs,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      vin: json['vin'] as String? ?? 'N/A',
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: json['year']?.toString() ?? '',
      mileage: json['mileage'] as String? ?? '',
      engineSpecs:
          json['engineSpecs'] != null &&
              json['engineSpecs'] is Map<String, dynamic>
          ? EngineSpecs.fromJson(json['engineSpecs'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'vin': vin,
    'make': make,
    'model': model,
    'year': year,
    'mileage': mileage,
    'engineSpecs': engineSpecs?.toJson(),
  };

  /// Formatted vehicle title: e.g. "Toyota Corolla • موديل 2004"
  String get formattedTitle {
    final vMake = make.trim();
    final vModel = model
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('السلندر', 'البسطوني')
        .replaceAll('سلندر', 'بسطوني')
        .trim();
    final vYear = year.trim().split('.').first;
    final parts = [
      if (vMake.isNotEmpty && vMake != 'غير محدد') vMake,
      if (vModel.isNotEmpty && vModel != 'مركبة' && vModel != 'غير محدد') vModel,
      if (vYear.isNotEmpty && vYear != '—') '• موديل $vYear',
    ];
    return parts.isNotEmpty ? parts.join(' ') : 'مركبة';
  }

  /// Clean VIN or empty if missing / placeholder
  String get cleanVin {
    return (vin.trim().isNotEmpty && vin.trim() != 'N/A') ? vin.trim() : '';
  }

  /// Formatted engine description: e.g. "1.8L 1ZZ-FE - 4 بسطوني • بنزين"
  String get formattedEngine {
    if (engineSpecs == null) return '';
    final sp = engineSpecs!;
    var disp = sp.displacement
        .replaceAll('السلندر', 'البسطوني')
        .replaceAll('سلندر', 'بسطوني')
        .replaceAll('(', '- ')
        .replaceAll(')', '')
        .trim();
    if (!disp.contains('بسطوني') && sp.cylinders > 0) {
      disp = disp.isNotEmpty
          ? '$disp - ${sp.cylinders} بسطوني'
          : '${sp.cylinders} بسطوني';
    }
    if (sp.fuelType.isNotEmpty && sp.fuelType != 'غير محدد') {
      disp = disp.isNotEmpty ? '$disp • ${sp.fuelType}' : sp.fuelType;
    }
    return disp;
  }

  /// Formatted transmission description: e.g. "كمبيو أوتوماتيك 4 سرعات - كونفيرتا"
  String get formattedTransmission {
    if (engineSpecs == null) return '';
    return ReportSanitizer.clean(
      engineSpecs!.transmission
          .replaceAll('السلندر', 'البسطوني')
          .replaceAll('سلندر', 'بسطوني')
          .replaceAll('(', '- ')
          .replaceAll(')', '')
          .trim(),
    );
  }

  /// Formatted mileage: if in miles, displays both miles and kilometers
  /// e.g. "281,461 ميل (452,968 كم)" or "185,000 كم"
  String get formattedMileage {
    final raw = mileage.trim();
    if (raw.isEmpty || raw == 'حسب العداد') {
      return raw;
    }

    final isMiles = raw.toLowerCase().contains('mil') || raw.contains('ميل');
    final hasKm = raw.toLowerCase().contains('km') || raw.contains('كم');

    if (isMiles && !hasKm) {
      final numMatch = RegExp(r'([\d,]+(?:\.\d+)?)').firstMatch(raw);
      if (numMatch != null) {
        final numStr = numMatch.group(1)!.replaceAll(',', '');
        final val = double.tryParse(numStr);
        if (val != null && val > 0) {
          final kmVal = (val * 1.609344).round();
          final milesFormatted = _formatWithCommas(val.round());
          final kmFormatted = _formatWithCommas(kmVal);
          return '$milesFormatted ميل ($kmFormatted كم)';
        }
      }
    }

    return raw
        .replaceAll('Miles', 'ميل')
        .replaceAll('miles', 'ميل')
        .replaceAll('Mile', 'ميل')
        .replaceAll('mile', 'ميل')
        .replaceAll('(~', '• حوالي ')
        .replaceAll('~', 'حوالي ')
        .replaceAll('(', '• ')
        .replaceAll(')', '')
        .replaceAll(' تقديري', '')
        .trim();
  }

  static String _formatWithCommas(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

class EngineSpecs {
  final String displacement;
  final String fuelType;
  final int cylinders;
  final String transmission;

  EngineSpecs({
    this.displacement = '',
    this.fuelType = 'بنزين',
    this.cylinders = 4,
    this.transmission = '',
  });

  factory EngineSpecs.fromJson(Map<String, dynamic> json) {
    return EngineSpecs(
      displacement: json['displacement'] as String? ?? '',
      fuelType: json['fuelType'] as String? ?? 'بنزين',
      cylinders: json['cylinders'] is int
          ? json['cylinders'] as int
          : int.tryParse(json['cylinders']?.toString() ?? '') ?? 4,
      transmission: json['transmission'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'displacement': displacement,
    'fuelType': fuelType,
    'cylinders': cylinders,
    'transmission': transmission,
  };
}
