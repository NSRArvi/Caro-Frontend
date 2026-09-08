import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:jimamuapp/data/models/delivery_request_model.dart';
import 'package:jimamuapp/utils/snakckbar_helper.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_typography.dart';
import '../order/customer/widgets/location_preview_screen.dart';

class DeliveryRequestDetailsView extends StatefulWidget {
  final DeliveryRequestModel orderDetails;
  final String pickupLocation;
  final String dropoffLocation;
  final LatLng pickupLatLng;
  final LatLng dropoffLatLng;

  const DeliveryRequestDetailsView({
    super.key,
    required this.orderDetails,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupLatLng,
    required this.dropoffLatLng,
  });

  @override
  State<DeliveryRequestDetailsView> createState() =>
      _DeliveryRequestDetailsViewState();
}

class _DeliveryRequestDetailsViewState
    extends State<DeliveryRequestDetailsView> {
  List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();
    getRoute();
  }

  /// 🔥 Google Directions API
  Future<void> getRoute() async {
    try {
      const apiKey = "AIzaSyBHaGiLX2iuLQ4uRHFAvDwr5Y6ZocAWJzM";

      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?origin=${widget.pickupLatLng.latitude},${widget.pickupLatLng.longitude}&destination=${widget.dropoffLatLng.latitude},${widget.dropoffLatLng.longitude}&key=$apiKey",
      );

      final response = await http.get(url);
      log("Directions API Response: ${response.body}");

      final data = json.decode(response.body);

      final points = data['routes'][0]['overview_polyline']['points'] as String;

      routePoints = decodePolyline(points);

      log("Route loaded: ${routePoints.length}");

      setState(() {});
    } catch (e) {
      log("Route error: $e");
    }
  }

  /// 🔥 Decode polyline
  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return poly;
  }

  Widget _nearMe(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        width: 28,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.near_me, color: Colors.white, size: 15),
      ),
    );
  }

  Widget _infoRow(String title, String value, {bool boldValue = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: boldValue
                ? AppTypography.bodySemiBold
                : AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String consignmentId = "#${widget.orderDetails.orderId}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Consignment ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Consignment ID:',
                  style: AppTypography.bodySemiBold.copyWith(
                    color: AppColors.black500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: widget.orderDetails.orderId),
                    );
                    AppSnackbar.success("Consignment ID copied");
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.file_copy,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                      6.horizontalSpace,
                      Text(consignmentId, style: AppTypography.sub1SemiBold),
                    ],
                  ),
                ),
              ],
            ),

            15.verticalSpace,

            /// Shipping Info Card
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Shipping Info:",
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),

                  8.verticalSpace,
                  GestureDetector(
                    // onTap: () {
                    //   Clipboard.setData(
                    //     ClipboardData(
                    //       text: widget
                    //           .orderDetails
                    //           .receiverInformation
                    //           .receiverPhone,
                    //     ),
                    //   );
                    //   AppSnackbar.success("Copied");
                    // },
                    onTap: () {
                      final receiverInfo =
                          widget.orderDetails.receiverInformation;

                      final phone =
                          "${receiverInfo.countryCode ?? ""}${receiverInfo.receiverPhone ?? ""}";
                      // final phone =
                      //     "${receiverInfo?.countryCode ?? ""}${receiverInfo?.receiverPhone ?? ""}";

                      Clipboard.setData(ClipboardData(text: phone));
                      AppSnackbar.success("Copied");
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.call,
                          size: 20,
                          color: AppColors.primaryColor,
                        ),
                        6.horizontalSpace,
                        Text(
                          // widget.orderDetails.receiverInformation.receiverPhone,
                          "${widget.orderDetails.receiverInformation.countryCode ?? ""}"
                              "${widget.orderDetails.receiverInformation.receiverPhone ?? ""}",
                          style: AppTypography.h2Regular.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  5.verticalSpace,
                  Text(
                    widget.orderDetails.receiverInformation.name,

                    style: AppTypography.bodyRegular.copyWith(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),

                  12.verticalSpace,

                  /// Pickup
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: const Icon(
                          Icons.circle,
                          size: 8,
                          color: Colors.red,
                        ),
                      ),
                      8.horizontalSpace,
                      Expanded(
                        child: Text(
                          widget.pickupLocation,
                          style: AppTypography.bodyRegular.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      _nearMe(() {
                        Get.to(
                          () => LocationPreviewScreen(
                            latLng: widget.pickupLatLng,
                            title: "Pickup Location",
                          ),
                        );
                      }),
                    ],
                  ),

                  12.verticalSpace,

                  /// Dropoff
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: const Icon(
                          Icons.circle,
                          size: 8,
                          color: Colors.red,
                        ),
                      ),
                      8.horizontalSpace,
                      Expanded(
                        child: Text(
                          widget.dropoffLocation,
                          style: AppTypography.bodyRegular.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      _nearMe(() {
                        Get.to(
                          () => LocationPreviewScreen(
                            latLng: widget.dropoffLatLng,
                            title: "Dropoff Location",
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),

            20.verticalSpace,

            /// Package Info Card
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Package Info:",
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),

                  10.verticalSpace,

                  _infoRow("Parcel type", widget.orderDetails.package),

                  _infoRow(
                    "Weight",
                    "${widget.orderDetails.weight} ${widget.orderDetails.weightType}",
                  ),

                  _infoRow(
                    "Delivery Charge",
                    "\$${widget.orderDetails.orderAttempts[0].fare}",
                    boldValue: true,
                  ),
                ],
              ),
            ),

            20.verticalSpace,

            /// Map View
            Text("Map View:", style: AppTypography.bodySemiBold),

            12.verticalSpace,

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 320,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.dropoffLatLng,
                    zoom: 12,
                  ),

                  markers: {
                    Marker(
                      markerId: const MarkerId("pickup"),
                      position: widget.pickupLatLng,
                      infoWindow: const InfoWindow(title: "Pickup Point"),
                    ),
                    Marker(
                      markerId: const MarkerId("dropoff"),
                      position: widget.dropoffLatLng,
                      infoWindow: const InfoWindow(title: "Destination"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                    ),
                  },

                  polylines: {
                    if (routePoints.isNotEmpty)
                      Polyline(
                        polylineId: const PolylineId("route"),
                        color: Colors.black,
                        width: 5,
                        points: routePoints,
                      ),
                  },

                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,

                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,

                  // ✅ IMPORTANT FIX
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                ),
              ),
            ),
            20.verticalSpace,
          ],
        ),
      ),
    );
  }
}
