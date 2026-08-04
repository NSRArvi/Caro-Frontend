import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_typography.dart';

class HeaderRow extends StatelessWidget {
  final String orderId;
  final String date;

  const HeaderRow({super.key, required this.orderId, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('#$orderId', style: AppTypography.sub1SemiBold),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: CircleAvatar(radius: 2, backgroundColor: AppColors.black400),
        ),
        Text(date, style: AppTypography.pRegular),
      ],
    );
  }
}
