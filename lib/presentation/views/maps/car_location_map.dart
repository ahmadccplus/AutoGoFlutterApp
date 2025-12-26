import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CarLocationMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? carName;

  const CarLocationMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.carName,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('car_location'),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(
              title: carName ?? 'Car Location',
            ),
          ),
        },
        zoomControlsEnabled: true,
        myLocationEnabled: false,
      ),
    );
  }
}



