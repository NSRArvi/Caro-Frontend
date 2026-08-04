import 'dart:developer';
import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_typography.dart';
import '../international_placing_order_controller.dart';

Widget internationalLocationSubmitButton(
  InternationalPlacingOrderController controller,
) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    onPressed: () async {
      log("Location Button pressed");
      await controller.locationStepConfirm();
    },
    child: Text(
      'Continue',
      style: AppTypography.sub1Medium.copyWith(color: Colors.white),
    ),
  );
}

Widget internationalInformationSubmitButton(
  InternationalPlacingOrderController controller,
) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () async {
        await controller.informationStepConfirm();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        "Continue",
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    ),
  );
}

Widget internationalPlaceOrderButton(
  InternationalPlacingOrderController controller,
) {
  return SizedBox(
    child: ElevatedButton(
      onPressed: () async {
        await controller.placeOrder();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
      child: const Text("Submit", style: TextStyle(color: Colors.white)),
    ),
  );
}
