import 'package:flutter/material.dart';

enum LightSeverity {
  criticalRed('خطر داهم (أحمر)', 0xFFE53935),
  warningAmber('تحذير يستوجب الفحص (أصفر/برتقالي)', 0xFFFDD835),
  infoGreenBlue('أنظمة عادية وإشعارات (أخضر/أزرق)', 0xFF43A047);

  final String labelArabic;
  final int defaultColor;
  const LightSeverity(this.labelArabic, this.defaultColor);
}

enum CanDriveStatus {
  stopImmediately('⛔ توقف فوراً وأطفئ المحرك (سحب برافعة)', 0xFFE53935),
  driveCarefully('⚠️ يمكنك القيادة بحذر لأقرب ورشة فحص', 0xFFE5A93C),
  normal('✅ آمن للقيادة (حالة تشغيلية طبيعية)', 0xFF2E9E5B);

  final String labelArabic;
  final int colorValue;
  const CanDriveStatus(this.labelArabic, this.colorValue);
}

class DashboardLightItem {
  final String id;
  final String nameArabic;
  final String nameEnglish;
  final LightSeverity severity;
  final CanDriveStatus canDrive;
  final String symbolCode;
  final IconData icon;
  final String meaningArabic;
  final List<String> commonCauses;
  final String actionRequired;
  final List<String> associatedDTCs;
  final int colorValue;

  const DashboardLightItem({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.severity,
    required this.canDrive,
    required this.symbolCode,
    required this.icon,
    required this.meaningArabic,
    required this.commonCauses,
    required this.actionRequired,
    required this.associatedDTCs,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameArabic': nameArabic,
    'nameEnglish': nameEnglish,
    'severity': severity.name,
    'canDrive': canDrive.name,
    'colorValue': colorValue,
  };

  factory DashboardLightItem.fromId(String id) {
    // Will be linked to repository lookup
    return DashboardLightItem(
      id: id,
      nameArabic: id,
      nameEnglish: id,
      severity: LightSeverity.warningAmber,
      canDrive: CanDriveStatus.driveCarefully,
      symbolCode: 'LIGHT',
      icon: Icons.warning_amber_rounded,
      meaningArabic: '',
      commonCauses: [],
      actionRequired: '',
      associatedDTCs: [],
      colorValue: 0xFFFDD835,
    );
  }
}
