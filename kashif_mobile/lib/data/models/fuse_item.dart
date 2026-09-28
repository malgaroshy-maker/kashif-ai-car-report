enum FuseLocation {
  engineBay('حوض المحرك (تحت الكبوت)'),
  interior('كابينة القيادة (تحت المقود / الطبلون)');

  final String labelArabic;
  const FuseLocation(this.labelArabic);
}

class FuseItem {
  final String id;
  final String nameArabic;
  final String circuitEnglish;
  final FuseLocation location;
  final int ratingAmps;
  final bool isRelay;
  final List<String> symptoms;
  final List<String> associatedDTCs;
  final String testingTip;
  final String standardColorName;
  final int colorValue;

  const FuseItem({
    required this.id,
    required this.nameArabic,
    required this.circuitEnglish,
    required this.location,
    required this.ratingAmps,
    this.isRelay = false,
    required this.symptoms,
    required this.associatedDTCs,
    required this.testingTip,
    required this.standardColorName,
    required this.colorValue,
  });

  /// Standard automotive blade fuse color code based on amperage
  static int getColorForAmps(int amps) {
    switch (amps) {
      case 5:
        return 0xFFFFB74D; // Amber/Orange
      case 7:
      case 8:
        return 0xFF8D6E63; // Brown
      case 10:
        return 0xFFE53935; // Red
      case 15:
        return 0xFF1E88E5; // Blue
      case 20:
        return 0xFFFDD835; // Yellow
      case 25:
        return 0xFFEEEEEE; // Clear / White
      case 30:
        return 0xFF43A047; // Green
      case 40:
        return 0xFFFB8C00; // Orange Maxi
      case 50:
        return 0xFFD32F2F; // Red Maxi
      default:
        return 0xFFD4AF37; // Kashif Gold
    }
  }

  static String getColorNameForAmps(int amps) {
    switch (amps) {
      case 5:
        return 'برتقالي (5A)';
      case 7:
      case 8:
        return 'بني (7.5A)';
      case 10:
        return 'أحمر (10A)';
      case 15:
        return 'أزرق (15A)';
      case 20:
        return 'أصفر (20A)';
      case 25:
        return 'أبيض شفاف (25A)';
      case 30:
        return 'أخضر (30A)';
      case 40:
        return 'برتقالي ماكسي (40A)';
      case 50:
        return 'أحمر ماكسي (50A)';
      default:
        return '$amps A';
    }
  }
}
