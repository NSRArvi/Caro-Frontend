// lib/app/modules/signin/signin_binding.dart
import 'package:get/get.dart';
import 'signin_controller.dart';

class SignInBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignInController>(() => SignInController());
  }
}
