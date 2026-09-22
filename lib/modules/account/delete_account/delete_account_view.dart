import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/utils/app_colors.dart';
import 'package:jimamuapp/utils/app_typography.dart';
import 'delete_account_controller.dart';

class DeleteAccountView extends GetView<DeleteAccountController> {
  const DeleteAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          "Delete Account",
          style: AppTypography.sub1Medium.copyWith(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            40.verticalSpace,
            Icon(
              Icons.warning_amber_rounded,
              size: 100.r,
              color: AppColors.primaryColor,
            ),
            24.verticalSpace,
            Text(
              "Delete Your Account?",
              style: AppTypography.h3Regular.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            16.verticalSpace,
            Text(
              "Are you sure you want to delete your account? This action is permanent and your account will be deactivated.",
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: Colors.grey.shade600),
            ),
            const Spacer(),
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            _showDeleteConfirmDialog();
                          },
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Delete Account",
                            style: AppTypography.sub1Medium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                )),
            16.verticalSpace,
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () => Get.back(),
                child: Text(
                  "Cancel",
                  style: AppTypography.sub1Medium.copyWith(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            20.verticalSpace,
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog() {
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
                    color: Colors.redAccent.withOpacity(.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: AppColors.primaryColor,
                    size: 32,
                  ),
                ),

                18.verticalSpace,

                /// title
                Text(
                  "Delete Account",
                  style: AppTypography.h3Regular.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                8.verticalSpace,

                /// subtitle
                Text(
                  "Are you sure you want to delete your account? This action cannot be undone.",
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

                    /// delete button
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
                          controller.deleteAccount();
                        },
                        child: const Text(
                          "Delete",
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
