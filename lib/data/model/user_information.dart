class ApplicantInfoRequest {
  final String applicationId;
  final String applicantName;
  final DateTime slotStart;

  const ApplicantInfoRequest({
    required this.applicationId,
    required this.applicantName,
    required this.slotStart,
  });

  Map<String, dynamic> toJson() {
    return {
      'applicationId': applicationId,
      'applicantName': applicantName,
      'slotStart': slotStart.toUtc().toIso8601String(),
    };
  }
}
