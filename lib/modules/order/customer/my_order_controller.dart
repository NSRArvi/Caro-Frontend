import 'package:get/get.dart';
import 'package:jimamuapp/controllers/auth_controller.dart';
import 'package:jimamuapp/data/models/completed_order_model.dart';
import 'package:jimamuapp/data/services/api_manager.dart';

import '../../../data/models/ongoing_order_model.dart';

class MyOrderController extends GetxController {
  AuthController authController = Get.find();
  RxInt selectedTab = 0.obs;

  RxBool isDataLoaded = false.obs;

  RxList<OngoingOrderModel> ongoingOrders = <OngoingOrderModel>[].obs;
  RxList<CompletedOrderModel> completedOrders = <CompletedOrderModel>[].obs;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchOrders();
  }

  fetchOrders() async {
    final ongoingOrderResponse = ApiManager.fetchMyOngoingOrders(
      authController.token.value,
    );
    final completedOrderResponse = ApiManager.fetchMyCompletedOrders(
      authController.token.value,
    );

    final response = await Future.wait([
      ongoingOrderResponse,
      completedOrderResponse,
    ]);

    ongoingOrders.assignAll(response[0] as List<OngoingOrderModel>);
    completedOrders.assignAll(response[1] as List<CompletedOrderModel>);

    isDataLoaded.value = true;
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
