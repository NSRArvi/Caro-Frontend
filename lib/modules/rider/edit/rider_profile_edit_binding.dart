import 'package:get/get.dart';
import 'package:jimamuapp/modules/rider/edit/rider_profile_edit_controller.dart';

class RiderProfileEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RiderProfileEditController());
  }
}
