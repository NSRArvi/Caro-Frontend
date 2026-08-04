import 'package:get/get.dart';
import 'package:jimamuapp/modules/place_order/international/international_placing_order_controller.dart';

class InternationalPlacingOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(InternationalPlacingOrderController());
  }
}
