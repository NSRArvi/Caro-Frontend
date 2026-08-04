import 'package:get/get.dart';
import 'package:jimamuapp/modules/delivery/details/delivery_details_controller.dart';

class DeliveryDetailsBindings extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.put(DeliveryDetailsController());
  }
}