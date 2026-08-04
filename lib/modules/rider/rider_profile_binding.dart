import 'package:get/get.dart';
import 'package:jimamuapp/modules/rider/rider_profile_controller.dart';

class RiderProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RiderProfileController());
  }
}
