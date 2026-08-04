import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/modules/bank_information/widgets/primary_button.dart';
import 'package:jimamuapp/modules/bank_information/widgets/upload_box.dart';

import '../../ui/widgets/app_text_feild.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_typography.dart';
import 'controller/bank_information_controller.dart';

class BankInformationPage extends StatelessWidget {
  BankInformationPage({super.key});

  final controller = Get.put(BankInformationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          "Bank Information",
          style: AppTypography.sub1Medium.copyWith(color: Colors.white),
        ),
        // centerTitle: true,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(
                child: const CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AppTextField(
                        label: "Account Holder Name",
                        controller: controller.nameController,
                      ),
                      AppTextField(
                        label: "Institution Number (3 digits)",
                        controller: controller.institutionController,
                        keyboardType: TextInputType.number,
                      ),
                      AppTextField(
                        label: "Transit Number (5 digits)",
                        controller: controller.transitController,
                        keyboardType: TextInputType.number,
                      ),
                      AppTextField(
                        label: "Account Number (7-12 digits)",
                        controller: controller.accountController,
                        keyboardType: TextInputType.number,
                      ),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Void Cheque Image (Image/PDF)",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Obx(() => UploadBox(
                      //   image: controller.voidChequeImage.value,
                      //   onTap: controller.pickImage,
                      // )),
                      Obx(() {
                        if (controller.voidChequeImage.value != null) {
                          return UploadBox(
                            image: controller.voidChequeImage.value,
                            onTap: controller.pickImage,
                          );
                        }

                        if (controller.networkImage.value.isNotEmpty) {
                          return GestureDetector(
                            onTap: controller.pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.black100,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    controller.networkImage.value,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.fill,
                                    loadingBuilder:
                                        (
                                          BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress,
                                        ) {
                                          if (loadingProgress == null) {
                                            return child; // image is fully loaded
                                          }
                                          return SizedBox(
                                            height: 200,
                                            width: double.infinity,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.primaryColor,
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        width: double.infinity,
                                        color: Colors.grey.shade200,
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        return UploadBox(
                          image: null,
                          onTap: controller.pickImage,
                        );
                      }),

                      const SizedBox(height: 30),

                      // Obx(
                      //   () => controller.isLoading.value
                      //       ? const CircularProgressIndicator()
                      //       :
                      PrimaryButton(
                        title: "Submit",
                        onTap: controller.submit,
                        // ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
