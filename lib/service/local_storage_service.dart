import 'package:hive_flutter/hive_flutter.dart';
import '../models/offline_models.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // Box Names
  static const String surveyBoxName = 'survey_cache';
  static const String answerBoxName = 'answer_offline';
  static const String queueBoxName = 'sync_queue';

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // Register Adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(SurveyCacheAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(AnswerOfflineAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SyncQueueItemAdapter());

    // Open Boxes
    await Hive.openBox<SurveyCache>(surveyBoxName);
    await Hive.openBox<AnswerOffline>(answerBoxName);
    await Hive.openBox<SyncQueueItem>(queueBoxName);

    _isInitialized = true;
  }

  // --- SURVEY CACHE METHODS ---

  Future<void> saveSurvey(SurveyCache survey) async {
    final box = Hive.box<SurveyCache>(surveyBoxName);
    await box.put(survey.surveyId, survey);
  }

  SurveyCache? getSurvey(int surveyId) {
    final box = Hive.box<SurveyCache>(surveyBoxName);
    return box.get(surveyId);
  }

  List<SurveyCache> getAllCachedSurveys() {
    final box = Hive.box<SurveyCache>(surveyBoxName);
    return box.values.toList();
  }

  // --- ANSWER OFFLINE METHODS ---

  Future<void> saveAnswer(AnswerOffline answer) async {
    final box = Hive.box<AnswerOffline>(answerBoxName);
    // Key is combination of surveyId and respondentId to ensure uniqueness
    final key = '${answer.surveyId}_${answer.respondentId}';
    await box.put(key, answer);
  }

  AnswerOffline? getAnswer(int surveyId, String respondentId) {
    final box = Hive.box<AnswerOffline>(answerBoxName);
    return box.get('${surveyId}_$respondentId');
  }

  List<AnswerOffline> getDrafts() {
    final box = Hive.box<AnswerOffline>(answerBoxName);
    return box.values.where((a) => a.status == 'DRAFT').toList();
  }

  // --- SYNC QUEUE METHODS ---

  Future<void> addToQueue(SyncQueueItem item) async {
    final box = Hive.box<SyncQueueItem>(queueBoxName);
    await box.add(item);
  }

  List<SyncQueueItem> getPendingQueue() {
    final box = Hive.box<SyncQueueItem>(queueBoxName);
    return box.values.where((item) => item.status == 'PENDING').toList();
  }

  Future<void> clearSyncedItems() async {
    final box = Hive.box<SyncQueueItem>(queueBoxName);
    final syncedKeys = box.keys.where((key) {
      final item = box.get(key);
      return item?.status == 'DONE';
    }).toList();
    
    await box.deleteAll(syncedKeys);
  }
}
