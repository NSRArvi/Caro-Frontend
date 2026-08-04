// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:get/get.dart';
// import 'package:jimamuapp/controllers/internet_connection_controller.dart';
// import 'package:jimamuapp/routes/app_pages.dart';
// import 'package:jimamuapp/routes/app_routes.dart';
// import 'package:jimamuapp/utils/app_keys.dart';

// import 'controllers/auth_controller.dart';
// import 'data/services/notification_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   // await Get.putAsync(() => NotificationService().init());
//   // final notificationService =
//   await Get.putAsync(() => NotificationService().init());
//   Get.put(AuthController());
//   Get.put(InternetController());
//   Stripe.publishableKey =
//       "pk_test_51S77utQv73ccwXLJ7SwHDKQ4Xl0p1hxl5UQ4yzo81w4ma2P3GHhATIzQBl9PhKTL5hAMoyB8WprEjgCf1clABlKi00ByyOsouc";
//   // Stripe.publishableKey =
//   //     "pk_test_51PxpnFJE1F9dO0ft9IMohwAhVKJRZd66bNbL8RY60g6OvfVMgm9e8FKNsQZBcHVux2v1JakVrTsSn6vYKWNnXf3a00hVwA7qyP";
//   runApp(const MyApp());
//   // Future.delayed(const Duration(milliseconds: 800), () {
//   //   notificationService.handlePendingNavigation();
//   // });
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(375, 812),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (_, __) => GetMaterialApp(
//         // scaffoldMessengerKey: scaffoldMessengerKey,
//         navigatorKey: navigatorKey,
//         debugShowCheckedModeBanner: false,
//         title: "CARO",
//         initialRoute: AppRoutes.splash, // Splash route has its binding
//         getPages: AppPages.routes,
//       ),
//     );
//   }
// }

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

  // Stripe.publishableKey =
  //     "pk_test_51S77utQv73ccwXLJ7SwHDKQ4Xl0p1hxl5UQ4yzo81w4ma2P3GHhATIzQBl9PhKTL5hAMoyB8WprEjgCf1clABlKi00ByyOsouce.";
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
        // onReady: () {
        //   // Ekhane ektu delay dile GetX er context error ashar chance kome jay
        //   Future.delayed(const Duration(milliseconds: 500), () {
        //     if (Get.isRegistered<NotificationService>()) {
        //       Get.find<NotificationService>().handlePendingNavigation();
        //     }
        //   });
        // },
        onReady: () {
          log("App Ready");
        },
      ),
    );
  }
}
