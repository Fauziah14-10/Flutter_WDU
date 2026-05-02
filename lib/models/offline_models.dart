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

  AnswerOffline({
    required this.surveyId,
    required this.respondentId,
    required this.enumeratorId,
    required this.answers,
    this.status = 'DRAFT',
    required this.createdAt,
    required this.updatedAt,
    this.isDirty = true,
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
