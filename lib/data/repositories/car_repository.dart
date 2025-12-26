import '../../core/network/api_client.dart';
import '../models/car_model.dart';

class CarRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<CarModel>> searchCars({
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    double? minPrice,
    double? maxPrice,
    String? make,
    String? transmission,
    String? fuelType,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (location != null) queryParams['location'] = location;
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
    if (minPrice != null) queryParams['min_price'] = minPrice;
    if (maxPrice != null) queryParams['max_price'] = maxPrice;
    if (make != null) queryParams['make'] = make;
    if (transmission != null) queryParams['transmission'] = transmission;
    if (fuelType != null) queryParams['fuel_type'] = fuelType;

    final response = await _apiClient.get('/cars/search', queryParameters: queryParams);
    final List<dynamic> carsJson = response.data['cars'] as List<dynamic>;
    return carsJson.map((json) => CarModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<CarModel> getCarById(int id) async {
    final response = await _apiClient.get('/cars/$id');
    return CarModel.fromJson(response.data['car'] as Map<String, dynamic>);
  }

  Future<List<CarModel>> getAvailableCars({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      '/cars',
      queryParameters: {'page': page, 'limit': limit},
    );
    final List<dynamic> carsJson = response.data['cars'] as List<dynamic>;
    return carsJson.map((json) => CarModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<CarModel> createCar({
    required String make,
    required String model,
    required int year,
    required double pricePerDay,
    double? pricePerHour,
    String? locationAddress,
    double? locationLatitude,
    double? locationLongitude,
    required List<String> images,
    int? seats,
    int? doors,
    String? transmission,
    String? fuelType,
    bool airConditioning = false,
    int? mileageLimit,
    String? description,
  }) async {
    final response = await _apiClient.post(
      '/host/cars',
      data: {
        'make': make,
        'model': model,
        'year': year,
        'price_per_day': pricePerDay,
        if (pricePerHour != null) 'price_per_hour': pricePerHour,
        if (locationAddress != null) 'location_address': locationAddress,
        if (locationLatitude != null) 'location_latitude': locationLatitude,
        if (locationLongitude != null) 'location_longitude': locationLongitude,
        'images': images,
        if (seats != null) 'seats': seats,
        if (doors != null) 'doors': doors,
        if (transmission != null) 'transmission': transmission,
        if (fuelType != null) 'fuel_type': fuelType,
        'air_conditioning': airConditioning,
        if (mileageLimit != null) 'mileage_limit': mileageLimit,
        if (description != null) 'description': description,
      },
    );
    return CarModel.fromJson(response.data['car'] as Map<String, dynamic>);
  }
}
