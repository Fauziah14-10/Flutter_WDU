import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../core/constants/endpoints.dart';
import '../models/submission_model.dart';

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int? _parseIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

class SubmissionService {
  final _api = ApiClient();

  Future<SurveySubmissionData?> getSubmission({
    required String clientSlug,
    required String projectSlug,
    required String surveySlug,
  }) async {
    try {
      final response = await _api.get(
        Endpoints.surveySubmission(clientSlug, projectSlug, surveySlug),
      );

      print(
        "DEBUG getSubmission: response.data keys: ${response.data?.keys.toList()}",
      );
      print(
        "DEBUG getSubmission: survey key exists: ${response.data?.containsKey('survey')}",
      );

      if (response.data != null) {
        final result = SurveySubmissionData.fromJson(response.data!);
        print(
          "DEBUG: provinceTargets count in service: ${result.provinceTargets.length}",
        );
        return result;
      }
      return null;
    } on ApiException {
      rethrow;
    } catch (e, st) {
      print("getSubmission ERROR: $e\n$st");
      throw Exception("Gagal mengambil data submission: $e");
    }
  }

  Future<bool> submitSurvey({
    required String clientSlug,
    required String projectSlug,
    required String surveySlug,
    required Map<String, dynamic> answers,
    Map<int, Uint8List>? attachmentBytes,
  }) async {
    try {
      debugPrint('🚀 [SUBMIT] Starting submission for surveySlug: $surveySlug');
      
      List<Map<String, dynamic>> filesToUpload = [];

      // 1. Extract voice note
      final voiceNotePath = answers['voice_note'] as String?;
      if (voiceNotePath != null && voiceNotePath.isNotEmpty) {
        filesToUpload.add({
          'fieldName': 'voice_note',
          'filePath': voiceNotePath,
        });
      }

      // 2. Extract attachments from answers
      if (answers['page'] is List) {
        for (var page in answers['page']) {
          if (page['answer'] is List) {
            for (var ans in page['answer']) {
              if (ans is Map && ans['hasFile'] == true) {
                final String? fPath = ans['filePath']?.toString();
                final String? fKey = ans['fileKey']?.toString();
                final String? fName = ans['fileName']?.toString();
                
                // Get ID from fileKey if possible (file_question_ID)
                int? qId;
                if (fKey != null) {
                   final parts = fKey.split('_');
                   if (parts.length >= 3) qId = int.tryParse(parts[2]);
                }

                Uint8List? fBytes;
                if (qId != null && attachmentBytes != null) {
                  fBytes = attachmentBytes[qId];
                }

                if (fKey != null) {
                  filesToUpload.add({
                    'fieldName': fKey,
                    'filePath': fPath ?? '',
                    'fileName': fName ?? '',
                    'bytes': fBytes,
                  });
                }
              }
            }
          }
        }
      }

      final additionalFields = {
        'data': jsonEncode(answers),
      };

      debugPrint(
        '🔗 [SUBMIT] ENDPOINT: ${Endpoints.submitAnswer(clientSlug, projectSlug, surveySlug)}',
      );
      debugPrint('📂 [SUBMIT] Files to upload: ${filesToUpload.length}');

      ApiResponse<Map<String, dynamic>> response;
      if (filesToUpload.isNotEmpty) {
        response = await _api.postWithMultipleFiles(
          Endpoints.submitAnswer(clientSlug, projectSlug, surveySlug),
          files: filesToUpload,
          additionalFields: additionalFields,
        );
      } else {
        response = await _api.post(
          Endpoints.submitAnswer(clientSlug, projectSlug, surveySlug),
          body: {'data': jsonEncode(answers)},
        );
      }

      if (response.success) {
        debugPrint('✅ [SUBMIT] SUCCESS: ${response.message}');
        return true;
      }
      return false;
    } catch (e, st) {
      debugPrint('🚨 [SUBMIT] FATAL ERROR: $e');
      debugPrint('StackTrace: $st');
      return false;
    }
  }
}

class SurveySubmissionData {
  final SurveyInfo? survey;
  final ProjectInfo? project;
  final ClientInfo? client;
  final List<SurveyPageData> pages;
  final List<ProvinceTarget> provinceTargets;

  SurveySubmissionData({
    this.survey,
    this.project,
    this.client,
    this.pages = const [],
    this.provinceTargets = const [],
  });

  factory SurveySubmissionData.fromJson(Map<String, dynamic> json) {
    List<SurveyPageData> pages = [];
    if (json.containsKey('pages') && json['pages'] is List) {
      pages = (json['pages'] as List)
          .map((e) => SurveyPageData.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<ProvinceTarget> provinceTargets = [];

    // Helper function to parse province targets from dynamic raw data
    List<ProvinceTarget> parseTargets(dynamic raw) {
      if (raw == null) return [];
      try {
        if (raw is String && raw.isNotEmpty) {
          final decoded = jsonDecode(raw) as List;
          return decoded
              .map((e) => ProvinceTarget.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (raw is List) {
          return raw
              .map((e) => ProvinceTarget.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        debugPrint('Error parsing province targets: $e');
      }
      return [];
    }

    // 1. Cek di top-level (paling sering untuk data master)
    if (json.containsKey('province_targets')) {
      provinceTargets = parseTargets(json['province_targets']);
    } else if (json.containsKey('provinces')) {
      provinceTargets = parseTargets(json['provinces']);
    }

    // 2. Jika masih kosong, cek di dalam objek survey (fallback lama)
    if (provinceTargets.isEmpty &&
        json.containsKey('survey') &&
        json['survey'] is Map) {
      final survey = json['survey'] as Map<String, dynamic>;
      if (survey.containsKey('province_targets')) {
        provinceTargets = parseTargets(survey['province_targets']);
      }
    }

    debugPrint('DEBUG: Final provinceTargets count: ${provinceTargets.length}');
    return SurveySubmissionData(
      survey: json.containsKey('survey') && json['survey'] != null
          ? SurveyInfo.fromJson(json['survey'] as Map<String, dynamic>)
          : null,
      project: json.containsKey('project') && json['project'] != null
          ? ProjectInfo.fromJson(json['project'] as Map<String, dynamic>)
          : null,
      client: json.containsKey('client') && json['client'] != null
          ? ClientInfo.fromJson(json['client'] as Map<String, dynamic>)
          : null,
      pages: pages,
      provinceTargets: provinceTargets,
    );
  }
}

class SurveyInfo {
  final int id;
  final String title;
  final String? desc;
  final String slug;
  final int projectId;
  final bool status;
  final String? spreadsheetUrl;
  final bool isCameraEnabled;
  final bool isVoiceEnabled;
  final bool isProgressBarEnabled;

  SurveyInfo({
    required this.id,
    required this.title,
    this.desc,
    required this.slug,
    required this.projectId,
    required this.status,
    this.spreadsheetUrl,
    this.isCameraEnabled = true,
    this.isVoiceEnabled = false,
    this.isProgressBarEnabled = false,
  });

  factory SurveyInfo.fromJson(Map<String, dynamic> json) {
    bool cameraEnabled = true;
    bool voiceEnabled = false;
    bool progressBarEnabled = false;
    final settingsMap = json['setting'] ?? json['survey_settings'];

    if (kDebugMode) {
      final keys = (settingsMap is Map) ? settingsMap.keys.toList() : 'not a map';
      print('SurveyInfo DEBUG [${json['title']}]: settingsMap type = ${settingsMap.runtimeType}, keys = $keys');
    }

    if (settingsMap != null && settingsMap is Map<String, dynamic>) {
      if (settingsMap.containsKey('is_camera_enabled')) {
         cameraEnabled = settingsMap['is_camera_enabled'] == 1 ||
                         settingsMap['is_camera_enabled'] == true ||
                         settingsMap['is_camera_enabled'] == '1';
      }
      if (settingsMap.containsKey('voice_submission')) {
         voiceEnabled = settingsMap['voice_submission'] == 1 ||
                        settingsMap['voice_submission'] == true ||
                        settingsMap['voice_submission'] == '1';
      }
      if (settingsMap.containsKey('progress_bar_status')) {
         progressBarEnabled = settingsMap['progress_bar_status'] == 1 ||
                              settingsMap['progress_bar_status'] == true ||
                              settingsMap['progress_bar_status'] == '1';
      }
    } else {
      if (json.containsKey('is_camera_enabled')) {
        cameraEnabled = json['is_camera_enabled'] == 1 ||
                        json['is_camera_enabled'] == true ||
                        json['is_camera_enabled'] == '1';
      }
      if (json.containsKey('voice_submission')) {
        voiceEnabled = json['voice_submission'] == 1 ||
                       json['voice_submission'] == true ||
                       json['voice_submission'] == '1';
      }
      if (json.containsKey('progress_bar_status')) {
        progressBarEnabled = json['progress_bar_status'] == 1 ||
                             json['progress_bar_status'] == true ||
                             json['progress_bar_status'] == '1';
      }
    }

    if (kDebugMode) {
      print('SurveyInfo DEBUG [${json['title']}]: cameraEnabled final = $cameraEnabled, voiceEnabled final = $voiceEnabled, progressEnabled = $progressBarEnabled');
    }

    return SurveyInfo(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      desc: json['desc']?.toString(),
      slug: json['slug']?.toString() ?? '',
      projectId: _parseInt(json['project_id']),
      status: json['status'] ?? false,
      spreadsheetUrl: json['spreadsheet_url']?.toString(),
      isCameraEnabled: cameraEnabled,
      isVoiceEnabled: voiceEnabled,
      isProgressBarEnabled: progressBarEnabled,
    );
  }}

class ProjectInfo {
  final int id;
  final String projectName;
  final String slug;
  final int clientId;

  ProjectInfo({
    required this.id,
    required this.projectName,
    required this.slug,
    required this.clientId,
  });

  factory ProjectInfo.fromJson(Map<String, dynamic> json) {
    return ProjectInfo(
      id: _parseInt(json['id']),
      projectName: json['project_name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      clientId: _parseInt(json['client_id']),
    );
  }
}

class ClientInfo {
  final int id;
  final String clientName;
  final String? image;
  final String? alamat;
  final String? phone;
  final String slug;

  ClientInfo({
    required this.id,
    required this.clientName,
    this.image,
    this.alamat,
    this.phone,
    required this.slug,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    return ClientInfo(
      id: _parseInt(json['id']),
      clientName: json['client_name']?.toString() ?? '',
      image: json['image']?.toString(),
      alamat: json['alamat']?.toString(),
      phone: json['phone']?.toString(),
      slug: json['slug']?.toString() ?? '',
    );
  }
}

class SurveyPageData {
  final int id;
  final String pageName;
  final int surveyId;
  final int order;
  final List<SurveyQuestionData> questions;
  final List<FlowData> flow;

  SurveyPageData({
    required this.id,
    required this.pageName,
    required this.surveyId,
    required this.order,
    this.questions = const [],
    this.flow = const [],
  });

  factory SurveyPageData.fromJson(Map<String, dynamic> json) {
    List<SurveyQuestionData> questions = [];
    if (json.containsKey('question') && json['question'] is List) {
      questions = (json['question'] as List)
          .map((e) => SurveyQuestionData.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<FlowData> flow = [];
    if (json.containsKey('flow') && json['flow'] is List) {
      flow = (json['flow'] as List).map((e) {
        // Handle nested { "flow": { ... } } structure from API
        final data = e['flow'] ?? e;
        return FlowData.fromJson(data as Map<String, dynamic>);
      }).toList();
    }

    return SurveyPageData(
      id: _parseInt(json['id']),
      pageName: json['page_name']?.toString() ?? '',
      surveyId: _parseInt(json['survey_id']),
      order: _parseInt(json['order']),
      questions: questions,
      flow: flow,
    );
  }
}

class FlowData {
  final int id;
  final int currentPageId;
  final int nextPageId;
  final int? questionId;
  final int? questionChoiceId;
  final String? customFieldName;
  final String? customFieldOperator;
  final String? customFieldValue;

  FlowData({
    required this.id,
    required this.currentPageId,
    required this.nextPageId,
    this.questionId,
    this.questionChoiceId,
    this.customFieldName,
    this.customFieldOperator,
    this.customFieldValue,
  });

  factory FlowData.fromJson(Map<String, dynamic> json) {
    return FlowData(
      id: _parseInt(json['id']),
      currentPageId: _parseInt(json['current_page_id']),
      nextPageId: _parseInt(json['next_page_id']),
      questionId: json['question_id'] != null ? _parseInt(json['question_id']) : null,
      questionChoiceId: json['question_choice_id'] != null ? _parseInt(json['question_choice_id']) : null,
      customFieldName: json['custom_field_name']?.toString(),
      customFieldOperator: json['custom_field_operator']?.toString(),
      customFieldValue: json['custom_field_value']?.toString(),
    );
  }
}

class SurveyQuestionData {
  final int id;
  final String questionText;
  final int questionTypeId;
  final int surveyId;
  final int order;
  final bool required;
  final int? questionChoiceId;
  final String logicType;
  final String logicName;
  final List<QuestionChoice> choice;
  final List<MatrixRow> matrixRows;
  final List<MatrixColumn> matrixColumns;
  final String matrixType;

  SurveyQuestionData({
    required this.id,
    required this.questionText,
    required this.questionTypeId,
    required this.surveyId,
    required this.order,
    required this.required,
    this.questionChoiceId,
    required this.logicType,
    required this.logicName,
    this.choice = const [],
    this.matrixRows = const [],
    this.matrixColumns = const [],
    this.matrixType = 'radio',
  });

  factory SurveyQuestionData.fromJson(Map<String, dynamic> json) {
    List<QuestionChoice> choice = [];
    if (json.containsKey('choice') && json['choice'] is List) {
      choice = (json['choice'] as List)
          .map((e) => QuestionChoice.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<MatrixRow> matrixRows = [];
    if (json.containsKey('matrix_rows') && json['matrix_rows'] is List) {
      matrixRows = (json['matrix_rows'] as List)
          .map((e) => MatrixRow.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<MatrixColumn> matrixColumns = [];
    if (json.containsKey('matrix_columns') && json['matrix_columns'] is List) {
      matrixColumns = (json['matrix_columns'] as List)
          .map((e) => MatrixColumn.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return SurveyQuestionData(
      id: _parseInt(json['id']),
      questionText: json['question_text']?.toString() ?? '',
      questionTypeId: _parseInt(json['question_type_id']),
      surveyId: _parseInt(json['survey_id']),
      order: _parseInt(json['order']),
      required: json['required'] ?? false,
      questionChoiceId: _parseIntNullable(json['question_choice_id']),
      logicType: json['logic_type']?.toString() ?? '1',
      logicName: json['logic_name']?.toString() ?? 'Always Display',
      choice: choice,
      matrixRows: matrixRows,
      matrixColumns: matrixColumns,
      matrixType: json['matrix_type']?.toString() ?? 'radio',
    );
  }

  String get plainText {
    final temp = questionText
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
    return temp;
  }

  String get typeString {
    switch (questionTypeId) {
      case 1:
        return 'text';
      case 2:
        return 'radio';
      case 3:
        return 'checkbox';
      case 4:
        return 'number';
      case 5:
        return 'info';
      case 6:
        return 'rating';
      case 7:
        return 'dropdown';
      case 8:
        return 'phone';
      case 9:
        return 'matrix';
      case 10:
        return 'attachment';
      default:
        return 'unknown';
    }
  }

  bool get isMatrix => questionTypeId == 9;
}

class QuestionChoice {
  final int id;
  final int questionId;
  final int order;
  final String value;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  QuestionChoice({
    required this.id,
    required this.questionId,
    required this.order,
    required this.value,
    this.createdAt,
    this.updatedAt,
  });

  factory QuestionChoice.fromJson(Map<String, dynamic> json) {
    return QuestionChoice(
      id: _parseInt(json['id']),
      questionId: _parseInt(json['question_id']),
      order: _parseInt(json['order']),
      value: json['value']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}

class MatrixRow {
  final String label;

  MatrixRow({required this.label});

  factory MatrixRow.fromJson(Map<String, dynamic> json) {
    return MatrixRow(label: json['label']?.toString() ?? '');
  }
}

class MatrixColumn {
  final String label;

  MatrixColumn({required this.label});

  factory MatrixColumn.fromJson(Map<String, dynamic> json) {
    return MatrixColumn(label: json['label']?.toString() ?? '');
  }
}
