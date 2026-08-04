import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPreviewScreen extends StatelessWidget {
  final LatLng latLng;
  final String title;

  const LocationPreviewScreen({
    super.key,
    required this.latLng,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: latLng,
          zoom: 16,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('location'),
            position: latLng,
          ),
        },
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
      ),
    );
  }
}
