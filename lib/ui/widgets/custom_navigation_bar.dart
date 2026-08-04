import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jimamuapp/utils/app_colors.dart';
import 'package:jimamuapp/utils/app_typography.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTabItem(
              iconPath: "assets/icons/home_icon.png",
              label: "Home",
              index: 0,
            ),
            _buildTabItem(
              iconPath: "assets/icons/activity_icon.png",
              label: "Activity",
              index: 1,
            ),
            _buildTabItem(
              iconPath: "assets/icons/profile.png",
              label: "Account",
              index: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required String iconPath,
    required String label,
    required int index,
  }) {
    final bool isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            height: 20.w,
            width: 20.w,
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0XFF6D6D6D),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppColors.primaryColor
                  : const Color(0XFF6D6D6D),
              fontSize: 11.r,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
