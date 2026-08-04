import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:jimamuapp/modules/delivery_request/widgets/request_card.dart';
import 'package:jimamuapp/utils/app_colors.dart';
import 'package:jimamuapp/utils/app_typography.dart';

import '../../../../ui/widgets/custom_dotted_line.dart';
import '../../../../ui/widgets/measure_size.dart';

class OrderCard extends StatefulWidget {
  final String orderId;
  final String date;
  final String fromLat;
  final String fromLong;
  final String toLat;
  final String toLong;
  final String status;
  final String? orderType;
  final VoidCallback onPressed;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.date,
    required this.fromLat,
    required this.fromLong,
    required this.toLat,
    required this.toLong,
    required this.status,
    required this.orderType,
    required this.onPressed,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  double _addressHeight = 0;
  String? pickupLocation;
  String? dropoffLocation;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadLocations();
  }

  // void loadLocations() async {
  //   List<Placemark> placemarks = await placemarkFromCoordinates(
  //     double.parse(widget.fromLat),
  //     double.parse(widget.fromLong),
  //   );
  //   final place = placemarks.first;
  //   pickupLocation =
  //       "${place.name}, ${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
  //   placemarks = await placemarkFromCoordinates(
  //     double.parse(widget.toLat),
  //     double.parse(widget.toLong),
  //   );
  //   final place2 = placemarks.first;
  //   dropoffLocation =
  //       "${place2.name}, ${place2.street}, ${place2.locality}, ${place2.administrativeArea}, ${place2.postalCode}, ${place2.country}";
  //   setState(() {
  //     isLoading = false;
  //   });
  // }
  void loadLocations() async {
    try {
      final from = await placemarkFromCoordinates(
        double.parse(widget.fromLat),
        double.parse(widget.fromLong),
      );

      final to = await placemarkFromCoordinates(
        double.parse(widget.toLat),
        double.parse(widget.toLong),
      );

      if (!mounted) return;

      setState(() {
        final place = from.first;
        final place2 = to.first;

        pickupLocation =
            "${place.name}, ${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";

        dropoffLocation =
            "${place2.name}, ${place2.street}, ${place2.locality}, ${place2.administrativeArea}, ${place2.postalCode}, ${place2.country}";

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 1, color: AppColors.white100),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.secondary,
                      ),
                      child: Image.asset('assets/icons/package.png'),
                    ),
                    const SizedBox(width: 16),
                    _buildHeaderRow(),
                  ],
                ),
                const SizedBox(height: 16),
                _buildAddressSection(),
                const SizedBox(height: 20),
                _buildStatusRow(),
              ],
            ),
          ),
        ),
        Positioned(
          right: 8,
          top: 4,
          child: IconButton(
            onPressed: widget.onPressed,
            icon: Icon(Icons.arrow_forward_ios, color: AppColors.black500),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        Text("#" + widget.orderId, style: AppTypography.sub1SemiBold),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: CircleAvatar(radius: 2, backgroundColor: AppColors.black400),
        ),
        Text(formatDate(widget.date), style: AppTypography.pRegular),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.horizontalSpace,
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
          child: Column(
            children: [
              CircleAvatar(radius: 2.5, backgroundColor: AppColors.black400),
              const SizedBox(height: 4),
              _addressHeight > 0
                  ? DottedLine(height: _addressHeight - 24)
                  : const SizedBox(width: 2),
              const SizedBox(height: 4),
              CircleAvatar(radius: 2.5, backgroundColor: AppColors.black400),
            ],
          ),
        ),
        const SizedBox(width: 12),
        MeasureSize(
          onChange: (size) => setState(() => _addressHeight = size.height),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('From', style: AppTypography.bodyMedium),
                  80.horizontalSpace,
                  widget.orderType != null
                      ? widget.orderType.toString().toLowerCase() != "national"
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Color(0xffffdfdf),
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.0.r,
                                    vertical: 2.r,
                                  ),
                                  child: Text(
                                    "Global",
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox.shrink()
                      : SizedBox.shrink(),
                ],
              ),

              const SizedBox(height: 4),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.55,
                child: Text(
                  pickupLocation ?? "",
                  style: AppTypography.pRegular,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              Text('To', style: AppTypography.bodyMedium),
              const SizedBox(height: 4),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.55,
                child: Text(
                  dropoffLocation ?? "",
                  style: AppTypography.pRegular,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow() {
    return Row(
      children: [
        45.horizontalSpace,
        Text(
          'Delivery Status:',
          style: AppTypography.pRegular.copyWith(color: AppColors.black400),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: widget.status.toLowerCase() == "confirmed"
                ? AppColors.greenBtnColor
                : AppColors.yellow,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.08),
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.status,
            style: AppTypography.pRegular.copyWith(
              color: widget.status.toLowerCase() == "confirmed"
                  ? AppColors.white
                  : AppColors.black,
            ),
          ),
        ),
      ],
    );
  }
}
