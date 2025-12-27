import 'package:flutter/material.dart';
import '../../../data/models/car_model.dart';
import '../../widgets/image_carousel.dart';

class CarCard extends StatelessWidget {
  final CarModel car;
  final VoidCallback onTap;

  const CarCard({
    super.key,
    required this.car,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: ImageCarousel(
                images: car.images.isNotEmpty ? car.images : [''],
                height: 200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.fullName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (car.seats != null) ...[
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${car.seats} seats', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(width: 16),
                      ],
                      if (car.transmission != null) ...[
                        Icon(Icons.settings, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          car.transmission!.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (car.fuelType != null) ...[
                        Icon(Icons.local_gas_station, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          car.fuelType!.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${car.pricePerDay.toStringAsFixed(0)}/day',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (car.locationAddress != null)
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 100,
                              child: Text(
                                car.locationAddress!,
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}








