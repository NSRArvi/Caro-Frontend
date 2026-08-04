import 'package:flutter/material.dart';

class MeasureSize extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onChange;

  const MeasureSize({
    super.key,
    required this.onChange,
    required this.child,
  });

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  Size? oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (!mounted) return;

      final contextSize = context.size;

      if (contextSize != null && oldSize != contextSize) {
        oldSize = contextSize;
        widget.onChange(contextSize);
      }
    });

    return widget.child;
  }
}
