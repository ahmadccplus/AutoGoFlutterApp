import 'package:flutter/material.dart';

class BrandCarousel extends StatelessWidget {
  const BrandCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final brands = [
      {'name': 'BMW', 'icon': Icons.directions_car},
      {'name': 'Honda', 'icon': Icons.directions_car},
      {'name': 'Mazda', 'icon': Icons.directions_car},
      {'name': 'Mercedes', 'icon': Icons.directions_car},
      {'name': 'Toyota', 'icon': Icons.directions_car},
      {'name': 'Ford', 'icon': Icons.directions_car},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Brand',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to all brands
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
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final brand = brands[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      brand['icon'] as IconData,
                      size: 32,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      brand['name'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

