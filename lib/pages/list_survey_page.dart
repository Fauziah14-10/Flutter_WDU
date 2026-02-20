import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/storage.dart';   // ← pakai Storage yang sama dengan auth_service
import '../service/api.dart';     // ← pakai baseUrl yang sama

class SurveyListPage extends StatefulWidget {
  final String clientSlug;
  final String projectSlug;
  final String projectTitle;

  const SurveyListPage({
    super.key,
    required this.clientSlug,
    required this.projectSlug,
    required this.projectTitle,
  });

  @override
  State<SurveyListPage> createState() => _SurveyListPageState();
}

class _SurveyListPageState extends State<SurveyListPage> {
  bool loading = true;
  String? errorMessage;
  List surveys = [];

  @override
  void initState() {
    super.initState();
    fetchSurveys();
  }

  Future<void> fetchSurveys() async {
    try {
      // ── Pakai Storage & baseUrl yang sama dengan auth_service ──
      final token = await Storage.getToken();

      final url =
          '${Api.baseUrl}/clients/${widget.clientSlug}/projects/${widget.projectSlug}/surveys';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          // Coba beberapa kemungkinan struktur response
          surveys = json['data'] ?? json['surveys'] ?? json ?? [];
          loading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal memuat data (${response.statusCode})';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color(0xFF333333), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.projectTitle.isNotEmpty ? widget.projectTitle : 'Surveys',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            const Text(
              'Daftar Survey',
              style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE8E8E8)),
        ),
      ),

      // ── Body ─────────────────────────────────────────────────
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 48, color: Colors.red[300]),
                      const SizedBox(height: 12),
                      Text(errorMessage!,
                          style: const TextStyle(color: Color(0xFFAAAAAA))),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            loading = true;
                            errorMessage = null;
                          });
                          fetchSurveys();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : surveys.isEmpty
                  ? const Center(
                      child: Text('Tidak ada survey ditemukan.',
                          style: TextStyle(color: Color(0xFFAAAAAA))),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: surveys.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final survey = surveys[index];
                        return _SurveyCard(survey: survey);
                      },
                    ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Survey Card Widget
// ─────────────────────────────────────────────────────────────
class _SurveyCard extends StatelessWidget {
  final Map<String, dynamic> survey;

  const _SurveyCard({required this.survey});

  @override
  Widget build(BuildContext context) {
    final status = (survey['status'] ?? '').toString().toUpperCase();
    final isOpen = status == 'DIBUKA' || status == 'OPEN' || status == '1';
    final responseCount = survey['response_count'] ?? survey['responses_count'] ?? 0;
    final targetLocation = survey['target_location'] ?? survey['location'] ?? 'No target location';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title + Response Count ───────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    survey['name'] ?? survey['title'] ?? '-',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Response count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bar_chart_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$responseCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Description ──────────────────────────────
            if (survey['description'] != null)
              Text(
                survey['description'],
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF777777),
                  height: 1.4,
                ),
              ),
            const SizedBox(height: 12),

            // ── Target Location + Status ─────────────────
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: Color(0xFFAAAAAA)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    targetLocation,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFFAAAAAA)),
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isOpen
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFEF5350),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isOpen
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFEF5350),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isOpen ? 'DIBUKA' : 'DITUTUP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isOpen
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFEF5350),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}