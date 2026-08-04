import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/routes/app_routes.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_typography.dart';
import 'account_controller.dart';

class AccountView extends GetView<AccountController> {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            24.verticalSpace,
            Obx(() {
              final imgUrl = controller.authController.user.value?.profileImage;

              return InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.profile);
                },
                child: CircleAvatar(
                  radius: 58.r,
                  backgroundImage: (imgUrl != null && imgUrl.isNotEmpty)
                      ? NetworkImage(imgUrl)
                      : const AssetImage('assets/images/profile.png'),
                ),
              );
            }),

            12.verticalSpace,
            Text(
              controller.authController.user.value?.name ?? 'User Name',
              style: AppTypography.h2Regular.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            4.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                4.horizontalSpace,
                Text(
                  controller
                          .settingsHelperController
                          .currentLocationAddress
                          .value
                          .isNotEmpty
                      ? controller
                            .settingsHelperController
                            .currentLocationAddress
                            .value
                      : 'Unknown Location',
                  style: AppTypography.bodyMedium.copyWith(color: Colors.grey),
                ),
              ],
            ),

            28.verticalSpace,

            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatCard(
                    controller.orderOverview.value != null
                        ? "${controller.orderOverview.value!.data!.totalCompletedMyDeliveries} Deliveries"
                        : "_ _ Deliveries",
                    "Completed",
                  ),
                  30.horizontalSpace,
                  _buildStatCard(
                    controller.orderOverview.value != null
                        ? "${controller.orderOverview.value!.data!.totalCompletedMyOrders} Parcels"
                        : "_ _ Parcels",
                    "Sent",
                  ),
                ],
              ),
            ),

            24.verticalSpace,

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Overviews",
                  style: AppTypography.sub1Medium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),

            16.verticalSpace,
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.person_outline,
                    "Customer Profile",
                    AppRoutes.profile,
                  ),
                  _divider(),
                  // Obx(
                  //   () => _buildMenuItem(
                  //     Icons.delivery_dining,
                  //     "Rider Profile",
                  //     controller.isRiderDocSubmitted.value
                  //         ? AppRoutes.riderProfile
                  //         : AppRoutes.riderProfileEdit,
                  //   ),
                  // ),
                  Obx(() {
                    final user = controller.authController.user.value;

                    final isRider = user?.roles.contains('rider') ?? false;

                    return _buildMenuItem(
                      Icons.delivery_dining,
                      "Rider Profile",
                      isRider
                          ? AppRoutes.riderProfile
                          : AppRoutes.riderProfileEdit,
                    );
                  }),
                  _divider(),
                  _buildMenuItem(
                    Icons.wallet_rounded,
                    "Wallet",
                    AppRoutes.wallet,
                  ),
                  _divider(),
                  _buildMenuItem(
                    Icons.account_balance_rounded,
                    "Bank Information",
                    AppRoutes.bank_information,
                  ),
                  _divider(),
                  // _buildMenuItem(
                  //   Icons.notifications_outlined,
                  //   "Notification",
                  //   '',
                  // ),
                  _divider(),
                  _buildAboutMenuItem(
                    Icons.support_agent_outlined,
                    "Support",
                    'https://thecaro.app/help-center',
                  ),
                  _divider(),
                  _buildAboutMenuItem(
                    Icons.email_outlined,
                    "Contact Us",
                    'https://thecaro.app/contact-us',
                  ),
                  // _divider(),
                  // _buildMenuItem(Icons.settings, "Settings", ''),
                ],
              ),
            ),

            30.verticalSpace,
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: _buildLogoutMenuItem(Icons.logout, "Logout", ''),
            ),

            50.verticalSpace,
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      width: (Get.width - 70.w) / 2,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.h4Regular.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          3.verticalSpace,
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.bodyBold.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String routeName) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(color: Colors.grey.shade800),
      ),
      onTap: () {
        if (routeName == AppRoutes.riderProfile) {
          Get.toNamed(
            routeName,
            arguments: controller
                .authController
                .riderProfile
                .value!
                .riderDocument!
                .first,
          );
        } else {
          Get.toNamed(routeName);
        }
      },
    );
  }

  Widget _buildAboutMenuItem(IconData icon, String title, String url) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(color: Colors.grey.shade800),
      ),
      onTap: () {
        controller.authController.launchURL(url);
      },
    );
  }

  Widget _buildLogoutMenuItem(IconData icon, String title, String routeName) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.primaryColor),
      ),
      onTap: () {
        showLogoutDialog(controller);
      },
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade300);

  void showLogoutDialog(AccountController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 350),
          tween: Tween<Offset>(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ),
          builder: (context, Offset value, child) {
            return Transform.translate(
              offset: Offset(0, value.dy * 200),
              child: child,
            );
          },
          child: Container(
            padding: EdgeInsets.all(22.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// icon
                Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: AppColors.primaryColor,
                    size: 32,
                  ),
                ),

                18.verticalSpace,

                /// title
                Text(
                  "Logout",
                  style: AppTypography.h3Regular.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                8.verticalSpace,

                /// subtitle
                Text(
                  "Are you sure you want to logout from your account?",
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(color: Colors.grey),
                ),

                26.verticalSpace,

                Row(
                  children: [
                    /// cancel button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text("Cancel"),
                      ),
                    ),

                    12.horizontalSpace,

                    /// logout button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                          controller.logOut();
                        },
                        child: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
