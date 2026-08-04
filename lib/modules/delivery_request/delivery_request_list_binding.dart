import 'package:get/get.dart';
import 'package:jimamuapp/modules/delivery_request/delivery_request_list_controller.dart';

class DeliveryRequestListBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DeliveryRequestListController());
  }
}
