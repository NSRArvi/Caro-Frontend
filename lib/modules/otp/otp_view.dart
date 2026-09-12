import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_typography.dart';
import '../../ui/widgets/custom_button.dart';
import 'otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  String formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // title: Text('My Deliveries'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(child: Image.asset('assets/images/otp.png')),
                    SizedBox(height: 15.h),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      child: Column(
                        children: [
                          Text('Verification Code', style: AppTypography.h1Medium),
                          SizedBox(height: 22.h),
                          Text(
                            'We have sent the code verification to your email ${controller.emailController.text}',
                            style: AppTypography.h2Regular,
                          ),
                          SizedBox(height: 20.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(4, (index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: SizedBox(
                                  width: 50.w,
                                  height: 60.h,
                                  child: TextFormField(
                                    controller: controller.otpControllers[index],
                                    focusNode: controller.focusNodes[index],
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d*$'),
                                      ),
                                    ],
                                    textAlign: TextAlign.center,
                                    maxLength: 4,
                                    style: AppTypography.h1Medium.copyWith(
                                      color: AppColors.black,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor: AppColors.black50,
                                    ),
                                    onChanged: (value) =>
                                        controller.onOtpChanged(index, value),
                                  ),
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: 20.h),
                          Obx(
                            () => Text(
                              formatTime(controller.secondsRemaining.value),
                              style: AppTypography.sub1SemiBold.copyWith(
                                color: AppColors.black700,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Didn’t receive the code?',
                                  style: AppTypography.sub1Regular,
                                ),
                                TextButton(
                                  onPressed: controller.canResend.value
                                      ? controller.resendOtp
                                      : null,
                                  child: Text(
                                    'Resend',
                                    style: AppTypography.sub1Medium.copyWith(
                                      color: controller.canResend.value
                                          ? AppColors.black800
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                          text: 'Submit',
                          function: controller.submitOtp,
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
