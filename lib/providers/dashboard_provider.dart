import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import '../service/client_service.dart';
import '../models/client_model.dart';
import '../models/user_project_model.dart';
import '../models/project_model.dart';
import '../core/utils/storage.dart';
import '../service/offline_download_service.dart';
import '../core/utils/connectivity_service.dart';

class DashboardProvider with ChangeNotifier {
  final AuthService authService = AuthService();
  final ClientService clientService = ClientService();
  final OfflineDownloadService _downloadService = OfflineDownloadService();
  final ConnectivityService _connectivity = ConnectivityService();


  Map<String, dynamic>? user;
  List<Client> clients = [];
  List<UserProject> projects = [];
  bool loading = true;
  bool clientsLoading = true;
  String? error;
  String clientSearch = '';

  List<Client> get filteredClients {
    if (clientSearch.isEmpty) return clients;
    final q = clientSearch.toLowerCase();
    return clients
        .where((c) => c.clientName.toLowerCase().contains(q))
        .toList();
  }

  List<UserProject> get filteredProjects {
    if (clientSearch.isEmpty) return projects;
    final q = clientSearch.toLowerCase();
    return projects
        .where(
          (p) =>
              p.projectName.toLowerCase().contains(q) ||
              p.clientName.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> init() async {
    await loadUser(); // ✅ tunggu token tersimpan dulu
    await loadClients(); // ✅ baru fetch clients
    autoDownloadOfflineSurveys(); // ✅ background download
  }

  Future<void> autoDownloadOfflineSurveys() async {
    if (await _connectivity.isOffline) return;
    if (projects.isEmpty) return;

    debugPrint('🚀 [DashboardProvider] Starting background auto-download...');
    for (var project in projects) {
      try {
        final apiProject = Project(
          projectName: project.projectName,
          slug: project.slug,
          client: project.clientSlug.isNotEmpty 
            ? Project.fromJson({'client': {'slug': project.clientSlug}}).client 
            : null,
        );
        // Only download if we have a slug
        if (apiProject.slug != null) {
          await _downloadService.downloadSurveyData(apiProject);
        }
      } catch (e) {
        debugPrint('⚠️ [DashboardProvider] Auto-download failed for project ${project.projectName}: $e');
      }
    }
    debugPrint('✅ [DashboardProvider] Background auto-download finished.');
  }

  Future<void> loadUser() async {
    try {
      user = await authService.getUser();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // dashboard_provider.dart
  Future<void> loadClients() async {
    try {
      clientsLoading = true;
      notifyListeners();

      final data = await clientService.getDashboardData();

      final List<dynamic> rawClients =
          (data['clients'] as List<dynamic>?) ?? [];
      final List<dynamic> rawProjects =
          (data['userProjects'] as List<dynamic>?) ?? [];

      clients = [];
      for (final e in rawClients) {
        try {
          clients.add(Client.fromJson(e));
        } catch (err) {
          debugPrint('[DashboardProvider] Error parse Client: $err');
        }
      }

      projects = [];
      for (final e in rawProjects) {
        try {
          UserProject p = UserProject.fromJson(e);

          // ✅ SINKRONISASI LOGO: Jika project tidak punya logo, cari dari list clients
          if (p.clientImage == null || p.clientImage!.isEmpty) {
            final clientMatch = clients
                .where((c) => c.slug == p.clientSlug)
                .firstOrNull;
            if (clientMatch != null && clientMatch.image != null) {
              p = p.copyWith(clientImage: clientMatch.image);
            }
          }

          projects.add(p);
        } catch (err) {
          debugPrint('[DashboardProvider] Error parse UserProject: $err');
        }
      }

      error = null;
    } catch (e) {
      debugPrint('[DashboardProvider] Error loadClients: $e');
      error = e.toString();
    } finally {
      clientsLoading = false;
      notifyListeners();
    }
  }

  void updateSearch(String val) {
    clientSearch = val;
    notifyListeners();
  }
}
