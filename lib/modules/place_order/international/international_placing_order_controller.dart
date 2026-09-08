import 'dart:convert';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:jimamuapp/controllers/auth_controller.dart';
import 'package:jimamuapp/data/services/api_manager.dart';
import 'package:jimamuapp/routes/app_routes.dart';
import 'package:jimamuapp/utils/app_constants.dart';

import '../../../data/models/delivery_request_model.dart';
import '../../../data/models/place_order_request_model.dart';
import '../../../data/models/user_model.dart';
import '../../../ui/widgets/custom_loader.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/snakckbar_helper.dart';
import 'international_location_picker_screen.dart';

class InternationalPlacingOrderController extends GetxController {
  AuthController authController = Get.find();
  RxString orderType = ''.obs;
  RxInt currentStep = 0.obs;
  var pickupAddress = "".obs;
  var deliveryAddress = "".obs;
  RxDouble baseFare = 0.0.obs;
  RxDouble platformCharge = 0.0.obs;
  RxDouble distanceInKm = 0.0.obs;
  RxDouble distanceCharge = 0.0.obs;
  var selectedDeliveryLocation = Rxn<LatLng>();
  var selectedPickupLocation = Rxn<LatLng>();
  String selectedWeightUnit = 'lbs';
  // RxString receiverCountryCode = '+880'.obs;
  final RxString receiverCountryCode = RxString('+1');
  final RxString receiverSelectedCountryName = RxString('Canada');
  final RxString senderCountryCode = RxString('+1');
  final RxString selectedCountryName = RxString('Canada');

  GoogleMapController? mapController;

  late BitmapDescriptor pickupIcon;

  RxList<LatLng> routePoints = <LatLng>[].obs;

  RxList<Map<String, dynamic>> packageType = <Map<String, dynamic>>[].obs;
  var selectedPackage = Rxn<Map<String, dynamic>>();

  final infoFormKey = GlobalKey<FormState>();
  final additionalInfoKey = GlobalKey<FormState>();

  late TextEditingController senderNameController;
  late TextEditingController senderPhoneController;
  late TextEditingController senderRemarksController;
  late TextEditingController receiverController;
  late TextEditingController receiverPhoneController;
  late TextEditingController receiverRemarksController;

  late TextEditingController productWeightController;
  late TextEditingController productValueController;
  late TextEditingController willingDeliveryChargeController;
  RxDouble prodWeight = 0.0.obs;
  RxDouble prodMarketValue = 0.0.obs;
  RxDouble willingDeliveryCharge = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    orderType.value = Get.arguments.toString();
    UserModel user = authController.user.value!;
    loadCustomMarkers();
    senderNameController = TextEditingController(text: user.name ?? '');
    senderPhoneController = TextEditingController(text: user.phoneNumber ?? '');
    senderRemarksController = TextEditingController();
    senderCountryCode.value = user.countryCode ?? "+1";
    selectedCountryName.value = user.country ?? "Canada";
    receiverController = TextEditingController();
    receiverPhoneController = TextEditingController();
    receiverRemarksController = TextEditingController();
    productWeightController = TextEditingController();
    productValueController = TextEditingController();
    willingDeliveryChargeController = TextEditingController();
  }

  locationStepConfirm() async {
    if (pickupAddress.value.isEmpty ||
        deliveryAddress.value.isEmpty ||
        selectedPickupLocation.value == null ||
        selectedDeliveryLocation.value == null) {
      AppSnackbar.error(
        "Please select Pickup Point and Destination before proceeding",
        // backgroundColor: AppColors.primaryColor.withOpacity(0.25),
      );
      return;
    }
    if (await isSameCountry()) {
      AppSnackbar.error(
        "Pickup and delivery locations must be in different countries!",
        // backgroundColor: AppColors.primaryColor.withOpacity(0.25),
      );
      return;
    }
    if (currentStep.value == 0) {
      CustomLoading.loadingDialog();
      final response = await ApiManager.fetchPackageTypes(
        token: authController.token.value,
        lat: selectedPickupLocation.value!.latitude,
        lng: selectedPickupLocation.value!.longitude,
      );
      log("getting response $response");
      packageType.value = List<Map<String, dynamic>>.from(response['data']);
      log("packageType List ${packageType.value}");
      currentStep.value = 1;
      log("Current Step ${currentStep.value}");
      Get.back();
    }
  }

  informationStepConfirm() async {
    log('weight:${prodWeight.value}  type:${prodMarketValue.value}');
    if (infoFormKey.currentState!.validate()) {
      if (additionalInfoKey.currentState!.validate()) {
        if (selectedPackage.value != null) {
          CustomLoading.loadingDialog();
          final response = await ApiManager.fetchPricingRate(
            token: authController.token.value,
          );
          log("getting response $response");
          final data = response['data']['international'];
          baseFare.value = double.tryParse(data['base_fare'].toString()) ?? 0.0;
          platformCharge.value =
              double.tryParse(data['platform_charge'].toString()) ?? 0.0;

          currentStep.value += 1;
          log("Current Step ${currentStep.value}");
          Get.back();
        } else {
          AppSnackbar.error('Please select package first!');
        }
      } else {
        AppSnackbar.error('Please fill additional information properly!');
      }
    } else {
      AppSnackbar.error(
        'Please fill sender and receiver information properly!',
      );
    }
  }

  selectPackage(Map<String, dynamic> package) {
    selectedPackage.value = package;
  }

  void loadCustomMarkers() async {
    pickupIcon = await getResizedMarker(
      'assets/icons/customer_pointer2.png',
      130,
    );
  }

  calculateRouteDistInKWithPrice(List<LatLng> routePoints) {
    double totalDistance = 0.0;

    for (int i = 0; i < routePoints.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        routePoints[i].latitude,
        routePoints[i].longitude,
        routePoints[i + 1].latitude,
        routePoints[i + 1].longitude,
      );
    }
    distanceInKm.value = totalDistance / 1000;
    distanceCharge.value = distanceInKm.value * 2;
  }

  calculateSubtotal() {
    double subtotal =
        baseFare.value + platformCharge.value + willingDeliveryCharge.value;
    return subtotal;
  }

  placeOrder() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      selectedDeliveryLocation.value!.latitude,
      selectedDeliveryLocation.value!.longitude,
    );
    final place = placemarks.first;
    // final fullPhone =
    //     '${receiverCountryCode.value}${receiverPhoneController.text.trim()}';

    final placeOrderRequest = PlaceOrderRequest(
      parcelEstimatePrice: prodMarketValue.value!,
      orderType: orderType.value,
      orderDestination: OrderDestination(
        country: place.country!,
        state: place.administrativeArea!,
        city: place.locality!,
        area: place.subLocality ?? place.subAdministrativeArea!,
        address:
            "${place.name}, ${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}",
      ),
      packageId: selectedPackage.value!['id'].toString(),
      pickupLatitude: (selectedPickupLocation.value?.latitude ?? 0.0)
          .toStringAsFixed(2),
      pickupLongitude: (selectedPickupLocation.value?.longitude ?? 0.0)
          .toStringAsFixed(2),
      dropLatitude: (selectedDeliveryLocation.value?.latitude ?? 0.0)
          .toStringAsFixed(2),
      dropLongitude: (selectedDeliveryLocation.value?.longitude ?? 0.0)
          .toStringAsFixed(2),
      weight: prodWeight.value!,
      weightType: selectedWeightUnit,
      totalFare: willingDeliveryCharge.value,
      pickupRadius: 1.0,
      senderInformation: PersonInfo(
        name: senderNameController!.text,
        phoneNumber: senderPhoneController.text,
        countryCode: senderCountryCode.value,
        country: selectedCountryName.value,
        remarks: senderRemarksController!.text,
      ),
      receiverInformation: PersonInfo(
        name: receiverController.text,
        phoneNumber: receiverPhoneController.text,
        countryCode: receiverCountryCode.value,
        country: receiverSelectedCountryName.value,
        remarks: receiverRemarksController.text,
      ),
    );

    try {
      CustomLoading.loadingDialog();
      final response = await ApiManager.placeGlobalOrder(
        placeOrderRequest,
        authController.token.value,
      );
      Get.back();
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackbar.success("Order submitted successfully");
        Get.offAllNamed(AppRoutes.home);
      } else {
        AppSnackbar.error("Failed: ${response.body}");
      }
    } catch (e) {
      AppSnackbar.error("Error: $e");
    }
  }

  Future<void> makePayment() async {
    try {
      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}payments/create/payment-intent"),
      );
      final jsonResponse = json.decode(response.body);
      final clientSecret = jsonResponse['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Caro',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      log("✅ Payment successful");
    } catch (e) {
      log("❌ Payment failed: $e");
    }
  }

  Future<BitmapDescriptor> getResizedMarker(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Uint8List bytes = data.buffer.asUint8List();

    // Decode and resize using Flutter's ui.instantiateImageCodec
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: width, // <-- resize here
    );

    final frame = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  void setPickup(String address) {
    pickupAddress.value = address;
  }

  void setDelivery(String address) {
    deliveryAddress.value = address;
  }

  void nextStep() {
    if (currentStep < 3) {
      currentStep++;
    }
  }

  void previousStep() {
    if (currentStep > 1) {
      currentStep--;
    }
  }

  setStepItem(int stepNum) {
    currentStep.value = stepNum;
  }

  Future<void> pickPickupLocation() async {
    final result = await Get.to(
      () => const InternationalLocationPickerScreen(),
    );
    if (result != null && result is Map) {
      selectedPickupLocation.value = result['latLng'];
      pickupAddress.value = result['address'];
    }
  }

  Future<void> pickDropoffLocation() async {
    final result = await Get.to(
      () => const InternationalLocationPickerScreen(),
    );
    if (result != null && result is Map) {
      selectedDeliveryLocation.value = result['latLng'];
      setDelivery(result['address']);
    }
  }

  getDirection() async {
    await getRouteCoordinates(
      selectedPickupLocation.value!,
      selectedDeliveryLocation.value!,
    ).then((points) {
      log("Route Points ${points}");
      if (points == null) return;
      routePoints.value = points!;
      //calculateRouteDistInKWithPrice(points);
    });
  }

  Future<List<LatLng>?> getRouteCoordinates(
    LatLng origin,
    LatLng destination,
  ) async {
    final String apiKey = 'AIzaSyBHaGiLX2iuLQ4uRHFAvDwr5Y6ZocAWJzM';
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      log("Map Api Response 200");
      final data = json.decode(response.body);
      if (data['routes'].isEmpty) {
        log("⚠️ No routes returned, skipping polyline drawing");
        return null;
      }
      log("Map Api Response $data");
      final points = data['routes'][0]['overview_polyline']['points'];
      log("Map points $points");
      return decodePolyline(points);
    } else {
      throw Exception('Failed to fetch route');
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  Future<bool> isSameCountry() async {
    try {
      // Get placemarks for pickup
      List<Placemark> pickupPlacemarks = await placemarkFromCoordinates(
        selectedPickupLocation.value!.latitude,
        selectedPickupLocation.value!.longitude,
      );

      // Get placemarks for delivery
      List<Placemark> deliveryPlacemarks = await placemarkFromCoordinates(
        selectedDeliveryLocation.value!.latitude,
        selectedDeliveryLocation.value!.longitude,
      );

      String? pickupCountry = pickupPlacemarks.first.country;
      String? deliveryCountry = deliveryPlacemarks.first.country;

      debugPrint("Pickup Country: $pickupCountry");
      debugPrint("Delivery Country: $deliveryCountry");

      return pickupCountry != null &&
          deliveryCountry != null &&
          pickupCountry == deliveryCountry;
    } catch (e) {
      debugPrint("Error checking countries: $e");
      return false;
    }
  }

  void showPackageListBottomSheet() {
    Get.bottomSheet(
      isDismissible: false,
      Container(
        decoration: BoxDecoration(
          color: const Color(0xffF1F4F3),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grab Handle
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            24.verticalSpace,
            Row(
              children: [
                GestureDetector(
                  onTap: Get.back,
                  child: const Icon(Icons.arrow_back_ios),
                ),
                16.horizontalSpace,
                const Text(
                  "Select package type",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            24.verticalSpace,
            SizedBox(
              height: Get.height * 0.65,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: packageType.length,
                separatorBuilder: (context, index) => 6.verticalSpace,
                itemBuilder: (context, index) {
                  final item = packageType[index];
                  return Obx(() {
                    final isSelected =
                        selectedPackage.value?['id'] == item['id'];

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          item['name']?.toString() ?? '',
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        subtitle: Text(
                          item['sort_description']?.toString() ?? '',
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primaryColor.withOpacity(0.5)
                                : Colors.black.withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Container(
                          height: 24,
                          width: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      AppColors.primaryColor.withAlpha(175),
                                      AppColors.primaryColor,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.grey.shade200,
                                      Colors.grey.shade500,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.7),
                                blurRadius: 2,
                                offset: const Offset(-2, -2),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 2,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                        onTap: () {
                          selectedPackage.value = item;
                        },
                      ),
                    );
                  });
                },
              ),
            ),
            24.verticalSpace,
            InkWell(
              onTap: Get.back,
              child: Container(
                width: double.infinity,
                height: 45.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Done",
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void showAdditionalInfoSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        productWeightController.text = prodWeight.value == 0.0
            ? ''
            : prodWeight.toString();
        productValueController.text = prodMarketValue.value == 0.0
            ? ''
            : prodMarketValue.toString();
        return Padding(
          padding: MediaQuery.of(context).viewInsets, // handle keyboard overlap
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: additionalInfoKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Text(
                    "Additional information",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: productWeightController,
                    decoration: InputDecoration(
                      hintText: "Enter product's weight",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      signed: false,
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: (val) {
                      prodWeight.value = double.parse(
                        productWeightController.text.trim(),
                      );
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please Enter the weight!';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: productValueController,
                    decoration: InputDecoration(
                      hintText: "Enter product's market value",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      signed: false,
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*'),
                      ), // allow only numbers & decimal
                    ],
                    onChanged: (val) {
                      prodMarketValue.value = double.parse(
                        productValueController.text.trim(),
                      );
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please Enter Product\'s Market Value!';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (additionalInfoKey.currentState!.validate()) {
                          prodWeight.value = double.parse(
                            productWeightController.text.trim(),
                          );
                          prodMarketValue.value = double.parse(
                            productValueController.text.trim(),
                          );

                          log(
                            "Weight: ${prodWeight?.value}, Value: ${prodMarketValue?.value}",
                          );

                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Confirm",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }

  Future<bool> onWillPopOrderDiscard(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Discard Order?"),
        content: const Text(
          "Are you sure you want to discard this order? All progress will be lost.",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              fixedSize: Size(100.w, 35.h),
            ),
            child: Text("Discard", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return shouldExit ?? false; // Default to false if dismissed
  }
}
