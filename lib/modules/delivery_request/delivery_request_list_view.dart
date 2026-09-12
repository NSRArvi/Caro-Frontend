import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/modules/delivery_request/delivery_request_list_controller.dart';
import 'package:jimamuapp/modules/delivery_request/widgets/custom_tabs.dart';
import 'package:jimamuapp/modules/delivery_request/widgets/request_card.dart';
import 'package:jimamuapp/utils/app_colors.dart';

class DeliveryRequestListView extends GetView<DeliveryRequestListController> {
  const DeliveryRequestListView({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchNewDeliveryRequest();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          title: const Text('Delivery Requests'),
        ),
        body: SafeArea(
          child: Obx(
            () => controller.isLoading.value
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        child: CustomTabs(
                          selectedIndex: controller.selectedTab.value,
                          onTabSelected: controller.changeTab,
                        ),
                      ),
                      8.verticalSpace,
                      Expanded(
                        child: controller.selectedTab.value == 0
                            ? controller.deliveryRequestList.value == null ||
                                    controller.deliveryRequestList.value!.isEmpty
                                ? const Center(
                                    child: Text(
                                      "There are no available order requests now.",
                                    ),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                                    itemCount: controller
                                        .deliveryRequestList
                                        .value!
                                        .length,
                                    itemBuilder: (context, index) {
                                      final request = controller
                                          .deliveryRequestList
                                          .value![index];
                                      return RequestCard(
                                        requestData: request,
                                        bid: 50,
                                        controller: controller,
                                        isMyBidCard: false,
                                      );
                                    },
                                  )
                            : controller.myBidsList.value == null ||
                                    controller.myBidsList.value!.isEmpty
                                ? const Center(
                                    child: Text("There is no Bid to show"),
                                  )
                                : ListView.builder(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                                    itemCount: controller.myBidsList.value!.length,
                                    itemBuilder: (context, index) {
                                      final request =
                                          controller.myBidsList.value![index];
                                      return RequestCard(
                                        requestData: request,
                                        bid: 50,
                                        controller: controller,
                                        isMyBidCard: true,
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
