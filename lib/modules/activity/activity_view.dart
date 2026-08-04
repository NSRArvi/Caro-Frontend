import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/modules/activity/activity_controller.dart';

import '../home/widgets/service_grid.dart';

class ActivityView extends GetView<ActivityController> {
  const ActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Activity'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ServicesGrid(
          services: controller.services,
          onServiceTap: controller.handleServiceTap,
        ),
      ),
    );
  }
}
