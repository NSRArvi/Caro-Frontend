import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/controllers/settings_helper_controller.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationBlockScreen extends StatelessWidget {
  final SettingsHelperController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() {
          if (!controller.isLocationEnabled.value) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Location is turned off"),
                ElevatedButton(
                  onPressed: () {
                    Geolocator.openLocationSettings();
                  },
                  child: Text("Enable Location"),
                ),
              ],
            );
          } else if (!controller.hasPermission.value) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Location permission is required"),
                ElevatedButton(
                  onPressed: () {
                    controller.requestPermission();
                  },
                  child: Text("Grant Permission"),
                ),
                ElevatedButton(
                  onPressed: () {
                    openAppSettings();
                  },
                  child: Text("Open App Settings"),
                ),
              ],
            );
          } else {
            return SizedBox.shrink(); // Normal flow (not blocked)
          }
        }),
      ),
    );
  }
}
