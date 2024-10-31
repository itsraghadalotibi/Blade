class InvestmentRequestModel {
  final String id;
  final String projectId;
  final String supporterId;
  final String supporterName;
  final String reasonForInterest;
  final String offer;
  final Map<String, String> contactInfo; // Updated to support multiple types of contact information
  final DateTime createdAt;
  final DateTime validUntil;
  final String? iconPath;

  InvestmentRequestModel({
    required this.id,
    required this.projectId,
    required this.supporterId,
    required this.supporterName,
    required this.reasonForInterest,
    required this.offer,
    required this.contactInfo, // Supports storing both email and phone if available
    required this.createdAt,
    required this.validUntil,
    this.iconPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'supporterId': supporterId,
      'supporterName': supporterName,
      'reasonForInterest': reasonForInterest,
      'offer': offer,
      'contactInfo': contactInfo, // Serialize contactInfo map
      'createdAt': createdAt.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'iconPath': iconPath,
    };
  }

  factory InvestmentRequestModel.fromMap(Map<String, dynamic> map) {
    return InvestmentRequestModel(
      id: map['id'] ?? '',
      projectId: map['projectId'] ?? '',
      supporterId: map['supporterId'] ?? '',
      supporterName: map['supporterName'] ?? '',
      reasonForInterest: map['reasonForInterest'] ?? '',
      offer: map['offer'] ?? '',
      contactInfo: Map<String, String>.from(map['contactInfo'] ?? {}), // Deserialize contactInfo map
      createdAt: DateTime.parse(map['createdAt']),
      validUntil: DateTime.parse(map['validUntil']),
      iconPath: map['iconPath'],
    );
  }

  InvestmentRequestModel copyWith({
    String? id,
    String? projectId,
    String? supporterId,
    String? supporterName,
    String? reasonForInterest,
    String? offer,
    Map<String, String>? contactInfo,
    DateTime? createdAt,
    DateTime? validUntil,
    String? iconPath,
  }) {
    return InvestmentRequestModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      supporterId: supporterId ?? this.supporterId,
      supporterName: supporterName ?? this.supporterName,
      reasonForInterest: reasonForInterest ?? this.reasonForInterest,
      offer: offer ?? this.offer,
      contactInfo: contactInfo ?? this.contactInfo,
      createdAt: createdAt ?? this.createdAt,
      validUntil: validUntil ?? this.validUntil,
      iconPath: iconPath ?? this.iconPath,
    );
  }
}
