import 'delivery_request_model.dart';

class DeliveryRequestListModel {
  bool success;
  String message;
  List<DeliveryRequestModel> data;
  dynamic error;

  DeliveryRequestListModel({
    required this.success,
    required this.message,
    required this.data,
    this.error,
  });

  factory DeliveryRequestListModel.fromJson(Map<String, dynamic> json) =>
      DeliveryRequestListModel(
        success: json['success'],
        message: json['message'],
        data: List<DeliveryRequestModel>.from(
          json['data'].map((x) => DeliveryRequestModel.fromJson(x)),
        ),
        error: json['error'],
      );

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
    'error': error,
  };
}
