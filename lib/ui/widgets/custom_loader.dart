import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/utils/app_style.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/app_colors.dart';

class CustomLoading {
  /// -------------------------
  /// Standard centered spinner
  /// -------------------------
  static Widget loadingScreen({
    double size = 40,
    Color color = AppColors.primaryColor,
  }) => Center(
    child: SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(strokeWidth: 3, color: color),
    ),
  );

  /// -------------------------
  /// Blocking dialog with spinner
  /// -------------------------
  static Future<void> loadingDialog({
    String? message,
    Color color = AppColors.primaryColor,
    bool barrierDismissible = false,
  }) => Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(strokeWidth: 4, color: color),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    ),
    barrierDismissible: barrierDismissible,
    useSafeArea: true,
  );

  /// -------------------------
  /// PDF download with progress bar
  /// -------------------------
  static Widget pdfLoading({
    double? progress,
    String message = 'Downloading...',
    Color color = AppColors.primaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              color: color,
              minHeight: 8,
              backgroundColor: AppColors.kGreyLight,
            ),
          ),
        ],
      ),
    );
  }

  void showLoadingDialog() {
    Get.dialog(
      Center(
        child: Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const CircularProgressIndicator(),
        ),
      ),
      barrierDismissible: false, // prevent closing by tapping outside
    );
  }

  /// -------------------------
  /// Shimmer placeholder for list items
  /// -------------------------
  static Widget shimmerLoadingList({
    required BuildContext context,
    int itemCount = 3,
    double avatarSize = 50,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Shimmer.fromColors(
        baseColor: AppColors.kGreyLight,
        highlightColor: Colors.white,
        child: ListView.separated(
          itemCount: itemCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circular avatar shimmer
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                // Text shimmer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 20,
                      ),
                      const SizedBox(height: 10),
                      _shimmerBox(width: 200, height: 20),
                      const SizedBox(height: 10),
                      _shimmerBox(width: 150, height: 20),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Private helper shimmer box
  static Widget _shimmerBox({double width = 100, double height = 20}) {
    return Container(
      width: width,
      height: height,
      decoration: AppStyle.kCustomBoxDecoration(
        color: AppColors.kGreyWhite,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
