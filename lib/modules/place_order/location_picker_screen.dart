import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jimamuapp/modules/place_order/national/placing_order_controller.dart';
import 'package:jimamuapp/utils/app_colors.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final PlacingOrderController controller = Get.find();
  TextEditingController searchController = TextEditingController();

  LatLng? _pickedLocation;

  List<Map<String, dynamic>> _placeSuggestions = [];
  String _sessionToken = '';

  GoogleMapController? _mapController;

  Future<void> _getPlaceSuggestions(String input) async {
    const apiKey = 'AIzaSyA_L-EJWV8sVrEVWFwLuGxQuJLLCNkt0XE';
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=geocode&language=en&key=$apiKey&sessiontoken=$_sessionToken';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final predictions = data['predictions'] as List;

      setState(() {
        _placeSuggestions = predictions
            .map(
              (p) => {
                'description': p['description'],
                'place_id': p['place_id'],
              },
            )
            .toList();
      });
    } else {
      print("Places API Error: ${response.body}");
    }
  }

  Future<LatLng?> _getLatLngFromPlaceId(String placeId) async {
    const apiKey = 'AIzaSyA_L-EJWV8sVrEVWFwLuGxQuJLLCNkt0XE'; // same API key
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final location = data['result']['geometry']['location'];
      return LatLng(location['lat'], location['lng']);
    }
    return null;
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    Placemark place = placemarks.first;
    return "${place.name}, ${place.street}, ${place.locality}, ${place.country}";
  }

  Future<LatLng> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw 'Location permissions are permanently denied.';
    }

    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  @override
  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      LatLng loc = await _getCurrentLocation();
      setState(() => _pickedLocation = loc);
    } catch (e) {
      print('Location error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  void _confirmSelection() async {
    if (_pickedLocation != null) {
      final address = await _getAddressFromLatLng(_pickedLocation!);
      Navigator.pop(context, {'latLng': _pickedLocation, 'address': address});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text("Select Location"),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          TextButton(
            onPressed: _confirmSelection,
            child: const Text("Done", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search location",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  if (value.length > 2) {
                    _sessionToken = DateTime.now().millisecondsSinceEpoch
                        .toString();
                    _getPlaceSuggestions(value);
                  } else {
                    setState(() => _placeSuggestions.clear());
                  }
                },
              ),
            ),
            if (_placeSuggestions.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _placeSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _placeSuggestions[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(suggestion['description']),
                      onTap: () async {
                        final latLng = await _getLatLngFromPlaceId(
                          suggestion['place_id'],
                        );
                        if (latLng != null) {
                          setState(() {
                            _pickedLocation = latLng;
                            _placeSuggestions.clear();
                            searchController.text = suggestion['description'];
                          });
                          if (_mapController == null) return;
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(latLng, 15),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            Expanded(
              child: _pickedLocation == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    )
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _pickedLocation!,
                        zoom: 15,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId("picked"),
                          position: _pickedLocation!,
                          draggable: true,
                          onDragEnd: (newPos) {
                            setState(() => _pickedLocation = newPos);
                          },
                        ),
                      },
                      onTap: _onMapTap,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
