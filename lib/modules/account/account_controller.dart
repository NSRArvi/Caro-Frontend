import 'dart:developer';

import 'package:get/get.dart';
import 'package:jimamuapp/controllers/auth_controller.dart';
import 'package:jimamuapp/controllers/settings_helper_controller.dart';
import 'package:jimamuapp/data/models/order_overview_model.dart';
import 'package:jimamuapp/data/services/api_manager.dart';
import 'package:jimamuapp/modules/home/home_controller.dart';

import '../../data/services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../../utils/snakckbar_helper.dart';

class AccountController extends GetxController {
  AuthController authController = Get.find();
  SettingsHelperController settingsHelperController = Get.find();
  late Rx<bool> isRiderDocSubmitted;
  var orderOverview = Rxn<OrderOverviewModel>();

  // @override
  // void onInit() {
  //   super.onInit();

  //   isRiderDocSubmitted = false.obs;

  //   ever(authController.user, (user) {
  //     if (user != null) {
  //       isRiderDocSubmitted.value =
  //           user.roles.contains('rider') ?? false;
  //     }
  //   });

  //   loadOrderOverview();

  //   ever(Get.find<HomeController>().selectedTabIndex, (index) {
  //     if (index == 2) {
  //       loadOrderOverview();
  //     }
  //   });
  // }
  @override
  void onInit() {
    super.onInit();

    isRiderDocSubmitted = false.obs;

    // ✅ INITIAL VALUE SET (🔥 MUST)
    final user = authController.user.value;

    if (user != null) {
      log("Initial roles: ${user.roles}");
      isRiderDocSubmitted.value = user.roles.contains('rider');
    }

    // ✅ FUTURE UPDATE LISTEN
    ever(authController.user, (user) {
      log("User updated: ${user?.roles}");

      if (user != null) {
        isRiderDocSubmitted.value = user.roles.contains('rider');
      }
    });

    loadOrderOverview();

    ever(Get.find<HomeController>().selectedTabIndex, (index) {
      if (index == 2) {
        loadOrderOverview();
      }
    });
  }

  void loadOrderOverview() async {
    try {
      final result = await ApiManager.fetchOrderOverview(
        authController.token.value,
      );

      if (result != null) {
        log("Completed Orders: ${result.data?.totalCompletedMyOrders}");
        log("Completed Deliveries: ${result.data?.totalCompletedMyDeliveries}");
        orderOverview.value = result;
      } else {
        log("⚠️ Failed: ${result?.message}");
      }
    } catch (e) {
      log("❌ Error fetching overview: $e");
    }
  }

  logOut() async {
    await AuthService.clearToken();
    AppSnackbar.success("Logged Out successfully");
    Get.offAllNamed(AppRoutes.signIn);
  }
}
