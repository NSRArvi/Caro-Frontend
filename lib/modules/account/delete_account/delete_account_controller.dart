import 'package:get/get.dart';
import 'package:jimamuapp/controllers/auth_controller.dart';
import 'package:jimamuapp/data/services/api_manager.dart';
import 'package:jimamuapp/utils/app_constants.dart';
import 'package:jimamuapp/utils/snakckbar_helper.dart';

import '../../../routes/app_routes.dart';

class DeleteAccountController extends GetxController {
  final AuthController authController = Get.find();
  var isLoading = false.obs;

  Future<void> deleteAccount() async {
    isLoading.value = true;
    try {
      final response = await ApiManager.delete(
        endpoint: AppConstants.deleteAccountUrl,
        token: authController.token.value,
      );

      if (response['success'] == true) {
        await authController.clearAuthData();
        AppSnackbar.success(response['message'] ?? "Account deleted successfully");
        Get.offAllNamed(AppRoutes.signIn);
      } else {
        AppSnackbar.error(response['message'] ?? "Failed to delete account");
      }
    } catch (e) {
      AppSnackbar.error("An error occurred. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }
}
