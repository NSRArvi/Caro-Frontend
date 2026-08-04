import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BannerIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;

  const BannerIndicator({
    Key? key,
    required this.itemCount,
    required this.currentIndex,
    this.activeColor = Colors.red,
    this.inactiveColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 9.h,
          height: 9.h,
          decoration: BoxDecoration(
            color: currentIndex == index ? activeColor : inactiveColor,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
