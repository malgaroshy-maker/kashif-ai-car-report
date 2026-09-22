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
      engineSpecs: json['engineSpecs'] != null && json['engineSpecs'] is Map<String, dynamic>
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
