import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/modules/place_order/national/placing_order_controller.dart';
import 'package:jimamuapp/modules/place_order/national/widgets/buttons_view_func.dart';
import 'package:jimamuapp/modules/place_order/national/widgets/confirmation_step.dart';
import 'package:jimamuapp/modules/place_order/national/widgets/information_step.dart';
import 'package:jimamuapp/modules/place_order/national/widgets/location_step.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_typography.dart';

class PlacingOrderView extends GetView<PlacingOrderController> {
  const PlacingOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final discard = await controller.onWillPopOrderDiscard(context);
        if (discard) {
          Get.back();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text("Place Order"),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            // width: Get.width,
            // height: Get.height,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Obx(() {
              log(
                "Current Step Number from view ${controller.currentStep.value}",
              );
              Widget stepWidget = controller.currentStep.value == 0
                  ? Expanded(child: LocationInfoStep(controller: controller))
                  : controller.currentStep.value == 1
                  ? Expanded(child: InformationStep(controller: controller))
                  : Expanded(child: ConfirmationStep(controller: controller));

              return Column(
                children: [
                  10.verticalSpace,
                  _buildSteps(),
                  30.verticalSpace,
                  stepWidget,
                  Container(
                    width: double.infinity,
                    height: 65.h,
                    padding: EdgeInsetsGeometry.only(
                      top: 10.h,
                      bottom: 8.h,
                    ),
                    child: Obx(
                      () => controller.currentStep.value == 0
                          ? locationSubmitButton(controller)
                          : controller.currentStep.value == 1
                          ? informationSubmitButton(controller)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total (incl. VAT)",
                                      style: TextStyle(
                                        fontSize: 13.r,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    Text(
                                      "\$"
                                      "${controller.calculateSubtotal()!.toStringAsFixed(2)} CAD",
                                      style: TextStyle(
                                        fontSize: 18.r,
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                placeOrderButton(controller),
                              ],
                            ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSteps() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: controller.currentStep.value > 0
              ? () => controller.setStepItem(0)
              : null,
          child: _buildStepItem(
            'locations',
            "Locations",
            controller.currentStep.value != 0,
          ),
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -12),
            child: Divider(
              thickness: 2,
              color: controller.currentStep.value >= 1
                  ? AppColors.primaryColor
                  : Colors.grey.shade400,
            ),
          ),
        ),
        InkWell(
          onTap: controller.currentStep.value > 1
              ? () => controller.setStepItem(1)
              : null,
          child: _buildStepItem(
            'information',
            "Information",
            controller.currentStep.value >= 2,
          ),
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -12),
            child: Divider(
              thickness: 2,
              color: controller.currentStep.value >= 2
                  ? AppColors.primaryColor
                  : Colors.grey.shade400,
            ),
          ),
        ),
        _buildStepItem(
          'confirmation',
          "Confirmation",
          controller.currentStep.value >= 3,
        ),
      ],
    );
  }

  Widget _buildStepItem(String icon, String label, bool active) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: active
              ? AppColors.primaryColor
              : AppColors.secondary,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: active
                ? const Icon(Icons.done, color: Colors.white)
                : Image.asset('assets/icons/$icon.png'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.bodyBold.copyWith(
            color: active ? AppColors.black : AppColors.black500,
          ),
        ),
      ],
    );
  }
}
