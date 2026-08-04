import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/controllers/auth_controller.dart';
import 'package:jimamuapp/controllers/settings_helper_controller.dart';
import 'package:jimamuapp/routes/app_routes.dart';
import 'package:jimamuapp/utils/app_colors.dart';
import 'package:jimamuapp/utils/app_typography.dart';

class UserInfoHeader extends StatelessWidget {
  final AuthController authController = Get.find();
  final SettingsHelperController settingsHelperController = Get.find();

  UserInfoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = authController.user.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Obx(() {
                final imgUrl = authController.user.value?.profileImage;

                return InkWell(
                  onTap: () {
                    Get.toNamed(AppRoutes.profile);
                  },
                  child: CircleAvatar(
                    radius: 30.r,
                    backgroundImage: (imgUrl != null && imgUrl.isNotEmpty)
                        ? NetworkImage(imgUrl)
                        : const AssetImage('assets/images/profile.png'),
                  ),
                );
              }),
              16.horizontalSpace,
              SizedBox(
                width: (Get.width) / 2.1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? "Guest User",
                      maxLines: 1,
                      style: AppTypography.h2Regular.copyWith(
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        settingsHelperController.currentLocationAddress.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.pBold.copyWith(fontSize: 13.r),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          InkWell(
            onTap: () {
              Get.toNamed(AppRoutes.wallet);
            },
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  Icon(Icons.wallet_rounded, size: 15, color: AppColors.white),
                  SizedBox(width: 6),
                  Text(
                    "Wallet",
                    maxLines: 1,
                    style: AppTypography.h2Regular.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
