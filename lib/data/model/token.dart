class Token {
  final String applicationId;
  final String applicantName;
  final int number;
  final String issuedAt;
  final String prioritizeAfter;
  final int serviceId;
  final bool skipped;
  final String? serviceStartedAt;
  final String? serviceEndedAt;
  final String? serverId;
  final String? operatorId;

  const Token({
    required this.applicationId,
    required this.applicantName,
    required this.number,
    required this.issuedAt,
    required this.prioritizeAfter,
    required this.serviceId,
    required this.skipped,
    this.serviceStartedAt,
    this.serviceEndedAt,
    this.serverId,
    this.operatorId,
  });

  Token.fromJson(Map<String, dynamic> json)
      : applicationId = json['applicationId'] as String,
        applicantName = json['applicantName'] as String,
        number = json['number'] as int,
        issuedAt = json['issuedAt'] as String,
        prioritizeAfter = json['prioritizeAfter'] as String,
        serviceId = json['serviceId'] as int,
        skipped = json['skipped'] as bool,
        serviceStartedAt = json['serviceStartedAt'] as String?,
        serviceEndedAt = json['serviceEndedAt'] as String?,
        serverId = json['serverId'] as String?,
        operatorId = json['operatorId'] as String?;
}
