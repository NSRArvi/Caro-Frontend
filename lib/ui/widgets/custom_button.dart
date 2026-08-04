// import 'package:flutter/material.dart';
// import 'package:jimamuapp/utils/app_typography.dart';
// import '../../utils/app_colors.dart';
//
// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback function;
//
//   const CustomButton({super.key, required this.text, required this.function});
//
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.primaryColor,
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//       onPressed: function,
//       child: Text(
//         text,
//         style: AppTypography.sub1SemiBold.copyWith(color: Colors.white),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? function;
  final bool loading;

  const CustomButton({
    super.key,
    required this.text,
    required this.function,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : function, // IMPORTANT
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: loading
            ? const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
