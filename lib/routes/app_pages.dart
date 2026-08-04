import 'package:get/get.dart';
import 'package:jimamuapp/data/models/rider_profile.dart';
import 'package:jimamuapp/modules/bank_information/bank_information_bindings.dart';
import 'package:jimamuapp/modules/bank_information/bank_information_page.dart';
import 'package:jimamuapp/modules/delivery/details/delivery_details_binding.dart';
import 'package:jimamuapp/modules/delivery/details/delivery_details_view.dart';
import 'package:jimamuapp/modules/delivery/my_deliveries_bindings.dart';
import 'package:jimamuapp/modules/delivery/my_deliveries_view.dart';
import 'package:jimamuapp/modules/delivery_request/delivery_request_list_binding.dart';
import 'package:jimamuapp/modules/delivery_request/delivery_request_list_view.dart';
import 'package:jimamuapp/modules/order/customer/details/order_details_bindings.dart';
import 'package:jimamuapp/modules/order/customer/details/order_details_view.dart';
import 'package:jimamuapp/modules/order/customer/my_order_bindings.dart';
import 'package:jimamuapp/modules/order/customer/my_order_view.dart';
import 'package:jimamuapp/modules/place_order/international/international_placing_order_view.dart';
import 'package:jimamuapp/modules/place_order/national/placing_order_binding.dart';
import 'package:jimamuapp/modules/place_order/national/placing_order_view.dart';
import 'package:jimamuapp/modules/rider/edit/rider_profile_edit_binding.dart';
import 'package:jimamuapp/modules/rider/edit/rider_profile_edit_view.dart';
import 'package:jimamuapp/modules/rider/rider_profile_binding.dart';
import 'package:jimamuapp/modules/rider/rider_profile_view.dart';
import 'package:jimamuapp/modules/wallet/wallet_bindings.dart';
import 'package:jimamuapp/modules/wallet/wallet_view.dart';
import 'package:jimamuapp/modules/wallet/withdraw/withdraw_bindings.dart';
import 'package:jimamuapp/modules/wallet/withdraw/withdraw_view.dart';
import 'package:jimamuapp/ui/location_blocking_screen.dart';

import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/otp/otp_binding.dart';
import '../modules/otp/otp_view.dart';
import '../modules/place_order/international/international_placing_order_binding.dart';
import '../modules/profile/profile_binding.dart';
import '../modules/profile/profile_view.dart';
import '../modules/signin/signin_binding.dart';
import '../modules/signin/signin_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import 'app_routes.dart';
// import 'notification_page.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: '/',
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    // GetPage(name: '/notification', page: () => const NotificationPage()),
    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInView(),
      binding: SignInBinding(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpView(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.riderProfile,
      page: () {
        final riderDocument = Get.arguments as RiderDocument;
        return RiderProfileView(riderDocument);
      },
      binding: RiderProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.riderProfileEdit,
      page: () => const RiderProfileEditView(),
      binding: RiderProfileEditBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.newOrders,
      page: () => const DeliveryRequestListView(),
      binding: DeliveryRequestListBinding(),
    ),
    GetPage(
      name: AppRoutes.placingOrder,
      page: () => PlacingOrderView(),
      binding: PlacingOrderBinding(),
    ),
    GetPage(
      name: AppRoutes.placingOrder,
      page: () => PlacingOrderView(),
      binding: PlacingOrderBinding(),
    ),
    GetPage(
      name: AppRoutes.globalPlacingOrder,
      page: () => InternationalPlacingOrderView(),
      binding: InternationalPlacingOrderBinding(),
    ),
    GetPage(
      name: AppRoutes.myOrders,
      page: () => MyOrderView(),
      binding: MyOrderBindings(),
    ),
    GetPage(
      name: AppRoutes.orderDetails,
      page: () => OrderDetailsScreen(),
      binding: OrderDetailsBindings(),
    ),
    GetPage(
      name: AppRoutes.myDeliveries,
      page: () => MyDeliveriesView(),
      binding: MyDeliveriesBindings(),
    ),
    GetPage(
      name: AppRoutes.deliveryDetails,
      page: () => DeliveryDetailsView(),
      binding: DeliveryDetailsBindings(),
    ),
    GetPage(
      name: AppRoutes.wallet,
      page: () => const WalletHome(),
      binding: WalletBindings(),
    ),
    GetPage(
      name: AppRoutes.bank_information,
      page: () => BankInformationPage(),
      binding: BankInformationBindings(),
    ),
    GetPage(
      name: AppRoutes.withdraw,
      page: () => WithdrawView(),
      binding: WithdrawBindings(),
    ),

    GetPage(name: AppRoutes.locationBlock, page: () => LocationBlockScreen()),
  ];
}
