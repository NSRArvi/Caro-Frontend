import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../ui/widgets/choose_type.dart';

class ChooseOrderTypeView extends StatelessWidget {
  const ChooseOrderTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: Text('Choose Order Type'),
      ),
      body: TypeSelectionView(
        nationalOnTap: () {
          Get.toNamed(AppRoutes.myOrders, arguments: "national");
        },
        globalOnTap: () {},
      ),
    );
  }
}
