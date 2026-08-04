import 'package:get/get.dart';
import 'package:jimamuapp/controllers/auth_controller.dart';
import 'package:jimamuapp/data/models/delivery_request_model.dart';

import '../../data/services/api_manager.dart';

class MyDeliveriesController extends GetxController {
  AuthController authController = Get.find();
  RxBool isLoading = true.obs;

  RxInt selectedTab = 0.obs;

  RxList<DeliveryRequestModel> ongoingDeliveries = <DeliveryRequestModel>[].obs;
  RxList<DeliveryRequestModel> completedDeliveries =
      <DeliveryRequestModel>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchDeliveries();
  }

  fetchDeliveries() async {
    final ongoingOrderResponse = ApiManager.fetchMyOngoingDeliveries(
      authController.token.value,
    );
    final completedOrderResponse = ApiManager.fetchMyCompletedDeliveries(
      authController.token.value,
    );

    final response = await Future.wait([
      ongoingOrderResponse,
      completedOrderResponse,
    ]);

    ongoingDeliveries.assignAll(response[0] as List<DeliveryRequestModel>);
    completedDeliveries.assignAll(response[1] as List<DeliveryRequestModel>);

    isLoading.value = false;
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
