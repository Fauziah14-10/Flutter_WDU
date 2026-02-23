import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/storage.dart';
import '../service/api.dart';
import '../models/survey_model.dart';

class ListSurveyTransjakarta extends StatefulWidget {
  final String clientSlug;
  final String projectSlug;
  final String projectTitle;

  const ListSurveyTransjakarta({
    super.key,
    required this.clientSlug,
    required this.projectSlug,
    required this.projectTitle,
  });

  @override
  State<ListSurveyTransjakarta> createState() => _ListSurveyTransjakartaState();
}

class _ListSurveyTransjakartaState extends State<ListSurveyTransjakarta> {
  bool loading = true;
  String? errorMessage;
  List<SurveyModel> surveys = [];

  @override
  void initState() {
    super.initState();
    fetchSurveys();
  }

  Future<void> fetchSurveys() async {
    try {
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
        final rawList = json['data'] ?? [];

        setState(() {
          surveys = (rawList as List)
              .map((item) => SurveyModel.fromJson(item as Map<String, dynamic>))
              .toList();
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

  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────
  Widget _clientHeader() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 15, color: Colors.grey.withOpacity(0.1)),
        ],
      ),
      child: Column(
        children: [
          // ── Area hijau: logo + nama client ──────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                // Layer 1: gradient background
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFBFDAD0), Color(0xFFE7F2EE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const SizedBox(height: 70),
                ),

                // Layer 2: logo full header sebagai background transparan
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.30,
                    child: Image.asset(
                      "assets/images/TJ.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Layer 3: konten (avatar + teks)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 20),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            AssetImage("assets/images/logo_trans.jpeg"),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.projectTitle.isNotEmpty
                                  ? widget.projectTitle
                                  : 'TransJakarta',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B4332),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "PT Transportasi Jakarta",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF3D7A5E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Area putih: deskripsi + tombol ──────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    "Survei Pengukuran Capaian SPM Penyelenggaraan PT Transportasi Jakarta Tahun 2026",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF555555),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Navigate to tambah kuisioner
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text(
                    "Tambah Kuisioner",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SEARCH BAR
  // ─────────────────────────────────────────────
  Widget _searchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Cari kuisioner berdasarkan judul atau deskripsi",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
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
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _clientHeader(),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _searchBar(),
                ),
                const SizedBox(height: 8),

                // ── Konten dinamis: error / empty / list ──
                if (errorMessage != null)
                  Expanded(
                    child: Center(
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
                    ),
                  )
                else if (surveys.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Tidak ada survey ditemukan.',
                        style: TextStyle(color: Color(0xFFAAAAAA)),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: surveys.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _SurveyCard(
                          survey: surveys[index],
                          clientSlug: widget.clientSlug,
                          projectSlug: widget.projectSlug,
                          onRefresh: fetchSurveys,
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────
// SURVEY CARD
// ─────────────────────────────────────────────
class _SurveyCard extends StatelessWidget {
  final SurveyModel survey;
  final String clientSlug;
  final String projectSlug;
  final VoidCallback onRefresh;

  const _SurveyCard({
    required this.survey,
    required this.clientSlug,
    required this.projectSlug,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
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
                    survey.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                        '${survey.responseCount}',
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
            if (survey.description != null)
              Text(
                survey.description!,
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
                    survey.targetLocation,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFFAAAAAA)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: survey.isOpen
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: survey.isOpen
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
                          color: survey.isOpen
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFEF5350),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        survey.isOpen ? 'DIBUKA' : 'DITUTUP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: survey.isOpen
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFEF5350),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 10),

            // ── Action Buttons ───────────────────────────
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Cek / Edit',
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      // TODO: Navigate to survey detail/edit
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _ActionButton(
                    label: 'Monitor',
                    color: const Color(0xFF5C6BC0),
                    onTap: () {
                      // TODO: Navigate to monitor page
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _ActionButton(
                    label: 'Pertanyaan',
                    color: const Color(0xFFFFA726),
                    onTap: () {
                      // TODO: Navigate to questions page
                    },
                  ),
                ),
                const SizedBox(width: 8),
                _IconActionButton(
                  icon: Icons.edit_rounded,
                  color: const Color(0xFF4CAF50),
                  onTap: () {},
                ),
                const SizedBox(width: 4),
                _IconActionButton(
                  icon: Icons.content_copy_rounded,
                  color: const Color(0xFF42A5F5),
                  onTap: () {},
                ),
                const SizedBox(width: 4),
                _IconActionButton(
                  icon: Icons.delete_rounded,
                  color: const Color(0xFFEF5350),
                  onTap: () => _showDeleteDialog(context, survey.name),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Hapus Survey'),
        content: Text('Apakah Anda yakin ingin menghapus "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF888888))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: call delete API then onRefresh()
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ACTION BUTTON (text)
// ─────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ICON ACTION BUTTON
// ─────────────────────────────────────────────
class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }
}