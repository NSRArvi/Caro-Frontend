// lib/app/modules/signin/signin_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jimamuapp/utils/app_typography.dart';

import '../../ui/widgets/custom_button.dart';
import '../../utils/app_colors.dart';
import 'signin_controller.dart';

class SignInView extends GetView<SignInController> {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    children: [
                      Image.asset('assets/images/signin.png', fit: BoxFit.fitWidth),
                      const SizedBox(height: 16),
                      Text(
                        'Caro',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                          fontSize: 36,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter your email',
                              style: AppTypography.sub1Medium.copyWith(
                                color: AppColors.black800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Column(
                              children: [
                                TextFormField(
                                  controller: controller.emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email is required';
                                    }

                                    final emailRegex = RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    );
                                    if (!emailRegex.hasMatch(value)) {
                                      return 'Enter a valid email address';
                                    }

                                    return null; // valid
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppColors.black100,
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppColors.black100,
                                        width: 1,
                                      ),
                                    ),
                                    hintText: 'example@gmail.com',
                                  ),
                                ),
                                const SizedBox(height: 40),
                                Center(
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: AppTypography.pRegular.copyWith(
                                        color: AppColors.black800,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'By tapping login, you agree to ',
                                        ),
                                        WidgetSpan(
                                          alignment: PlaceholderAlignment.baseline,
                                          baseline: TextBaseline.alphabetic,
                                          child: GestureDetector(
                                            onTap: () => controller.launchURL(
                                              'https://thecaro.app/terms-and-conditions',
                                            ),
                                            child: Text(
                                              'Terms and Conditions',
                                              style: AppTypography.pRegular
                                                  .copyWith(
                                                    color: Colors.blue,
                                                    decoration:
                                                        TextDecoration.underline,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const TextSpan(text: ' and '),
                                        WidgetSpan(
                                          alignment: PlaceholderAlignment.baseline,
                                          baseline: TextBaseline.alphabetic,
                                          child: GestureDetector(
                                            onTap: () => controller.launchURL(
                                              'https://thecaro.app/privacy-policy',
                                            ),
                                            child: Text(
                                              'Privacy',
                                              style: AppTypography.pRegular
                                                  .copyWith(
                                                    color: Colors.blue,
                                                    decoration:
                                                        TextDecoration.underline,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const TextSpan(text: ' of Jimamu.'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: SizedBox(
                width: double.infinity,
                child: Obx(
                  () => controller.isLoading.value
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        )
                      : CustomButton(
                          text: 'Continue',
                          function: () {
                            controller.submitEmail();
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
