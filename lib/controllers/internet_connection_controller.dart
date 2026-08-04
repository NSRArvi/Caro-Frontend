import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/routes/app_routes.dart';
import 'package:jimamuapp/utils/app_colors.dart';


class InternetController extends GetxController {
  var isConnected = true.obs;
  bool isDialogOpen = false;
  List<String> allowedRoutes = [
    AppRoutes.splash,
    AppRoutes.signIn,
    AppRoutes.riderProfile,
    AppRoutes.home,
  ];

  @override
  void onInit() {
    super.onInit();
    _checkConnection();
    _listenConnection();
  }

  Future<void> _checkConnection() async {
    var result = await Connectivity().checkConnectivity();
    isConnected.value = result != ConnectivityResult.none;
  }

  void _listenConnection() {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      isConnected.value = !results.contains(ConnectivityResult.none);
      _showDialogIfNeeded();
    });
  }

  void _showDialogIfNeeded() {
    if (!isConnected.value && !isDialogOpen) {
      isDialogOpen = true;

      // final currentRoute = Get.currentRoute;

      Get.dialog(
        useSafeArea: false,
        PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 30.w),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140.w,
                        height: 140.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          color: Color(0xffFEF3F1),
                        ),
                        child: Icon(
                          CupertinoIcons.wifi_slash,
                          color: AppColors.primaryColor,
                          size: 45.r,
                        ),
                      ),
                      70.verticalSpace,
                      Text(
                        "No Internet Connection",
                        style: TextStyle(
                          fontSize: 25.r,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      15.verticalSpace,
                      Text(
                        "Please check your Wi-Fi or mobile data and try again.",
                        style: TextStyle(
                          color: AppColors.black700,
                          fontSize: 16.r,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      50.verticalSpace,
                      GestureDetector(
                        onTap: _checkConnection,
                        child: Container(
                          width: Get.width / 1.6,
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              fontSize: 16.r,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } else if (isConnected.value && isDialogOpen) {
      isDialogOpen = false;
      if (Get.isDialogOpen!) {
        Get.back(); // close dialog first
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        Get.offAllNamed(AppRoutes.splash);
      });
    }
  }
}
