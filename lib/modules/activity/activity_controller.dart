import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/controllers/auth_controller.dart';

import '../../routes/app_routes.dart';
import '../../utils/snakckbar_helper.dart';

class ActivityController extends GetxController {
  AuthController authController = Get.find();
  final List<Map<String, String>> services = [
    {'icon': 'assets/icons/service_icon3.png', 'title': 'My Deliveries'},
    {'icon': 'assets/icons/service_icon4.png', 'title': 'My Orders'},
  ];

  void handleServiceTap(String title) {
    switch (title) {
      case 'My Orders':
        Get.toNamed(AppRoutes.myOrders);
        break;
      case 'My Deliveries':
        if (!authController.user.value!.roles.contains('rider')) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.toNamed(AppRoutes.riderProfileEdit);
            AppSnackbar.error(
              "You must complete your rider profile to access deliveries.",
              // backgroundColor: Colors.red.shade100,
              // colorText: Colors.red.shade900,
              // duration: const Duration(seconds: 3),
            );
          });
          return;
        }
        Get.toNamed(AppRoutes.myDeliveries);
        break;
      default:
        log("Service not handled: $title");
    }
  }
}
