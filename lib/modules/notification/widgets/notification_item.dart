import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final String message;
  final String time;

  const NotificationItem({
    super.key,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF6F6F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Image.asset("assets/icons/Alarm.png", height: 14, width: 14),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  time,
                  style: TextStyle(fontSize: 10, color: Color(0xff6D6D6D)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
