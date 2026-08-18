import 'dart:async';
import 'package:flutter/material.dart';
import 'app_keys.dart';

class AppSnackbar {
  static final List<OverlayEntry> _overlayQueue = [];

  static void success(
    String message, {
    Duration? duration,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
  }) {
    _showToast(
      message: message,
      duration: duration ?? const Duration(seconds: 3),
      bgColor: backgroundColor ?? const Color(0xFF16A34A),
      textColor: textColor ?? Colors.white,
      icon: icon ?? Icons.check_circle_rounded,
    );
  }

  static void error(
    String message, {
    Duration? duration,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
  }) {
    _showToast(
      message: message,
      duration: duration ?? const Duration(seconds: 3),
      bgColor: backgroundColor ?? const Color(0xFFDC2626),
      textColor: textColor ?? Colors.white,
      icon: icon ?? Icons.error_rounded,
    );
  }

  static void _showToast({
    required String message,
    required Duration duration,
    required Color bgColor,
    required Color textColor,
    required IconData icon,
  }) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        final index = _overlayQueue.indexOf(entry);
        return _AnimatedToast(
          message: message,
          duration: duration,
          bgColor: bgColor,
          textColor: textColor,
          icon: icon,
          topOffset: 12.0 + (index * 80),
          onDismiss: () {
            entry.remove();
            _overlayQueue.remove(entry);
          },
        );
      },
    );

    _overlayQueue.add(entry);
    overlay.insert(entry);
  }
}

class _AnimatedToast extends StatefulWidget {
  final String message;
  final Duration duration;
  final Color bgColor;
  final Color textColor;
  final IconData icon;
  final double topOffset;
  final VoidCallback onDismiss;

  const _AnimatedToast({
    required this.message,
    required this.duration,
    required this.bgColor,
    required this.textColor,
    required this.icon,
    required this.topOffset,
    required this.onDismiss,
  });

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();

    Future.delayed(widget.duration, () {
      dismiss();
    });
  }

  void dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + widget.topOffset,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.horizontal,
            onDismissed: (_) => widget.onDismiss(),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: widget.bgColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: widget.bgColor.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(widget.icon,
                        color: widget.textColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: widget.textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}