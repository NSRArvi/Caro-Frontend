import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jimamuapp/controllers/auth_controller.dart';
import 'package:jimamuapp/data/models/completed_order_model.dart';
import 'package:jimamuapp/data/models/delivery_request_list_model.dart';
import 'package:jimamuapp/data/models/delivery_request_model.dart';
import 'package:jimamuapp/data/models/order_overview_model.dart';
import 'package:jimamuapp/data/models/wallet_history_model.dart';

import '../../utils/app_constants.dart';
import '../models/ongoing_order_model.dart';
import '../models/place_order_request_model.dart';
import '../models/rider_profile.dart';

bool isUnauthorizedResponse(dynamic response, {String? body}) {
  try {
    String? responseBody;

    if (response is http.Response) {
      responseBody = response.body;
      if (response.statusCode == 401) return true;
    } else if (response is http.StreamedResponse) {
      responseBody = body; // must be passed manually after decoding
      if (response.statusCode == 401) return true;
    }

    if (responseBody == null) return false;

    final jsonResponse = json.decode(responseBody);
    final message = (jsonResponse["message"] ?? "").toString().toLowerCase();

    return message.contains("unauthenticated");
  } catch (e) {
    return false;
  }
}

String getUserFriendlyError(int statusCode, dynamic responseBody) {
  try {
    final decoded = responseBody is String
        ? jsonDecode(responseBody)
        : responseBody;

    final serverMessage = decoded?["message"];

    /// If backend gives clean message → use it
    if (statusCode >= 400 && statusCode < 500) {
      return serverMessage ?? "Request failed";
    }
    return "Something went wrong. Please try again.";
  } catch (e) {
    return "Something went wrong. Please try again.";
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

final AuthController authController = Get.find();

class ApiManager {
  ApiManager._();

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (isUnauthorizedResponse(response)) {
        authController.logOut();
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      }

      return {
        "success": false,
        "message": getUserFriendlyError(response.statusCode, response.body),
      };
    } catch (_) {
      return {
        "success": false,
        "message": "Something went wrong. Please try again.",
      };
    }
  }

  static Future<Map<String, dynamic>> post({
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse("${AppConstants.baseUrl}$endpoint");

    log("Api Post URL: $url");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body != null ? jsonEncode(body) : null,
      );

      log("Status Code: ${response.statusCode}");
      log("Response Body: ${response.body}");

      if (isUnauthorizedResponse(response)) {
        authController.logOut();
      }

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded;
      }

      return {
        "success": false,
        "message": getUserFriendlyError(response.statusCode, response.body),
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Network error. Please check your connection.",
      };
    }
  }

  static Future<Map<String, dynamic>> get({
    required String endpoint,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');

    try {
      final response = await http.get(uri, headers: headers);

      log("GET Status: ${response.statusCode}");
      log("GET Body: ${response.body}");

      return _handleResponse(response);
    } catch (e) {
      return {
        "success": false,
        "message": "Network error. Please check your connection.",
      };
    }
  }

  // ========================
  // Send Email OTP API
  // ========================
  static Future<Map<String, dynamic>> sendEmailOtp(String email) async {
    return await post(
      endpoint: AppConstants.sendEmailOtpUrl,
      body: {"email": email},
    );
  }

  // ========================
  // VERIFY OTP API
  // ========================
  static Future<Map<String, dynamic>> emailOtpVerify(
    String email,
    String otp,
    String deviceToken,
  ) async {
    return await post(
      endpoint: AppConstants.emailOtpVerifyUrl,
      body: {"email": email, "otp_code": otp, "device_token": deviceToken},
    );
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    final url = Uri.parse(
      "${AppConstants.baseUrl}${AppConstants.getUserProfileDataUrl}",
    );

    log("Request URL $url");

    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      log("Api Manager Profile response: ${response.body}");
      return _handleResponse(response);
    } catch (e) {
      return {
        "success": false,
        "message": "Network error. Please check your connection.",
      };
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phoneNumber,
    required String countryCode,
    required String country,
    required String dob,
    required String gender,
    required File? profileImage,
    required String token, // pass token dynamically
  }) async {
    try {
      var uri = Uri.parse(
        "${AppConstants.baseUrl}${AppConstants.updateUserProfileDataUrl}",
      );

      var request = http.MultipartRequest("POST", uri);

      request.fields["name"] = name;
      request.fields["phone_number"] = phoneNumber;
      request.fields["country_code"] = countryCode;
      request.fields["country"] = country;
      request.fields["dob"] = dob;
      request.fields["gender"] = gender;
      request.fields["_method"] = "put";

      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath("profile_image", profileImage.path),
        );
      }

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      log("Token $token");

      var streamedResponse = await request.send();
      var responseString = await streamedResponse.stream.bytesToString();
      var responseJson = jsonDecode(responseString);
      if (isUnauthorizedResponse(streamedResponse, body: responseString)) {
        authController.logOut();
      }

      if (streamedResponse.statusCode == 200) {
        log("✅ Profile updated successfully: $responseJson");
        return {"success": true, "data": responseJson};
      } else {
        log("❌ Profile update failed: $responseJson");
        return {"success": false, "data": responseJson};
      }
    } catch (e) {
      log("⚠️ Exception in updateProfile: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<List<String>> fetchBanners(String token) async {
    var url = Uri.parse("${AppConstants.baseUrl}banners");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
      log("Banner url: $url");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        log("Banner fetch response: $data");

        List banners = data['data'] ?? [];

        // ✅ Filter only active banners
        final activeBanners = banners.where((e) => e['status'] == 'active');

        return activeBanners
            .map<String>((e) => (e['image_url'] ?? '').toString())
            .where((url) => url.isNotEmpty)
            .toList();
      } else if (response.statusCode == 401) {
        authController.logOut();
        return [];
      } else {
        log("❌ Banner fetch failed: ${response.body}");
        return [];
      }
    } catch (e) {
      log("🚨 Banner API exception: $e");
      return [];
    }
  }

  static Future<RiderProfile?> fetchRiderProfile(String token) async {
    try {
      final url = Uri.parse(
        "${AppConstants.baseUrl}${AppConstants.getRiderProfileDataUrl}",
      );

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (isUnauthorizedResponse(response)) {
        authController.logOut();
      }

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          return RiderProfile.fromJson(jsonResponse['data']);
        } else {
          throw ApiException(jsonResponse['message']);
        }
      } else {
        final error = _handleResponse(response);
        throw ApiException(error["message"]);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<OrderOverviewModel?> fetchOrderOverview(String token) async {
    try {
      final url = Uri.parse(
        "${AppConstants.baseUrl}${AppConstants.getOrderOverviewUrl}",
      );
      log("Request URL $url");
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (isUnauthorizedResponse(response)) {
        authController.logOut();
      }

      log("Request response ${response.statusCode} ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        log("response $jsonResponse");
        if (jsonResponse['success'] == true) {
          return OrderOverviewModel.fromJson(jsonResponse);
        } else {
          throw Exception(jsonResponse['message']);
        }
      } else {
        final error = _handleResponse(response);
        throw ApiException(error["message"]);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<WalletHistoryModel?> fetchWalletHistory(String token) async {
    try {
      final url = Uri.parse(
        "${AppConstants.baseUrl}${AppConstants.getWalletHistoryUrl}",
      );
      log("Request URL $url");
      log("Token $token");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // If token is required
        },
      );

      log(
        "Api Response: status code - ${response.body} body- ${response.body}",
      );
      if (isUnauthorizedResponse(response)) {
        authController.logOut();
      }

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return WalletHistoryModel.fromJson(jsonResponse);
        } else {
          if (jsonResponse['data'] == null) {
            return null;
          } else {
            throw Exception(
              jsonResponse['message'] ?? 'Failed to fetch wallet',
            );
          }
        }
      } else {
        final error = _handleResponse(response);
        throw ApiException(error["message"]);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> withdrawWallet({
    required double amount,
    required String token, // if your API uses Bearer auth
  }) async {
    final url = Uri.parse("${AppConstants.baseUrl}wallets/withdrawal");
    log('Withdraw URL: $url');
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // remove if not needed
        },
        body: jsonEncode({"amount": amount}),
      );

      if (isUnauthorizedResponse(response)) {
        authController.logOut();
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        log("✅ Success: ${response.body}");
        return data;
      } else {
        log("❌ Failed with status: ${response.statusCode}");
        return {
          "success": false,
          "status": response.statusCode,
          "message": data['message'],
        };
      }
    } catch (e) {
      log("⚠️ Error calling API: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> uploadRiderDocument({
    required String token,
    required String docType,
    required String docNumber,
    required String expiryDate,
    File? frontFile,
    File? backFile,
    File? singleDocFile,
  }) async {
    var url = Uri.parse(
      "${AppConstants.baseUrl}${AppConstants.riderUpdateProfileDataUrl}",
    );

    var request = http.MultipartRequest("POST", url);

    request.fields["_method"] = "put";
    request.fields["document_type"] = docType;
    request.fields["document_number"] = docNumber;
    request.fields["expire_date"] = expiryDate;

    if (docType.toLowerCase() == "passport") {
      if (singleDocFile == null) {
        log("⚠️ Please provide the document file.");
        return null;
      }
      request.files.add(
        await http.MultipartFile.fromPath("document[]", singleDocFile.path),
      );
    } else {
      if (frontFile == null || backFile == null) {
        log("⚠️ Please provide both front and back images for ID card.");
        return null;
      }
      request.files.add(
        await http.MultipartFile.fromPath("document[]", frontFile.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath("document[]", backFile.path),
      );
    }

    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    try {
      var response = await request.send();

      var responseData = await response.stream.bytesToString();
      if (isUnauthorizedResponse(response, body: responseData)) {
        authController.logOut();
      }

      log("✅ Succes: $responseData");

      if (response.statusCode == 200) {
        log("✅ Success: $responseData");
        return jsonDecode(responseData);
      } else {
        log("❌ Failed with status: ${response.statusCode}");
        return {
          "success": false,
          "status": response.statusCode,
          "message": responseData,
        };
      }
    } catch (e) {
      log("🚨 Exception: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<DeliveryRequestListModel?> fetchNewDeliveryRequestList(
    String token,
  ) async {
    try {
      final url = Uri.parse(
        "${AppConstants.baseUrl}${AppConstants.riderNewOrderRequest}",
      );
      log("Request URL $url");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token", // If token is required
        },
      );
      log("Token $token");
      log("Fetch OrderList response $response");
      if (isUnauthorizedResponse(response)) {
        authController.logOut();
      }
      if (response.statusCode == 200) {
        log("Response ${response.body}");
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true &&
            jsonResponse['data'].length != 0) {
          log("Inside response if");
          return DeliveryRequestListModel.fromJson(jsonResponse);
        } else {
          return null;
        }
      } else {
        final error = _handleResponse(response);
        throw ApiException(error["message"]);
      }
    } catch (e) {
      rethrow;
    }
  }

  // static Future<Map<String, dynamic>> applyBid({
  //   required String token,
  //   required String orderId,
  //   required int bidAmount,
  // }) async {
  //   final url = Uri.parse(
  //     "${AppConstants.baseUrl}${AppConstants.bidPlacement}$orderId",
  //   );

  //   log("Apply Bid Url $url");

  //   final response = await http.post(
  //     url,
  //     headers: {
  //       "Content-Type": "application/json",
  //       "Authorization": "Bearer $token",
  //     },
  //     body: jsonEncode({"bid_amount": bidAmount.toString()}),
  //   );

  //   log("Apply Bid response $response");
  //   if (isUnauthorizedResponse(response)) {
  //     authController.logOut();
  //   }
  //   if (response.statusCode == 201) {
  //     return jsonDecode(response.body);
  //   } else {
  //     return _handleResponse(response);
  //     // throw Exception(
  //     //   "Failed to apply bid: ${response.statusCode} - ${response.body}",
  //     // );
  //   }
  // }
  static Future<Map<String, dynamic>> applyBid({
    required String token,
    required String orderId,
    required int bidAmount,
  }) async {
    final url = Uri.parse(
      "${AppConstants.baseUrl}${AppConstants.bidPlacement}$orderId",
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"bid_amount": bidAmount.toString()}),
    );

    log("Apply Bid statusCode: ${response.statusCode}");
    log("Apply Bid body: ${response.body}");

    if (isUnauthorizedResponse(response)) {
      authController.logOut();
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)["message"] ?? "Something went wrong",
      );
    }
  }

  static Future<Map<String, dynamic>> fetchPackageTypes({
    required String token,
    required double lat,
    required double lng,
  }) async {
    log("Token $token");
    String url =
        '${AppConstants.baseUrl}${AppConstants.fetchPackageTypeUrl}?latitude=$lat&longitude=$lng';
    log("url: $url");
    final uri = Uri.parse(url);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    log(
      "Package Type fetching response ${response.body} ${response.statusCode}",
    );
    if (isUnauthorizedResponse(response)) {
      authController.logOut();
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log("Package Type fetching response decoded $data");
      return data;
    } else {
      return _handleResponse(response);
      // throw Exception(
      //   "Failed fetch Package Type: ${response.statusCode} - ${response.body}",
      // );
    }
  }

  static Future<Map<String, dynamic>> fetchPricingRate({
    required String token,
  }) async {
    log("Token $token");
    String url = '${AppConstants.baseUrl}${AppConstants.fetchOrderPricingRate}';
    log("url: $url");
    final uri = Uri.parse(url);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    log(
      "Order Pricing Rate fetching response ${response.body} ${response.statusCode}",
    );
    if (isUnauthorizedResponse(response)) {
      authController.logOut();
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log("Order Pricing Rate fetching response decoded $data");
      return data;
    } else {
      return _handleResponse(response);
      // throw Exception(
      //   "Failed fetch Order Pricing Rate: ${response.statusCode} - ${response.body}",
      // );
    }
  }

  static Future<http.Response> placeOrder(
    PlaceOrderRequest request,
    String token,
  ) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.placeOrder}');
    final body = jsonEncode(request.toJson());

    log('🔷 [POST] Request to: $url');
    log('🛡️ Token: $token');
    log('📤 Request Body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);
      log('✅ [POST] Response Code: ${response.statusCode}');
      log('📥 Response Body: ${response.body}');
      if (isUnauthorizedResponse(response)) {
        authController.logOut();
      }
      return response;
    } catch (e) {
      log('❗ Error placing order: $e');
      rethrow;
    }
  }

  static Future<http.Response> placeGlobalOrder(
    PlaceOrderRequest request,
    String token,
  ) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.placeGlobalOrder}',
    );
    final body = jsonEncode(request.toJson());

    log('🔷 [POST] Request to: $url');
    log('🛡️ Token: $token');
    log('📤 Request Body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (isUnauthorizedResponse(response)) {
        authController.logOut();
      }
      log('✅ [POST] Response Code: ${response.statusCode}');
      log('📥 Response Body: ${response.body}');
      return response;
    } catch (e) {
      log('❗ Error placing order: $e');
      rethrow;
    }
  }

  static Future<List<OngoingOrderModel>> fetchMyOngoingOrders(
    String token,
  ) async {
    log("Token $token");
    final url = '${AppConstants.baseUrl}${AppConstants.fetchMyOngoingOrders}';
    log("url: $url");
    final uri = Uri.parse(url);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    log(
      "My Ongoing Orders fetching response ${response.body} ${response.statusCode}",
    );

    if (isUnauthorizedResponse(response)) {
      authController.logOut();
    }
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      log("My Ongoing Orders fetching response decoded $data");

      return (data['data'] as List)
          .map((e) => OngoingOrderModel.fromJson(e))
          .toList();
    } else {
      final error = _handleResponse(response);
      throw ApiException(error["message"]);
    }
  }

  static Future<List<CompletedOrderModel>> fetchMyCompletedOrders(
    String token,
  ) async {
    log("Token $token");
    final url = '${AppConstants.baseUrl}${AppConstants.fetchMyCompletedOrders}';
    log("url: $url");
    final uri = Uri.parse(url);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    log(
      "My Completed Orders fetching response ${response.body} ${response.statusCode}",
    );
    if (isUnauthorizedResponse(response)) {
      authController.logOut();
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      log("My Completed Orders fetching response decoded $data");

      return (data['data'] as List)
          .map((e) => CompletedOrderModel.fromJson(e))
          .toList();
    } else {
      final error = _handleResponse(response);
      throw ApiException(error["message"]);
    }
  }

  static Future<DeliveryRequestModel?> fetchOrderDetails(
    String token,
    String orderId,
  ) async {
    try {
      final url = Uri.parse(
        "${AppConstants.baseUrl}${AppConstants.orderDetails}$orderId",
      );
      log("Request URL $url");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token", // If token is required
        },
      );
      log("Token $token");
      if (isUnauthorizedResponse(response)) {
        authController.logOut();
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final data = jsonDecode(response.body);
          log("Fetch Order Details response $data");
          return DeliveryRequestModel.fromJson(data['data'][0]);
        } else {
          throw Exception(jsonResponse['message']);
        }
      } else {
        final error = _handleResponse(response);
        throw ApiException(error["message"]);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> acceptRiderBid(
    String token,
    String orderId,
    String subOrderId,
    int riderId,
  ) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.confirmRider}$orderId/$subOrderId/$riderId',
    );
    log("URL: $url");
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    log("Response ${response.body}");
    if (isUnauthorizedResponse(response)) {
      authController.logOut();
    }

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      log("Response $body");
      return body;
    } else {
      return _handleResponse(response);
      // throw Exception(
      //   "Failed accepting rider bid: ${response.statusCode} - ${response.body}",
      // );
    }
  }

  static Future<bool> rejectRiderBid(
    String token,
    String orderId,
    int riderId,
  ) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.rejectRider}$orderId/$riderId',
    );
    log("URL: $url");
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    log("Response ${response.body}");
    if (isUnauthorizedResponse(response)) {
      authController.logOut();
    }

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      log("Response $body");
      return body["success"];
    } else {
      final error = _handleResponse(response);
      throw ApiException(error["message"]);
    }
  }

  static Future<Map<String, dynamic>> fetchOrderCancelReasons({
    required String token,
  }) async {
    log("Token $token");
    String url =
        '${AppConstants.baseUrl}${AppConstants.orderCancelReasonListURL}';
    log("url: $url");
    final uri = Uri.parse(url);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    log(
      "Package Type fetching response ${response.body} ${response.statusCode}",
    );
    if (isUnauthorizedResponse(response)) {
      authController.logOut();
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log("Order Cancel reasons fetching response decoded $data");
      return data;
    } else {
      return _handleResponse(response);
      // throw Exception(
      //   "Failed fetch Package Type: ${response.statusCode} - ${response.body}",
      // );
    }
  }

  static Future<bool> cancelOrder(
    String token,
    String orderId,
    String reason,
  ) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.cancelOrderURL}$orderId',
    );
    log("URL: $url");
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
      body: {"reason": reason},
    );

    log("Response ${response.body}");
    if (isUnauthorizedResponse(response)) {
      authController.logOut();
    }

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      log("Response $body");
      return body["success"];
    } else {
      final error = _handleResponse(response);
      throw ApiException(error["message"]);
    }
  }

  static Future<List<DeliveryRequestModel>> fetchMyOngoingDeliveries(
    String token,
  ) async {
    log("Token $token");
    final url = '${AppConstants.baseUrl}${AppConstants.fetchMyOngoingDelivery}';
    log("url: $url");
    final uri = Uri.parse(url);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    log(
      "My Ongoing deliveries fetching response ${response.body} ${response.statusCode}",
    );

    if (isUnauthorizedResponse(response)) {
      authController.logOut();
    }
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      log("My Ongoing deliveries fetching response decoded $data");

      return (data['data'] as List)
          .map((e) => DeliveryRequestModel.fromJson(e))
          .toList();
    } else {
      final error = _handleResponse(response);
      throw ApiException(error["message"]);
    }
  }

  static Future<List<DeliveryRequestModel>> fetchMyCompletedDeliveries(
    String token,
  ) async {
    log("Token $token");
    final url =
        '${AppConstants.baseUrl}${AppConstants.fetchMyCompletedDelivery}';
    log("url: $url");
    final uri = Uri.parse(url);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    log(
      "My Completed delivery fetching response ${response.body} ${response.statusCode}",
    );
    if (isUnauthorizedResponse(response)) {
      authController.logOut();
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      log("My Completed delivery fetching response decoded $data");

      return (data['data'] as List)
          .map((e) => DeliveryRequestModel.fromJson(e))
          .toList();
    } else {
      final error = _handleResponse(response);
      throw ApiException(error["message"]);
    }
  }

  static Future<Map<String, dynamic>> sendOtp(
    String token,
    String orderId,
    String otpType,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.sendRiderOtpUrl}$orderId/$otpType',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    log("Send Rider OTP response ${response.body} ${response.statusCode}");
    if (isUnauthorizedResponse(response)) {
      authController.logOut();
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log("Send Rider OTP response decoded $data");
      return data;
    } else {
      return _handleResponse(response);
      // throw Exception(
      //   "Failed Sending Rider OTP response: ${response.statusCode} - ${response.body}",
      // );
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
    String token,
    String orderId,
    String otpType,
    String otp,
  ) async {
    String url =
        '${AppConstants.baseUrl}${AppConstants.verifyRiderOtpUrl}$orderId/$otpType/$otp';
    log("url: $url");
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    log("response:${response.body}");
    if (isUnauthorizedResponse(response)) {
      authController.logOut();
    }
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log("Send Rider OTP response decoded $data");
      return data;
    } else {
      return _handleResponse(response);
      // throw Exception(
      //   "Failed Sending Rider OTP response: ${response.statusCode} - ${response.body}",
      // );
    }
  }
}
