class OngoingOrderModel {
  final String orderId;
  final String orderType;
  final String pickupLatitude;
  final String pickupLongitude;
  final String dropLatitude;
  final String dropLongitude;
  final String date;
  final String status;

  OngoingOrderModel({
    required this.orderId,
    required this.orderType,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropLatitude,
    required this.dropLongitude,
    required this.date,
    required this.status,
  });

  factory OngoingOrderModel.fromJson(Map<String, dynamic> json) {
    return OngoingOrderModel(
      orderId: json['order_id'] ?? '',
      orderType: json['order_type'] ?? '',
      pickupLatitude: json['pickup_latitude'] ?? '',
      pickupLongitude: json['pickup_longitude'] ?? '',
      dropLatitude: json['drop_latitude'] ?? '',
      dropLongitude: json['drop_longitude'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'order_type': orderType,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'drop_latitude': dropLatitude,
      'drop_longitude': dropLongitude,
      'date': date,
      'status': status,
    };
  }
}
