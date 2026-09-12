import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/modules/wallet/wallet_controller.dart';
import 'package:jimamuapp/utils/app_colors.dart';

import '../../utils/app_typography.dart';

class WalletHome extends GetView<WalletController> {
  const WalletHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          "Wallet",
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
      backgroundColor: Color(0xffF6F5FA),
      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
              : ListView(
                  padding: EdgeInsets.zero,
                  children: [
                      Container(
                        width: Get.width,
                        height: 160.h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 1),
                              color: Color(0xffe1e1e1),
                              spreadRadius: 1,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "\$ ${controller.walletHistory.value == null ? 0.0 : controller.walletHistory.value!.balance}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 35.r,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "Total Balance (in CAD)",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.r,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      15.verticalSpace,
                      InkWell(
                        onTap: controller.withdrawButtonClicked,
                        child: Container(
                          width: Get.width,
                          height: 50.h,
                          margin: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 1),
                                color: Color(0xffeaeaea),
                                spreadRadius: 1,
                                blurRadius: 1,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.0.w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      "assets/icons/deposit.png",
                                      height: 20.h,
                                      width: 20.h,
                                      color: AppColors.primaryColor.withAlpha(
                                        180,
                                      ),
                                    ),
                                    15.horizontalSpace,
                                    Text(
                                      "Withdraw",
                                      style: TextStyle(
                                        fontSize: 16.r,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_sharp,
                                  size: 22.r,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      10.verticalSpace,
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        child: Text(
                          "Transactions",
                          style: TextStyle(
                            color: Color(0xff302e2e),
                            fontWeight: FontWeight.bold,
                            fontSize: 16.r,
                          ),
                        ),
                      ),

                      if (controller.walletHistory.value != null &&
                          controller.walletHistory.value!.history.isNotEmpty)
                        ...controller.walletHistory.value!.history.map((tx) {
                          final bool isCredit = tx.type == "credit";
                          final Color amountColor = isCredit
                              ? Colors.green
                              : Color(0xfff84e37);

                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 5.h,
                            ),
                            child: Container(
                              width: Get.width,
                              height: 50.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.r),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0, 0),
                                    color: Color(0xffeaeaea),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 22.r),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: 50.h,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            tx.purpose,
                                            style: TextStyle(
                                              fontSize: 11.r,
                                              color: Color(0xff302e2e),
                                            ),
                                          ),
                                          Text(
                                            "\$${tx.amount} CAD",
                                            style: TextStyle(
                                              color: amountColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15.r,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 30.w,
                                      width: 30.w,
                                      decoration: BoxDecoration(
                                        color: isCredit
                                            ? Color(0xffe3f9e5)
                                            : Color(0xfffae3e3),
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          isCredit
                                              ? Icons.arrow_downward
                                              : Icons.payments_outlined,
                                          size: 18,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })
                      else
                        SizedBox(
                          height: 200.h,
                          child: Center(child: Text("No wallet history!")),
                        ),
                    ],
                  ),
        ),
      ),
    );
  }
}
