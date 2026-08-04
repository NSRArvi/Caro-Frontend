import 'package:get/get.dart';
import 'package:jimamuapp/modules/wallet/topup/topup_controller.dart';

class TopUpBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.put(TopUpController());
  }
}
