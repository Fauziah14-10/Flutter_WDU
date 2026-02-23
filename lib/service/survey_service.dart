import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/storage.dart';
import 'api.dart';
import '../models/survey_model.dart';

class SurveyService {
  // Ambil list survey
  Future<List<SurveyModel>> getSurveys(
  String clientSlug,
  String projectSlug,
) async {
    final token = await Storage.getToken();
    final url = Uri.parse(
      "${Api.baseUrl}/clients/$clientSlug/projects/$projectSlug/surveys",
    );

    final res = await http.get(
      url,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (res.statusCode == 200) {
  final body = jsonDecode(res.body);
  final List raw = body['data'] ?? [];

  return raw
      .map((e) => SurveyModel.fromJson(e))
      .toList();
} else {
      throw Exception('Failed to load surveys: ${res.statusCode}');
    }
  }

  // Ambil detail survey / location
  Future<Map<String, dynamic>> getSurveyDetail(
    String clientSlug,
    String projectSlug,
    String slug,
  ) async {
    final token = await Storage.getToken();
    final url = Uri.parse(
      "${Api.baseUrl}/clients/$clientSlug/projects/$projectSlug/surveys/$slug/detail",
    );

    final res = await http.get(
      url,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load survey detail: ${res.statusCode}');
    }
  }
}

