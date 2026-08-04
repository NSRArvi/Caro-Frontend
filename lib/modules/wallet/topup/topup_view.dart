import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/modules/wallet/topup/topup_controller.dart';

import '../../../utils/app_colors.dart';

class TopUpView extends GetView<TopUpController> {
  const TopUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          "Wallet",
          style: TextStyle(color: Colors.white, fontSize: 18.r),
        ),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
    );
  }
}
