import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../service/local_storage_service.dart';
import '../service/submission_service.dart';
import '../core/utils/connectivity_service.dart';
import '../models/offline_models.dart';

class SyncProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  final SubmissionService _api = SubmissionService();
  final ConnectivityService _connectivity = ConnectivityService();

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  String _syncStatusMessage = '';
  String get syncStatusMessage => _syncStatusMessage;

  StreamSubscription? _connectivitySubscription;

  SyncProvider() {
    _init();
  }

  void _init() {
    // Listen for connectivity changes to trigger auto-sync
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) async {
      final isOnline = results.any((result) => result != ConnectivityResult.none);
      if (isOnline) {
        debugPrint('🌐 Internet detected! Starting auto-sync...');
        syncData();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> syncData() async {
    if (_isSyncing) return;

    final pendingItems = _storage.getPendingQueue();
    if (pendingItems.isEmpty) return;

    _isSyncing = true;
    _syncStatusMessage = 'Mengirim ${pendingItems.length} data tertunda...';
    notifyListeners();

    int successCount = 0;
    int failCount = 0;

    for (var item in pendingItems) {
      try {
        item.status = 'PROCESSING';
        await item.save();

        // Extract required slugs from payload or storage
        // Assuming payload has these or we need to find another way to get them
        final String clientSlug = item.payload['clientSlug'] ?? '';
        final String projectSlug = item.payload['projectSlug'] ?? '';
        final String surveySlug = item.payload['surveySlug'] ?? '';
        final Map<String, dynamic> answers = item.payload['answers'] ?? {};

        final success = await _api.submitSurvey(
          clientSlug: clientSlug,
          projectSlug: projectSlug,
          surveySlug: surveySlug,
          answers: answers,
        );

        if (success) {
          item.status = 'DONE';
          successCount++;
          
          // Update corresponding AnswerOffline status
          final localAnswer = _storage.getAnswer(item.surveyId, item.respondentId);
          if (localAnswer != null) {
            localAnswer.status = 'SYNCED';
            localAnswer.isDirty = false;
            await localAnswer.save();
          }
        } else {
          item.status = 'FAILED';
          item.retryCount++;
          item.lastError = 'Server returned failure';
          failCount++;
        }
      } catch (e) {
        item.status = 'FAILED';
        item.retryCount++;
        item.lastError = e.toString();
        failCount++;
      } finally {
        await item.save();
      }
    }

    _isSyncing = false;
    if (failCount == 0) {
      _syncStatusMessage = 'Berhasil mengirim $successCount data.';
    } else {
      _syncStatusMessage = 'Selesai. $successCount sukses, $failCount gagal.';
    }
    
    notifyListeners();
    
    // Clear success items after some time or immediately
    await _storage.clearSyncedItems();
  }
}
