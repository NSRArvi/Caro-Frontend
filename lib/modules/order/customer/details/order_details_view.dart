import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/data/models/delivery_request_model.dart';
import 'package:jimamuapp/modules/order/customer/details/order_details_controller.dart';
import 'package:jimamuapp/utils/app_colors.dart';
import 'package:jimamuapp/utils/app_typography.dart';
import 'package:jimamuapp/utils/snakckbar_helper.dart';

import '../../../bank_information/widgets/primary_button.dart';
import '../widgets/location_preview_screen.dart';

class OrderDetailsScreen extends GetView<OrderDetailsController> {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final order = controller.orderDetails.value;
      final bids = (order != null && order.orderAttempts.isNotEmpty)
          ? order.orderAttempts.first.riderBids
          : [];
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Orders Details'),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          actions: <Widget>[
            !(controller.isLoading.value) &&
                    (controller.orderDetails.value!.status.toLowerCase() ==
                            "pending" ||
                        controller.orderDetails.value!.status.toLowerCase() ==
                            "confirmed")
                ? InkWell(
                    onTap: () {
                      log("tapped cancel");
                      controller.fetchOrderCancelReasons();
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
            20.horizontalSpace,
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primaryColor,
            backgroundColor: Colors.white,
            onRefresh: () async {
              await controller.refreshOrderDetails();
            },
            child: controller.isLoading.value
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 15.h,
                      ),
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
                                      text: controller
                                          .orderDetails
                                          .value!
                                          .orderId,
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
                                      "#${controller.orderDetails.value!.orderId}",
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
                                    final receiverInfo = controller
                                        .orderDetails
                                        .value
                                        ?.receiverInformation;

                                    final phone =
                                        "${receiverInfo?.countryCode ?? ""}${receiverInfo?.receiverPhone ?? ""}";
                                    // final phone =
                                    //     "${receiverInfo?.countryCode ?? ""}${receiverInfo?.receiverPhone ?? ""}";

                                    Clipboard.setData(
                                      ClipboardData(text: phone),
                                    );
                                    AppSnackbar.success("Copied");
                                  },
                                  // onTap: () {
                                  //   Clipboard.setData(
                                  //     ClipboardData(
                                  //       text: controller
                                  //           .orderDetails
                                  //           .value!
                                  //           .receiverInformation
                                  //           .receiverPhone,
                                  //     ),
                                  //   );
                                  //   AppSnackbar.success("Copied");
                                  // },
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.call,
                                        size: 20,
                                        color: AppColors.primaryColor,
                                      ),
                                      6.horizontalSpace,
                                      Text(
                                        "${controller.orderDetails.value?.receiverInformation.countryCode ?? ""}"
                                        "${controller.orderDetails.value?.receiverInformation.receiverPhone ?? ""}",
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
                                      .orderDetails
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
                                        controller.pickupLocation.value,
                                        style: AppTypography.bodyRegular
                                            .copyWith(
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
                                        controller.dropoffLocation.value,
                                        style: AppTypography.bodyRegular
                                            .copyWith(
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
                                  controller.orderDetails.value!.package,
                                ),

                                _infoRow(
                                  "Weight",
                                  "${controller.orderDetails.value!.weight} ${controller.orderDetails.value!.weightType}",
                                ),

                                _infoRow(
                                  "Delivery Charge",
                                  "\$${controller.orderDetails.value!.orderAttempts[0].fare}",
                                  boldValue: true,
                                ),
                              ],
                            ),
                          ),

                          20.verticalSpace,
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Text(
                          //       'Order Id',
                          //       style: AppTypography.bodySemiBold.copyWith(
                          //         color: AppColors.black500,
                          //       ),
                          //     ),
                          //     Text(
                          //       '#${controller.orderDetails.value!.orderId}',
                          //       style: AppTypography.sub1SemiBold,
                          //     ),
                          //   ],
                          // ),
                          // 15.verticalSpace,
                          // Divider(color: AppColors.black100, thickness: 0.6),
                          // 15.verticalSpace,
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Text(
                          //       'Recipient',
                          //       style: AppTypography.bodySemiBold.copyWith(
                          //         color: AppColors.black500,
                          //       ),
                          //     ),
                          //     Text(
                          //       controller
                          //           .orderDetails
                          //           .value!
                          //           .receiverInformation
                          //           .name,
                          //       style: AppTypography.sub1SemiBold,
                          //     ),
                          //   ],
                          // ),
                          // 15.verticalSpace,
                          // Divider(color: AppColors.black100, thickness: 0.6),
                          // 15.verticalSpace,
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Text(
                          //       'Mobile',
                          //       style: AppTypography.bodySemiBold.copyWith(
                          //         color: AppColors.black500,
                          //       ),
                          //     ),
                          //     Text(
                          //       controller
                          //           .orderDetails
                          //           .value!
                          //           .receiverInformation
                          //           .receiverPhone,
                          //       style: AppTypography.sub1SemiBold,
                          //     ),
                          //   ],
                          // ),
                          // 15.verticalSpace,
                          // Divider(color: AppColors.black100, thickness: 0.6),
                          // 15.verticalSpace,
                          // Text(
                          //   'From',
                          //   style: AppTypography.bodySemiBold.copyWith(
                          //     color: AppColors.black500,
                          //   ),
                          // ),
                          // 15.verticalSpace,
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Expanded(
                          //       child: Text(
                          //         controller.pickupLocation.value,
                          //         style: AppTypography.bodySemiBold,
                          //       ),
                          //     ),
                          //     const SizedBox(width: 8),
                          //     GestureDetector(
                          //       onTap: () {
                          //         if (controller.pickupLatLng == null) {
                          //           AppSnackbar.error(
                          //             "Pickup location not available",
                          //           );
                          //           return;
                          //         }

                          //         controller.openLocationOnMap(
                          //           latLng: controller.pickupLatLng!,
                          //           title: 'Pickup Location',
                          //         );
                          //       },
                          //       child: Container(
                          //         decoration: BoxDecoration(
                          //           color: AppColors.nearMeColor,
                          //           borderRadius: BorderRadius.circular(100),
                          //         ),
                          //         padding: const EdgeInsets.all(7),
                          //         child: const Icon(
                          //           Icons.near_me,
                          //           color: Colors.white,
                          //           size: 15,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // 15.verticalSpace,
                          // Divider(color: AppColors.black100, thickness: 0.6),
                          // 15.verticalSpace,
                          // Text(
                          //   'To',
                          //   style: AppTypography.bodySemiBold.copyWith(
                          //     color: AppColors.black500,
                          //   ),
                          // ),
                          // 15.verticalSpace,
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Expanded(
                          //       child: Text(
                          //         controller.dropoffLocation!.value,
                          //         style: AppTypography.bodySemiBold,
                          //       ),
                          //     ),
                          //     const SizedBox(width: 8),
                          //     GestureDetector(
                          //       onTap: () {
                          //         if (controller.dropoffLatLng == null) {
                          //           AppSnackbar.error(
                          //             "Dropoff location not available",
                          //           );
                          //           return;
                          //         }

                          //         controller.openLocationOnMap(
                          //           latLng: controller.dropoffLatLng!,
                          //           title: 'Dropoff Location',
                          //         );
                          //       },
                          //       child: Container(
                          //         decoration: BoxDecoration(
                          //           color: AppColors.nearMeColor,
                          //           borderRadius: BorderRadius.circular(100),
                          //         ),
                          //         padding: const EdgeInsets.all(7),
                          //         child: const Icon(
                          //           Icons.near_me,
                          //           color: Colors.white,
                          //           size: 15,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // 15.verticalSpace,
                          // Divider(color: AppColors.black100, thickness: 0.6),
                          // 15.verticalSpace,
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Text(
                          //       'Package',
                          //       style: AppTypography.bodySemiBold.copyWith(
                          //         color: AppColors.black500,
                          //       ),
                          //     ),
                          //     Text(
                          //       '${controller.orderDetails.value!.package}',
                          //       style: AppTypography.sub1SemiBold,
                          //     ),
                          //   ],
                          // ),
                          // 15.verticalSpace,
                          // Divider(color: AppColors.black100, thickness: 0.6),
                          // 15.verticalSpace,
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Text(
                          //       'Weight',
                          //       style: AppTypography.bodySemiBold.copyWith(
                          //         color: AppColors.black500,
                          //       ),
                          //     ),
                          //     Text(
                          //       '${controller.orderDetails.value!.weight} ${controller.orderDetails.value!.weightType}',
                          //       style: AppTypography.h2Regular.copyWith(
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // 15.verticalSpace,
                          // Divider(color: AppColors.black100, thickness: 0.6),
                          // 15.verticalSpace,
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Text(
                          //       'Fare',
                          //       style: AppTypography.bodySemiBold.copyWith(
                          //         color: AppColors.black500,
                          //       ),
                          //     ),
                          //     Text(
                          //       '\$${controller.orderDetails.value!.orderAttempts[0].fare}',
                          //       style: AppTypography.h2Regular.copyWith(
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // 45.verticalSpace,
                          (controller.orderDetails.value!.status != "pending")
                              ? buildAcceptedRiderStatus()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(color: AppColors.kGreyLight),
                                    10.verticalSpace,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Offers:',
                                          style: AppTypography.sub1Regular
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.black700,
                                              ),
                                        ),
                                        // Text(
                                        //   'See all',
                                        //   style: AppTypography.bodyMedium,
                                        // ),
                                      ],
                                    ),
                                    25.verticalSpace,

                                    //  final order = controller.orderDetails.value;
                                    bids.isEmpty
                                        ? Center(
                                            child: Container(
                                              padding: EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryColor
                                                    .withOpacity(.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.local_offer_outlined,
                                                    size: 50,
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                                  12.verticalSpace,
                                                  Text(
                                                    "You didn't get any offer yet",
                                                    style: AppTypography
                                                        .sub1Regular
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 20,
                                                        ),
                                                  ),
                                                  6.verticalSpace,
                                                  Text(
                                                    "Riders will send offers soon",
                                                    style: AppTypography
                                                        .bodyMedium
                                                        .copyWith(
                                                          color: AppColors
                                                              .kGreyMain,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        // Center(
                                        //     child: Text(
                                        //       "You didn't get any offer yet",
                                        //       style: AppTypography.sub1Regular
                                        //           .copyWith(
                                        //             fontWeight: FontWeight.w400,
                                        //             color: AppColors.black700,
                                        //             fontSize: 20,
                                        //           ),
                                        //     ),
                                        //   )
                                        : Column(
                                            children: bids
                                                .asMap()
                                                .entries
                                                .map(
                                                  (entry) => buildRiderOffer(
                                                    entry.value,
                                                    entry.key,
                                                    context,
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                    25.verticalSpace,
                                    Divider(color: AppColors.kGreyLight),
                                    //  ...controller
                                    //     .orderDetails
                                    //     .value!
                                    //     .orderAttempts[0]
                                    //     .riderBids
                                    //     .asMap()
                                    //     .entries
                                    //     .map(
                                    //       (entry) => buildRiderOffer(
                                    //         entry.value,
                                    //         entry.key,
                                    //         context,
                                    //       ),
                                    //     ),
                                  ],
                                ),
                          25.verticalSpace,
                          // Divider(color: AppColors.kGreyLight),
                          PrimaryButton(
                            title: "Contact Support",
                            icon: "assets/icons/Headset.png",
                            onTap: () {
                              controller.callNow("0000000000000");
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      );
    });
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

  Widget buildRiderOffer(RiderBid riderBid, int index, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.secondary,
            radius: 25.r, // total size
            backgroundImage: riderBid.profileImage != null
                ? NetworkImage(riderBid.profileImage!)
                : null,
            child: riderBid.profileImage == null
                ? Image.asset(
                    'assets/icons/profile.png',
                    width: 50.w,
                    height: 50.w,
                    fit: BoxFit.contain,
                  )
                : null,
          ),

          8.horizontalSpace,
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row(
                      //   children: [
                      //     Image.asset('assets/icons/Star.png', height: 15.r),
                      //     Text(' 4.5', style: AppTypography.pMedium),
                      //   ],
                      // ),
                      // 6.verticalSpace,
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text(
                          '${riderBid.name}',
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                      4.verticalSpace,
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text(
                          'Offer : \$${riderBid.bidAmount} CAD',
                          style: AppTypography.sub1Bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await controller.rejectOrder(riderBid.riderId!);
                          // setState(() {
                          //   widget.orderDetails.orderAttempts[0].riderBids
                          //       .removeAt(index);
                          // });
                        },
                        child: Container(
                          // width: 45.w,
                          // height: 25.h,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.primaryColor,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Reject',
                            style: AppTypography.bodyRegular.copyWith(
                              // fontSize: 12,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      4.horizontalSpace,
                      GestureDetector(
                        onTap: () async {
                          await controller.acceptOrder(riderBid.riderId!);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.greenBtnColor,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Accept',
                            style: AppTypography.bodyRegular.copyWith(
                              // fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAcceptedRiderStatus() {
    final List<Map<String, dynamic>> steps = [
      {'label': 'Confirmed', 'icon': 'assets/icons/confirmed.png'},
      {'label': 'Picked', 'icon': 'assets/icons/picked.png'},
      {'label': 'Shipping', 'icon': 'assets/icons/shipping.png'},
      {'label': 'Delivered', 'icon': 'assets/icons/delivered.png'},
    ];

    Map<String, int> statusIndex = {
      'pending': -1,
      'confirmed': 0,
      'picked': 2,
      'delivered': 3,
    };

    int activeStep =
        statusIndex[controller.orderDetails.value!.status.toLowerCase()] ?? -1;
    log("Profile Image ${controller.acceptedRider.value!['profileImage']}");
    final imageUrl = controller.acceptedRider.value?['profileImage'];
    return Column(
      children: [
        // Accepted Rider Info
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                backgroundImage:
                    (imageUrl != null &&
                        imageUrl.toString().isNotEmpty &&
                        imageUrl.toString().startsWith('http'))
                    ? NetworkImage(imageUrl)
                    : null,
                child:
                    (imageUrl == null ||
                        imageUrl.toString().isEmpty ||
                        !imageUrl.toString().startsWith('http'))
                    ? Image.asset(
                        'assets/icons/profile.png',
                        width: 35.w,
                        height: 35.w,
                        fit: BoxFit.contain,
                      )
                    : null,
              ),

              // CircleAvatar(
              //         backgroundColor: Colors.white,
              //         radius: 20,
              //         backgroundImage:
              //             controller.acceptedRider.value!['profileImage'] != null
              //             ? NetworkImage(
              //                 controller.acceptedRider.value!['profileImage'],
              //               )
              //             : null,
              //         child: controller.acceptedRider.value!['profileImage'] == null
              //             ? Image.asset(
              //                 'assets/icons/profile.png',
              //                 width: 35.w,
              //                 height: 35.w,
              //                 fit: BoxFit.contain,
              //               )
              //             : null,
              //       ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${controller.acceptedRider.value!['name']}',
                      style: AppTypography.bodyBold,
                    ),
                    // Text(
                    //   '48 trials completed',
                    //   style: AppTypography.bodyRegular,
                    // ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => controller.sendMessage(
                  phoneNumber: "${controller.acceptedRider.value!['country_code'] ?? ""}"
                      "${controller.acceptedRider.value!['phone'] ?? ""}",
                  userName:
                      controller.authController.user.value!.name ?? "User",
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
                onTap: () => controller.callNow(
                  "${controller.acceptedRider.value!['country_code'] ?? ""}"
                  "${controller.acceptedRider.value!['phone'] ?? ""}",
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xff06c800),
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
        // Timeline Steps
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: Column(
            children: List.generate(steps.length, (index) {
              final bool isActive = index <= activeStep;
              final Color labelColor = isActive
                  ? AppColors.black
                  : AppColors.black400;
              final String iconPath = steps[index]['icon'];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: !isActive
                                ? Colors.white60
                                : AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.25),
                                blurRadius: 1,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: !isActive
                              ? Image.asset(iconPath, height: 20)
                              : Icon(
                                  Icons.done,
                                  size: 20,
                                  weight: 10,
                                  color: AppColors.white,
                                ),
                        ),
                      ),
                      if (index != steps.length - 1)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          width: 2,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: isActive
                                    ? AppColors.primaryColor.withOpacity(0.5)
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
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      steps[index]['label'],
                      style: AppTypography.bodyBold.copyWith(color: labelColor),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
