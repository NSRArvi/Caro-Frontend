// lib/app/modules/signin/signin_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth_controller.dart';
import '../../data/services/api_manager.dart';
import '../../routes/app_routes.dart';
import '../../utils/snakckbar_helper.dart';

class SignInController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final isLoading = false.obs; // observable boolean

  void launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AppSnackbar.error( 'Could not launch $url');
    }
  }

  void submitEmail() async {
    if (formKey.currentState!.validate()) {
      if (emailController.text.isEmpty ||
          !GetUtils.isEmail(emailController.text)) {
        AppSnackbar.error( "Enter a valid email");
        return;
      }

      isLoading.value = true;

      final result = await ApiManager.sendEmailOtp(emailController.text);

      isLoading.value = false;

      if (result["success"]) {
        Get.find<AuthController>().setEmail(emailController.text);
        AppSnackbar.success("OTP sent to your email");
        Get.toNamed(AppRoutes.otp, arguments: {"email": emailController.text});
      } else {
        AppSnackbar.error( result["message"] ?? "Failed to send OTP");
      }
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
