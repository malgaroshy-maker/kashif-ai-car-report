class PriceRangeLYD {
  final double min;
  final double max;
  final String marketNote;

  PriceRangeLYD({
    required this.min,
    required this.max,
    this.marketNote = '',
  });

  factory PriceRangeLYD.fromJson(Map<String, dynamic> json) {
    return PriceRangeLYD(
      min: (json['min'] is num) ? (json['min'] as num).toDouble() : 0.0,
      max: (json['max'] is num) ? (json['max'] as num).toDouble() : 0.0,
      marketNote: json['marketNote'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'min': min,
        'max': max,
        'marketNote': marketNote,
      };
}

class SparePartItem {
  final String id;
  final String relatedCode;
  final String partNameLibyan;
  final String partNameStandardArabic;
  final String partNameEnglish;
  final String? oemPartNumber;
  final List<String> aftermarketReplacements;
  final PriceRangeLYD? estimatedPriceRangeLYD;
  final String? systemCategory;
  final String? partImageUrl;
  final String? replacementUrgency;

  SparePartItem({
    required this.id,
    required this.relatedCode,
    required this.partNameLibyan,
    required this.partNameStandardArabic,
    required this.partNameEnglish,
    this.oemPartNumber,
    required this.aftermarketReplacements,
    this.estimatedPriceRangeLYD,
    this.systemCategory,
    this.partImageUrl,
    this.replacementUrgency,
  });

  String get diagramCategory => systemCategory ?? '';

  factory SparePartItem.fromJson(Map<String, dynamic> json) {
    return SparePartItem(
      id: json['id'] as String? ?? '',
      relatedCode: json['relatedCode'] as String? ?? '',
      partNameLibyan: json['partNameLibyan'] as String? ?? '',
      partNameStandardArabic: json['partNameStandardArabic'] as String? ?? '',
      partNameEnglish: json['partNameEnglish'] as String? ?? '',
      oemPartNumber: json['oemPartNumber'] as String?,
      aftermarketReplacements: (json['aftermarketReplacements'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      estimatedPriceRangeLYD: json['estimatedPriceRangeLYD'] != null &&
              json['estimatedPriceRangeLYD'] is Map<String, dynamic>
          ? PriceRangeLYD.fromJson(json['estimatedPriceRangeLYD'] as Map<String, dynamic>)
          : null,
      systemCategory: (json['systemCategory'] ?? json['diagramCategory']) as String?,
      partImageUrl: json['partImageUrl'] as String?,
      replacementUrgency: json['replacementUrgency'] as String? ?? json['urgency'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'relatedCode': relatedCode,
        'partNameLibyan': partNameLibyan,
        'partNameStandardArabic': partNameStandardArabic,
        'partNameEnglish': partNameEnglish,
        'oemPartNumber': oemPartNumber,
        'aftermarketReplacements': aftermarketReplacements,
        'estimatedPriceRangeLYD': estimatedPriceRangeLYD?.toJson(),
        'systemCategory': systemCategory,
        'partImageUrl': partImageUrl,
        'replacementUrgency': replacementUrgency,
      };
}
