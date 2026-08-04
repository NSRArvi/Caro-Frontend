import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/modules/delivery/details/delivery_details_controller.dart';
import 'package:jimamuapp/utils/app_colors.dart';
import 'package:jimamuapp/utils/app_typography.dart';

import '../../../utils/snakckbar_helper.dart';
import '../../bank_information/widgets/primary_button.dart';
import '../../order/customer/widgets/location_preview_screen.dart';

class DeliveryDetailsView extends GetView<DeliveryDetailsController> {
  const DeliveryDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Orders Details'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value ||
              controller.deliveryDetails.value == null) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }
          final data = controller.deliveryDetails.value!;
          final String consignmentId = "#${data.orderId}";

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  10.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Consignment ID:',
                        style: AppTypography.bodySemiBold.copyWith(
                          color: AppColors.black500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: controller.deliveryDetails.value!.orderId,
                            ),
                          );
                          AppSnackbar.success("Consignment ID copied");
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.file_copy,
                              size: 16,
                              color: AppColors.primaryColor,
                            ),
                            6.horizontalSpace,
                            Text(
                              consignmentId,
                              style: AppTypography.sub1SemiBold,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  15.verticalSpace,

                  /// Shipping Info Card
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Shipping Info:",
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),

                        8.verticalSpace,
                        GestureDetector(
                          onTap: () {
                            final receiverInfo =
                                controller.deliveryDetails.value?.receiverInformation;

                            final phone =
                                "${receiverInfo?.countryCode ?? ""}${receiverInfo?.receiverPhone ?? ""}";
                            // final phone =
                            //     "${receiverInfo?.countryCode ?? ""}${receiverInfo?.receiverPhone ?? ""}";

                            Clipboard.setData(ClipboardData(text: phone));
                            AppSnackbar.success("Copied");
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.call,
                                size: 20,
                                color: AppColors.primaryColor,
                              ),
                              6.horizontalSpace,
                              Text(
                                "${controller.deliveryDetails.value?.receiverInformation.countryCode ?? ""}"
                                    "${controller.deliveryDetails.value?.receiverInformation.receiverPhone ?? ""}",
                                style: AppTypography.h2Regular.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        5.verticalSpace,
                        Text(
                          controller
                              .deliveryDetails
                              .value!
                              .receiverInformation
                              .name,

                          style: AppTypography.bodyRegular.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),

                        12.verticalSpace,

                        /// Pickup
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: const Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.red,
                              ),
                            ),
                            8.horizontalSpace,
                            Expanded(
                              child: Text(
                                controller.pickupLocation!.value,
                                style: AppTypography.bodyRegular.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            _nearMe(() {
                              Get.to(
                                () => LocationPreviewScreen(
                                  latLng: controller.pickupLatLng!,
                                  title: "Pickup Location",
                                ),
                              );
                            }),
                          ],
                        ),

                        12.verticalSpace,

                        /// Dropoff
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: const Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.red,
                              ),
                            ),
                            8.horizontalSpace,
                            Expanded(
                              child: Text(
                                controller.dropoffLocation!.value,
                                style: AppTypography.bodyRegular.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            _nearMe(() {
                              Get.to(
                                () => LocationPreviewScreen(
                                  latLng: controller.dropoffLatLng!,
                                  title: "Dropoff Location",
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),

                  20.verticalSpace,

                  /// Package Info Card
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Package Info:",
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),

                        10.verticalSpace,

                        _infoRow(
                          "Parcel type",
                          controller.deliveryDetails.value!.package,
                        ),

                        _infoRow(
                          "Weight",
                          "${controller.deliveryDetails.value!.weight} ${controller.deliveryDetails.value!.weightType}",
                        ),

                        _infoRow(
                          "Delivery Charge",
                          "\$${controller.deliveryDetails.value!.orderAttempts[0].fare}",
                          boldValue: true,
                        ),
                      ],
                    ),
                  ),

                  20.verticalSpace,

                  buildAcceptedRiderStatus(context),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _nearMe(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        width: 28,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.near_me, color: Colors.white, size: 15),
      ),
    );
  }

  Widget _infoRow(String title, String value, {bool boldValue = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: boldValue
                ? AppTypography.bodySemiBold
                : AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget buildAcceptedRiderStatus(BuildContext context) {
    final List<Map<String, dynamic>> steps = [
      {'label': 'Confirmed', 'icon': 'assets/icons/confirmed.png'},
      {'label': 'Picked', 'icon': 'assets/icons/picked.png'},
      {'label': 'Shipping', 'icon': 'assets/icons/shipping.png'},
      {'label': 'Delivered', 'icon': 'assets/icons/delivered.png'},
    ];

    final Map<String, int> statusIndex = {
      'pending': -1,
      'confirmed': 0,
      'picked': 2,
      'delivered': 3,
    };

    final int activeStep =
        statusIndex[controller.deliveryDetails.value!.status.toLowerCase()] ??
        -1;
    String getOtpLabel(int index) {
      if (index == 1) return 'Tap to get your Picked up OTP';
      if (index == 2) return 'Tap to get your Shipping OTP';
      if (index == 3) return 'Tap to get your Delivered OTP';
      return 'Tap to get your OTP';
    }

    return Column(
      children: [
        // Accepted Rider Info
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26.r,
                backgroundColor: Colors.white,
                child: Text(
                  (() {
                    final name = controller
                        .deliveryDetails
                        .value!
                        .senderInformation
                        .name
                        .trim();

                    if (name.isEmpty) return '';

                    final parts = name
                        .split(RegExp(r'\s+'))
                        .where((e) => e.isNotEmpty)
                        .toList();

                    if (parts.length >= 2) {
                      return (parts[0][0] + parts[1][0]).toUpperCase();
                    } else if (parts.isNotEmpty) {
                      final single = parts[0];
                      return single.length >= 2
                          ? single.substring(0, 2).toUpperCase()
                          : single[0].toUpperCase();
                    }

                    return '';
                  })(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.deliveryDetails.value!.senderInformation.name,
                      style: AppTypography.bodyBold,
                    ),
                    // Text(
                    //   '40 trials completed',
                    //   style: AppTypography.bodyRegular,
                    // ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => controller.sendMessage(
                  phoneNumber: "${controller.deliveryDetails.value?.receiverInformation.countryCode ?? ""}"
                      "${controller.deliveryDetails.value?.receiverInformation.receiverPhone ?? ""}",
                  userName: controller.authController.user.value!.name
                      .toString(),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xff167EE6),
                  ),
                  child: const Text(
                    'Message',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              4.horizontalSpace,
              GestureDetector(
                // onTap: () async {
                //   String phoneNumber =
                //       controller.deliveryDetails.value!.senderInformation.receiverPhone;
                //
                // },
                onTap: () => controller.callNow(
                  "${controller.deliveryDetails.value?.receiverInformation.countryCode ?? ""}"
                      "${controller.deliveryDetails.value?.receiverInformation.receiverPhone ?? ""}",
                  // controller
                  //     .deliveryDetails
                  //     .value!
                  //     .senderInformation
                  //     .receiverPhone,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xff06c363),
                  ),
                  child: const Text(
                    'Call Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: controller.isSendingOTP.value
              ? CircularProgressIndicator(color: AppColors.primaryColor)
              : Column(
                  children: List.generate(steps.length, (index) {
                    if (!shouldHideStepText(index)) const SizedBox(width: 8);

                    final bool isActive = index <= activeStep;
                    final Color labelColor = isActive
                        ? AppColors.black
                        : AppColors.black400;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            InkWell(
                              onTap: controller.isSendingOTP.value
                                  ? null
                                  : () async {
                                      log(
                                        '${controller.deliveryDetails.value!.status} $index',
                                      );
                                      if (canTapIcon(index)) {
                                        final status = controller
                                            .deliveryDetails
                                            .value!
                                            .status
                                            .trim()
                                            .toLowerCase();

                                        if (index == 1 &&
                                            status == 'confirmed') {
                                          await controller.sendRiderOtp(
                                            'picked',
                                          );
                                        }

                                        if (index == 3 && status == 'picked') {
                                          log('true');
                                          log(
                                            '${controller.deliveryDetails.value!.orderId} delivered',
                                          );
                                          // Delivered icon
                                          await controller.sendRiderOtp(
                                            'delivered',
                                          );
                                        }
                                      }
                                    },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: !isActive
                                        ? Colors.white60
                                        : AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.black.withOpacity(
                                          0.25,
                                        ),
                                        blurRadius: 1,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: !isActive
                                      ? Image.asset(
                                          steps[index]['icon'],
                                          height: 20,
                                        )
                                      : Icon(
                                          Icons.done,
                                          size: 20,
                                          color: AppColors.white,
                                        ),
                                ),
                              ),
                            ),
                            if (index != steps.length - 1)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                width: 2,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: index < activeStep
                                          ? AppColors.primaryColor.withOpacity(
                                              0.5,
                                            )
                                          : AppColors.white600,
                                      width: 2,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            children: [
                              if (!shouldHideStepText(index))
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    steps[index]['label'],
                                    style: AppTypography.bodyBold.copyWith(
                                      color: labelColor,
                                    ),
                                  ),
                                ),

                              const SizedBox(width: 8),

                              if (canTapIcon(index))
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 0.0),
                                    child: GestureDetector(
                                      onTap: controller.isSendingOTP.value
                                          ? null
                                          : () async {
                                              final status = controller
                                                  .deliveryDetails
                                                  .value!
                                                  .status
                                                  .trim()
                                                  .toLowerCase();

                                              if (index == 1 &&
                                                  status == 'confirmed') {
                                                await controller.sendRiderOtp(
                                                  'picked',
                                                );
                                              }

                                              if (index == 3 &&
                                                  status == 'picked') {
                                                await controller.sendRiderOtp(
                                                  'delivered',
                                                );
                                              }
                                            },
                                      child: Container(
                                        // width: MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 18,
                                        ),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              height: 28,
                                              width: 28,
                                              "assets/icons/picked_otp.png",
                                            ),
                                            const SizedBox(width: 8),
                                            // Text(
                                            //   'Tap to get your Picked up OTP',
                                            //   style: TextStyle(
                                            //     fontSize: 12,
                                            //     fontWeight: FontWeight.w400,
                                            //     color: AppColors.black,
                                            //   ),
                                            // ),
                                            Text(
                                              getOtpLabel(index),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
        ),
        25.verticalSpace,
        PrimaryButton(
          title: "Contact Support",
          icon: "assets/icons/Headset.png",
          onTap: () {
            controller.callNow("18001234567");
          },
        ),
      ],
    );
  }

  bool canTapIcon(int index) {
    switch (controller.deliveryDetails.value!.status.toLowerCase()) {
      case 'confirmed':
        return index == 1;
      case 'picked':
        return index == 3;
      default:
        return false;
    }
  }

  bool shouldHideStepText(int index) {
    final status = controller.deliveryDetails.value!.status.toLowerCase();

    // Hide "Picked" text when waiting for Picked OTP
    if (status == 'confirmed' && index == 1) return true;

    // Hide "Delivered" text when waiting for Delivered OTP
    if (status == 'picked' && index == 3) return true;

    return false;
  }
}
