import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../international_placing_order_controller.dart';
import 'international_information_step.dart';

class InternationalConfirmationStep extends StatelessWidget {
  final InternationalPlacingOrderController controller;
  const InternationalConfirmationStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          sectionTitle("Address details"),
          const SizedBox(height: 12),
          _buildAddressCard(),
          const SizedBox(height: 24),
          // _sectionTitle("Payment method"),
          // const SizedBox(height: 12),
          // _buildPaymentOption("Mastercard"),
          // const SizedBox(height: 8),
          // _buildPaymentOption("Visa"),
          // const SizedBox(height: 24),
          sectionTitle("Order summary"),
          const SizedBox(height: 12),
          _buildOrderSummary(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _addressRow(
            label: "Collect from",
            subLabel: "Sender address",
            address: controller.pickupAddress.value,
            editable: true,
          ),
          const SizedBox(height: 16),
          _addressRow(
            label: "Delivery to",
            subLabel: "Receiver address",
            address: controller.deliveryAddress.value,
            editable: true,
          ),
          const SizedBox(height: 16),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(24),
          //     color: Colors.white,
          //   ),
          //   child: const Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Icon(Icons.access_time, size: 18, color: Colors.black54),
          //       SizedBox(width: 6),
          //       Text("Take around 20 min", style: TextStyle(fontSize: 13)),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _addressRow({
    required String label,
    required String subLabel,
    required String address,
    bool editable = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_pin, color: AppColors.primaryColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                subLabel,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(address, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
        // if (editable) const Icon(Icons.edit, size: 18, color: Colors.black45),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          controller.selectedPackage != null
              ? _summaryRow(
                  "Package Type",
                  "${controller.selectedPackage.value!["name"]}",
                )
              : SizedBox(),
          const SizedBox(height: 8),
          _summaryRow(
            "Weight (in ${controller.selectedWeightUnit})",
            "${controller.prodWeight.value} ${controller.selectedWeightUnit}",
          ),
          const SizedBox(height: 8),
          _summaryRow(
            "Offered Price",
            "\$${controller.willingDeliveryCharge.value.toStringAsFixed(2)}",
          ),
          const SizedBox(height: 8),
          _summaryRow("Base Fare", "\$${controller.baseFare.value}"),

          const SizedBox(height: 8),
          _summaryRow(
            "Platform Charge",
            "\$${controller.platformCharge.value}",
          ),
          const Divider(height: 24, thickness: 1),
          _summaryRow(
            "Subtotal (in CAD)",
            "\$${controller.calculateSubtotal().toStringAsFixed(2)}",
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
