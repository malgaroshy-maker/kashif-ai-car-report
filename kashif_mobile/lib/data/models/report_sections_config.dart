import 'package:flutter/material.dart';

/// Configuration definition for each customizable report section.
class ReportSectionItem {
  final String key;
  final String title;
  final String description;
  final IconData icon;
  final bool isEnabled;

  const ReportSectionItem({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isEnabled,
  });
}

/// Extensible model controlling which parts/sections of the diagnostic report
/// are included or excluded across UI screens, PDF prints, and HTML exports.
class ReportSectionsConfig {
  final bool includeTechnicalAssessment; // تقييم الفني للسيارة
  final bool includeFaultsTable;          // جدول التشخيص وحصر الأعطال
  final bool includePassedSystems;        // الأنظمة السليمة
  final bool includeProbabilitiesTable;  // جدول احتمالات ومسببات الأعطال المشتركة
  final bool includeChecklist;            // قائمة خطوات الفحص
  final bool includeSpareParts;           // دليل قطع الغيار
  final bool includeTechnicianSignature;  // اعتماد وختم الفحص وتوقيع الفني

  const ReportSectionsConfig({
    this.includeTechnicalAssessment = true,
    this.includeFaultsTable = true,
    this.includePassedSystems = true,
    this.includeProbabilitiesTable = true,
    this.includeChecklist = true,
    this.includeSpareParts = true,
    this.includeTechnicianSignature = true,
  });

  ReportSectionsConfig copyWith({
    bool? includeTechnicalAssessment,
    bool? includeFaultsTable,
    bool? includePassedSystems,
    bool? includeProbabilitiesTable,
    bool? includeChecklist,
    bool? includeSpareParts,
    bool? includeTechnicianSignature,
  }) {
    return ReportSectionsConfig(
      includeTechnicalAssessment:
          includeTechnicalAssessment ?? this.includeTechnicalAssessment,
      includeFaultsTable: includeFaultsTable ?? this.includeFaultsTable,
      includePassedSystems:
          includePassedSystems ?? this.includePassedSystems,
      includeProbabilitiesTable:
          includeProbabilitiesTable ?? this.includeProbabilitiesTable,
      includeChecklist: includeChecklist ?? this.includeChecklist,
      includeSpareParts: includeSpareParts ?? this.includeSpareParts,
      includeTechnicianSignature:
          includeTechnicianSignature ?? this.includeTechnicianSignature,
    );
  }

  ReportSectionsConfig toggleByKey(String key, bool enabled) {
    switch (key) {
      case 'includeTechnicalAssessment':
        return copyWith(includeTechnicalAssessment: enabled);
      case 'includeFaultsTable':
        return copyWith(includeFaultsTable: enabled);
      case 'includePassedSystems':
        return copyWith(includePassedSystems: enabled);
      case 'includeProbabilitiesTable':
        return copyWith(includeProbabilitiesTable: enabled);
      case 'includeChecklist':
        return copyWith(includeChecklist: enabled);
      case 'includeSpareParts':
        return copyWith(includeSpareParts: enabled);
      case 'includeTechnicianSignature':
        return copyWith(includeTechnicianSignature: enabled);
      default:
        return this;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'includeTechnicalAssessment': includeTechnicalAssessment,
      'includeFaultsTable': includeFaultsTable,
      'includePassedSystems': includePassedSystems,
      'includeProbabilitiesTable': includeProbabilitiesTable,
      'includeChecklist': includeChecklist,
      'includeSpareParts': includeSpareParts,
      'includeTechnicianSignature': includeTechnicianSignature,
    };
  }

  factory ReportSectionsConfig.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return const ReportSectionsConfig();
    return ReportSectionsConfig(
      includeTechnicalAssessment:
          map['includeTechnicalAssessment'] as bool? ?? true,
      includeFaultsTable: map['includeFaultsTable'] as bool? ?? true,
      includePassedSystems: map['includePassedSystems'] as bool? ?? true,
      includeProbabilitiesTable:
          map['includeProbabilitiesTable'] as bool? ?? true,
      includeChecklist: map['includeChecklist'] as bool? ?? true,
      includeSpareParts: map['includeSpareParts'] as bool? ?? true,
      includeTechnicianSignature:
          map['includeTechnicianSignature'] as bool? ?? true,
    );
  }

  /// Extensible listing: Any new section added to the system can simply be declared here.
  /// The Settings screen dynamically iterates over this list so any new section is
  /// automatically exposed with its switch, icon, and description.
  List<ReportSectionItem> toItemList() {
    return [
      ReportSectionItem(
        key: 'includeTechnicalAssessment',
        title: 'تقييم الفني للسيارة',
        description: 'خلاصة حالة المركبة، التقييم العام، وملاحظات الفني الأساسية',
        icon: Icons.engineering_rounded,
        isEnabled: includeTechnicalAssessment,
      ),
      ReportSectionItem(
        key: 'includeFaultsTable',
        title: 'جدول التشخيص وحصر الأعطال',
        description: 'جداول أكواد الأعطال (الحرجة، المتوسطة، وأعطال الذاكرة المسجلة)',
        icon: Icons.table_chart_rounded,
        isEnabled: includeFaultsTable,
      ),
      ReportSectionItem(
        key: 'includePassedSystems',
        title: 'الأنظمة السليمة',
        description: 'قائمة المنظومات الإلكترونية التي تم فحصها وتأكيد سلامتها وخلوها من المشاكل',
        icon: Icons.check_circle_outline_rounded,
        isEnabled: includePassedSystems,
      ),
      ReportSectionItem(
        key: 'includeProbabilitiesTable',
        title: 'جدول احتمالات ومسببات الأعطال',
        description: 'حصر للأعطال متعددة الأسباب مع سلسلة الاحتمالات للفحص المتسلسل',
        icon: Icons.alt_route_rounded,
        isEnabled: includeProbabilitiesTable,
      ),
      ReportSectionItem(
        key: 'includeChecklist',
        title: 'قائمة خطوات الفحص',
        description: 'خطة عمل الفحص الفني خطوة بخطوة والأدوات والعدة المقترحة لكل إجراء',
        icon: Icons.checklist_rounded,
        isEnabled: includeChecklist,
      ),
      ReportSectionItem(
        key: 'includeSpareParts',
        title: 'دليل قطع الغيار التقديرية',
        description: 'قائمة القطع البديلة المطلوبة للإصلاح والأسعار التقديرية بالدينار الليبي',
        icon: Icons.build_circle_outlined,
        isEnabled: includeSpareParts,
      ),
      ReportSectionItem(
        key: 'includeTechnicianSignature',
        title: 'اعتماد وختم الفحص وتوقيع الفني',
        description: 'مربع رسمي لتوقيع الفني المسؤول وختم المركز المعتمد أسفل التقرير',
        icon: Icons.verified_rounded,
        isEnabled: includeTechnicianSignature,
      ),
    ];
  }
}
