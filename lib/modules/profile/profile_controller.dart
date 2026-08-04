import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jimamuapp/routes/app_routes.dart';

import '../../controllers/auth_controller.dart';
import '../../data/models/user_model.dart';
import '../../data/services/api_manager.dart';
import '../../utils/snakckbar_helper.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var user = Rxn<UserModel>();
  AuthController authController = Get.find<AuthController>();

  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController dobController;
  late TextEditingController genderController;

  var gender = "".obs;
  final RxString receiverCountryCode = RxString('+1');
  final RxString selectedCountryName = RxString('Canada');

  var imageFile = Rx<File?>(null);
  var croppedFile = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    final user = authController.user.value;

    nameController = TextEditingController(text: user?.name ?? "");
    emailController = TextEditingController(text: user?.email ?? "");
    phoneController = TextEditingController(text: user?.phoneNumber ?? "");
    receiverCountryCode.value = user?.countryCode ?? "+1";
    selectedCountryName.value = user?.country ?? "Canada";
    dobController = TextEditingController(text: user?.dob ?? "");
    gender.value = user?.gender ?? "";
    genderController = TextEditingController(text: user?.gender ?? "");
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      imageFile.value = File(pickedFile.path);
      await cropImage();
    }
  }

  Future<void> cropImage() async {
    if (imageFile.value != null) {
      final cropped = await ImageCropper().cropImage(
        sourcePath: imageFile.value!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.red,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
          IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: true),
        ],
      );
      if (cropped != null) {
        croppedFile.value = File(cropped.path);
      }
    }
  }

  Future<void> updateProfile() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty) {
      AppSnackbar.error("Name and Email cannot be empty");
      return;
    }
    
    isLoading.value = true;
    File? fileToUpload = croppedFile.value ?? imageFile.value;

    try {
      final token = authController.token.value;
      final response = await ApiManager.updateProfile(
        token: token,
        name: nameController.text,
        dob: dobController.text,
        gender: gender.value,
        countryCode: receiverCountryCode.value,
        country: selectedCountryName.value,
        phoneNumber: phoneController.text,
        profileImage: fileToUpload,
      );

      if (response['success'] == true) {
        final profileResponse = await ApiManager.getProfile(token);

        authController.setUserProfile(
          UserModel.fromJson(profileResponse['data']),
        );

        AppSnackbar.success("Profile updated successfully");
        Get.offAllNamed(AppRoutes.home);
      } else {
        AppSnackbar.error(
          response['message'] ?? "Failed to update profile",
        );
      }
    } catch (e) {
      AppSnackbar.error("Request failed! Unknown error occurred.");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    super.onClose();
  }
}
