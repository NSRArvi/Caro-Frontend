import 'package:get/get.dart';
import 'package:jimamuapp/modules/bank_information/controller/bank_information_controller.dart';

class BankInformationBindings extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.put(BankInformationController());
  }
}
