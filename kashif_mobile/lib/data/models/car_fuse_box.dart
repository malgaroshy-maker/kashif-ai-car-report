import 'package:flutter/material.dart';

enum FuseBoxLocationType {
  engineBay('حجرة المحرك (تحت الكبوت)', Icons.directions_car_filled_rounded),
  cabin('المقصورة الداخلية (تحت المقود / الطبلون)', Icons.airline_seat_recline_normal_rounded),
  trunk('صندوق الأمتعة الخلفي (الشنطة)', Icons.luggage_rounded),
  special('موقع فريد / فيوزات خاصة وحساسة', Icons.stars_rounded);

  final String labelArabic;
  final IconData icon;
  const FuseBoxLocationType(this.labelArabic, this.icon);
}

class FuseSlot {
  final String slotId; // e.g. "F1", "F15", "R3"
  final String label; // e.g. "CIG / DLC"
  final String nameArabic; // e.g. "فيوز ولاعة السجائر ومدخل الفحص OBD"
  final int ratingAmps; // e.g. 15
  final bool isRelay; // false for blade fuse, true for relay
  final String relayType; // e.g. "4-Pin Micro Relay"
  final bool isSpecial;
  final String descriptionArabic;
  final List<String> symptoms; // e.g. ["شاشة جهاز الفحص OBD لا تضيء"]
  final List<String> associatedDTCs; // e.g. ["U0100", "U0155"]
  final String testingTip;
  final int gridRow;
  final int gridCol;
  final int colSpan;

  const FuseSlot({
    required this.slotId,
    required this.label,
    required this.nameArabic,
    required this.ratingAmps,
    this.isRelay = false,
    this.relayType = '',
    this.isSpecial = false,
    required this.descriptionArabic,
    this.symptoms = const [],
    this.associatedDTCs = const [],
    this.testingTip = '',
    this.gridRow = 0,
    this.gridCol = 0,
    this.colSpan = 1,
  });

  int get colorValue {
    if (isRelay) return 0xFF2A374A; // Slate dark for automotive relays
    switch (ratingAmps) {
      case 5:
        return 0xFFFFB74D; // Amber/Orange 5A
      case 7:
      case 8:
        return 0xFF8D6E63; // Brown 7.5A
      case 10:
        return 0xFFE53935; // Red 10A
      case 15:
        return 0xFF1E88E5; // Blue 15A
      case 20:
        return 0xFFFDD835; // Yellow 20A
      case 25:
        return 0xFFEEEEEE; // Clear/White 25A
      case 30:
        return 0xFF43A047; // Green 30A
      case 40:
        return 0xFFFB8C00; // Orange Maxi 40A
      case 50:
      case 60:
        return 0xFFD32F2F; // Red Maxi 50A/60A
      default:
        return 0xFFD4AF37; // Luxury Gold
    }
  }

  String get colorNameArabic {
    if (isRelay) return 'مرحل كتاوت (Relay)';
    switch (ratingAmps) {
      case 5:
        return 'برتقالي فاتح (5A)';
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
        return '$ratingAmps A';
    }
  }
}

class EquipmentFuseMapping {
  final String equipmentEnglish;
  final String equipmentArabic;
  final List<int> fuseNumbers;
  final String? category;
  final String? notesArabic;

  const EquipmentFuseMapping({
    required this.equipmentEnglish,
    required this.equipmentArabic,
    required this.fuseNumbers,
    this.category,
    this.notesArabic,
  });
}

class VehicleFuseBox {
  final String id;
  final String nameArabic;
  final FuseBoxLocationType locationType;
  final String detailedLocationArabic;
  final String accessInstructions;
  final String? diagramImage;
  final bool isSpecialLocation;
  final String? specialBadgeText;
  final String? realisticCoverNote;
  final List<FuseSlot> slots;
  final List<EquipmentFuseMapping> equipmentMappings;
  final String? cardPartNumber;
  final bool hasPullTab;
  final int totalRows;
  final int totalCols;

  const VehicleFuseBox({
    required this.id,
    required this.nameArabic,
    required this.locationType,
    required this.detailedLocationArabic,
    required this.accessInstructions,
    this.diagramImage,
    this.isSpecialLocation = false,
    this.specialBadgeText,
    this.realisticCoverNote,
    required this.slots,
    this.equipmentMappings = const [],
    this.cardPartNumber,
    this.hasPullTab = false,
    this.totalRows = 5,
    this.totalCols = 6,
  });
}

class CarVehicleModel {
  final String id;
  final String make;
  final String makeArabic;
  final String model;
  final String modelArabic;
  final String yearRange;
  final String bodyType;
  final String obdLocation;
  final List<VehicleFuseBox> fuseBoxes;

  const CarVehicleModel({
    required this.id,
    required this.make,
    required this.makeArabic,
    required this.model,
    required this.modelArabic,
    required this.yearRange,
    required this.bodyType,
    required this.obdLocation,
    required this.fuseBoxes,
  });
}
