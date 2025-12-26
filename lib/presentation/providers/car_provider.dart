import 'package:flutter/foundation.dart';
import '../../data/models/car_model.dart';
import '../../data/repositories/car_repository.dart';

class CarProvider extends ChangeNotifier {
  final CarRepository _repository = CarRepository();

  List<CarModel> _cars = [];
  CarModel? _selectedCar;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasMore = true;
  int _currentPage = 1;

  // Search filters
  String? _searchLocation;
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minPrice;
  double? _maxPrice;
  String? _selectedMake;
  String? _selectedTransmission;
  String? _selectedFuelType;

  List<CarModel> get cars => _cars;
  CarModel? get selectedCar => _selectedCar;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  // Getters for filters
  String? get searchLocation => _searchLocation;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String? get selectedMake => _selectedMake;
  String? get selectedTransmission => _selectedTransmission;
  String? get selectedFuelType => _selectedFuelType;

  Future<void> searchCars({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _cars = [];
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final results = await _repository.searchCars(
        location: _searchLocation,
        startDate: _startDate,
        endDate: _endDate,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        make: _selectedMake,
        transmission: _selectedTransmission,
        fuelType: _selectedFuelType,
        page: _currentPage,
      );

      if (reset) {
        _cars = results;
      } else {
        _cars.addAll(results);
      }

      _hasMore = results.length >= 20;
      _currentPage++;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAvailableCars({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _cars = [];
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final results = await _repository.getAvailableCars(page: _currentPage);

      if (reset) {
        _cars = results;
      } else {
        _cars.addAll(results);
      }

      _hasMore = results.length >= 20;
      _currentPage++;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCarById(int id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _selectedCar = await _repository.getCarById(id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter setters
  void setSearchLocation(String? location) {
    _searchLocation = location;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }

  void setMake(String? make) {
    _selectedMake = make;
    notifyListeners();
  }

  void setTransmission(String? transmission) {
    _selectedTransmission = transmission;
    notifyListeners();
  }

  void setFuelType(String? fuelType) {
    _selectedFuelType = fuelType;
    notifyListeners();
  }

  void clearFilters() {
    _searchLocation = null;
    _startDate = null;
    _endDate = null;
    _minPrice = null;
    _maxPrice = null;
    _selectedMake = null;
    _selectedTransmission = null;
    _selectedFuelType = null;
    notifyListeners();
  }
}



