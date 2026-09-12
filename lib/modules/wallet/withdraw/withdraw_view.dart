import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/modules/wallet/withdraw/withdraw_controller.dart';
import 'package:jimamuapp/utils/app_typography.dart';

import '../../../utils/app_colors.dart';

class WithdrawView extends GetView<WithdrawController> {
  const WithdrawView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.primaryColor,
        title: Text(
          "Withdraw Money",
          style: AppTypography.sub1Medium.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 100.h),
                      SizedBox(
                        width: Get.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "\$",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 40.r,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            5.horizontalSpace,
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: 50.w,
                                maxWidth: Get.width / 1.5,
                              ),
                              child: IntrinsicWidth(
                                child: TextFormField(
                                  controller: controller.withdrawController,
                                  textAlign: TextAlign.left,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*$'),
                                    ),
                                  ],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 45.r,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "0.0",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 45.r,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onFieldSubmitted: (val) {
                                    if (val.isEmpty) return;
                                    double parsed = double.tryParse(val) ?? 0.0;
                                    controller.withdrawController.text = parsed
                                        .toStringAsFixed(1);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text('Withdraw Amount', style: AppTypography.sub1Bold),
                      60.verticalSpace,
                      Text(
                        "\$ ${controller.balance.toStringAsFixed(2)} CAD",
                        style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold),
                      ),
                      10.verticalSpace,
                      Text(
                        'Available Balance',
                        style: AppTypography.bodyBold.copyWith(
                          color: AppColors.black400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.only(
                left: 20.w,
                right: 20.w,
                bottom: 15.h,
                top: 5.h,
              ),
              child: InkWell(
                onTap: controller.confirmWithdraw,
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.primaryColor,
                  ),
                  child: Text(
                    "Confirm Withdraw",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.r,
                    ),
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
