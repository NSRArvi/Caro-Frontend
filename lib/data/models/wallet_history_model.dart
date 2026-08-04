import 'package:jimamuapp/data/models/wallet_transaction_model.dart';

class WalletHistoryModel {
  final double balance;
  final List<WalletTransaction> history;

  WalletHistoryModel({required this.balance, required this.history});

  factory WalletHistoryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final balance = double.tryParse(data['balance'].toString()) ?? 0.0;

    final historyList =
        (data['walletHistory'] as List<dynamic>?)
            ?.map((e) => WalletTransaction.fromJson(e))
            .toList() ??
        [];

    return WalletHistoryModel(balance: balance, history: historyList);
  }
}
