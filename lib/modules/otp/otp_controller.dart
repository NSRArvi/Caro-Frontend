import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../data/models/user_model.dart';
import '../../data/services/api_manager.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/notification_service.dart';
import '../../routes/app_routes.dart';
import '../../utils/snakckbar_helper.dart';

class OtpController extends GetxController {
  late final AuthController auth = Get.find();
  late TextEditingController emailController;
  late List<TextEditingController> otpControllers;
  late List<FocusNode> focusNodes;

  var otp = ''.obs;
  var secondsRemaining = 180.obs;
  var canResend = false.obs;
  Timer? _timer;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController(text: auth.email.value);
    otpControllers = List.generate(4, (_) => TextEditingController());
    focusNodes = List.generate(4, (_) => FocusNode());

    startTimer();
  }

  final NotificationService notificationService = Get.find();

  void onOtpChanged(int index, String value) {
    if (value.length > 1) {
      String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (int i = 0; i < digits.length && (index + i) < 4; i++) {
        otpControllers[index + i].text = digits[i];
      }
      int nextFocus = index + digits.length;
      if (nextFocus > 3) nextFocus = 3;
      focusNodes[nextFocus].requestFocus();
    } else {
      if (value.isNotEmpty && index < 3) {
        focusNodes[index + 1].requestFocus();
      }
      if (value.isEmpty && index > 0) {
        focusNodes[index - 1].requestFocus();
      }
    }
  }

  void submitOtp() {
    otp.value = otpControllers.map((c) => c.text).join();
    if (otp.value.length < 4) {
      AppSnackbar.error('Please enter all 4 digits');
      return;
    }

    verifyOtp();
  }

  Future<void> verifyOtp() async {
    isLoading.value = true;
    try {
      if (notificationService.fcmToken == null || notificationService.fcmToken!.isEmpty) {
        log("FCM Token null, retrying...");
        notificationService.fcmToken = await FirebaseMessaging.instance.getToken();
      }

      if (notificationService.fcmToken == null) {
        AppSnackbar.error("Verification error: Security token not generated.");
        return;
      }
      final result = await ApiManager.emailOtpVerify(
        emailController.text,
        otp.value,
        notificationService.fcmToken ?? "",
      );

      if (result['success'] != true) {
        AppSnackbar.error(result['message'] ?? "OTP verification failed");
        return;
      }

      final token = result['data']['token'];
      log("OTP token: $token");
      auth.setToken(token);
      await AuthService.saveToken(token);

      final profileResponse = await ApiManager.getProfile(token);
      log("OTP profile response: $profileResponse");

      if (profileResponse['success'] == true) {
        final userModel = UserModel.fromJson(profileResponse['data']);
        auth.setUserProfile(userModel);

        if (profileResponse['data']['status'] == 'active') {
          if (auth.user.value!.roles.contains("rider")) {
            final response = await ApiManager.fetchRiderProfile(token);
            log("Fetch Rider Profile $response");
            if (response != null) {
              auth.setRiderProfile(response);
            }
          }
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.offAllNamed(AppRoutes.profile);
        }
      }
    } catch (e) {
      AppSnackbar.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void startTimer() {
    secondsRemaining.value = 180;
    canResend.value = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value == 0) {
        canResend.value = true;
        timer.cancel();
      } else {
        secondsRemaining.value--;
      }
    });
  }

  void resendOtp() async {
    if (!canResend.value) return;
    canResend.value = false;
    startTimer();
    await ApiManager.post(
      endpoint: 'send/email/otp',
      body: {"email": emailController.text},
    );
    AppSnackbar.success('OTP resent to your email');
  }

  @override
  void onClose() {
    emailController.dispose();
    otpControllers.forEach((c) => c.dispose());
    focusNodes.forEach((f) => f.dispose());
    _timer?.cancel();
    super.onClose();
  }
}
