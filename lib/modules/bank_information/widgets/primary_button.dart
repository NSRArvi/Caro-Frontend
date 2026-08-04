import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final String? icon;
  final VoidCallback onTap;

  const PrimaryButton({
    super.key,
    required this.title,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Image.asset(
                icon!,
                width: 25,
                height: 25,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}