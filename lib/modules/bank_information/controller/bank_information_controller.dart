import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jimamuapp/utils/snakckbar_helper.dart';

import '../../../controllers/auth_controller.dart';
import '../../../utils/app_constants.dart';

class BankInformationController extends GetxController {
  final nameController = TextEditingController();
  final institutionController = TextEditingController();
  final transitController = TextEditingController();
  final accountController = TextEditingController();

  final Rx<File?> voidChequeImage = Rx<File?>(null);
  final RxString networkImage = ''.obs; // existing image url
  final RxBool isLoading = false.obs;

  final _picker = ImagePicker();
  AuthController authController = Get.find();
  String get token => authController.token.value;

  @override
  void onInit() {
    super.onInit();
    getBankData();
  }

  // ================= GET DATA =================
  Future<void> getBankData() async {
    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse("${AppConstants.baseUrl}${AppConstants.bankInformationGet}"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        final bankData = data["data"];

        if (bankData != null) {
          nameController.text = bankData["account_holer_name"] ?? "";
          accountController.text = bankData["account_number"] ?? "";
          institutionController.text = bankData["institution_number"] ?? "";
          transitController.text = bankData["transit_number"] ?? "";
          networkImage.value = bankData["bank_document"] ?? "";
        }
      } else {
        AppSnackbar.error(data["message"] ?? "Failed to load data");
      }
    } catch (e) {
      AppSnackbar.error("Failed to load data");
    } finally {
      isLoading.value = false;
    }
  }

  // ================= PICK IMAGE =================
  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      voidChequeImage.value = File(picked.path);
      networkImage.value = ""; // clear old network image
    }
  }

  // ================= SUBMIT / UPDATE =================
  Future<void> submit() async {
    if (nameController.text.isEmpty) {
      AppSnackbar.error("Name is required");
      return;
    }

    if (institutionController.text.isEmpty) {
      AppSnackbar.error("Institution number is required");
      return;
    }

    if (institutionController.text.length != 3) {
      AppSnackbar.error("Institution number must be 3 digits");
      return;
    }

    if (transitController.text.isEmpty) {
      AppSnackbar.error("Transit number is required");
      return;
    }

    if (transitController.text.length != 5) {
      AppSnackbar.error("Transit number must be 5 digits");
      return;
    }

    if (accountController.text.isEmpty) {
      AppSnackbar.error("Account number is required");
      return;
    }

    if (accountController.text.length < 7 ||
        accountController.text.length > 12) {
      AppSnackbar.error("Account number must be 7 to 12 digits");
      return;
    }

    if (voidChequeImage.value == null && networkImage.value.isEmpty) {
      AppSnackbar.error("Please upload void cheque image");
      return;
    }

    try {
      isLoading.value = true;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${AppConstants.baseUrl}${AppConstants.bankInformationPost}"),
      );

      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      request.fields['name'] = nameController.text;
      request.fields['account_number'] = accountController.text;
      request.fields['institution_number'] = institutionController.text;
      request.fields['transit_number'] = transitController.text;

      if (voidChequeImage.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'bank_document',
            voidChequeImage.value!.path,
          ),
        );
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      final message = data["message"]?.toString() ?? "Something went wrong";

      final successValue = data["success"];
      final isSuccess = successValue == true || successValue == "true";

      if (isSuccess) {
        AppSnackbar.success(message);
        getBankData();
      } else {
        AppSnackbar.error(message);
      }
    } catch (e) {
      AppSnackbar.error("Failed to submit data");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    institutionController.dispose();
    transitController.dispose();
    accountController.dispose();
    super.onClose();
  }
}
