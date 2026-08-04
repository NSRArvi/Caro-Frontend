import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/modules/profile/profile_controller.dart';
import 'package:jimamuapp/utils/app_typography.dart';

import '../../ui/widgets/custom_button.dart';
import '../../utils/app_colors.dart';
import '../../utils/snakckbar_helper.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Customer Profile',
          style: AppTypography.sub1Medium.copyWith(color: Colors.white),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Obx(() {
          return controller.isLoading.value
              ? SizedBox()
              : Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: 16.w,
                    bottom: 20.h,
                    right: 16.w,
                    left: 16.w,
                  ),
                  margin: EdgeInsetsGeometry.only(top: 5.w),
                  child: CustomButton(
                    text: 'Submit',
                    function: () {
                      if (!controller.formKey.currentState!.validate()) {
                        AppSnackbar.error(
                          'Please fill all required fields',
                          // colorText: Colors.white,
                          // backgroundColor: Colors.red,
                        );
                        return;
                      }

                      if (controller.dobController.text.isEmpty) {
                        AppSnackbar.error(
                          'Please select your Date of Birth',
                          // colorText: Colors.white,
                          // backgroundColor: Colors.red,
                        );
                        return;
                      }

                      final dob = DateTime.parse(controller.dobController.text);
                      final age = DateTime.now().year - dob.year;
                      if (age < 18) {
                        AppSnackbar.error(
                          'You must be at least 18 years old',
                          // backgroundColor: Colors.red,
                          // colorText: Colors.white,
                        );
                        return;
                      }

                      if (controller.gender.value.isEmpty) {
                        AppSnackbar.error(
                          'Please select your gender',
                          // colorText: Colors.white,
                          // backgroundColor: Colors.red,
                        );
                        return;
                      }

                      controller.updateProfile();
                    },
                  ),
                );
        }),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }
          final user = controller.authController.user.value;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      height: 70.h,
                      color: AppColors.primaryColor,
                      width: double.infinity,
                    ),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Padding(
                          padding: EdgeInsetsGeometry.only(top: 15.h),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 64.r,
                                backgroundColor: Colors.white,
                              ),
                              Obx(() {
                                final img =
                                    controller.croppedFile.value ??
                                    controller.imageFile.value;
                                return CircleAvatar(
                                  radius: 60.r,
                                  backgroundImage: img != null
                                      ? FileImage(img)
                                      : (user?.profileImage != null
                                                ? NetworkImage(
                                                    user!.profileImage!,
                                                  )
                                                : const AssetImage(
                                                    'assets/images/profile.png',
                                                  ))
                                            as ImageProvider,
                                );
                              }),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor,
                            ),
                            child: Image.asset(
                              'assets/images/edit.png',
                              width: 20.w,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Form
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'Enter Name',
                          hintText: 'Type name',
                          controller: controller.nameController,
                        ),
                        18.verticalSpace,
                        _buildTextField(
                          label: 'Email Address',
                          hintText: 'Type email',
                          controller: controller.emailController,
                        ),
                        18.verticalSpace,
                        phoneInputField(
                          controller: controller.phoneController,
                          countryCode: controller.receiverCountryCode,
                          countryName: controller.selectedCountryName,
                        ),
                        18.verticalSpace,
                        _buildDatePickerField(
                          "Date of Birth",
                          controller.dobController,
                          context,
                        ),
                        18.verticalSpace,
                        Obx(() => _buildDropdownField("Select Gender")),
                        32.verticalSpace,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  //
  Widget phoneInputField({
    required TextEditingController controller,
    required RxString countryCode,
    required RxString countryName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Country",
          style: AppTypography.bodyMedium.copyWith(color: AppColors.black700),
        ),
        const SizedBox(height: 6),
        Container(
          height: 52,
          // padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.black100),
          ),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CountryCodePicker(
                onChanged: (code) {
                  if (code != null) {
                    countryCode.value = code.dialCode ?? '+1';
                    countryName.value = code.code ?? 'Canada';
                  }
                },
                // initialSelection: 'CA',
                initialSelection: countryName.value,
                favorite: const ['+1', '+880', '+91'],
                showCountryOnly: true,
                showOnlyCountryWhenClosed: true,
                hideMainText: false,
                alignLeft: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          "Enter Phone Number",
          style: AppTypography.bodyMedium.copyWith(color: AppColors.black700),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            ///  Country Code Display
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.black100),
              ),
              child: Obx(
                () => Text(countryCode.value, style: AppTypography.bodyRegular),
              ),
            ),

            const SizedBox(width: 8),

            // Phone Number Field
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.length < 7) {
                    return 'Invalid phone number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Phone number',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.black100),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePickerField(
    String label,
    TextEditingController controller,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.black700),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final DateTime today = DateTime.now();
            final DateTime minAdultDate = DateTime(
              today.year - 18,
              today.month,
              today.day,
            );

            final date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              lastDate: minAdultDate, // 18 years restriction
              initialDate: minAdultDate,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    dialogBackgroundColor: Colors.blue.shade50,
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primaryColor,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (date != null) {
              controller.text = date.toIso8601String().split("T").first;
            }
          },

          // onTap: () async {
          //   final date = await showDatePicker(
          //     context: context,
          //     firstDate: DateTime(1900),
          //     lastDate: DateTime.now(),
          //     initialDate: DateTime(2000),
          //     builder: (context, child) {
          //       return Theme(
          //         data: Theme.of(context).copyWith(
          //           dialogBackgroundColor:
          //               Colors.blue.shade50, // 🎯 change bg color
          //           colorScheme: ColorScheme.light(
          //             primary: AppColors.primaryColor, // header & selected date
          //             onPrimary: Colors.white, // text color on selected date
          //             onSurface: Colors.black, // default text color
          //           ),
          //           textButtonTheme: TextButtonThemeData(
          //             style: TextButton.styleFrom(
          //               foregroundColor:
          //                   AppColors.primaryColor, // button text color
          //             ),
          //           ),
          //         ),
          //         child: child!,
          //       );
          //     },
          //   );
          //   if (date != null) {
          //     controller.text = date.toIso8601String().split("T").first;
          //   }
          // },
          child: AbsorbPointer(
            child: TextFormField(
              keyboardType: TextInputType.datetime,
              controller: controller,
              validator: (value) => value == null || value.isEmpty
                  ? 'This field is required'
                  : null,
              decoration: InputDecoration(
                hintText: 'Select Date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.black100),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                suffixIcon: Icon(
                  Icons.calendar_today,
                  color: AppColors.black500,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.black700),
        ),
        const SizedBox(height: 6),
        label == 'Email Address'
            ? InkWell(
                onTap: () {
                  AppSnackbar.error(
                    'You can not change your email.',
                    // colorText: Colors.white,
                  );
                },
                child: IgnorePointer(
                  child: TextFormField(
                    controller: controller,
                    validator: (value) => value == null || value.isEmpty
                        ? 'This field is required'
                        : null,
                    decoration: InputDecoration(
                      hintText: label == 'Email Address' ? null : hintText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.black100),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              )
            : TextFormField(
                controller: controller,
                keyboardType: label == 'Enter Phone Number'
                    ? TextInputType.phone
                    : TextInputType.text,
                validator: (value) => value == null || value.isEmpty
                    ? 'This field is required'
                    : null,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.black100),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildDropdownField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.black700),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.black100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.gender.value.isEmpty
                  ? null
                  : controller.gender.value,
              hint: const Text("Select Gender"),
              isExpanded: true,
              menuWidth: Get.width - 34.w,
              dropdownColor: Colors.white,
              items: const [
                DropdownMenuItem(
                  value: null,
                  child: Text(
                    'Select Gender',
                    style: TextStyle(color: Colors.grey),
                  ),
                  enabled: false,
                ),
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                controller.genderController.text = value!;
                controller.gender.value = value;
              },
            ),
          ),
        ),
      ],
    );
  }
}
