class AppConstants {
  AppConstants._();

  // static const String baseUrl = 'https://api.jimamu.com/api/v1/';
  static const String baseUrl = 'https://admin.nsrdev.com/api/v1/';
  // static const String baseUrl = 'https://thecaro.app/';
  /////  Login //////////
  static const String socialLoginUrl = 'social/login';
  static const String sendEmailOtpUrl = 'send/email/otp';

  ////////// Otp Verify //////////
  static const String emailOtpVerifyUrl = 'email/otp/verify';

  /// Update User
  static const String getUserProfileDataUrl = 'user/profile';
  static const String updateUserProfileDataUrl = 'user/profile/update';
  static const String riderUpdateProfileDataUrl = 'rider/profile/update';
  static const String getRiderProfileDataUrl = 'rider/profile';
  static const String getOrderOverviewUrl = 'order/overview';
  static const String getWalletHistoryUrl = 'wallets/history';

  //Order
  static const String fetchPackageTypeUrl = 'orders/packages';
  static const String fetchOrderPricingRate = 'order/pricing/rate';
  static const String placeOrder = 'orders/new/order/request';
  static const String placeGlobalOrder = 'orders/international/order/request';
  static const String fetchMyOngoingOrders =
      'orders/new/order/request/ongoing/list/';
  static const String fetchMyCompletedOrders = 'orders/my/completed/order/list';
  static const String orderDetails = 'orders/new/order/request/show/';
  static const String orderCancelReasonListURL =
      "orders/order/cancel/reason/list";
  static const String cancelOrderURL = "orders/order/cancel/";

  static const String riderNewOrderRequest = 'rider/my/new/order/request';
  static const String bidPlacement = 'rider/order/apply/bids/';
  static const String confirmRider = 'orders/confirmed/order/';
  static const String rejectRider = 'cancel/order/accepted/bid/';
  static const String fetchMyOngoingDelivery = 'rider/my/ongoing/order/';
  static const String fetchMyCompletedDelivery = 'rider/my/completed/order';
  static const String sendRiderOtpUrl = 'rider/order/send/otp/';
  static const String verifyRiderOtpUrl = 'rider/order/verify/';

  //bank information
  static const String bankInformationGet = 'rider/bank/index';
  static const String bankInformationPost = 'rider/bank/store';
}
