import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/storage.dart';
import 'submission_page.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _drafts = [];

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    final List<Map<String, dynamic>> loadedDrafts = [];

    for (String key in keys) {
      if (key.startsWith('draft_survey_')) {
        final surveySlug = key.replaceFirst('draft_survey_', '');
        final draftData = await StorageHelper.getDraftSurvey(surveySlug);
        
        if (draftData != null) {
          final updatedAt = draftData['updatedAt'] != null 
              ? DateTime.tryParse(draftData['updatedAt']) 
              : null;
          final dateStr = updatedAt != null 
              ? DateFormat('dd MMM yyyy, HH:mm').format(updatedAt)
              : 'Waktu tidak diketahui';

          loadedDrafts.add({
            'key': key,
            'type': 'survey',
            'slug': surveySlug,
            'clientSlug': draftData['clientSlug'],
            'projectSlug': draftData['projectSlug'],
            'surveyTitle': draftData['surveyTitle'] ?? surveySlug,
            'title': draftData['surveyTitle'] ?? 'Draf Kuisioner | $surveySlug',
            'description': 'Tersimpan pada $dateStr',
            'icon': Icons.assignment_late_rounded,
          });
        }
      } else if (key.startsWith('draft_biodata_')) {
        // ... biodata handling remains similar or can be expanded if needed
        final surveySlug = key.replaceFirst('draft_biodata_', '');
        loadedDrafts.add({
          'key': key,
          'type': 'biodata',
          'slug': surveySlug,
          'title': 'Draf Biodata | $surveySlug',
          'description': 'Draf pengisian profil / biodata responden.',
          'icon': Icons.person_pin_rounded,
        });
      }
    }

    setState(() {
      _drafts = loadedDrafts;
      _isLoading = false;
    });
  }

  Future<void> _deleteDraft(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    _loadDrafts();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draf berhasil dihapus'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openSurveyDraft(Map<String, dynamic> draft) {
    if (draft['type'] != 'survey') return;

    final clientSlug = draft['clientSlug'];
    final projectSlug = draft['projectSlug'];

    if (clientSlug == null || projectSlug == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konteks draf (Klien/Proyek) tidak ditemukan. Mohon buat draf baru.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmissionPage(
          surveySlug: draft['slug'],
          clientSlug: clientSlug,
          projectSlug: projectSlug,
          surveyTitle: draft['surveyTitle'] ?? '',
        ),
      ),
    ).then((_) => _loadDrafts()); // Refresh list when coming back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Draf Tersimpan',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _drafts.isEmpty
              ? _buildEmptyState()
              : _buildDraftList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_rounded,
              color: AppTheme.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Draf',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anda belum memiliki draf biodata atau kuisioner.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: _drafts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final draft = _drafts[index];
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.onSurface.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            onTap: () => _openSurveyDraft(draft),
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: draft['type'] == 'survey'
                    ? const Color(0xFF006A36).withOpacity(0.1)
                    : const Color(0xFF00838F).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                draft['icon'],
                color: draft['type'] == 'survey'
                    ? const Color(0xFF006A36)
                    : const Color(0xFF00838F),
              ),
            ),
            title: Text(
              draft['title'],
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
            subtitle: Text(
              draft['description'],
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.outline,
              ),
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: AppTheme.outline),
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteDraft(draft['key']);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Hapus Draf', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
