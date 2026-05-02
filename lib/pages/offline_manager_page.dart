import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../service/local_storage_service.dart';
import '../models/offline_models.dart';
import '../providers/sync_provider.dart';
import 'submission_page.dart';

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
    final queue = _storage.getPendingQueue();

    if (queue.isEmpty) {
      return _buildEmptyState(Icons.cloud_done_outlined, 'Antrean kirim kosong');
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Data di bawah akan dikirim otomatis saat internet tersedia.',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
              Consumer<SyncProvider>(
                builder: (context, sync, _) {
                  return TextButton.icon(
                    onPressed: sync.isSyncing ? null : () => sync.syncData(),
                    icon: sync.isSyncing 
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.sync, size: 18),
                    label: const Text('Kirim Sekarang'),
                  );
                }
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: queue.length,
            itemBuilder: (context, index) {
              final item = queue[index];
              final surveyTitle = 'Kuesioner #${item.surveyId}'; // We could improve this by caching titles in queue too

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.cloud_upload_outlined, color: AppTheme.monGreenMid),
                  title: Text(surveyTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('Dibuat: ${DateFormat('dd MMM HH:mm').format(item.createdAt)}', style: const TextStyle(fontSize: 12)),
                  trailing: Text(item.status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.orange)),
                ),
              );
            },
          ),
        ),
      ],
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
    // We need the slugs to resume. Let's assume we can find them or they are in the draft
    // For now, this is a placeholder navigation. In a real app, we'd need slug info in AnswerOffline.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Membuka draft...')),
    );
    // Navigation logic here...
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
