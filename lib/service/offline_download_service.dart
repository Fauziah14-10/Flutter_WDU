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

  Future<void> downloadSingleSurvey({
    required String clientSlug,
    required String projectSlug,
    required String surveySlug,
    SurveyModel? survey,
  }) async {
    try {
      if (clientSlug.isEmpty || projectSlug.isEmpty || surveySlug.isEmpty) {
        throw Exception('Client slug, Project slug, or Survey slug is missing.');
      }

      statusMessage.value = 'Mengunduh data survey...';
      downloadProgress.value = 0.05;

      // 1. Fetch submission data
      SurveySubmissionData? data;
      if (survey != null && surveySlug == survey.slug) {
        data = await _api.getSubmission(
          clientSlug: clientSlug,
          projectSlug: projectSlug,
          surveySlug: surveySlug,
        );
      } else {
        data = await _api.getSubmission(
          clientSlug: clientSlug,
          projectSlug: projectSlug,
          surveySlug: surveySlug,
        );
      }

      if (data == null || data.survey == null) {
        throw Exception('Data survey tidak ditemukan.');
      }

      statusMessage.value = 'Menyimpan data survey...';
      downloadProgress.value = 0.15;

      // 2. Cache survey data
      final cache = SurveyCache(
        surveyId: data.survey!.id,
        title: data.survey!.title,
        slug: surveySlug,
        surveyData: data.toJson(),
        version: 1,
        lastUpdated: DateTime.now(),
        projectSlug: projectSlug,
      );
      await _storage.saveSurvey(cache);

      // 3. Collect all unique province IDs to download location data
      final Set<String> provinceIds = {};
      for (var target in data.provinceTargets) {
        provinceIds.add(target.provinceId.toString());
      }

      // 4. Cache base provinces
      statusMessage.value = 'Mengunduh data provinsi...';
      downloadProgress.value = 0.20;
      final cachedProvinces = _storage.getLocationData('PROVINCE', 'root');
      List<Map<String, dynamic>> provincesList = [];
      if (cachedProvinces == null) {
        provincesList = await _api.getWilayahProvinces();
        if (provincesList.isNotEmpty) {
          await _storage.saveLocationData(LocationCache(
            parentId: 'root',
            type: 'PROVINCE',
            data: provincesList,
            cachedAt: DateTime.now(),
          ));
        }
      } else {
        provincesList = List<Map<String, dynamic>>.from(cachedProvinces.data);
      }

      // Build province name map
      final Map<String, String> provinceNameMap = {};
      for (var prov in provincesList) {
        provinceNameMap[prov['id']?.toString() ?? ''] = prov['name']?.toString() ?? '';
      }

      // 5. Download cities for each province target
      int totalProvinces = provinceIds.length;
      int currentProvince = 0;
      double provinceWeight = 0.50; // 50% of progress for cities+districts+villages
      double perProvince = totalProvinces > 0 ? provinceWeight / totalProvinces : 0;

      for (var provId in provinceIds) {
        final provName = provinceNameMap[provId] ?? 'Provinsi $provId';
        statusMessage.value = 'Mengunduh kota/kabupaten untuk $provName...';
        downloadProgress.value = 0.20 + (currentProvince * perProvince);

        final cities = await _api.getCitiesAndRegencies(provId);
        if (cities.isNotEmpty) {
          await _storage.saveLocationData(LocationCache(
            parentId: provId,
            type: 'CITY',
            data: cities,
            cachedAt: DateTime.now(),
          ));

          // 6. Download districts for each city
          for (int i = 0; i < cities.length; i++) {
            final city = cities[i];
            final cityId = city['id']?.toString() ?? '';
            final cityName = city['name']?.toString() ?? '';

            // Check if already cached
            final cachedCity = _storage.getLocationData('DISTRICT', cityId);
            if (cachedCity == null) {
              statusMessage.value = 'Mengunduh kecamatan untuk $cityName...';
              final districts = await _api.getWilayahDistricts(cityId);
              if (districts.isNotEmpty) {
                await _storage.saveLocationData(LocationCache(
                  parentId: cityId,
                  type: 'DISTRICT',
                  data: districts,
                  cachedAt: DateTime.now(),
                ));

                // 7. Download villages for each district (lightweight per-district)
                for (var district in districts) {
                  final districtId = district['id']?.toString() ?? '';

                  // Check if already cached
                  final cachedVillage = _storage.getLocationData('VILLAGE', districtId);
                  if (cachedVillage == null) {
                    final villages = await _api.getWilayahVillages(districtId);
                    if (villages.isNotEmpty) {
                      await _storage.saveLocationData(LocationCache(
                        parentId: districtId,
                        type: 'VILLAGE',
                        data: villages,
                        cachedAt: DateTime.now(),
                      ));
                    }
                  }
                }
              }
            }
          }
        }

        currentProvince++;
      }

      downloadProgress.value = 1.0;
      statusMessage.value = 'Berhasil diunduh untuk offline.';
    } catch (e) {
      statusMessage.value = 'Gagal mengunduh: $e';
      debugPrint('❌ [OfflineDownloadService] downloadSingleSurvey Error: $e');
      rethrow;
    }
  }

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
            projectSlug: projectSlug, // Store project slug for filtering
          );
          await _storage.saveSurvey(cache);

          // 2. Fetch Location Data for this survey's targets
          if (data.provinceTargets.isNotEmpty) {
            for (var target in data.provinceTargets) {
              final String emsifaProvId = target.provinceId.toString();
              statusMessage.value = 'Mengunduh kota untuk: ${target.provinceName}...';
              
              final cities = await _api.getCitiesAndRegencies(emsifaProvId);
              if (cities.isNotEmpty) {
                await _storage.saveLocationData(LocationCache(
                  parentId: emsifaProvId,
                  type: 'CITY',
                  data: cities,
                  cachedAt: DateTime.now(),
                ));
                debugPrint('✅ Cached ${cities.length} cities for province $emsifaProvId');
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

  Future<bool> isSurveyDownloadedBySlug(String slug) async {
    return _storage.getSurveyBySlug(slug) != null;
  }
}
