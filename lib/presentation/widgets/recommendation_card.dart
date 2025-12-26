import 'package:flutter/material.dart';
import '../../data/models/car_model.dart';

class RecommendationCard extends StatelessWidget {
  final CarModel car;
  final VoidCallback onTap;

  const RecommendationCard({
    super.key,
    required this.car,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommendation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to all recommendations
                },
                child: const Text(
                  'view all',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating and Availability Badge
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFF2196F3),
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '4.9/5.0',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Available now',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Car Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: car.images.isNotEmpty
                          ? Image.network(
                              car.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.directions_car,
                                  size: 80,
                                  color: Colors.grey,
                                );
                              },
                            )
                          : const Icon(
                              Icons.directions_car,
                              size: 80,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  // Car Details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  car.make,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${car.model} ${car.year}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '\$${car.pricePerDay.toStringAsFixed(0)}/day',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Specs Row
                        Row(
                          children: [
                            _buildSpecItem(
                              Icons.local_gas_station,
                              car.fuelType?.toUpperCase() ?? 'PETROL',
                            ),
                            const SizedBox(width: 16),
                            _buildSpecItem(
                              Icons.people,
                              '${car.seats ?? 4}',
                            ),
                            const SizedBox(width: 16),
                            _buildSpecItem(
                              Icons.settings,
                              car.transmission?.toUpperCase() ?? 'AUTOMATIC',
                            ),
                            const SizedBox(width: 16),
                            _buildSpecItem(
                              Icons.directions_car,
                              'Sedan',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF2196F3),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

