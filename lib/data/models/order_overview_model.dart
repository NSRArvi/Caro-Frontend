class OrderOverviewModel {
  final bool success;
  final String message;
  final OrderOverviewData? data;
  final dynamic error;

  OrderOverviewModel({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory OrderOverviewModel.fromJson(Map<String, dynamic> json) {
    return OrderOverviewModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? OrderOverviewData.fromJson(json['data'])
          : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
      'error': error,
    };
  }
}

class OrderOverviewData {
  final String totalCompletedMyOrders;
  final String totalCompletedMyDeliveries;

  OrderOverviewData({
    required this.totalCompletedMyOrders,
    required this.totalCompletedMyDeliveries,
  });

  factory OrderOverviewData.fromJson(Map<String, dynamic> json) {
    return OrderOverviewData(
      totalCompletedMyOrders: json['totalCompletedMyOrders'] ?? '0',
      totalCompletedMyDeliveries: json['totalCompletedMyDeliveries'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCompletedMyOrders': totalCompletedMyOrders,
      'totalCompletedMyDeliveries': totalCompletedMyDeliveries,
    };
  }
}
