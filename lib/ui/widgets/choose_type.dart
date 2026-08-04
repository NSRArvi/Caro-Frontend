import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/routes/app_routes.dart';
import 'package:jimamuapp/utils/app_colors.dart';
import 'package:jimamuapp/utils/app_typography.dart';

class TypeSelectionView extends StatelessWidget {
  final VoidCallback nationalOnTap;
  final VoidCallback globalOnTap;
  const TypeSelectionView({
    super.key,
    required this.nationalOnTap,
    required this.globalOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(16.w),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: nationalOnTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: AppColors.black50,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),

              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 12.w,
                  vertical: 15.h,
                ),
                child: Row(
                  children: [
                    Image.asset('assets/icons/national.png', width: 60.w),
                    12.horizontalSpace,
                    SizedBox(
                      width: Get.width - 138.w,
                      // height: 70.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nationwide Delivery",
                            maxLines: 1,
                            style: AppTypography.sub1Bold,
                          ),
                          3.verticalSpace,
                          Text(
                            'Delivering anywhere across Canada with ease.',
                            style: AppTypography.pRegular,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          20.verticalSpace,
          InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: globalOnTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: AppColors.black50,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 12.w,
                  vertical: 15.h,
                ),
                child: Row(
                  children: [
                    Image.asset('assets/icons/global.png', width: 60.w),
                    12.horizontalSpace,
                    SizedBox(
                      width: Get.width - 138.w,
                      // height: 60.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Global Delivery",
                            maxLines: 1,
                            style: AppTypography.sub1Bold,
                          ),
                          3.verticalSpace,
                          Text(
                            'Ship your items anywhere across the world.',
                            style: AppTypography.pRegular,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
