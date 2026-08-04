import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/modules/delivery/my_deliveries_controller.dart';
import 'package:jimamuapp/routes/app_routes.dart';

import '../../ui/widgets/custom_order_tabs.dart';
import '../../utils/app_colors.dart';
import '../order/customer/widgets/order_card.dart';

class MyDeliveriesView extends GetView<MyDeliveriesController> {
  const MyDeliveriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('My Deliveries'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () async {
            await controller.fetchDeliveries();
          },
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              );
            }

            final isOngoing = controller.selectedTab.value == 0;
            final deliveries = isOngoing
                ? controller.ongoingDeliveries.value
                : controller.completedDeliveries.value;

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: CustomOrderTabs(
                    selectedIndex: controller.selectedTab.value,
                    onTabSelected: controller.changeTab,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: deliveries.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: Get.height * 0.3),
                            Center(
                              child: Text(
                                isOngoing
                                    ? 'No ongoing deliveries to show'
                                    : 'No completed deliveries to show',
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: deliveries.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final order = deliveries[index];
                            return OrderCard(
                              orderId: order.orderId,
                              date: order.date,
                              fromLat: order.pickupLatitude,
                              fromLong: order.pickupLongitude,
                              toLat: order.dropLatitude,
                              toLong: order.dropLongitude,
                              status: order.status.replaceFirst(
                                order.status[0],
                                order.status[0].toUpperCase(),
                              ),
                              orderType: order.orderType,
                              onPressed: () {
                                Get.toNamed(
                                  AppRoutes.deliveryDetails,
                                  arguments: order.orderId,
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
