import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/car_provider.dart';
import '../../widgets/image_carousel.dart';
import '../booking/booking_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  final int carId;

  const CarDetailsScreen({super.key, required this.carId});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  int _currentImageIndex = 0;
  bool _descriptionExpanded = true;
  bool _facilitiesExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarProvider>().getCarById(widget.carId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final carProvider = context.watch<CarProvider>();
    final car = carProvider.selectedCar;

    if (carProvider.isLoading && car == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (car == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: Text('Car not found')),
      );
    }

    // Calculate dates for booking (example: Nov 30 - Dec 23)
    final startDate = DateTime.now().add(const Duration(days: 5));
    final endDate = startDate.add(const Duration(days: 23));
    final days = endDate.difference(startDate).inDays;
    final originalPrice = car.pricePerDay * days;
    final discountedPrice = originalPrice * 0.8; // 20% discount

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car Image with pagination
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (car.images.length > 1) {
                          setState(() {
                            _currentImageIndex = (_currentImageIndex + 1) % car.images.length;
                          });
                        }
                      },
                      child: Container(
                        height: 300,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: car.images.isNotEmpty
                            ? Image.network(
                                car.images[_currentImageIndex % car.images.length],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.directions_car,
                                    size: 100,
                                    color: Colors.grey,
                                  );
                                },
                              )
                            : const Icon(
                                Icons.directions_car,
                                size: 100,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                    // Pagination dots
                    if (car.images.length > 1)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            car.images.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == _currentImageIndex
                                    ? const Color(0xFF2196F3)
                                    : const Color(0xFF2196F3).withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                // Car Info
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  car.make,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${car.model} ${car.year}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${car.pricePerDay.toStringAsFixed(0)}/day',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Specs Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildSpecCard(
                              Icons.settings,
                              'Transmission',
                              car.transmission?.toUpperCase() ?? 'AUTOMATIC',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSpecCard(
                              Icons.people,
                              'Passengers',
                              '${car.seats ?? 4} adults',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSpecCard(
                              Icons.directions_car,
                              'Type',
                              'Hatchback',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSpecCard(
                              Icons.local_gas_station,
                              'Fuel',
                              car.fuelType?.toUpperCase() ?? 'PETROL',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Description Section
                      _buildExpandableSection(
                        title: 'Description',
                        isExpanded: _descriptionExpanded,
                        onToggle: () {
                          setState(() {
                            _descriptionExpanded = !_descriptionExpanded;
                          });
                        },
                        child: Text(
                          car.description ??
                              'Precision engineering meets cutting-edge design for a perfect blend of style and performance. Elevate your journey with innovation and every turn.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Facilities Section
                      _buildExpandableSection(
                        title: 'Facilities',
                        isExpanded: _facilitiesExpanded,
                        onToggle: () {
                          setState(() {
                            _facilitiesExpanded = !_facilitiesExpanded;
                          });
                        },
                        child: Column(
                          children: [
                            _buildFacilityItem(Icons.air, 'Air Conditioning'),
                            _buildFacilityItem(Icons.music_note, 'Music System'),
                            _buildFacilityItem(Icons.bluetooth, 'Bluetooth'),
                            _buildFacilityItem(Icons.gps_fixed, 'GPS Navigation'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Reviews Section
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFF2196F3), size: 20),
                          const SizedBox(width: 4),
                          const Text(
                            '4.9 (24 reviews)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Sample Review
                      _buildReviewItem(
                        name: 'Victoriya',
                        timeAgo: '3 weeks ago',
                        review: 'The vehicle was not only spotless and well-maintained but also exceeded my expectations in terms of comfort and performance.',
                      ),
                      const SizedBox(height: 100), // Space for bottom booking bar
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom Booking Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '\$${originalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '\$${discountedPrice.toStringAsFixed(0)}/day',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd').format(endDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BookingScreen(carId: car.id),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Book a car',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.grey.shade700),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          child,
        ],
      ],
    );
  }

  Widget _buildFacilityItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem({
    required String name,
    required String timeAgo,
    required String review,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF2196F3),
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  review,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
