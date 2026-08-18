import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/controllers/auth_controller.dart';
import 'package:jimamuapp/modules/place_order/order_type_selection_view.dart';
import 'package:jimamuapp/routes/app_routes.dart';

import '../../controllers/settings_helper_controller.dart';
import '../../data/services/api_manager.dart';
import '../../utils/snakckbar_helper.dart';

class HomeController extends GetxController {
  AuthController authController = Get.find();
  var selectedTabIndex = 0.obs;
  var currentBannerIndex = 0.obs;
  RxBool isBannerLoading = false.obs;
  var bannerImages = <String>[].obs;

  // final bannerImages = [
  //   'assets/images/banner.png',
  //   'assets/images/banner.png',
  //   'assets/images/banner.png',
  // ];

  final services = [
    {'icon': 'assets/icons/service_icon1.png', 'title': 'Delivery Requests'},
    {'icon': 'assets/icons/service_icon2.png', 'title': 'Place Order'},
    {'icon': 'assets/icons/service_icon3.png', 'title': 'My Deliveries'},
    {'icon': 'assets/icons/service_icon4.png', 'title': 'My Orders'},
  ];

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<SettingsHelperController>()) {
      Get.lazyPut(() => SettingsHelperController(), fenix: true);
    }
    loadBanners();
  }



  Future<void> loadBanners() async {
    isBannerLoading.value = true;
    try {
      bannerImages.value = await ApiManager.fetchBanners(
        authController.token.value,
      );
    } finally {
      isBannerLoading.value = false;
    }
  }

  void handleServiceTap(String title) {
    switch (title) {
      case 'My Orders':
        Get.toNamed(AppRoutes.myOrders);
        break;
      case 'Place Order':
        Get.to(const OrderTypeSelectionView());
        break;
      case 'Delivery Requests':
        if (!authController.user.value!.roles.contains('rider')) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.toNamed(AppRoutes.riderProfileEdit);
            AppSnackbar.error(
              "You must complete your rider profile to access delivery requests.",
              // backgroundColor: Colors.red.shade100,
              // colorText: Colors.red.shade900,
              // duration: const Duration(seconds: 3),
            );
          });
          return;
        }
        Get.toNamed(AppRoutes.newOrders);
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
