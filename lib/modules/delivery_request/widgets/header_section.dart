import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:jimamuapp/utils/app_typography.dart';

import '../../../utils/app_colors.dart';

class AddressSection extends StatelessWidget {
  final String fromLat;
  final String fromLong;
  final String toLat;
  final String toLong;
  final String orderType;

  const AddressSection({
    super.key,
    required this.fromLat,
    required this.fromLong,
    required this.toLat,
    required this.toLong,
    required this.orderType,
  });

  Future<String> _getAddress(double lat, double long) async {
    final placemarks = await placemarkFromCoordinates(lat, long);
    final place = placemarks.first;
    return "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: Future.wait([
        _getAddress(double.parse(fromLat), double.parse(fromLong)),
        _getAddress(double.parse(toLat), double.parse(toLong)),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final fromAddress = snapshot.data![0];
        final toAddress = snapshot.data![1];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('From', style: AppTypography.bodyMedium),
                const Spacer(),
                if (orderType.toLowerCase() != "national")
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffffdfdf),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      orderType,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(fromAddress, style: AppTypography.pRegular),
            const SizedBox(height: 16),
            Text('To', style: AppTypography.bodyMedium),
            const SizedBox(height: 4),
            Text(toAddress, style: AppTypography.pRegular),
          ],
        );
      },
    );
  }
}
