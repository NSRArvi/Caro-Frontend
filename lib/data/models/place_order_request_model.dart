import 'delivery_request_model.dart';

class PlaceOrderRequest {
  final String packageId;
  final String orderType; // "national" or "international"
  final String pickupLatitude;
  final String pickupLongitude;
  final String dropLatitude;
  final String dropLongitude;
  final double weight;
  final String weightType;
  final double parcelEstimatePrice;
  final double totalFare;
  final double pickupRadius;
  final PersonInfo senderInformation;
  final PersonInfo receiverInformation;
  final OrderDestination orderDestination;

  PlaceOrderRequest({
    required this.packageId,
    required this.orderType,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropLatitude,
    required this.dropLongitude,
    required this.weight,
    required this.weightType,
    required this.parcelEstimatePrice,
    required this.totalFare,
    required this.pickupRadius,
    required this.senderInformation,
    required this.receiverInformation,
    required this.orderDestination,
  });

  factory PlaceOrderRequest.fromJson(Map<String, dynamic> json) {
    return PlaceOrderRequest(
      packageId: json["package_id"],
      orderType: json["order_type"],
      pickupLatitude: json["pickup_latitude"],
      pickupLongitude: json["pickup_longitude"],
      dropLatitude: json["drop_latitude"],
      dropLongitude: json["drop_longitude"],
      weight: (json["weight"] as num).toDouble(),
      weightType: json["weight_type"],
      parcelEstimatePrice: (json["parcel_estimate_price"] as num).toDouble(),
      totalFare: (json["total_fare"] as num).toDouble(),
      pickupRadius: (json["pickup_radius"] as num).toDouble(),
      senderInformation: PersonInfo.fromJson(json["sender_information"]),
      receiverInformation: PersonInfo.fromJson(json["receiver_information"]),
      orderDestination: OrderDestination.fromJson(json["order_destination"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "package_id": packageId,
      "order_type": orderType,
      "pickup_latitude": pickupLatitude,
      "pickup_longitude": pickupLongitude,
      "drop_latitude": dropLatitude,
      "drop_longitude": dropLongitude,
      "weight": weight,
      "weight_type": weightType,
      "parcel_estimate_price": parcelEstimatePrice,
      "total_fare": totalFare,
      "pickup_radius": pickupRadius,
      "sender_information": senderInformation.toJson(),
      "receiver_information": receiverInformation.toJson(),
      "order_destination": orderDestination.toJson(),
    };
  }
}

class PersonInfo {
  final String name;
  final String phoneNumber;
  final String countryCode;
  final String country;
  final String remarks;

  PersonInfo({
    required this.name,
    required this.phoneNumber,
    required this.countryCode,
    required this.country,
    required this.remarks,
  });

  factory PersonInfo.fromJson(Map<String, dynamic> json) {
    return PersonInfo(
      name: json["name"],
      phoneNumber: json["phone_number"],
      countryCode: json["country_code"],
      country: json["country"],
      remarks: json["remarks"],
    );
  }

  Map<String, dynamic> toJson() {
    return {"name": name,
      "phone_number": phoneNumber,
      "country_code": countryCode,
      "country": country,
      "remarks": remarks};
  }
}
