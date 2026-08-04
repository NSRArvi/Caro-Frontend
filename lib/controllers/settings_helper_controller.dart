
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jimamuapp/utils/app_colors.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;

import '../utils/location_helper.dart';

class SettingsHelperController extends GetxController {
  Rxn<Position> pos = Rxn<Position>(); // Nullable Rx
  RxString currentLocationAddress = "".obs;
  var isLocationEnabled = false.obs;
  var hasPermission = false.obs;
  bool isDialogOpen = false;

  @override
  void onInit() {
    super.onInit();
    initLocationSettings();
    // checkLocationStatus();
    // listenMode();
    // fetchCurrentLocation();
  }

  Future<void> initLocationSettings() async {
    await checkLocationStatus(); // wait until done

    // Now start listening and fetching
    listenMode();

    if (isLocationEnabled.value && hasPermission.value) {
      fetchCurrentLocation();
    } else {
      showBlockDialog();
    }
  }

  Future<void> listenMode() async {
    await checkLocationStatus();
    Geolocator.getServiceStatusStream().listen((status) {
      isLocationEnabled.value = (status == ServiceStatus.enabled);
      showBlockDialog();
    });

    everAll([isLocationEnabled, hasPermission], (_) {
      showBlockDialog();
    });
  }

  Future<void> checkLocationStatus() async {
    // Check if service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    isLocationEnabled.value = serviceEnabled;

    // Check permission
    var status = await Permission.location.status;
    hasPermission.value = status.isGranted;
  }

  Future<void> requestPermission() async {
    final result = await Permission.location.request();
    hasPermission.value = result.isGranted;
    showBlockDialog();
  }

  Future<void> fetchCurrentLocation() async {
    try {
      Position? position = await LocationHelper.getCurrentPosition();
      if (position != null) {
        pos.value = position;
        String? address = await LocationHelper.getAddressFromLatLng(position);
        if (address != null) {
          currentLocationAddress.value = address;
        }
      } else {
        currentLocationAddress.value = "Unable to fetch location";
      }
    } catch (e) {
      currentLocationAddress.value = "Error: $e";
    }

    debugPrint("Current Location $pos $currentLocationAddress");
  }

  void showBlockDialog() {
    if ((!isLocationEnabled.value || !hasPermission.value) && !isDialogOpen) {
      isDialogOpen = true;

      Get.dialog(
        useSafeArea: false,
        PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: Get.width / 1.2,
                      height: Get.width / 1.2,
                      child: Image.asset(
                        'assets/images/location_permission.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    40.verticalSpace,
                    Text(
                      !isLocationEnabled.value
                          ? "Enable your location"
                          : "Location permission is required",
                      style: TextStyle(
                        fontSize: 24.r,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    20.verticalSpace,
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 40.w),
                      child: Text(
                        "Enable location access so we can show your current, pickup, and destination locations correctly.",
                        style: TextStyle(
                          fontSize: 14.r,
                          color: AppColors.black700,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    60.verticalSpace,
                    GestureDetector(
                      onTap: () {
                        if (!isLocationEnabled.value) {
                          Geolocator.openLocationSettings();
                        } else if (!hasPermission.value) {
                          requestPermission();
                        }
                      },
                      child: Container(
                        width: Get.width - 40.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          !isLocationEnabled.value
                              ? "Enable Location"
                              : "Grant Permission",
                          style: TextStyle(
                            fontSize: 16.r,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false, // cannot tap outside to close
      );
    } else if (isLocationEnabled.value && hasPermission.value && isDialogOpen) {
      isDialogOpen = false;
      if (Get.isDialogOpen!) Get.back();
      fetchCurrentLocation();
    }
  }
}
