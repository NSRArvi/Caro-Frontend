import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/modules/order/customer/my_order_controller.dart';
import 'package:jimamuapp/modules/order/customer/widgets/order_card.dart';
import 'package:jimamuapp/routes/app_routes.dart';
import 'package:jimamuapp/ui/widgets/custom_order_tabs.dart';
import 'package:jimamuapp/utils/app_colors.dart';

class MyOrderView extends GetView<MyOrderController> {
  const MyOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('My Orders'),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        body: RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () async {
            await controller.fetchOrders();
          },
          child: Padding(
            padding: EdgeInsetsGeometry.only(
              left: 20.w,
              top: 20.w,
              right: 20.w,
            ),
            child: Obx(
              () => controller.isDataLoaded.value
                  ? Column(
                      children: [
                        CustomOrderTabs(
                          selectedIndex: controller.selectedTab.value,
                          onTabSelected: controller.changeTab,
                        ),
                        25.verticalSpace,
                        controller.selectedTab.value == 0
                            ? controller.ongoingOrders.value.isEmpty
                                  ? SizedBox(
                                      width: double.infinity,
                                      height: Get.height * 0.7,
                                      child: Center(
                                        child: Text(
                                          "No ongoing orders to show",
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      height: Get.height - 190.h,
                                      width: double.infinity,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: controller
                                            .ongoingOrders
                                            .value
                                            .length,
                                        itemBuilder: (context, index) {
                                          final order = controller
                                              .ongoingOrders
                                              .value[index];
                                          return Column(
                                            children: [
                                              OrderCard(
                                                orderId: order.orderId,
                                                date: order.date.toString(),
                                                fromLat:
                                                    '${double.parse(order.pickupLatitude)}',
                                                fromLong:
                                                    '${double.parse(order.pickupLongitude)}',
                                                toLat:
                                                    '${double.parse(order.dropLatitude)}',
                                                toLong:
                                                    '${double.parse(order.dropLongitude)}',
                                                status: order.status
                                                    .replaceFirst(
                                                      order.status[0],
                                                      order.status[0]
                                                          .toUpperCase(),
                                                    ),
                                                orderType: order.orderType,
                                                onPressed: () async {
                                                  final result =
                                                      await Get.toNamed(
                                                        AppRoutes.orderDetails,
                                                        arguments:
                                                            order.orderId,
                                                      ) ??
                                                      false;
                                                  if (result) {
                                                    await controller
                                                        .fetchOrders();
                                                  }
                                                },
                                              ),
                                              const SizedBox(height: 12),
                                            ],
                                          );
                                        },
                                      ),
                                    )
                            : controller.completedOrders.isEmpty
                            ? SizedBox(
                                width: double.infinity,
                                height: Get.height * 0.7,
                                child: Center(
                                  child: Text("No Completed orders to show"),
                                ),
                              )
                            : SizedBox(
                                height: Get.height - 190.h,
                                width: double.infinity,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount:
                                      controller.completedOrders.value.length,
                                  itemBuilder: (context, index) {
                                    final order =
                                        controller.completedOrders.value[index];
                                    log(
                                      "completed orders: ${controller.completedOrders.value[index].orderId}",
                                    );
                                    return Column(
                                      children: [
                                        OrderCard(
                                          orderId: order.orderId,
                                          date: order
                                              .orderAttempts
                                              .first
                                              .orderDate
                                              .toString(),
                                          fromLat:
                                              '${double.parse(order.pickupLatitude)}',
                                          fromLong:
                                              '${double.parse(order.pickupLongitude)}',
                                          toLat:
                                              '${double.parse(order.dropLatitude)}',
                                          toLong:
                                              '${double.parse(order.dropLongitude)}',
                                          status: order.status.replaceFirst(
                                            order.status[0],
                                            order.status[0].toUpperCase(),
                                          ),
                                          orderType: null,
                                          onPressed: () async {
                                            Get.toNamed(
                                              AppRoutes.orderDetails,
                                              arguments: order.orderId,
                                            );
                                            // final details =
                                            // await OrderService
                                            //     .fetchOrderDetails(
                                            //     order.orderId);
                                            // if (details != null) {
                                            //   Get.to(() =>
                                            //       OrderDetailsScreen(
                                            //           orderDetails:
                                            //           details));
                                            // } else {
                                            //   Get.snackbar("Error",
                                            //       "Failed to load order details");
                                            // }
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    );
                                  },
                                ),
                              ),
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
