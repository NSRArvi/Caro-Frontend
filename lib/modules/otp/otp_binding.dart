import 'package:get/get.dart';
import 'package:jimamuapp/modules/otp/otp_controller.dart';

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(OtpController());
  }
}
