import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_typography.dart';

class ServiceItem extends StatelessWidget {
  final Map service;
  final VoidCallback onTap;

  const ServiceItem({super.key, required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Image.asset(
                service['icon'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 90.h,
              ),
            ),
            5.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Center(
                child: Text(service['title'], style: AppTypography.bodyBold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
