import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jimamuapp/controllers/auth_controller.dart';
import 'package:jimamuapp/data/models/delivery_request_model.dart';
import 'package:jimamuapp/data/services/api_manager.dart';
import 'package:jimamuapp/modules/order/customer/my_order_controller.dart';
import 'package:jimamuapp/ui/widgets/custom_loader.dart';
import 'package:jimamuapp/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/snakckbar_helper.dart';
import '../widgets/location_preview_screen.dart';

class OrderDetailsController extends GetxController {
  AuthController authController = Get.find();
  MyOrderController myOrderController = Get.find();
  int type = 0;

  // RxString? pickupLocation;
  // RxString? dropoffLocation;
  RxString pickupLocation = ''.obs;
  RxString dropoffLocation = ''.obs;
  RxString orderId = ''.obs;
  RxBool isLoading = false.obs;
  final orderDetails = Rxn<DeliveryRequestModel>();
  final acceptedRider = Rxn<Map<String, dynamic>>();
  var selectedReason = Rxn<Map<String, dynamic>>();
  LatLng? pickupLatLng;
  LatLng? dropoffLatLng;

  RxList<Map<String, dynamic>> reasons = <Map<String, dynamic>>[].obs;
  @override
  void onInit() {
    super.onInit();
    orderId.value = Get.arguments.toString();
    fetchOrderDetails();
  }

  void openLocationOnMap({required LatLng latLng, required String title}) {
    Get.to(() => LocationPreviewScreen(latLng: latLng, title: title));
  }

  fetchOrderDetails() async {
    isLoading.value = true;

    final response = await ApiManager.fetchOrderDetails(
      authController.token.value,
      orderId.value,
    );

    if (response != null) {
      orderDetails.value = response;

      if (orderDetails.value!.status != 'pending') {
        acceptedRider.value = {
          "name": orderDetails.value!.orderAttempts[0].riderBids[0].name,
          // "profileImage":
          // orderDetails.value!.orderAttempts[0].riderBids[0].profileImage ?? '',
          "profileImage":
              orderDetails.value!.orderAttempts[0].riderBids[0].profileImage,
          "offerAmount":
              orderDetails.value!.orderAttempts[0].riderBids[0].bidAmount,
          "rating": 4.5,
          "phone":
              orderDetails.value!.orderAttempts[0].riderBids[0].phoneNumber ??
              '',
          "country_code":
              orderDetails.value!.orderAttempts[0].riderBids[0].countryCode ??
              '',
        };
      }

      await loadLocations();
    } else {
      AppSnackbar.error("Something went wrong. Try later!");
      Get.back();
    }

    isLoading.value = false;
  }

  Future<void> loadLocations() async {
    final pickupLat = double.parse(orderDetails.value!.pickupLatitude);
    final pickupLng = double.parse(orderDetails.value!.pickupLongitude);

    final dropLat = double.parse(orderDetails.value!.dropLatitude);
    final dropLng = double.parse(orderDetails.value!.dropLongitude);

    pickupLatLng = LatLng(pickupLat, pickupLng);
    dropoffLatLng = LatLng(dropLat, dropLng);

    pickupLocation.value = await _getReadableAddress(pickupLat, pickupLng);

    dropoffLocation.value = await _getReadableAddress(dropLat, dropLng);
  }

  Future<String> _getReadableAddress(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      final place = placemarks.first;

      final parts = <String>[
        if (place.street != null && place.street!.isNotEmpty) place.street!,
        if (place.subLocality != null && place.subLocality!.isNotEmpty)
          place.subLocality!,
        if (place.locality != null && place.locality!.isNotEmpty)
          place.locality!,
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty)
          place.administrativeArea!,
        if (place.country != null && place.country!.isNotEmpty) place.country!,
      ];

      return parts.join(', ');
    } catch (e) {
      debugPrint("Geocoding error: $e");
      return "Location not available";
    }
  }

  refreshOrderDetails() async {
    final response = await ApiManager.fetchOrderDetails(
      authController.token.value,
      orderId.value,
    );
    if (response != null) {
      orderDetails.value = response;
      final index = myOrderController.ongoingOrders.value.indexWhere(
        (e) => e.orderId == orderId.value,
      );

      if (orderDetails.value!.status == "delivered" && index != -1) {
        await myOrderController.fetchOrders();
      }

      if (orderDetails.value!.status != 'pending') {
        acceptedRider.value = {
          "name": orderDetails.value!.orderAttempts[0].riderBids[0].name,
          "profileImage":
              orderDetails.value!.orderAttempts[0].riderBids[0].profileImage ??
              '', // fallback
          "offerAmount":
              orderDetails.value!.orderAttempts[0].riderBids[0].bidAmount,
          "rating": 4.5,
          "phone":
              orderDetails.value!.orderAttempts[0].riderBids[0].phoneNumber ??
              '',
          "country_code":
          orderDetails.value!.orderAttempts[0].riderBids[0].countryCode ??
              '',
        };
      }
      await loadLocations();
    }
  }

  cancelOrder() async {
    if (selectedReason.value == null) {
      AppSnackbar.error(
        "Please select a valid reason before canceling your order.",
      );
      return;
    }
    try {
      CustomLoading.loadingDialog();
      final response = await ApiManager.cancelOrder(
        authController.token.value,
        orderId.value,
        selectedReason.value!["name"],
      );

      if (response) {
        Get.back();
        Get.back();
        Future.delayed(const Duration(milliseconds: 200), () {
          Get.back(result: true);
          AppSnackbar.success("Your order has been canceled!");
        });
      } else {
        Get.back();
        AppSnackbar.error(
          "Failed to cancel the order. Please try again.",
          // backgroundColor: AppColors.primaryColor.withOpacity(0.25),
        );
      }
    } catch (e) {
      Get.back(); // close loader
      AppSnackbar.error("Request failed! Unknown error occurred.");
    }
  }

  Future<void> acceptOrder1(int riderId) async {
    try {
      Get.dialog(
        Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
        barrierDismissible: false,
      );

      final response = await ApiManager.acceptRiderBid(
        authController.token.value,
        orderId.value,
        orderDetails.value!.orderAttempts[0].orderTrackingNumber,
        riderId,
      );

      if (response['success']) {
        final clientSecret = response['data']['client_secret'];
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Caro',
          ),
        );

        await Stripe.instance.presentPaymentSheet();
        refreshOrderDetails();
        Get.back();
        AppSnackbar.success("Selected offer has been accepted!");
      }
    } catch (e) {
      Get.back(); // close loader
      AppSnackbar.error("Request failed! Unknown error occurred.");
    }
  }

  Future<void> acceptOrder(int riderId) async {
    try {
      Get.dialog(
        Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
        barrierDismissible: false,
      );

      final response = await ApiManager.acceptRiderBid(
        authController.token.value,
        orderId.value,
        orderDetails.value!.orderAttempts[0].orderTrackingNumber,
        riderId,
      );

      if (response['success']) {
        final clientSecret = response['data']['client_secret'];
        log("Client Secret: $clientSecret");
        // FIXED HERE
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Caro',
          ),
        );

        // 🔥 THIS WILL OPEN STRIPE UI
        await Stripe.instance.presentPaymentSheet();

        Get.back(); // close loader

        refreshOrderDetails();

        AppSnackbar.success("Payment Successful & Order Accepted!");
      }
    } catch (e) {
      Get.back();
      AppSnackbar.error("Payment failed or cancelled");
      log("Stripe Error: $e");
    }
  }

  Future<void> rejectOrder(int riderId) async {
    try {
      Get.dialog(
        Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
        barrierDismissible: false,
      );

      final response = await ApiManager.rejectRiderBid(
        authController.token.value,
        orderId.value,
        //orderDetails.value!.orderAttempts[0].orderTrackingNumber,
        riderId,
      );

      if (response) {
        refreshOrderDetails();
        Get.back();
        AppSnackbar.success("Selected offer has been rejected!");
      }
    } catch (e) {
      Get.back(); // close loader
      AppSnackbar.error("Request failed! Unknown error occurred.");
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

  fetchOrderCancelReasons() async {
    CustomLoading.loadingDialog();
    final response = await ApiManager.fetchOrderCancelReasons(
      token: authController.token.value,
    );
    log("getting response $response");
    reasons.value = List<Map<String, dynamic>>.from(response['data']);
    log("Reason List ${reasons.value}");
    Get.back();
    showReasonListBottomSheet();
  }

  void showReasonListBottomSheet() {
    Get.bottomSheet(
      isDismissible: false,
      Container(
        decoration: BoxDecoration(
          color: const Color(0xffF1F4F3),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grab Handle
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            24.verticalSpace,
            Row(
              children: [
                GestureDetector(
                  onTap: Get.back,
                  child: const Icon(Icons.arrow_back_ios),
                ),
                16.horizontalSpace,
                const Text(
                  "Select an Option",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            24.verticalSpace,
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: reasons.length,
                separatorBuilder: (context, index) => 6.verticalSpace,
                itemBuilder: (context, index) {
                  final item = reasons[index];
                  return Obx(() {
                    final isSelected =
                        selectedReason.value?['id'] == item['id'];

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          item['name'],
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.black,
                          ),
                        ),
                        trailing: Container(
                          height: 24,
                          width: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      AppColors.primaryColor.withAlpha(175),
                                      AppColors.primaryColor,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.grey.shade200,
                                      Colors.grey.shade500,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.7),
                                blurRadius: 2,
                                offset: const Offset(-2, -2),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 2,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                        onTap: () {
                          selectedReason.value = item;
                        },
                      ),
                    );
                  });
                },
              ),
            ),
            24.verticalSpace,
            InkWell(
              onTap: cancelOrder,
              child: Container(
                width: double.infinity,
                height: 45.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Cancel Order",
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}
