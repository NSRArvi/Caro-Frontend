import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/controllers/internet_connection_controller.dart';
import 'package:jimamuapp/routes/app_pages.dart';
import 'package:jimamuapp/routes/app_routes.dart';
import 'package:jimamuapp/utils/app_keys.dart';

import 'controllers/auth_controller.dart';
import 'data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Get.putAsync(() => NotificationService().init());

  Get.put(AuthController());
  Get.put(InternetController());

 Stripe.publishableKey =
      "pk_live_51S77utQv73ccwXLJJJ2vFLtDShMqnnNpY4Coa1mPYft2TvTbklT7xgfo5ZwmUwb50Lqjs55VfTiOKnFqQdv5XtsU00Hyyd8wFw";

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: "CARO",
        initialRoute: AppRoutes.splash, // Splash route has its binding
        getPages: AppPages.routes,
        onReady: () {
          log("App Ready");
        },
      ),
    );
  }
}
