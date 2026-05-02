import 'package:flutter/foundation.dart';
import '../models/offline_models.dart';
import '../models/project_model.dart';
import 'local_storage_service.dart';
import 'submission_service.dart';

class OfflineDownloadService {
  final LocalStorageService _storage = LocalStorageService();
  final SubmissionService _api = SubmissionService();

  // Observable progress
  final ValueNotifier<double> downloadProgress = ValueNotifier(0.0);
  final ValueNotifier<String> statusMessage = ValueNotifier('');

  Future<void> downloadSurveyData(Project project) async {
    try {
      statusMessage.value = 'Memulai unduhan untuk ${project.projectName}...';
      downloadProgress.value = 0.0;

      // 1. Fetch Survey definitions for this project
      final surveySlugs = project.surveys?.map((s) => s.slug).toList() ?? [];
      
      int totalSteps = surveySlugs.length + 1; // Surveys + Location Data
      int currentStep = 0;

      for (var slug in surveySlugs) {
        statusMessage.value = 'Mengunduh kuesioner: $slug...';
        final data = await _api.getSubmission(
          clientSlug: project.client?.slug ?? '',
          projectSlug: project.slug ?? '',
          surveySlug: slug,
        );

        if (data != null && data.survey != null) {
          final cache = SurveyCache(
            surveyId: data.survey!.id,
            title: data.survey!.title,
            slug: slug,
            surveyData: data.toJson(),
            version: 1, // Default version
            lastUpdated: DateTime.now(),
          );
          await _storage.saveSurvey(cache);
        }
        
        currentStep++;
        downloadProgress.value = currentStep / totalSteps;
      }

      // 2. Fetch Location Data (Provinces first)
      statusMessage.value = 'Mengunduh data wilayah (Provinsi)...';
      final provinces = await _api.getWilayahProvinces();
      if (provinces.isNotEmpty) {
        await _storage.saveLocationData(LocationCache(
          parentId: 'root',
          type: 'PROVINCE',
          data: provinces,
          cachedAt: DateTime.now(),
        ));
      }

      // 3. Fetch cities for project targets
      // Since downloading the entire Indonesia database is too large, 
      // we'll fetch cities for the provinces that are targets of this project.
      // Note: We need to handle the case where province targets might be inside the survey data
      // but for now let's assume we have them or skip if not.
      // In project_model.dart, Project does not seem to have provinceTargets directly.
      // We might need to extract them from the cached surveys.
      
      final cachedSurveys = _storage.getAllCachedSurveys().where((s) => s.slug.contains(project.slug ?? '')).toList();
      
      for (var survey in cachedSurveys) {
        final surveyData = SurveySubmissionData.fromJson(Map<String, dynamic>.from(survey.surveyData));
        if (surveyData.provinceTargets.isNotEmpty) {
          for (var target in surveyData.provinceTargets) {
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

      downloadProgress.value = 1.0;
      statusMessage.value = 'Berhasil diunduh untuk offline.';
    } catch (e) {
      statusMessage.value = 'Gagal mengunduh: $e';
      rethrow;
    }
  }

  Future<bool> isSurveyDownloaded(int surveyId) async {
    return _storage.getSurvey(surveyId) != null;
  }
}
