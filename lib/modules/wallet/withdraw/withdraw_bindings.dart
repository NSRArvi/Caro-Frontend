import 'package:get/get.dart';
import 'package:jimamuapp/modules/wallet/withdraw/withdraw_controller.dart';

class WithdrawBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.put(WithdrawController());
  }
}
