import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<bool> handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static Future<Position?> getCurrentPosition() async {
    bool hasPermission = await handlePermission();
    if (!hasPermission) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static Future<String?> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        String fullAddress = [
          place.street,
          place.subLocality,
          place.locality,
        ].where((e) => e != null && e.isNotEmpty).join(", ");

        return fullAddress;
      }
      return null;
    } catch (e) {
      print("Error getting address: $e");
      return null;
    }
  }

static Future<String> getAddress(double lat, double lng) async {
  final placemarks = await placemarkFromCoordinates(lat, lng);
  final place = placemarks.first;

  return "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
}
}
