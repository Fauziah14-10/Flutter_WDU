import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../core/constants/endpoints.dart';
import '../models/survey_model.dart';
import '../models/survey_response_detail_model.dart';

class SurveyService {
  final _api = ApiClient();

  // ── AMBIL LIST SURVEY ─────────────────────────────────────
  // GET /api/clients/{clientSlug}/projects/{projectSlug}/surveys
  Future<List<SurveyModel>> getSurveys(
    String clientSlug,
    String projectSlug,
  ) async {
    final response = await _api.get(Endpoints.surveys(clientSlug, projectSlug));

    final List raw = response.data?['data'] ?? [];
    return raw.map((e) => SurveyModel.fromJson(e)).toList();
  }

  // ── AMBIL DETAIL SURVEY / LOCATION ───────────────────────
  // GET /api/clients/{clientSlug}/projects/{projectSlug}/surveys/{slug}/detail
  Future<Map<String, dynamic>> getSurveyDetail(
    String clientSlug,
    String projectSlug,
    String surveySlug,
  ) async {
    final response = await _api.get(
      Endpoints.surveyDetail(clientSlug, projectSlug, surveySlug),
    );

    return response.data ?? {};
  }

  // ── AMBIL SEMUA REPORT SURVEY ─────────────────────────────
  // GET /api/clients/{clientSlug}/projects/{projectSlug}/surveys/{slug}/all-report
  Future<Map<String, dynamic>> getSurveyAllReport(
    String clientSlug,
    String projectSlug,
    String surveySlug,
  ) async {
    final response = await _api.get(
      Endpoints.surveyAllReport(clientSlug, projectSlug, surveySlug),
    );

    return response.data ?? {};
  }

  // ── AMBIL JAWABAN INDIVIDU ────────────────────────────────
  // GET /api/clients/{clientSlug}/projects/{projectSlug}/surveys/{slug}/report/{responseId}
  Future<Map<String, dynamic>> getSurveyResponse(
    String clientSlug,
    String projectSlug,
    String surveySlug,
    int responseId,
  ) async {
    final response = await _api.get(
      Endpoints.surveyReport(clientSlug, projectSlug, surveySlug, responseId),
    );

    return response.data ?? {};
  }

  Future<SurveyResponseDetail?> getSurveyResponseDetail(
    String clientSlug,
    String projectSlug,
    String surveySlug,
    int responseId,
  ) async {
    final response = await _api.get(
      Endpoints.surveyReport(clientSlug, projectSlug, surveySlug, responseId),
    );

    if (response.data != null) {
      return SurveyResponseDetail.fromJson(response.data!);
    }
    return null;
  }

  // ── GABUNGKAN REPORT + ALL-REPORT ────────────────────────────
  // GET /report/{responseId} + GET /all-report
  // Untuk dapat: respondent info, location, status + pertanyaan lengkap
  Future<SurveyResponseDetail?> getFullSurveyDetail({
    required String clientSlug,
    required String projectSlug,
    required String surveySlug,
    required int responseId,
  }) async {
    try {
      // Panggil kedua endpoint secara paralel
      // /all-report biasanya berisi semua data survey termasuk pertanyaan
      final results = await Future.wait([
        _api.get(
          Endpoints.surveyReport(
            clientSlug,
            projectSlug,
            surveySlug,
            responseId,
          ),
        ),
        _api.get(
          Endpoints.surveyAllReport(clientSlug, projectSlug, surveySlug),
        ),
      ]);

      final reportData = results[0].data;
      final allReportData = results[1].data;

      debugPrint('DEBUG: reportData keys = ${reportData?.keys.toList()}');
      debugPrint('DEBUG: allReportData keys = ${allReportData?.keys.toList()}');

      if (reportData == null && allReportData == null) return null;

      // Gabungkan data dari kedua endpoint
      final Map<String, dynamic> combined = {};

      // Ambil dari report: surveys, biodata, responses, location, status
      if (reportData != null) {
        combined.addAll(reportData);
      }

      // Ambil questions dari all-report
      if (allReportData != null) {
        debugPrint('DEBUG allReportData keys: ${allReportData.keys.toList()}');

        // Cek apakah ada 'page' key di root
        if (allReportData.containsKey('page')) {
          final pagesList = allReportData['page'] as List?;
          debugPrint(
            'DEBUG: Found page key with ${pagesList?.length ?? 0} pages',
          );
          if (pagesList != null && pagesList.isNotEmpty) {
            combined['detail_pages'] = pagesList;
            debugPrint('DEBUG: Set detail_pages from page key');
          }
        }
        // Cek di surveys
        else if (allReportData.containsKey('surveys')) {
          final surveysData = allReportData['surveys'];
          if (surveysData is Map) {
            // Cek 'page' di dalam surveys
            if (surveysData.containsKey('page')) {
              final pagesList = surveysData['page'] as List?;
              if (pagesList != null && pagesList.isNotEmpty) {
                combined['detail_pages'] = pagesList;
              }
            }
            // Fallback ke questions
            else if (surveysData.containsKey('questions')) {
              final questionsList = surveysData['questions'] as List?;
              if (questionsList != null) {
                combined['detail_pages'] = [
                  {
                    'id': 1,
                    'page_name': 'Semua Pertanyaan',
                    'survey_id': surveysData['id'] ?? 0,
                    'order': 1,
                    'questions': questionsList,
                  },
                ];
              }
            }
          }
        }
      }

      debugPrint('DEBUG: Combined keys = ${combined.keys.toList()}');
      debugPrint(
        'DEBUG: Combined has pages: ${combined.containsKey('detail_pages')}',
      );

      final result = SurveyResponseDetail.fromJson(combined);
      debugPrint('DEBUG: Parsed result pages count: ${result.pages.length}');
      return result;
    } catch (e, st) {
      debugPrint('Error getFullSurveyDetail: $e');
      debugPrint('Stack: $st');
      return null;
    }
  }

  // ── EDIT JAWABAN INDIVIDU ─────────────────────────────────
  // POST /api/clients/{clientSlug}/projects/{projectSlug}/surveys/{slug}/change-answer/{responseId}
  Future<bool> changeAnswer({
    required String clientSlug,
    required String projectSlug,
    required String surveySlug,
    required String responseId,
    required int questionId,
    required dynamic answerValue,
  }) async {
    try {
      await _api.post(
        Endpoints.changeAnswer(
          clientSlug,
          projectSlug,
          surveySlug,
          int.parse(responseId),
        ),
        body: {'question_id': questionId, 'answer': answerValue},
      );

      // assuming success if status code is 200/201
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── HAPUS RESPONSE ─────────────────────────────────────────
  // DELETE /api/clients/{clientSlug}/projects/{projectSlug}/surveys/{slug}/responses/{responseId}
  Future<bool> deleteResponse(
    String clientSlug,
    String projectSlug,
    String surveySlug,
    int responseId,
  ) async {
    try {
      await _api.delete(
        Endpoints.deleteResponse(
          clientSlug,
          projectSlug,
          surveySlug,
          responseId,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Error delete response: $e');
      return false;
    }
  }
}
