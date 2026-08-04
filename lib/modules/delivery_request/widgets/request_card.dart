import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jimamuapp/modules/delivery_request/delivery_request_details_view.dart';
import 'package:jimamuapp/modules/delivery_request/delivery_request_list_controller.dart';
import 'package:jimamuapp/ui/widgets/measure_size.dart';
import 'package:jimamuapp/utils/app_colors.dart';

import '../../../data/models/delivery_request_model.dart';
import '../../../ui/widgets/custom_dotted_line.dart';
import '../../../utils/app_typography.dart';

class RequestCard extends StatelessWidget {
  final DeliveryRequestListController controller;
  final DeliveryRequestModel requestData;
  final double bid;
  final bool isMyBidCard;

  const RequestCard({
    super.key,
    required this.controller,
    required this.requestData,
    required this.bid,
    required this.isMyBidCard,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        log("Next chevron on clicked");

        final pickupLat = double.parse(requestData.pickupLatitude);
        final pickupLng = double.parse(requestData.pickupLongitude);
        final dropLat = double.parse(requestData.dropLatitude);
        final dropLng = double.parse(requestData.dropLongitude);

        String pickupLocation = await _getAddress(pickupLat, pickupLng);
        String dropoffLocation = await _getAddress(dropLat, dropLng);

        Get.to(
          () => DeliveryRequestDetailsView(
            orderDetails: requestData,
            pickupLocation: pickupLocation,
            dropoffLocation: dropoffLocation,
            pickupLatLng: LatLng(pickupLat, pickupLng),
            dropoffLatLng: LatLng(dropLat, dropLng),
          ),
        );
      },

      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: AppColors.kGreyLight),
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row
              Row(
                children: [
                  _IconContainer(),
                  12.horizontalSpace,
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "#${requestData.orderId}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                8.horizontalSpace,
                                CircleAvatar(
                                  radius: 3,
                                  backgroundColor: AppColors.black100,
                                ),
                                8.horizontalSpace,
                                Text(
                                  formatDate(requestData.date),
                                  style: TextStyle(color: AppColors.black400),
                                ),
                              ],
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () async {
                            log("Next chevron on clicked");

                            final pickupLat = double.parse(
                              requestData.pickupLatitude,
                            );
                            final pickupLng = double.parse(
                              requestData.pickupLongitude,
                            );
                            final dropLat = double.parse(
                              requestData.dropLatitude,
                            );
                            final dropLng = double.parse(
                              requestData.dropLongitude,
                            );

                            String pickupLocation = await _getAddress(
                              pickupLat,
                              pickupLng,
                            );
                            String dropoffLocation = await _getAddress(
                              dropLat,
                              dropLng,
                            );

                            Get.to(
                              () => DeliveryRequestDetailsView(
                                orderDetails: requestData,
                                pickupLocation: pickupLocation,
                                dropoffLocation: dropoffLocation,
                                pickupLatLng: LatLng(pickupLat, pickupLng),
                                dropoffLatLng: LatLng(dropLat, dropLng),
                              ),
                            );
                          },

                          child: Icon(CupertinoIcons.chevron_right, size: 22.r),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              16.verticalSpace,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  20.horizontalSpace,
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 2.5,
                          backgroundColor: AppColors.black400,
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => DottedLine(
                            height: controller.addressSecHeight.value - 22.h,
                          ),
                        ),
                        const SizedBox(height: 4),
                        CircleAvatar(
                          radius: 2.5,
                          backgroundColor: AppColors.black400,
                        ),
                      ],
                    ),
                  ),
                  22.horizontalSpace,
                  FutureBuilder<List<String>>(
                    future: Future.wait([
                      _getAddress(
                        double.parse(requestData.pickupLatitude),
                        double.parse(requestData.pickupLongitude),
                      ),
                      _getAddress(
                        double.parse(requestData.dropLatitude),
                        double.parse(requestData.dropLongitude),
                      ),
                    ]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        );
                      }
                      final fromAddress = snapshot.data![0];
                      final toAddress = snapshot.data![1];

                      return Expanded(
                        child: MeasureSize(
                          onChange: (size) {
                            controller.addressSecHeight.value = size.height;
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'From',
                                          style: AppTypography.bodyMedium,
                                        ),
                                        80.horizontalSpace,
                                        if (requestData.orderType
                                                .toLowerCase() !=
                                            "national")
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xffffdfdf),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              "Global",
                                              style: AppTypography.bodyMedium
                                                  .copyWith(
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      fromAddress,
                                      style: AppTypography.pRegular,
                                    ),
                                  ],
                                ),
                              ),
                              12.verticalSpace,
                              SizedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('To', style: AppTypography.bodyMedium),
                                    4.verticalSpace,
                                    Text(
                                      toAddress,
                                      style: AppTypography.pRegular,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              16.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isMyBidCard ? 0.horizontalSpace : 0.horizontalSpace,
                  Text(
                    "Fare:",
                    style: TextStyle(color: AppColors.black400, fontSize: 14.r),
                  ),
                  12.horizontalSpace,
                  Container(
                    padding: EdgeInsetsGeometry.symmetric(
                      horizontal: 10.w,
                      vertical: 0,
                    ),
                    height: 30.h,
                    constraints: BoxConstraints(
                      minWidth: 70.w,
                      maxWidth: 120.w,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "\$${requestData.orderAttempts.first.fare}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.r,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  20.horizontalSpace,
                  isMyBidCard
                      ? SizedBox.shrink()
                      : InkWell(
                          onTap: () {
                            if (!(requestData.orderAttempts.first.riderBids.any(
                              (e) =>
                                  e.riderId ==
                                  controller
                                      .authController
                                      .riderProfile
                                      .value
                                      ?.riderId,
                            ))) {
                              controller.showBidPopup(requestData);
                            }
                          },
                          child: Container(
                            width: 70.w,
                            height: 30.h,
                            decoration: BoxDecoration(
                              color:
                                  (requestData.orderAttempts.first.riderBids
                                      .any(
                                        (e) =>
                                            e.riderId ==
                                            controller
                                                .authController
                                                .riderProfile
                                                .value
                                                ?.riderId,
                                      ))
                                  ? AppColors.black100
                                  : AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: Text(
                                "BID",
                                style: TextStyle(
                                  fontSize: 14.r,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                  isMyBidCard
                      ? Row(
                          children: [
                            Text(
                              "Bid:",
                              style: TextStyle(
                                color: AppColors.black400,
                                fontSize: 14.r,
                              ),
                            ),
                            12.horizontalSpace,
                            Container(
                              padding: EdgeInsetsGeometry.symmetric(
                                horizontal: 10.w,
                                vertical: 0,
                              ),
                              height: 30.h,
                              constraints: BoxConstraints(
                                minWidth: 70.w,
                                maxWidth: 120.w,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "\$${requestData.orderAttempts.first.riderBids.where((e) => e.phoneNumber == controller.authController.user.value!.phoneNumber).first.bidAmount}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.r,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                ],
              ),
              16.verticalSpace,
              isMyBidCard
                  ? InkWell(
                      onTap: () async {
                        int riderId = requestData.orderAttempts.first.riderBids
                            .where(
                              (e) =>
                                  e.phoneNumber ==
                                  controller
                                      .authController
                                      .user
                                      .value!
                                      .phoneNumber,
                            )
                            .first
                            .riderId!;
                        await controller.cancelBid(
                          riderId,
                          requestData.orderId,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 40.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: AppColors.primaryColor,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Cancel Bid",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.r,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
              isMyBidCard ? 5.verticalSpace : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String> _getAddress(double lat, double long) async {
  final placemarks = await placemarkFromCoordinates(lat, long);
  final place = placemarks.first;
  return "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
}

String formatDate(String inputDate) {
  final formats = [
    "dd-MM-yyyy hh:mm:ss a",
    "dd-MM-yyyy HH:mm:ss",
    "yyyy-MM-dd HH:mm:ss",
    "yyyy/MM/dd HH:mm:ss",
    "MM-dd-yyyy hh:mm:ss a",
    "MM/dd/yyyy hh:mm:ss a",
    "dd MMM yyyy HH:mm:ss",
    "yyyy-MM-dd",
    "dd-MM-yyyy",
    "MM/dd/yyyy",
    "dd MMM yyyy",
    "MMMM d, yyyy, hh:mm:ss a",
  ];
  log("INput date $inputDate");
  inputDate = inputDate.replaceAll(RegExp(r'\s+'), ' ');

  for (var pattern in formats) {
    try {
      DateTime dateTime = DateFormat(pattern).parseStrict(inputDate);
      log("Matched pattern: $pattern → $dateTime");
      return DateFormat("dd MMM yyyy").format(dateTime);
    } catch (_) {
      // try next format
    }
  }

  return "Invalid date";
}

class _IconContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: AppColors.secondary,
      ),
      child: Image.asset('assets/icons/package.png', width: 24.w, height: 24.w),
    );
  }
}
