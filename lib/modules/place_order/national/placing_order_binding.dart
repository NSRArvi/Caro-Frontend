import 'package:get/get.dart';
import 'package:jimamuapp/modules/place_order/national/placing_order_controller.dart';

class PlacingOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PlacingOrderController());
  }
}
