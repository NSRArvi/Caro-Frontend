import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/modules/account/account_view.dart';
import 'package:jimamuapp/modules/activity/activity_binding.dart';
import 'package:jimamuapp/modules/activity/activity_view.dart';
import 'package:jimamuapp/modules/home/home_controller.dart';
import 'package:jimamuapp/modules/home/widgets/banner_indicator.dart';
import 'package:jimamuapp/modules/home/widgets/banner_slider.dart';
import 'package:jimamuapp/modules/home/widgets/service_grid.dart';
import 'package:jimamuapp/modules/home/widgets/user_info_header.dart';
import 'package:jimamuapp/utils/app_typography.dart';
import '../../ui/widgets/custom_navigation_bar.dart';
import '../account/account_binding.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark, // white icons
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: Obx(
          () => SafeArea(
            top: false,
            child: CustomBottomNavigationBar(
              currentIndex: controller.selectedTabIndex.value,
              onTap: (index) => controller.selectedTabIndex.value = index,
            ),
          ),
        ),
        body: SafeArea(
          child: Obx(() {
            switch (controller.selectedTabIndex.value) {
              case 0:
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      15.verticalSpace,
                      UserInfoHeader(),
                      35.verticalSpace,
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: controller.isBannerLoading.value
                            ? BannerShimmer(height: Get.height * 0.2)
                            : BannerSlider(
                                bannerImages: controller.bannerImages,
                                currentIndex:
                                    controller.currentBannerIndex.value,
                                onPageChanged: (index) =>
                                    controller.currentBannerIndex.value = index,
                                height: Get.height * 0.2,
                              ),
                      ),
                      15.verticalSpace,
                      BannerIndicator(
                        itemCount: controller.bannerImages.length,
                        currentIndex: controller.currentBannerIndex.value,
                      ),
                      30.verticalSpace,
                      Text(
                        'Services',
                        style: AppTypography.h2Regular.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      30.verticalSpace,
                      ServicesGrid(
                        services: controller.services,
                        onServiceTap: controller.handleServiceTap,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                );
              case 1:
                ActivityBinding().dependencies();
                return const ActivityView();
              case 2:
                AccountBinding().dependencies();
                return const AccountView();
              default:
                return const SizedBox();
            }
          }),
        ),
      ),
    );
  }
}
