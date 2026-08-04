import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/routes/app_routes.dart';
import 'package:jimamuapp/ui/widgets/choose_type.dart';

class OrderTypeSelectionView extends StatelessWidget {
  const OrderTypeSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: Text('Choose Order Type'),
      ),
      body: SafeArea(
        child: TypeSelectionView(
          nationalOnTap: () {
            Get.toNamed(AppRoutes.placingOrder, arguments: "national");
          },
          globalOnTap: () {
            Get.toNamed(
              AppRoutes.globalPlacingOrder,
              arguments: "international",
            );
          },
        ),
      ),
    );
  }
}
