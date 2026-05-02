import 'package:flutter/foundation.dart';
import '../models/offline_models.dart';
import '../models/project_model.dart';
import '../models/survey_model.dart';
import 'local_storage_service.dart';
import 'submission_service.dart';
import 'survey_service.dart';

class OfflineDownloadService {
  final LocalStorageService _storage = LocalStorageService();
  final SubmissionService _api = SubmissionService();
  final SurveyService _surveyApi = SurveyService();

  // Observable progress
  final ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  final ValueNotifier<String> statusMessage = ValueNotifier('');

  Future<void> downloadSurveyData(Project project) async {
    try {
      final String clientSlug = project.client?.slug ?? '';
      final String projectSlug = project.slug ?? '';

      if (clientSlug.isEmpty || projectSlug.isEmpty) {
        throw Exception('Client slug or Project slug is missing.');
      }

      statusMessage.value = 'Memulai unduhan untuk ${project.projectName}...';
      downloadProgress.value = 0.0;

      // 1. Fetch Survey list if not provided
      List<SurveyModel> surveys = project.surveys ?? [];
      if (surveys.isEmpty) {
        statusMessage.value = 'Mengambil daftar kuesioner...';
        surveys = await _surveyApi.getSurveys(clientSlug, projectSlug);
      }

      if (surveys.isEmpty) {
        statusMessage.value = 'Tidak ada kuesioner untuk diunduh.';
        downloadProgress.value = 1.0;
        return;
      }

      int totalSteps = surveys.length + 1;
      int currentStep = 0;

      for (var survey in surveys) {
        statusMessage.value = 'Mengunduh kuesioner: ${survey.title}...';
        final data = await _api.getSubmission(
          clientSlug: clientSlug,
          projectSlug: projectSlug,
          surveySlug: survey.slug,
        );

        if (data != null && data.survey != null) {
          final cache = SurveyCache(
            surveyId: data.survey!.id,
            title: data.survey!.title,
            slug: survey.slug,
            surveyData: data.toJson(),
            version: 1,
            lastUpdated: DateTime.now(),
          );
          await _storage.saveSurvey(cache);

          // 2. Fetch Location Data for this survey's targets
          if (data.provinceTargets.isNotEmpty) {
            for (var target in data.provinceTargets) {
              statusMessage.value = 'Mengunduh kota untuk: ${target.provinceName}...';
              final cities = await _api.getCitiesAndRegencies(target.provinceId);
              if (cities.isNotEmpty) {
                await _storage.saveLocationData(LocationCache(
                  parentId: target.provinceId.toString(),
                  type: 'CITY',
                  data: cities,
                  cachedAt: DateTime.now(),
                ));
              }
            }
          }
        }
        
        currentStep++;
        downloadProgress.value = currentStep / totalSteps;
      }

      // 3. Ensure base provinces are cached
      statusMessage.value = 'Memastikan data wilayah tersedia...';
      final cachedProvinces = _storage.getLocationData('PROVINCE', 'root');
      if (cachedProvinces == null) {
        final provinces = await _api.getWilayahProvinces();
        if (provinces.isNotEmpty) {
          await _storage.saveLocationData(LocationCache(
            parentId: 'root',
            type: 'PROVINCE',
            data: provinces,
            cachedAt: DateTime.now(),
          ));
        }
      }

      downloadProgress.value = 1.0;
      statusMessage.value = 'Berhasil diunduh untuk offline.';
    } catch (e) {
      statusMessage.value = 'Gagal mengunduh: $e';
      debugPrint('❌ [OfflineDownloadService] Error: $e');
      rethrow;
    }
  }

  Future<bool> isSurveyDownloaded(int surveyId) async {
    return _storage.getSurvey(surveyId) != null;
  }
}
