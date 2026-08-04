import 'package:get/get.dart';
import 'package:jimamuapp/modules/wallet/wallet_controller.dart';

class WalletBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.put(WalletController());
  }
}
