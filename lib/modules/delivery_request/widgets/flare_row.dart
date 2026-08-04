import 'package:flutter/material.dart';
import 'package:jimamuapp/utils/app_typography.dart';

import '../../../utils/app_colors.dart';

class FareRow extends StatefulWidget {
  final String orderId;
  final double initialBid;

  const FareRow({super.key, required this.orderId, required this.initialBid});

  @override
  State<FareRow> createState() => _FareRowState();
}

class _FareRowState extends State<FareRow> {
  late double _currentBid;

  @override
  void initState() {
    super.initState();
    _currentBid = widget.initialBid;
  }

  void _showBidPopup() {
    // final controller = TextEditingController();
    // double leadingBid = _currentBid;
    // double minimalBid = leadingBid - 40;

    // showDialog(
    //   context: context,
    //   builder: (context) => BidPopup(
    //     leadingBid: leadingBid,
    //     minimalBid: minimalBid,
    //     onBidPlaced: (bid) {
    //       setState(() => _currentBid = bid);
    //     },
    //     orderId: widget.orderId,
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Fare:',
          style: AppTypography.pRegular.copyWith(color: AppColors.black400),
        ),
        const SizedBox(width: 16),
        _FareBox(value: '\$$_currentBid', color: AppColors.secondary),
        const SizedBox(width: 16),
        InkWell(
          onTap: _showBidPopup,
          child: _FareBox(value: 'BID', color: AppColors.primaryColor),
        ),
      ],
    );
  }
}

class _FareBox extends StatelessWidget {
  final String value;
  final Color color;

  const _FareBox({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: AppTypography.pBold.copyWith(color: Colors.white),
      ),
    );
  }
}
