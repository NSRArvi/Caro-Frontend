import 'package:flutter/material.dart';

class DottedLine extends StatelessWidget {
  final double height;
  final double dotSize;
  final Color color;
  final double spacing;

  const DottedLine({
    super.key,
    required this.height,
    this.dotSize = 4,
    this.color = Colors.grey,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    final dotCount = height > 0 ? (height / (dotSize + spacing)).floor() : 0;
    return Column(
      children: List.generate(dotCount, (index) {
        return Container(
          width: 2,
          height: dotSize,
          margin: EdgeInsets.only(bottom: spacing),
          color: color,
        );
      }),
    );
  }
}
