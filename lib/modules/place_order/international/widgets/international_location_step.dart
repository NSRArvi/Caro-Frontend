import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_typography.dart';
import '../international_placing_order_controller.dart';

class InternationalLocationInfoStep extends StatelessWidget {
  final InternationalPlacingOrderController controller;
  const InternationalLocationInfoStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Obx(() => _buildAddressCard()),
          25.verticalSpace,
          Obx(() => _buildMapPreview()),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildAddressRow(
            label: 'Pickup Point',
            address: controller.pickupAddress.value,
            onEdit: () async {
              await controller.pickPickupLocation();
            },
          ),
          const Divider(height: 28),
          _buildAddressRow(
            label: 'Destination',
            address: controller.deliveryAddress.value,
            onEdit: () async {
              await controller.pickDropoffLocation();
            },
          ),
        ],
      ),
    );
  }

  _buildAddressRow({
    required String label,
    required String? address,
    required VoidCallback onEdit,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_pin, color: AppColors.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.bodyMedium),
              const SizedBox(height: 4),
              Text(
                address ?? "Select $label",
                style: AppTypography.pRegular.copyWith(
                  color: address == null ? Colors.grey : Colors.black,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.black100,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.edit, color: AppColors.black, size: 18),
            onPressed: onEdit,
          ),
        ),
      ],
    );
  }

  Widget _buildMapPreview() {
    log("Build Map Preview Widget");
    everAll(
      [controller.selectedPickupLocation, controller.selectedDeliveryLocation],
      (_) {
        if (controller.selectedPickupLocation.value != null &&
            controller.selectedDeliveryLocation.value != null) {
          controller.getDirection();
        }
      },
    );

    return Container(
      height: Get.height / 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.black100),
      ),
      clipBehavior: Clip.hardEdge,
      child:
          (controller.selectedPickupLocation.value == null ||
              controller.selectedDeliveryLocation.value == null)
          ? const Center(child: Text('Pickup or Destination not selected'))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.selectedPickupLocation.value!,
                zoom: 5,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("pickup"),
                  position: controller.selectedPickupLocation.value!!,
                  infoWindow: const InfoWindow(title: "Pickup Point"),
                  icon: controller.pickupIcon,
                ),
                Marker(
                  markerId: const MarkerId("dropoff"),
                  position: controller.selectedDeliveryLocation.value!!,
                  infoWindow: const InfoWindow(title: "Destination"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                ),
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId("airRoute"),
                  color: Colors.black,
                  width: 4,
                  points: [
                    LatLng(
                      controller.selectedPickupLocation.value!.latitude,
                      controller.selectedPickupLocation.value!.longitude,
                    ),
                    LatLng(
                      controller.selectedDeliveryLocation.value!.latitude,
                      controller.selectedDeliveryLocation.value!.longitude,
                    ),
                  ],
                ),
              },
              onMapCreated: (cntrlr) {
                controller.mapController = cntrlr;
              },
              zoomControlsEnabled: false,
            ),
    );
  }
}
