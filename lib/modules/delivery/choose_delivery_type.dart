import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../ui/widgets/choose_type.dart';

class ChooseDeliveryType extends StatelessWidget {
  const ChooseDeliveryType({super.key});

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
            Get.toNamed(AppRoutes.myDeliveries, arguments: "national");
          },
          globalOnTap: () {},
        ),
      ),
    );
  }
}
