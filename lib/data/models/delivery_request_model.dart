class DeliveryRequestModel {
  String orderId;
  String orderType;
  String pickupLatitude;
  String pickupLongitude;
  String dropLatitude;
  String dropLongitude;
  String status;
  String package;
  double weight;
  String weightType;
  String date;
  List<OrderAttempt> orderAttempts;
  ReceiverInformation receiverInformation;
  SenderInformation senderInformation;
  OrderDestination? orderDestination;

  DeliveryRequestModel({
    required this.orderId,
    required this.orderType,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropLatitude,
    required this.dropLongitude,
    required this.status,
    required this.package,
    required this.weight,
    required this.weightType,
    required this.date,
    required this.orderAttempts,
    required this.receiverInformation,
    required this.senderInformation,
    this.orderDestination,
  });

  factory DeliveryRequestModel.fromJson(Map<String, dynamic> json) =>
      DeliveryRequestModel(
        orderId: json['order_id'],
        orderType: json['order_type'],
        pickupLatitude: json['pickup_latitude'],
        pickupLongitude: json['pickup_longitude'],
        dropLatitude: json['drop_latitude'],
        dropLongitude: json['drop_longitude'],
        package: json["package"],
        status: json['status'],
        weight: double.tryParse(json['weight'].toString()) ?? 0.0,
        weightType: json['weight_type'],
        date: json['date'],
        orderAttempts: List<OrderAttempt>.from(
          json['order_attempts'].map((x) => OrderAttempt.fromJson(x)),
        ),
        receiverInformation: ReceiverInformation.fromJson(
          json['receiver_information'],
        ),
        senderInformation: SenderInformation.fromJson(
          json['sender_information'],
        ),
        orderDestination: json['order_destination'] != null
            ? OrderDestination.fromJson(json['order_destination'])
            : null,
      );

  Map<String, dynamic> toJson() => {
    'order_id': orderId,
    'order_type': orderType,
    'pickup_latitude': pickupLatitude,
    'pickup_longitude': pickupLongitude,
    'drop_latitude': dropLatitude,
    'drop_longitude': dropLongitude,
    'package': package,
    'status': status,
    'weight': weight,
    'weight_type': weightType,
    'date': date,
    'order_attempts': List<dynamic>.from(orderAttempts.map((x) => x.toJson())),
    'receiver_information': receiverInformation.toJson(),
    'sender_information': senderInformation.toJson(),
    'order_destination': orderDestination?.toJson(),
  };
}

class OrderAttempt {
  String status;
  String orderTrackingNumber;
  int paymentStatus;
  double fare;
  String orderDate;
  List<RiderBid> riderBids;

  OrderAttempt({
    required this.status,
    required this.orderTrackingNumber,
    required this.paymentStatus,
    required this.fare,
    required this.orderDate,
    required this.riderBids,
  });

  factory OrderAttempt.fromJson(Map<String, dynamic> json) => OrderAttempt(
    status: json['status'],
    orderTrackingNumber: json['order_tracking_number'],
    paymentStatus: json['payment_status'],
    fare: double.parse(json['fare'].toString()),
    orderDate: json['order_date'],
    riderBids: (json['rider_bids'] as List<dynamic>)
        .map((e) => RiderBid.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'order_tracking_number': orderTrackingNumber,
    'payment_status': paymentStatus,
    'fare': fare,
    'order_date': orderDate,
    'rider_bids': riderBids.map((e) => e.toJson()).toList(),
  };
}

class ReceiverInformation {
  String name;
  String receiverPhone;
  String? countryCode;
  String? country;

  ReceiverInformation({
    required this.name,
     this.countryCode,
     this.country,
    required this.receiverPhone});

  factory ReceiverInformation.fromJson(Map<String, dynamic> json) =>
      ReceiverInformation(
        name: json['name']?.toString() ?? "",
        receiverPhone: json['receiver_phone']?.toString() ?? "",
        countryCode: json['country_code']?.toString(),
        country: json['country']?.toString(),
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'receiver_phone': receiverPhone,
  };
}

class SenderInformation {
  String name;
  String receiverPhone;
  String? countryCode;
  String? country;

  SenderInformation({
    required this.name,
    required this.receiverPhone,
    this.countryCode,
    this.country,
  });

  factory SenderInformation.fromJson(Map<String, dynamic> json) =>
      SenderInformation(
        name: json['name']?.toString() ?? "",
        receiverPhone: json['receiver_phone']?.toString() ?? "",
        countryCode: json['country_code']?.toString(),
        country: json['country']?.toString(),
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'receiver_phone': receiverPhone,
    'country_code': countryCode,
    'country': country,
  };
}

class OrderDestination {
  String country;
  String state;
  String city;
  String? area;
  String address;

  OrderDestination({
    required this.country,
    required this.state,
    required this.city,
    this.area,
    required this.address,
  });

  factory OrderDestination.fromJson(Map<String, dynamic> json) =>
      OrderDestination(
        country: json['country'],
        state: json['state'],
        city: json['city'],
        area: json['area'],
        address: json['address'],
      );

  Map<String, dynamic> toJson() => {
    'country': country,
    'state': state,
    'city': city,
    'area': area,
    'address': address,
  };
}

class RiderBid {
  final int? riderId;
  final String? name;
  final String? profileImage;
  final String? phoneNumber;
  final String? countryCode;
  final String? bidAmount;

  RiderBid({
    this.riderId,
    this.name,
    this.profileImage,
    this.phoneNumber,
    this.countryCode,
    this.bidAmount,
  });

  factory RiderBid.fromJson(Map<String, dynamic> json) {
    return RiderBid(
      riderId: json['rider_id'],
      name: json['name'],
      profileImage: json['profile_image'],
      phoneNumber: json['phone_number'],
      countryCode: json['country_code']?.toString(),
      bidAmount: json['bid_amount'].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'rider_id': riderId,
    'name': name,
    'profile_image': profileImage,
    'bid_amount': bidAmount,
  };
}
