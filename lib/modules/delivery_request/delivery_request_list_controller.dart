import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/controllers/auth_controller.dart';
import 'package:jimamuapp/data/models/delivery_request_model.dart';
import 'package:jimamuapp/data/services/api_manager.dart';
import 'package:jimamuapp/utils/app_typography.dart';

import '../../utils/app_colors.dart';
import '../../utils/snakckbar_helper.dart';

class DeliveryRequestListController extends GetxController {
  AuthController authController = Get.find();
  Rx<bool> isLoading = false.obs;
  Rx<bool> isBidSubmitting = false.obs;
  var deliveryRequestList = Rxn<List<DeliveryRequestModel>>();
  var myBidsList = Rxn<List<DeliveryRequestModel>>();
  Rx<double> addressSecHeight = 0.0.obs;
  Rx<double> fare = 0.0.obs;
  Rx<double> offeredAmount = 0.0.obs;

  RxInt selectedTab = 0.obs;

  final key = GlobalKey<FormState>();
  TextEditingController bidAmountController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchNewDeliveryRequest();
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  fetchNewDeliveryRequest() async {
    isLoading.value = true;
    final response = await ApiManager.fetchNewDeliveryRequestList(
      authController.token.value,
    );
    log("From fetchNewOrders $response");
    if (response != null && response.success == true) {
      log("From fetchNewOrders inside if");
      deliveryRequestList.value = response.data.where((data) {
        if (data.orderAttempts.isEmpty) {
          return false;
        }

        return !data.orderAttempts.first.riderBids.any(
          (e) => e.riderId == authController.riderProfile.value?.riderId!,
        );
      }).toList();

      myBidsList.value = response.data.where((data) {
        if (data.orderAttempts.isEmpty) {
          return false;
        }

        return data.orderAttempts.first.riderBids.any(
          (e) => e.riderId == authController.riderProfile.value?.riderId,
        );
      }).toList();

      isLoading.value = false;
    } else {
      isLoading.value = false;
    }
  }

  int? getMaxFromStringList(List<dynamic> numbers) {
    if (numbers.isEmpty) return null;
    final parsed = numbers
        .map((e) => int.tryParse(e.toString()))
        .where((e) => e != null)
        .cast<int>()
        .toList();
    return parsed.reduce((a, b) => a > b ? a : b);
  }

  int? getMinFromStringList(List<dynamic> numbers) {
    if (numbers.isEmpty) return null;
    final parsed = numbers
        .map((e) => int.tryParse(e.toString()))
        .where((e) => e != null)
        .cast<int>()
        .toList();
    return parsed.length == 1
        ? parsed.first
        : parsed.reduce((a, b) => a < b ? a : b);
  }

  Future<void> applyBid({
    required String token,
    required String orderId,
    required int bidAmount,
  }) async {
    try {
      isBidSubmitting.value = true;

      final result = await ApiManager.applyBid(
        token: token,
        orderId: orderId,
        bidAmount: bidAmount,
      );

      log("ApplyBid result: $result");

      /// FIX: flexible success check
      if (result != null &&
          (result["success"] == true ||
              result["status"] == true ||
              result["message"] != null)) {
        /// close dialog FIRST
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        await fetchNewDeliveryRequest();

        AppSnackbar.success(
          result["message"] ?? "Your bid has been successful.",
        );

        bidAmountController.clear();
        key.currentState?.reset();
      } else {
        throw Exception(result["message"] ?? "Something went wrong");
      }
    } catch (e) {
      /// error snackbar
      AppSnackbar.error(e.toString());
    } finally {
      isBidSubmitting.value = false;
    }
  }

  Future<void> applyBid1({
    required String token,
    required String orderId,
    required int bidAmount,
  }) async {
    try {
      isBidSubmitting.value = true;

      final result = await ApiManager.applyBid(
        token: token,
        orderId: orderId,
        bidAmount: bidAmount,
      );

      if (result["success"] == true) {
        // close dialog safely
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        await fetchNewDeliveryRequest();

        AppSnackbar.success(
          result["message"] ?? "Your bid has been successful.",
        );

        bidAmountController.clear();
        key.currentState?.reset();
      }
    } catch (e) {
      // AppSnackbar.error("Request failed! Unknown error occurred.");
      AppSnackbar.error(e.toString());
    } finally {
      isBidSubmitting.value = false;
    }
  }

  void showBidPopup(DeliveryRequestModel requestData) {
    double offeredAmount = requestData.orderAttempts.first.fare;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Place your offer",
                  style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold),
                ),
              ),
              24.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Offered Amount", style: AppTypography.sub1Medium),
                  Text(
                    "\$${requestData.orderAttempts.first.fare}",
                    style: AppTypography.sub1Medium,
                  ),
                ],
              ),
              20.verticalSpace,
              Form(
                key: key,
                child: TextFormField(
                  enabled: !isBidSubmitting.value, // works fine
                  controller: bidAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    hintText: "Enter amount",
                    hintStyle: AppTypography.bodyRegular.copyWith(
                      color: AppColors.black400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: AppColors.kGreyLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: AppColors.kGreyLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: AppColors.kGreyLight),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter your bid";
                    }

                    final bid = int.tryParse(value.trim());

                    if (bid == null) {
                      return "Please enter a valid number";
                    }

                    if (bid <= 0) {
                      return "Please enter valid amount.";
                    }

                    if (bid > 500) {
                      return "Your bid is exceeding the maximum \nfare (500)";
                    }
                    // if (bid > offeredAmount) {
                    //   return "Your bid is exceeding the maximum \nfare ($offeredAmount)";
                    // }

                    return null;
                  },
                ),
              ),
              16.verticalSpace,
              Obx(() {
                return isBidSubmitting.value
                    ? Container(
                        width: double.infinity,
                        height: 45.h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10.h),
                        child: SizedBox(
                          width: 25.h,
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          if (key.currentState!.validate()) {
                            // parse bid here
                            final bid = int.parse(
                              bidAmountController.text.trim(),
                            );

                            // remove Get.back() from here
                            applyBid(
                              token: authController.token.value,
                              orderId: requestData.orderId,
                              bidAmount: bid,
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 45.h,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "SUBMIT",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
              }),
              10.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> cancelBid(int riderId, String orderId) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
        barrierDismissible: false,
      );

      final response = await ApiManager.rejectRiderBid(
        authController.token.value,
        orderId,
        riderId,
      );

      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (response == true) {
        await fetchNewDeliveryRequest();
        AppSnackbar.success("Your bid has been canceled!");
      }
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      // AppSnackbar.error("Request failed! Unknown error occurred.");
      AppSnackbar.error(e.toString());
    }
  }

  void closeOnlyDialog() {
    if (Get.isDialogOpen == true) {
      Navigator.of(Get.overlayContext!).pop();
    }
  }

  DeliveryRequestModel? findOrderById(String orderId) {
    // check delivery list
    if (deliveryRequestList.value != null) {
      try {
        return deliveryRequestList.value!.firstWhere(
          (e) => e.orderId == orderId,
        );
      } catch (_) {}
    }

    // check my bids list
    if (myBidsList.value != null) {
      try {
        return myBidsList.value!.firstWhere((e) => e.orderId == orderId);
      } catch (_) {}
    }

    return null;
  }

  @override
  void onClose() {
    bidAmountController.dispose();
    super.onClose();
  }
}
