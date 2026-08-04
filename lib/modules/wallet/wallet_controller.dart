import 'package:get/get.dart';
import 'package:jimamuapp/controllers/auth_controller.dart';
import 'package:jimamuapp/data/models/wallet_history_model.dart';
import 'package:jimamuapp/data/services/api_manager.dart';

import '../../routes/app_routes.dart';
import '../../utils/snakckbar_helper.dart';

class WalletController extends GetxController {
  AuthController authController = Get.find();
  RxBool isLoading = false.obs;
  var walletHistory = Rxn<WalletHistoryModel>();
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadWalletHistory();
  }

  Future<void> loadWalletHistory() async {
    try {
      isLoading.value = true;
      final walletResponse = await ApiManager.fetchWalletHistory(
        authController.token.value,
      );
      if (walletResponse != null) {
        walletHistory.value = walletResponse;
      }
    } catch (e) {
      AppSnackbar.error("Request failed! Unknown error occurred.");
    } finally {
      isLoading.value = false;
    }
  }

  withdrawButtonClicked() async {
    final result =
        await Get.toNamed(
          AppRoutes.withdraw,
          arguments: walletHistory.value == null
              ? 0.0
              : walletHistory.value!.balance,
        ) ??
        false;
    if (result) loadWalletHistory();
  }
}
