import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jimamuapp/controllers/auth_controller.dart';
import 'package:jimamuapp/data/models/delivery_request_model.dart';
import 'package:jimamuapp/modules/delivery/my_deliveries_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/services/api_manager.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/snakckbar_helper.dart';
import '../../order/customer/widgets/location_preview_screen.dart';

class DeliveryDetailsController extends GetxController {
  AuthController authController = Get.find();
  MyDeliveriesController myDeliveriesController = Get.find();

  RxString deliveryOrderId = ''.obs;
  final deliveryDetails = Rxn<DeliveryRequestModel>();
  RxBool isLoading = true.obs;
  RxBool isSendingOTP = false.obs;
  RxBool isOTPVerifying = false.obs;

  RxString? pickupLocation;
  RxString? dropoffLocation;
  LatLng? pickupLatLng;
  LatLng? dropoffLatLng;

  void openLocationOnMap({required LatLng latLng, required String title}) {
    Get.to(() => LocationPreviewScreen(latLng: latLng, title: title));
  }

  // @override
  // void onInit() {
  //   super.onInit();
  //   deliveryOrderId.value = Get.arguments;
  //   deliveryDetails.value = getDeliveryById(deliveryOrderId.value);
  //   loadLocations();
  // }
 @override
void onInit() async {
  super.onInit();

  isLoading.value = true;

  deliveryOrderId.value = Get.arguments;

  await myDeliveriesController.fetchDeliveries();

  final localData = getDeliveryById(deliveryOrderId.value);

  if (localData != null) {
    deliveryDetails.value = localData;
    await loadLocations();
  } else {
    log("Still not found ❌");
  }

  isLoading.value = false;
}
  // DeliveryRequestModel? getDeliveryById(String id) {
  //   final allDeliveries = [
  //     ...myDeliveriesController.ongoingDeliveries.value!,
  //     ...myDeliveriesController.completedDeliveries.value!,
  //   ];

  //   return allDeliveries.firstWhere((d) => deliveryOrderId.value == d.orderId);
  // }
  DeliveryRequestModel? getDeliveryById(String id) {
    final allDeliveries = [
      ...(myDeliveriesController.ongoingDeliveries.value ?? []),
      ...(myDeliveriesController.completedDeliveries.value ?? []),
    ];

    try {
      return allDeliveries.firstWhere(
        (d) => d.orderId.toString() == id.toString(),
      );
    } catch (e) {
      log("Order not found in list ❌ ID: $id");
      return null;
    }
  }

  // loadLocations() async {
  //   final pickupLat = double.parse(deliveryDetails.value!.pickupLatitude);
  //   final pickupLng = double.parse(deliveryDetails.value!.pickupLongitude);

  //   final dropLat = double.parse(deliveryDetails.value!.dropLatitude);
  //   final dropLng = double.parse(deliveryDetails.value!.dropLongitude);

  //   // SET LatLng (THIS WAS MISSING)
  //   pickupLatLng = LatLng(pickupLat, pickupLng);
  //   dropoffLatLng = LatLng(dropLat, dropLng);
  //   List<Placemark> placemarks = await placemarkFromCoordinates(
  //     double.parse(deliveryDetails.value!.pickupLatitude),
  //     double.parse(deliveryDetails.value!.pickupLongitude),
  //   );
  //   final place = placemarks.first;
  //   pickupLocation =
  //       "${place.name}, ${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}"
  //           .obs;
  //   placemarks = await placemarkFromCoordinates(
  //     double.parse(deliveryDetails.value!.dropLatitude),
  //     double.parse(deliveryDetails.value!.dropLongitude),
  //   );
  //   final place2 = placemarks.first;
  //   dropoffLocation =
  //       "${place2.name}, ${place2.street}, ${place2.locality}, ${place2.administrativeArea}, ${place2.postalCode}, ${place2.country}"
  //           .obs;

  //   isLoading.value = false;
  // }
  loadLocations() async {
    if (deliveryDetails.value == null) {
      log("DeliveryDetails is NULL ❌");
      return;
    }

    final pickupLat = double.parse(deliveryDetails.value!.pickupLatitude);
    final pickupLng = double.parse(deliveryDetails.value!.pickupLongitude);

    final dropLat = double.parse(deliveryDetails.value!.dropLatitude);
    final dropLng = double.parse(deliveryDetails.value!.dropLongitude);

    pickupLatLng = LatLng(pickupLat, pickupLng);
    dropoffLatLng = LatLng(dropLat, dropLng);

    List<Placemark> placemarks = await placemarkFromCoordinates(
      pickupLat,
      pickupLng,
    );

    final place = placemarks.first;
    pickupLocation =
        "${place.name}, ${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}"
            .obs;

    placemarks = await placemarkFromCoordinates(dropLat, dropLng);

    final place2 = placemarks.first;
    dropoffLocation =
        "${place2.name}, ${place2.street}, ${place2.locality}, ${place2.administrativeArea}, ${place2.postalCode}, ${place2.country}"
            .obs;

    isLoading.value = false;
  }

  // Future<void> loadLocations() async {
  //   final pickupLat = double.parse(deliveryDetails.value!.pickupLatitude);
  //   final pickupLng = double.parse(deliveryDetails.value!.pickupLongitude);
  //
  //   final dropLat = double.parse(deliveryDetails.value!.dropLatitude);
  //   final dropLng = double.parse(deliveryDetails.value!.dropLongitude);
  //
  //   // SET LatLng (THIS WAS MISSING)
  //   pickupLatLng = LatLng(pickupLat, pickupLng);
  //   dropoffLatLng = LatLng(dropLat, dropLng);
  //
  //   // Reverse geocoding for display text
  //   List<Placemark> placemarks =
  //   await placemarkFromCoordinates(pickupLat, pickupLng);
  //
  //   final place = placemarks.first;
  //   pickupLocation = "${place.name}, ${place.street}, ${place.locality}, "
  //       "${place.administrativeArea}, ${place.country}"
  //       .obs;
  //
  //   placemarks = await placemarkFromCoordinates(dropLat, dropLng);
  //   final place2 = placemarks.first;
  //   dropoffLocation = "${place2.name}, ${place2.street}, ${place2.locality}, "
  //       "${place2.administrativeArea}, ${place2.country}"
  //       .obs;
  // }
  Future<void> sendRiderOtp(String otpType) async {
    try {
      isSendingOTP.value = true;

      final response = await ApiManager.sendOtp(
        authController.token.value,
        deliveryDetails.value!.orderId,
        otpType,
      );

      if (response["success"] == true) {
        showOtpDialog(
          otpType: otpType,
          onVerified: () async {
            await myDeliveriesController.fetchDeliveries();
            deliveryDetails.value = getDeliveryById(deliveryOrderId.value);
            if (otpType == "picked") {
              log("Inside Snackbar show check OtpType picked");
              AppSnackbar.success(
                "Item has been picked successfully!",
                // snackPosition: SnackPosition.BOTTOM,
              );
            }
            if (otpType == "delivered") {
              final index = myDeliveriesController.ongoingDeliveries.value
                  .indexWhere((e) => e.orderId == deliveryOrderId.value);

              if (index != -1) {
                myDeliveriesController.ongoingDeliveries.value.removeAt(index);
                myDeliveriesController.ongoingDeliveries.refresh();
                myDeliveriesController.completedDeliveries.value.add(
                  deliveryDetails.value!,
                );
                myDeliveriesController.completedDeliveries.refresh();
              }

              log("Inside Snackbar show check OtpType delivered");
              AppSnackbar.success(
                "Item has been delivered successfully!",
                // snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
        );
      } else {
        AppSnackbar.error(
          response["message"] ?? "Something went wrong",
          // snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      AppSnackbar.error("Something went wrong");
    } finally {
      isSendingOTP.value = false;
    }
  }

  Future<void> callNow(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Dialer not available');
    }
  }

  Future<void> sendMessage({
    required String phoneNumber,
    required String userName,
  }) async {
    final String message = 'Hi I am $userName';

    final Uri uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('SMS app not available');
    }
  }

  Future<void> showOtpDialog({
    required String otpType,
    required Function() onVerified,
  }) async {
    String enteredOtp = '';

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Enter OTP Code", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SizedBox(height: 12,),
            Text(
              "We have sent otp to sender email for verifying delivery progress",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.black,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: 22),
            OtpTextField(
              fieldWidth: Get.width * 0.14,
              numberOfFields: 4,
              borderColor: AppColors.kGreyBlack,
              focusedBorderColor: AppColors.primaryColor,
              showFieldAsBox: true,
              onCodeChanged: (String code) {},
              onSubmit: (String code) {
                enteredOtp = code;
                log("Entered Otp $enteredOtp");
              },
            ),
            const SizedBox(height: 24),
            Obx(
              () => isOTPVerifying.value
                  ? const CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          isOTPVerifying.value = true;
                          if (enteredOtp.length != 4) {
                            ScaffoldMessenger.of(Get.context!).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please enter a valid 4-digit OTP",
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            isOTPVerifying.value = false;
                            return;
                          }

                          final response = await ApiManager.verifyOtp(
                            authController.token.value,
                            deliveryDetails.value!.orderId,
                            otpType,
                            enteredOtp,
                          );

                          isOTPVerifying.value = false;

                          if (response['success']) {
                            Get.back();
                            onVerified();
                          } else {
                            isOTPVerifying.value = false;
                            Get.back();
                            AppSnackbar.error(response['success']);
                          }
                        },
                        child: const Text(
                          "Verify OTP",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
