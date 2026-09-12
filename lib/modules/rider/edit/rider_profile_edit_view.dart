import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/modules/rider/edit/rider_profile_edit_controller.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_typography.dart';

class RiderProfileEditView extends GetView<RiderProfileEditController> {
  const RiderProfileEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surface
            : Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          title: Text(
            'Rider Profile Edit',
            style: AppTypography.sub1Medium.copyWith(color: Colors.white),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Select Document Type",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FormField<String>(
                          validator: (value) {
                            if (controller.docTypeController.value.isEmpty) {
                              return 'Please select a document type';
                            }
                            return null;
                          },
                          builder: (FormFieldState<String> state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownMenu<String>(
                                  width: MediaQuery.of(context).size.width - 32.w,
                                  initialSelection:
                                      controller.docTypeController.value.isEmpty
                                      ? null
                                      : controller.docTypeController.value,
                                  hintText: "Select Document Type",
                                  dropdownMenuEntries: const [
                                    DropdownMenuEntry(
                                      value: 'Passport',
                                      label: 'Passport',
                                    ),
                                    DropdownMenuEntry(
                                      value: 'ID Card',
                                      label: 'ID Card',
                                    ),
                                    DropdownMenuEntry(
                                      value: 'Driver License',
                                      label: 'Driver License',
                                    ),
                                  ],
                                  onSelected: (String? newValue) {
                                    if (newValue != null) {
                                      controller.docTypeController.value =
                                          newValue;
                                      controller.frontFile.value = null;
                                      controller.backFile.value = null;
                                      controller.singleDocFile.value = null;
                                      state.didChange(
                                        newValue,
                                      ); // important for validation
                                    }
                                  },
                                  inputDecorationTheme: InputDecorationTheme(
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppColors.black100,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.blue,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  menuStyle: MenuStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                      Colors.white,
                                    ),
                                    surfaceTintColor: WidgetStateProperty.all(
                                      Colors.transparent,
                                    ),
                                    fixedSize: WidgetStateProperty.all(
                                      Size(
                                        MediaQuery.of(context).size.width - 32.w,
                                        180.h,
                                      ),
                                    ),
                                    elevation: WidgetStateProperty.all(4),
                                  ),
                                ),
                                if (state.hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 6,
                                      left: 4,
                                    ),
                                    child: Text(
                                      state.errorText ?? '',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Enter Document Number",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: controller.docNumberController,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Required Field';
                            }
                            if (controller.docTypeController.value == 'ID Card' &&
                                val.length < 10) {
                              return 'ID number must be 10 digit or more';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'XXXXXXXXX',
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
                        18.verticalSpace,
                        _buildDatePickerField(
                          "Expiry date",
                          controller.expiryDateController,
                          context,
                        ),
                        18.verticalSpace,
                        const SizedBox(height: 20),
                        // Document Images
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Document Image",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 12),

                        controller.docTypeController.value == 'Passport'
                            ? _imageUploadField(
                                controller.singleDocFile,
                                "Upload Document",
                                () => controller.pickImage("single"),
                              )
                            : Column(
                                children: [
                                  _imageUploadField(
                                    controller.frontFile,
                                    "Front Side",
                                    () => controller.pickImage("front"),
                                  ),
                                  const SizedBox(height: 10),
                                  _imageUploadField(
                                    controller.backFile,
                                    "Back Side",
                                    () => controller.pickImage("back"),
                                  ),
                                ],
                              ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      log("Submit Button on CLicked");
                      if (controller.formKey.currentState!.validate()) {
                        controller.updateUserProfile(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      );
    });
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
              today.year + 10,
              today.month,
              today.day,
            );

            final date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              lastDate: minAdultDate, // 18 years restriction
              initialDate: today,
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

  Widget _imageUploadField(Rx<File?> file, String label, VoidCallback onTap) {
    return FormField<File>(
      validator: (value) {
        if (file.value == null) return 'Please select a $label image';
        return null;
      },
      builder: (state) {
        return GestureDetector(
          onTap: controller.isDocumentAlreadySubmitted ? null : onTap,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: state.hasError ? Colors.red : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(
              () => file.value != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(file.value!, fit: BoxFit.cover),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            color: AppColors.primaryColor,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            label,
                            style: TextStyle(
                              color:
                                  Theme.of(Get.context!).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black54,
                            ),
                          ),
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                state.errorText ?? '',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
