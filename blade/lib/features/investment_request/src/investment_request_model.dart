class InvestmentRequestModel {
  final String id;
  final String projectId;
  final String projectName;
  final String supporterId;
  final String supporterName;
  final String reasonForInterest;
  final String offer;
  final Map<String, String> contactInfo;
  final DateTime createdAt;
  final DateTime validUntil;
  final String? iconPath;
  late String status;
  final String reasonForRejection; // New field

  InvestmentRequestModel({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.supporterId,
    required this.supporterName,
    required this.reasonForInterest,
    required this.offer,
    required this.contactInfo,
    required this.createdAt,
    required this.validUntil,
    this.iconPath,
    this.status = "Pending",
    this.reasonForRejection = "", // Initialize as an empty string
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'supporterId': supporterId,
      'projectName': projectName,
      'supporterName': supporterName,
      'reasonForInterest': reasonForInterest,
      'offer': offer,
      'contactInfo': contactInfo,
      'createdAt': createdAt.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'iconPath': iconPath,
      'status': status,
      'reasonForRejection': reasonForRejection, // Include reasonForRejection in serialization
    };
  }

  factory InvestmentRequestModel.fromMap(Map<String, dynamic> map) {
    return InvestmentRequestModel(
      id: map['id'] ?? '',
      projectId: map['projectId'] ?? '',
      projectName: map['projectName'] ?? '',
      supporterId: map['supporterId'] ?? '',
      supporterName: map['supporterName'] ?? '',
      reasonForInterest: map['reasonForInterest'] ?? '',
      offer: map['offer'] ?? '',
      contactInfo: Map<String, String>.from(map['contactInfo'] ?? {}),
      createdAt: DateTime.parse(map['createdAt']),
      validUntil: DateTime.parse(map['validUntil']),
      iconPath: map['iconPath'],
      status: map['status'] ?? 'Pending',
      reasonForRejection: map['reasonForRejection'] ?? "", // Initialize if not present
    );
  }

  InvestmentRequestModel copyWith({
    String? id,
    String? projectId,
    String? projectName,
    String? supporterId,
    String? supporterName,
    String? reasonForInterest,
    String? offer,
    Map<String, String>? contactInfo,
    DateTime? createdAt,
    DateTime? validUntil,
    String? iconPath,
    String? status,
    String? reasonForRejection,
  }) {
    return InvestmentRequestModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      supporterId: supporterId ?? this.supporterId,
      supporterName: supporterName ?? this.supporterName,
      reasonForInterest: reasonForInterest ?? this.reasonForInterest,
      offer: offer ?? this.offer,
      contactInfo: contactInfo ?? this.contactInfo,
      createdAt: createdAt ?? this.createdAt,
      validUntil: validUntil ?? this.validUntil,
      iconPath: iconPath ?? this.iconPath,
      status: status ?? this.status,
      reasonForRejection: reasonForRejection ?? this.reasonForRejection, // Support rejection reason in copyWith
    );
  }
}