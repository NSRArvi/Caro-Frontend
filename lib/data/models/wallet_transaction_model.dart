class WalletTransaction {
  final double amount;
  final String purpose;
  final String type;
  final String status;
  final String date;

  WalletTransaction({
    required this.amount,
    required this.purpose,
    required this.type,
    required this.status,
    required this.date,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      purpose: json['purpose_of_transaction'] ?? '',
      type: json['transaction_type'] ?? '',
      status: json['status'] ?? '',
      date: json['transaction_date'] ?? '',
    );
  }
}
