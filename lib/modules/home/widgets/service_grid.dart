import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/modules/home/widgets/service_item.dart';
import 'package:jimamuapp/utils/app_typography.dart';

import '../../../utils/app_colors.dart';

class ServicesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> services;
  final void Function(String title) onServiceTap;

  const ServicesGrid({
    super.key,
    required this.services,
    required this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.16,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return ServiceItem(
          service: service,
          onTap: () => onServiceTap(service['title']),
        );
      },
    );
  }
}
