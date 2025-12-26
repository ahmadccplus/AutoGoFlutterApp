import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/car_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/brand_carousel.dart';
import '../../widgets/recommendation_card.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../car/car_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pickupLocationController = TextEditingController();
  final _scrollController = ScrollController();
  DateTime? _pickupDate;
  DateTime? _returnDate;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoadCars();
    });
  }

  Future<void> _checkAuthAndLoadCars() async {
    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = await authProvider.checkAuthStatus();
    
    if (!mounted) return;
    
    if (!isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }
    
    context.read<CarProvider>().loadAvailableCars(reset: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<CarProvider>().loadAvailableCars();
    }
  }

  Future<void> _selectPickupDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _pickupDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _pickupDate = picked;
      });
    }
  }

  Future<void> _selectReturnDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: _pickupDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _returnDate ?? (_pickupDate?.add(const Duration(days: 1)) ?? DateTime.now().add(const Duration(days: 1))),
    );

    if (picked != null) {
      setState(() {
        _returnDate = picked;
      });
    }
  }

  void _searchCars() {
    final carProvider = context.read<CarProvider>();
    carProvider.setSearchLocation(_pickupLocationController.text.isEmpty ? null : _pickupLocationController.text);
    if (_pickupDate != null && _returnDate != null) {
      carProvider.setDateRange(_pickupDate, _returnDate);
    }
    carProvider.searchCars(reset: true);
  }

  @override
  void dispose() {
    _pickupLocationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carProvider = context.watch<CarProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Location Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your location',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Cairo, Egypt',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Search Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Pick up location field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _pickupLocationController,
                      decoration: const InputDecoration(
                        hintText: 'Pick up location',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Date fields
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectPickupDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  _pickupDate != null
                                      ? DateFormat('MMM dd').format(_pickupDate!)
                                      : 'Pick up date',
                                  style: TextStyle(
                                    color: _pickupDate != null ? Colors.black : Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectReturnDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  _returnDate != null
                                      ? DateFormat('MMM dd').format(_returnDate!)
                                      : 'return date',
                                  style: TextStyle(
                                    color: _returnDate != null ? Colors.black : Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _searchCars,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Search car',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Content Section
            Expanded(
              child: carProvider.isLoading && carProvider.cars.isEmpty
                  ? const LoadingIndicator()
                  : SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Brand Carousel
                          const BrandCarousel(),
                          const SizedBox(height: 24),
                          // Recommendation Section
                          if (carProvider.cars.isNotEmpty)
                            RecommendationCard(
                              car: carProvider.cars.first,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CarDetailsScreen(carId: carProvider.cars.first.id),
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 24),
                          // More Cars Section
                          if (carProvider.cars.length > 1) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Text(
                                'More Cars',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...carProvider.cars.skip(1).map((car) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  child: _buildCarListItem(car),
                                )),
                          ],
                          const SizedBox(height: 100), // Space for bottom nav
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          _navigateToTab(index);
        },
      ),
    );
  }

  void _navigateToTab(int index) {
    switch (index) {
      case 0:
        // Already on Home screen
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/bookings');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/post-car');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/account');
        break;
    }
  }

  Widget _buildCarListItem(car) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CarDetailsScreen(carId: car.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Car Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Container(
                width: 120,
                height: 100,
                color: Colors.grey.shade200,
                child: car.images.isNotEmpty
                    ? Image.network(
                        car.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.directions_car, size: 40, color: Colors.grey);
                        },
                      )
                    : const Icon(Icons.directions_car, size: 40, color: Colors.grey),
              ),
            ),
            // Car Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${car.model} ${car.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      car.make,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (car.seats != null) ...[
                          const Icon(Icons.people, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${car.seats}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(width: 12),
                        ],
                        if (car.transmission != null) ...[
                          const Icon(Icons.settings, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(car.transmission!.toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${car.pricePerDay.toStringAsFixed(0)}/day',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
