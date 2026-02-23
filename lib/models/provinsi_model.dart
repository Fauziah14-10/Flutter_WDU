class ProvinceTarget {
  final int provinceId;
  final String provinceName;
  final int targetResponse;
  final int submissionResponse;

  ProvinceTarget({
    required this.provinceId,
    required this.provinceName,
    required this.targetResponse,
    required this.submissionResponse,
  });

  factory ProvinceTarget.fromJson(Map<String, dynamic> json) {
    return ProvinceTarget(
      provinceId: json['province_id'],
      provinceName: json['province_name'] ?? '-',
      targetResponse:
          int.tryParse(json['target_response'].toString()) ?? 0,
      submissionResponse: json['submission_response'] ?? 0,
    );
  }
}