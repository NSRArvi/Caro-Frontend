import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/data/services/api_manager.dart';
import 'package:jimamuapp/utils/app_colors.dart';

import '../../../routes/app_routes.dart';
import '../../../ui/widgets/custom_loader.dart';
import '../../../utils/snakckbar_helper.dart';

class WithdrawController extends GetxController {
  RxDouble balance = 0.0.obs;

  final withdrawKey = GlobalKey<FormState>();

  late TextEditingController withdrawController;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    balance.value = Get.arguments;
    withdrawController = TextEditingController();
  }

  confirmWithdraw() async {
    final val = withdrawController.text.trim();

    if (val.isEmpty) {
      AppSnackbar.error(
        "Please enter amount",
        // snackPosition: SnackPosition.BOTTOM,
        // margin: EdgeInsets.only(bottom: 75),
      );
      return;
    }

    final amount = double.tryParse(val);
    if (amount == null) {
      AppSnackbar.error(
        "Please enter a valid number",
        // snackPosition: SnackPosition.BOTTOM,
        // margin: EdgeInsets.only(bottom: 100),
      );
      return;
    }

    if (amount == 0.0) {
      AppSnackbar.error(
        "Enter withdrawal amount",
        // snackPosition: SnackPosition.BOTTOM,
        // margin: EdgeInsets.only(bottom: 100),
      );
      return;
    }

    if (amount > balance.value) {
      AppSnackbar.error(
        "Amount exceeds your balance!",
        // snackPosition: SnackPosition.BOTTOM,
        // margin: EdgeInsets.only(bottom: 100),
      );
      return;
    }
    try {
      CustomLoading.loadingDialog();
      final response = await ApiManager.withdrawWallet(
        amount: double.tryParse(withdrawController.text) ?? 0.0,
        token: authController.token.value,
      );
      Get.back();
      if (response['success']) {
        Get.back(result: true);
        AppSnackbar.error(
          "Withdraw Request submitted successfully",
          // snackPosition: SnackPosition.BOTTOM,
          // margin: EdgeInsets.only(bottom: 100),
        );
      } else {
        AppSnackbar.error(
          "Failed: ${response["message"]}",
          // snackPosition: SnackPosition.BOTTOM,
          // margin: EdgeInsets.only(bottom: 100),
        );
      }
    } catch (e) {
      AppSnackbar.error(
        "Error: $e",
        // snackPosition: SnackPosition.BOTTOM,
        // margin: EdgeInsets.only(bottom: 100),
      );
    }
  }
}
