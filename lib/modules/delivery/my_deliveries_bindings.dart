import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/modules/delivery/my_deliveries_controller.dart';

class MyDeliveriesBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(MyDeliveriesController());
  }
}
