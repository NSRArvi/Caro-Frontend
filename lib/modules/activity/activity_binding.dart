import 'package:get/get.dart';
import 'package:jimamuapp/modules/activity/activity_controller.dart';

class ActivityBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ActivityController());
  }
}
