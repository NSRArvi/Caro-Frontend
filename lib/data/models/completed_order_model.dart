import 'delivery_request_model.dart';

class CompletedOrderModel {
  final String orderId;
  final String pickupLatitude;
  final String pickupLongitude;
  final String dropLatitude;
  final String dropLongitude;
  final String status;
  final List<OrderAttempt> orderAttempts;
  final ReceiverInformation receiverInformation;

  CompletedOrderModel({
    required this.orderId,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropLatitude,
    required this.dropLongitude,
    required this.status,
    required this.orderAttempts,
    required this.receiverInformation,
  });

  factory CompletedOrderModel.fromJson(Map<String, dynamic> json) {
    return CompletedOrderModel(
      orderId: json['order_id'] ?? '',
      pickupLatitude: json['pickup_latitude'] ?? '',
      pickupLongitude: json['pickup_longitude'] ?? '',
      dropLatitude: json['drop_latitude'] ?? '',
      dropLongitude: json['drop_longitude'] ?? '',
      status: json['status'] ?? '',
      orderAttempts: (json['order_attempts'] as List? ?? [])
          .map((e) => OrderAttempt.fromJson(e))
          .toList(),
      receiverInformation: ReceiverInformation.fromJson(
        json['receiver_information'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'drop_latitude': dropLatitude,
      'drop_longitude': dropLongitude,
      'status': status,
      'order_attempts': orderAttempts.map((e) => e.toJson()).toList(),
      'receiver_information': receiverInformation.toJson(),
    };
  }
}

class ReceiverInformation {
  final String name;
  final String receiverPhone;

  ReceiverInformation({required this.name, required this.receiverPhone});

  factory ReceiverInformation.fromJson(Map<String, dynamic> json) {
    return ReceiverInformation(
      name: json['name'] ?? '',
      receiverPhone: json['receiver_phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'receiver_phone': receiverPhone};
  }
}
