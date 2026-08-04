import 'package:flutter/material.dart';
import 'package:jimamuapp/utils/app_colors.dart';
import 'package:jimamuapp/utils/app_typography.dart';

class CustomOrderTabs extends StatelessWidget {
  final int selectedIndex; // current selected index
  final Function(int) onTabSelected; // callback on click

  const CustomOrderTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTab('Ongoing Orders', 0),
        const SizedBox(width: 8),
        _buildTab('History', 1),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onTabSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTypography.pMedium.copyWith(
            color: isSelected ? AppColors.white : AppColors.black,
          ),
        ),
      ),
    );
  }
}
