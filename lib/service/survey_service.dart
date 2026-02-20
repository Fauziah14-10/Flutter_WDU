import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/storage.dart';
import 'api.dart';

class SurveyService {
  // Ambil list survey
  Future<List<dynamic>> getSurveys(
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
      return body['data']; // Ambil array surveys
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
