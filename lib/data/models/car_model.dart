class CarModel {
  final int id;
  final int ownerId;
  final String make;
  final String model;
  final int year;
  final double pricePerDay;
  final double? pricePerHour;
  final double? locationLatitude;
  final double? locationLongitude;
  final String? locationAddress;
  final List<String> images;
  final bool isAvailable;
  final int? seats;
  final int? doors;
  final String? transmission;
  final String? fuelType;
  final bool airConditioning;
  final int? mileageLimit;
  final String? description;
  final Map<String, dynamic>? specs;
  final DateTime createdAt;

  CarModel({
    required this.id,
    required this.ownerId,
    required this.make,
    required this.model,
    required this.year,
    required this.pricePerDay,
    this.pricePerHour,
    this.locationLatitude,
    this.locationLongitude,
    this.locationAddress,
    required this.images,
    required this.isAvailable,
    this.seats,
    this.doors,
    this.transmission,
    this.fuelType,
    this.airConditioning = false,
    this.mileageLimit,
    this.description,
    this.specs,
    required this.createdAt,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'] as int,
      ownerId: json['owner_id'] as int,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      pricePerDay: (json['price_per_day'] as num).toDouble(),
      pricePerHour: json['price_per_hour'] != null
          ? (json['price_per_hour'] as num).toDouble()
          : null,
      locationLatitude: json['location_latitude'] != null
          ? (json['location_latitude'] as num).toDouble()
          : null,
      locationLongitude: json['location_longitude'] != null
          ? (json['location_longitude'] as num).toDouble()
          : null,
      locationAddress: json['location_address'] as String?,
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      isAvailable: json['is_available'] as bool? ?? true,
      seats: json['seats'] as int?,
      doors: json['doors'] as int?,
      transmission: json['transmission'] as String?,
      fuelType: json['fuel_type'] as String?,
      airConditioning: json['air_conditioning'] as bool? ?? false,
      mileageLimit: json['mileage_limit'] as int?,
      description: json['description'] as String?,
      specs: json['specs'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'make': make,
      'model': model,
      'year': year,
      'price_per_day': pricePerDay,
      'price_per_hour': pricePerHour,
      'location_latitude': locationLatitude,
      'location_longitude': locationLongitude,
      'location_address': locationAddress,
      'images': images,
      'is_available': isAvailable,
      'seats': seats,
      'doors': doors,
      'transmission': transmission,
      'fuel_type': fuelType,
      'air_conditioning': airConditioning,
      'mileage_limit': mileageLimit,
      'description': description,
      'specs': specs,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get fullName => '$make $model ($year)';
}



