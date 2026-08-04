import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jimamuapp/controllers/auth_controller.dart';
import 'package:jimamuapp/data/models/rider_profile.dart';
import 'package:jimamuapp/data/models/user_model.dart';
import 'package:jimamuapp/data/services/api_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../../../utils/snakckbar_helper.dart';

class RiderProfileEditController extends GetxController {
  AuthController authController = Get.find();
  final formKey = GlobalKey<FormState>();

  var isLoading = false.obs;

  Rx<File?> frontFile = Rx<File?>(null);
  Rx<File?> backFile = Rx<File?>(null);
  Rx<File?> singleDocFile = Rx<File?>(null);

  var docTypeController = ''.obs;
  var docNumberController = TextEditingController();
  var expiryDateController = TextEditingController();

  RiderProfile? riderProfile;

  String? existingFrontImageUrl;
  String? existingBackImageUrl;
  String? existingOtherImageUrl;

  bool isDocumentAlreadySubmitted = false;

  Future<void> pickImage(String type) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      // compress the file into bytes
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: 70, // adjust quality (0–100)
      );

      // create a temp file with compressed data
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File('${tempDir.path}/doc_${pickedFile.name}');
      await compressedFile.writeAsBytes(compressedBytes!, flush: true);

      // assign file to correct variable
      if (type == "front") {
        frontFile.value = compressedFile;
      } else if (type == "back") {
        backFile.value = compressedFile;
      } else {
        singleDocFile.value = compressedFile;
      }
    }
  }

  void updateUserProfile(BuildContext context) async {
    isLoading.value = true;
    try {
      final response = await ApiManager.uploadRiderDocument(
        token: authController.token.value,
        docType: docTypeController.value,
        docNumber: docNumberController.text,
        frontFile: frontFile.value,
        backFile: backFile.value,
        singleDocFile: singleDocFile.value,
        expiryDate: expiryDateController.text,
      );

      if (response != null && response['success'] == true) {
        final riderDocuments = response['data'];
        log("Uploaded documents: $riderDocuments");

        authController.setRiderProfile(RiderProfile.fromJson(riderDocuments));
        log(
          "documents updated in auth controller: ${authController.riderProfile.value}",
        );

        final profileResponse = await ApiManager.getProfile(
          authController.token.value,
        );
        log("profile response $profileResponse");

        authController.setUserProfile(
          UserModel.fromJson(profileResponse['data']),
        );
        Get.back();
        AppSnackbar.success( "Profile updated successfully");
      } else {
        AppSnackbar.error(
          response?['message'] ?? 'Something went wrong',
          // snackPosition: SnackPosition.BOTTOM,
          // backgroundColor: Colors.red,
          // colorText: Colors.white,
        );
      }
    } catch (e) {
      AppSnackbar.error(
        'Something went wrong: $e',
        // snackPosition: SnackPosition.BOTTOM,
        // backgroundColor: Colors.red,
        // colorText: Colors.white,
      );
    }

    isLoading.value = false;
  }
}
