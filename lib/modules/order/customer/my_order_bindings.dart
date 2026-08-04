import 'package:get/get.dart';
import 'package:jimamuapp/modules/order/customer/my_order_controller.dart';

class MyOrderBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(MyOrderController());
  }
}
