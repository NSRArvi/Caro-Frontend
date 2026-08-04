import 'dart:developer';

import 'package:get/get.dart';
import 'package:jimamuapp/data/models/user_model.dart';
import 'package:jimamuapp/routes/app_routes.dart';

import '../../controllers/auth_controller.dart';
import '../../data/services/api_manager.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/notification_service.dart';
import '../../utils/snakckbar_helper.dart';
import '../delivery/my_deliveries_controller.dart';
import '../delivery_request/delivery_request_list_controller.dart';
import '../order/customer/my_order_controller.dart';

class SplashController extends GetxController {
  late final AuthController auth = Get.find();
  late final NotificationService notificationService = Get.find();

  @override
  void onReady() {
    super.onReady();
    _init();
  }

  Future<void> _init() async {
    log("🚀 Splash Init Started");

    await Future.delayed(const Duration(seconds: 2));

    final token = await AuthService.getToken();
    log("Auth Token: $token");

    if (token == null || token.isEmpty) {
      Get.offAllNamed(AppRoutes.signIn);
      return;
    }

    auth.setToken(token);

    try {
      // Profile fetch
      final profileResponse = await ApiManager.getProfile(token);
      log("Profile Response: $profileResponse");

      if (profileResponse['success'] == true &&
          profileResponse['data']['status'] == 'active') {
        // User profile setup
        auth.setUserProfile(UserModel.fromJson(profileResponse['data']));

        // Rider hole rider info fetch
        if (auth.user.value!.roles.contains("rider")) {
          final response = await ApiManager.fetchRiderProfile(token);
          if (response != null) {
            auth.setRiderProfile(response);
          }
        }

        _handleAppLaunchNavigation();
      } else if (profileResponse['success'] == true) {
        auth.setUserProfile(UserModel.fromJson(profileResponse['data']));
        Get.offAllNamed(AppRoutes.profile);
      } else {
        Get.offAllNamed(AppRoutes.signIn);
      }
    } on Exception catch (e) {
      log("❌ Profile Error: $e");
      if (e.toString().contains("Unauthorized")) {
        Get.offAllNamed(AppRoutes.signIn);
      } else {
        AppSnackbar.error("Server error. Please check internet connection.");
      }
    }
  }

  void _handleAppLaunchNavigation() {
    final Map<String, dynamic>? data =
        notificationService.pendingNotificationData;

    if (data != null) {
      final notificationData = Map<String, dynamic>.from(data);
      notificationService.consumePendingData();

      Get.offAllNamed(AppRoutes.home);

      Future.delayed(const Duration(milliseconds: 1500), () {
        final String? route = notificationData['route'];
        final String? orderId = notificationData['order_id']?.toString();

        log("🚀 Navigating from Splash: route=$route, orderId=$orderId");

        switch (route) {
          case '/order_details':
          case '/new_bid_received':
            if (orderId != null) {
              if (!Get.isRegistered<MyOrderController>()) {
                Get.put(MyOrderController());
              }
              Get.toNamed(AppRoutes.orderDetails, arguments: orderId);
            }
            break;

          case '/bid_accepted':
            if (orderId != null) {
              if (!Get.isRegistered<MyDeliveriesController>()) {
                Get.put(MyDeliveriesController());
              }
              Get.toNamed(AppRoutes.deliveryDetails, arguments: orderId);
            }
            break;

          // case '/new_order_created':
          //   if (orderId != null) {
          //     // complex logic handles inside notification service for this route
          //     notificationService.navigateToNewOrderDetails(orderId);
          //   }
          //   break;

          case '/order_cancelled':
            if (!Get.isRegistered<DeliveryRequestListController>()) {
              Get.put(DeliveryRequestListController());
            }
            Get.toNamed(AppRoutes.newOrders);
            break;

          default:
            log("Unknown route from splash notification: $route");
            break;
        }
      });
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }
}
