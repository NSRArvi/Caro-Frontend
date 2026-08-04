import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jimamuapp/utils/location_helper.dart';

import '../../modules/delivery/my_deliveries_controller.dart';
import '../../modules/delivery_request/delivery_request_details_view.dart';
import '../../modules/delivery_request/delivery_request_list_controller.dart';
import '../../modules/order/customer/my_order_controller.dart';
import '../../routes/app_routes.dart';
import '../models/delivery_request_model.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  late AndroidNotificationChannel channel;

  String? fcmToken;
  Map<String, dynamic>? _pendingNotificationData;
  Map<String, dynamic>? get pendingNotificationData => _pendingNotificationData;
  bool _isNavigating = false;

  void handlePendingNavigation() {
    final data = consumePendingData();
    if (data != null) {
      log("🔥 Executing Navigation from Pending Data: $data");

      // Delay ektu bariye 1000-1500ms korun jate splash screen load hoye jay
      Future.delayed(const Duration(milliseconds: 1500), () {
        _handleMessageNavigation(data);
      });
    }
  }

  Map<String, dynamic>? consumePendingData() {
    final data = _pendingNotificationData;
    _pendingNotificationData = null;
    return data;
  }

  Future<NotificationService> init() async {
    await _requestPermission();
    await _initLocalNotification();
    await _getToken();

    _listenTokenRefresh();
    _listenForegroundNotification();
    _listenBackgroundNotification();
    _handleTerminatedNotification();
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
    return this;
  }

  /// ---------------- PERMISSION ----------------
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log("Notification permission: ${settings.authorizationStatus}");
  }

  /// ---------------- LOCAL NOTIFICATION ----------------
  Future<void> _initLocalNotification() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidInit);

    // await _localNotifications.initialize(
    //   settings: settings,
    //   onDidReceiveNotificationResponse: (response) {
    //     log("Notification Click Payload: ${response.payload}");
    //   },
    // );
    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        log("Notification Click Payload: ${response.payload}");

        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final decoded = jsonDecode(response.payload!);

            if (decoded is Map) {
              final data = decoded.map(
                (key, value) => MapEntry(key.toString(), value),
              );

              log("DECODED DATA: $data");

              _handleMessageNavigation(data);
            } else {
              log("Decoded payload is not a Map ❌");
            }
          } catch (e) {
            log("PAYLOAD DECODE ERROR: $e");
          }
        }
      },
    );
    channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// ---------------- GET TOKEN ----------------
  Future<void> _getToken() async {
    try {
      fcmToken = await _messaging.getToken();
      log("FCM TOKEN: $fcmToken");
    } catch (e) {
      log("FCM TOKEN ERROR: $e");
    }
  }

  /// ---------------- TOKEN REFRESH ----------------
  void _listenTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      fcmToken = newToken;
      log("NEW FCM TOKEN: $newToken");

      /// update token to server here
    });
  }

  /// ---------------- FULL DEBUG ----------------
  void _logFullMessage(RemoteMessage message) {
    log("======== FCM FULL MESSAGE ========");
    log("TITLE: ${message.notification?.title}");
    log("BODY: ${message.notification?.body}");
    log("DATA: ${message.data}");
    log("MESSAGE ID: ${message.messageId}");
    log("==================================");
  }

  /// ---------------- FOREGROUND ----------------
  void _listenForegroundNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logFullMessage(message);

      _showLocalNotification(message);
    });
  }

  /// ---------------- BACKGROUND CLICK ----------------
  void _listenBackgroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("Notification Clicked (Background)");

      _logFullMessage(message);

      _handleMessageNavigation(message.data);
    });
  }

  /// ---------------- TERMINATED ----------------
  // void _handleTerminatedNotification() async {
  //   final message = await FirebaseMessaging.instance.getInitialMessage();

  //   if (message != null) {
  //     log("Notification opened from terminated state");

  //     _logFullMessage(message);

  //     _handleMessageNavigation(message.data);
  //   }
  // }

  // NotificationService er vitore update korun
  void _handleTerminatedNotification() async {
    // অ্যাপ যখন একদম বন্ধ থাকে তখন এখান থেকে ডাটা রিসিভ হয়
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    if (initialMessage != null) {
      log(
        "🔥 TERMINATED MESSAGE DETECTED (Saving for later): ${initialMessage.data}",
      );
      // সরাসরি নেভিগেট না করে ডাটা সেভ করে রাখুন
      _pendingNotificationData = initialMessage.data;
    }
  }

  /// ---------------- SHOW LOCAL ----------------
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;

    if (notification == null) return;

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),

      payload: jsonEncode(message.data),
    );
  }

  /// ---------------- NAVIGATION ----------------
  void _navigateToNewOrderDetails(String orderId) async {
    final controller = Get.isRegistered<DeliveryRequestListController>()
        ? Get.find<DeliveryRequestListController>()
        : Get.put(DeliveryRequestListController());

    /// ensure data loaded
    if (controller.deliveryRequestList.value == null) {
      await controller.fetchNewDeliveryRequest();
    }

    DeliveryRequestModel? order = controller.findOrderById(orderId);

    if (order == null) {
      log("❌ Order not found");
      return;
    }

    final pickupLat = double.parse(order.pickupLatitude);
    final pickupLng = double.parse(order.pickupLongitude);
    final dropLat = double.parse(order.dropLatitude);
    final dropLng = double.parse(order.dropLongitude);

    final pickupLocation = await LocationHelper.getAddress(
      pickupLat,
      pickupLng,
    );
    final dropoffLocation = await LocationHelper.getAddress(dropLat, dropLng);

    Get.to(
      () => DeliveryRequestDetailsView(
        orderDetails: order,
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        pickupLatLng: LatLng(pickupLat, pickupLng),
        dropoffLatLng: LatLng(dropLat, dropLng),
      ),
    );
  }

  void _navigateToOrderDetails(String orderId) {
    // Future.delayed(const Duration(milliseconds: 500), () {
    if (!Get.isRegistered<MyOrderController>()) {
      Get.put(MyOrderController());
    }
    Get.toNamed(AppRoutes.orderDetails, arguments: orderId);
    // if (Get.context != null) {
    // } else {
    //   log("Get.context NULL ❌");
    // }
    // });
  }

  void _navigateToDeliveriesOrderDetails(String orderId) {
    // Future.delayed(const Duration(milliseconds: 500), () {
    if (!Get.isRegistered<MyDeliveriesController>()) {
      Get.put(MyDeliveriesController());
    }
    Get.toNamed(AppRoutes.deliveryDetails, arguments: orderId);
    // if (Get.context != null) {
    // } else {
    //   log("Get.context NULL ❌");
    // }
    // });
  }

  void _navigateToDeliverieryRequestOrderDetails(String orderId) {
    // Future.delayed(const Duration(milliseconds: 500), () {
    if (!Get.isRegistered<DeliveryRequestListController>()) {
      Get.put(DeliveryRequestListController());
    }
    Get.toNamed(AppRoutes.newOrders);
    // if (Get.context != null) {
    // } else {
    //   log("Get.context NULL ❌");
    // }
    // });
  }

  /// ---------------- HANDLE DATA ----------------
  void _handleMessageNavigation(Map<String, dynamic> data) {
    log("NAVIGATION DATA: $data");
    log("ROUTE: ${data['route']}");
    log("ORDER ID: ${data['order_id']}");
    log("NAVIGATION DATA: $data");
    if (_isNavigating) return;


    // Get.key.currentState check kora besi safe
    if (Get.key.currentState == null) {
      log("❌ Navigator state is null, postponing navigation");
      _pendingNotificationData = data;
      return;
    }

    _isNavigating = true;
    final route = data['route'];
    final orderId = data['order_id'];
    Future.delayed(const Duration(milliseconds: 200), () {
    // Future.microtask(() {
    switch (route) {
      case '/order_details':
      case '/new_bid_received':
        if (orderId != null) {
          _navigateToOrderDetails(orderId.toString());
        } else {
          log("Order ID NULL ❌");
        }
        break;

      case '/new_order_created':
        if (orderId != null) {
          _navigateToNewOrderDetails(orderId.toString());
        } else {
          log("Order ID NULL ❌");
        }
        break;
      case '/bid_accepted':
        if (orderId != null) {
          _navigateToDeliveriesOrderDetails(orderId.toString());
        } else {
          log("Order ID NULL ❌");
        }
        break;
      case '/order_cancelled':
        if (orderId != null) {
          _navigateToDeliverieryRequestOrderDetails(orderId.toString());
        } else {
          log("Order ID NULL ❌");
        }
        break;

      default:
        // Get.offAllNamed(AppRoutes.splash);
        log("Unknown route ❌: $route");
    }
    // Future.delayed(const Duration(seconds: 1), () {
    _isNavigating = false;
    // });
    });
  }
}

/// ---------------- BACKGROUND HANDLER ----------------

Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  log("Background Notification:");
  log("TITLE: ${message.notification?.title}");
  log("BODY: ${message.notification?.body}");
  log("DATA: ${message.data}");
}
