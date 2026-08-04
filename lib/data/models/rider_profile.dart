class RiderProfile {
  int? riderId;
  String? status;
  List<String>? role;
  List<RiderDocument>? riderDocument;

  RiderProfile({this.riderId, this.status, this.role, this.riderDocument});

  factory RiderProfile.fromJson(Map<String, dynamic> json) {
    return RiderProfile(
      riderId: json['user_id'] as int?,
      status: json['status'] as String?,
      role: (json['role'] as List<dynamic>?)?.map((e) => e as String).toList(),
      riderDocument: (json['rider_document'] as List<dynamic>?)
          ?.map((e) => RiderDocument.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': riderId,
    'status': status,
    'role': role,
    'rider_document': riderDocument?.map((e) => e.toJson()).toList(),
  };
}

class RiderDocument {
  String? documentType;
  String? documentNumber;
  List<String>? document;
  String? reviewStatus;

  RiderDocument({
    this.documentType,
    this.documentNumber,
    this.document,
    this.reviewStatus,
  });

  factory RiderDocument.fromJson(Map<String, dynamic> json) {
    return RiderDocument(
      documentType: json['document_type'] as String?,
      documentNumber: json['document_number'] as String?,
      document: (json['document'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      reviewStatus: json['review_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'document_type': documentType,
    'document_number': documentNumber,
    'document': document,
    'review_status': reviewStatus,
  };
}
