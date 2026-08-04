import 'package:get/get.dart';
import 'package:jimamuapp/modules/account/account_controller.dart';

class AccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AccountController());
  }
}
