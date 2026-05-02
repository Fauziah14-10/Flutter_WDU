import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../service/local_storage_service.dart';
import '../models/offline_models.dart';
import '../providers/sync_provider.dart';
import 'submission_page.dart';

import 'package:hive_flutter/hive_flutter.dart';

class OfflineManagerPage extends StatefulWidget {
  const OfflineManagerPage({super.key});

  @override
  State<OfflineManagerPage> createState() => _OfflineManagerPageState();
}

class _OfflineManagerPageState extends State<OfflineManagerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LocalStorageService _storage = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.monBgColor,
      appBar: AppBar(
        title: const Text('Manajemen Data Offline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.monTextDark,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.monGreenMid,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.monGreenMid,
          tabs: const [
            Tab(text: 'Draft Jawaban'),
            Tab(text: 'Antrean Kirim'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDraftsTab(),
          _buildSyncQueueTab(),
        ],
      ),
    );
  }

  Widget _buildDraftsTab() {
    final drafts = _storage.getDrafts();

    if (drafts.isEmpty) {
      return _buildEmptyState(Icons.note_alt_outlined, 'Tidak ada draft jawaban');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: drafts.length,
      itemBuilder: (context, index) {
        final draft = drafts[index];
        final isAuto = draft.draftType == 'AUTO';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              draft.surveyTitle.isNotEmpty ? draft.surveyTitle : 'Kuesioner #${draft.surveyId}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Diperbarui: ${DateFormat('dd MMM yyyy, HH:mm').format(draft.updatedAt)}', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAuto ? Colors.blue.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isAuto ? 'Tersimpan Otomatis' : 'Tersimpan Manual',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isAuto ? Colors.blue : Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDeleteDraft(draft),
            ),
            onTap: () => _resumeDraft(draft),
          ),
        );
      },
    );
  }

  Widget _buildSyncQueueTab() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<SyncQueueItem>(LocalStorageService.queueBoxName).listenable(),
      builder: (context, Box<SyncQueueItem> box, _) {
        final allItems = box.values.toList();
        final pendingItems = allItems.where((item) => item.status != 'DONE').toList();
        final syncedItems = allItems.where((item) => item.status == 'DONE').toList();

        if (allItems.isEmpty) {
          return _buildEmptyState(Icons.cloud_done_outlined, 'Antrean kirim kosong');
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (pendingItems.isNotEmpty) ...[
              _buildSectionHeader('Antrean & Gagal', Colors.orange),
              ...pendingItems.map((item) => _buildQueueItem(item)),
              const SizedBox(height: 24),
            ],
            if (syncedItems.isNotEmpty) ...[
              _buildSectionHeader('Selesai Terkirim', Colors.green),
              ...syncedItems.map((item) => _buildQueueItem(item)),
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: _clearSyncedHistory,
                  icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: Colors.grey),
                  label: const Text('Hapus Riwayat Terkirim', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              ),
            ],
          ],
        );
      }
    );
  }

  void _clearSyncedHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat?'),
        content: const Text('Semua data yang sudah berhasil terkirim akan dihapus dari daftar ini.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.clearSyncedItems();
      setState(() {});
    }
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          const Spacer(),
          if (title == 'Antrean & Gagal')
            Consumer<SyncProvider>(
              builder: (context, sync, _) {
                return TextButton.icon(
                  onPressed: sync.isSyncing ? null : () => sync.syncData(),
                  icon: sync.isSyncing 
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.sync, size: 16),
                  label: const Text('Sync', style: TextStyle(fontSize: 12)),
                );
              }
            ),
        ],
      ),
    );
  }

  Widget _buildQueueItem(SyncQueueItem item) {
    final surveyTitle = 'Kuesioner #${item.surveyId}';
    
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.cloud_upload_outlined;
    
    if (item.status == 'DONE') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    } else if (item.status == 'FAILED') {
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
    } else if (item.status == 'PROCESSING') {
      statusColor = Colors.blue;
      statusIcon = Icons.sync;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(surveyTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dibuat: ${DateFormat('dd MMM HH:mm').format(item.createdAt)}', style: const TextStyle(fontSize: 12)),
            if (item.status == 'FAILED' && item.lastError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Error: ${item.lastError}',
                  style: const TextStyle(fontSize: 10, color: Colors.red),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            item.status,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  void _resumeDraft(AnswerOffline draft) {
    if (draft.surveySlug.isEmpty || draft.clientSlug.isEmpty || draft.projectSlug.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data draft tidak lengkap untuk dipulihkan.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmissionPage(
          surveySlug: draft.surveySlug,
          clientSlug: draft.clientSlug,
          projectSlug: draft.projectSlug,
          surveyTitle: draft.surveyTitle,
        ),
      ),
    );
  }

  void _confirmDeleteDraft(AnswerOffline draft) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Draft?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              await draft.delete();
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
