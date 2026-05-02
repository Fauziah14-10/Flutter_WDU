import 'package:hive/hive.dart';

part 'offline_models.g.dart';

@HiveType(typeId: 0)
class SurveyCache extends HiveObject {
  @HiveField(0)
  final int surveyId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String slug;

  @HiveField(3)
  final Map<String, dynamic> surveyData; // Raw JSON definition

  @HiveField(4)
  final int version;

  @HiveField(5)
  final DateTime lastUpdated;

  SurveyCache({
    required this.surveyId,
    required this.title,
    required this.slug,
    required this.surveyData,
    required this.version,
    required this.lastUpdated,
  });
}

@HiveType(typeId: 1)
class AnswerOffline extends HiveObject {
  @HiveField(0)
  final int surveyId;

  @HiveField(1)
  final String respondentId; // UUID

  @HiveField(2)
  final int enumeratorId;

  @HiveField(3)
  final Map<dynamic, dynamic> answers;

  @HiveField(4)
  String status; // DRAFT, PENDING, SYNCED, FAILED

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  bool isDirty;

  @HiveField(8)
  final String surveyTitle; // Added for easier list display

  @HiveField(9)
  String draftType; // MANUAL, AUTO (Added for auto-save detection)

  @HiveField(10)
  final String clientSlug;

  @HiveField(11)
  final String projectSlug;

  @HiveField(12)
  final String surveySlug;

  AnswerOffline({
    required this.surveyId,
    required this.respondentId,
    required this.enumeratorId,
    required this.answers,
    this.status = 'DRAFT',
    required this.createdAt,
    required this.updatedAt,
    this.isDirty = true,
    this.surveyTitle = '',
    this.draftType = 'MANUAL',
    this.clientSlug = '',
    this.projectSlug = '',
    this.surveySlug = '',
  });
}

@HiveType(typeId: 3)
class LocationCache extends HiveObject {
  @HiveField(0)
  final String parentId; // e.g. provinceId for cities, cityId for districts

  @HiveField(1)
  final String type; // PROVINCE, CITY, DISTRICT, VILLAGE

  @HiveField(2)
  final List<Map<dynamic, dynamic>> data; // List of location objects

  @HiveField(3)
  final DateTime cachedAt;

  LocationCache({
    required this.parentId,
    required this.type,
    required this.data,
    required this.cachedAt,
  });
}

@HiveType(typeId: 2)
class SyncQueueItem extends HiveObject {
  @HiveField(0)
  final int surveyId;

  @HiveField(1)
  final String respondentId;

  @HiveField(2)
  final Map<String, dynamic> payload; // Data to be sent to API

  @HiveField(3)
  String status; // PENDING, PROCESSING, FAILED

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  int retryCount;

  @HiveField(6)
  String? lastError;

  SyncQueueItem({
    required this.surveyId,
    required this.respondentId,
    required this.payload,
    this.status = 'PENDING',
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });
}
