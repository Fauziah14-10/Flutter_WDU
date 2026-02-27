import '../models/provinsi_model.dart';

class SurveyModel {
  final String name;
  final String slug;
  final String? description;
  final String status;
  final String targetLocation;
  final int responseCount;

  // TAMBAHKAN INI
  final List<ProvinceTarget> provinceTargets;

  SurveyModel({
    required this.name,
    required this.slug,
    required this.status,
    required this.targetLocation,
    required this.responseCount,
    required this.provinceTargets,
    this.description,
  });

  /// Parse dari JSON response API
  factory SurveyModel.fromJson(Map<String, dynamic> json) {
  final rawProvinces = json['province_targets'] as List? ?? [];

  final provinces = rawProvinces
      .map((e) => ProvinceTarget.fromJson(e))
      .toList();

  final location = provinces.isNotEmpty
      ? provinces.map((e) => e.provinceName).join(', ')
      : '-';

  return SurveyModel(
    name: json['name'] ?? json['title'] ?? '-',
    slug: json['slug'] ?? json['id']?.toString() ?? '',
    description: json['description'],
    status: (json['status'] ?? '').toString().toUpperCase(),
    targetLocation: location,
    responseCount:
        json['response_count'] ??
        json['responses_count'] ??
        0,
    provinceTargets: provinces, // Setelah parsing, simpan list provinsi yang ditargetkan
  );
}

  /// Konversi kembali ke Map jika diperlukan (misal untuk kirim ke API)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
      'description': description,
      'status': status,
      'target_location': targetLocation,
      'response_count': responseCount,
    };
  }

  /// Helper: apakah survey sedang dibuka?
  bool get isOpen =>
      status == 'DIBUKA' || status == 'OPEN' || status == '1';
}