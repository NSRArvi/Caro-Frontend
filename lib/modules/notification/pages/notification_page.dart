import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/notification_controller.dart';
import '../widgets/notification_item.dart';

class NotificationPage extends StatelessWidget {
  NotificationPage({super.key});

  final controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        // leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => ListView.builder(
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final item = controller.notifications[index];

              return NotificationItem(
                message: item["message"]!,
                time: item["time"]!,
              );
            },
          ),
        ),
      ),
    );
  }
}
