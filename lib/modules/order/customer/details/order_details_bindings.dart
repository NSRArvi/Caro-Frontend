import 'package:get/get.dart';
import 'package:jimamuapp/modules/order/customer/details/order_details_controller.dart';

class OrderDetailsBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(OrderDetailsController());
  }
}
