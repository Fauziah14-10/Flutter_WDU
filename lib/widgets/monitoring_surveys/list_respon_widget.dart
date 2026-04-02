import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/monitoring_provider.dart';
import '../../pages/lihat_monitor_page.dart';

class ListResponWidget extends StatelessWidget {
  final List<Map<String, dynamic>> responses;
  final int currentPage;
  final int totalData;
  final int perPage;
  final ValueChanged<int> onPageChanged;
  final void Function(
    int responseId,
    String surveySlug,
    String clientSlug,
    String projectSlug,
  )?
  onDeleteResponse;

  const ListResponWidget({
    super.key,
    required this.responses,
    required this.currentPage,
    required this.totalData,
    required this.perPage,
    required this.onPageChanged,
    this.onDeleteResponse,
  });

  int get totalPages => totalData == 0 ? 1 : (totalData / perPage).ceil();

  List<Map<String, dynamic>> get _paged {
    final start = (currentPage - 1) * perPage;
    final end = (start + perPage).clamp(0, responses.length);
    if (start >= responses.length) return [];
    return responses.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.list_alt_outlined,
              size: 16,
              color: Color(0xFF333333),
            ),
            const SizedBox(width: 6),
            const Text(
              'List Respon',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Total $totalData respon',
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: 750, // Lebar ditambah untuk menampung kolom Status di akhir
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(
                children: [
                  Container(
                    color: const Color(0xFF2D9E6B),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Row(
                      children: const [
                        _H('WAKTU', flex: 3),
                        _H('SUMBER', flex: 4),
                        _H('PROVINSI', flex: 3),
                        _H('ROLE', flex: 2),
                        _H('ACTION', flex: 4, center: true),
                        _H('STATUS', flex: 2, center: true),
                      ],
                    ),
                  ),
                  if (_paged.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'Belum ada data respon',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    )
                  else
                    ..._paged.asMap().entries.map(
                      (e) => _Row(
                        response: e.value,
                        isLast: e.key == _paged.length - 1,
                        onDeleteResponse: onDeleteResponse,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                totalData == 0
                    ? 'Menampilkan 0 dari 0 hasil'
                    : 'Menampilkan '
                          '${(currentPage - 1) * perPage + 1}–'
                          '${(currentPage * perPage).clamp(0, totalData)} '
                          'dari $totalData hasil',
                style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
              ),
            ),
            _Pagination(
              currentPage: currentPage,
              totalPages: totalPages,
              onPageChanged: onPageChanged,
            ),
          ],
        ),
      ],
    );
  }
}

class _H extends StatelessWidget {
  final String text;
  final int flex;
  final bool center;
  const _H(this.text, {required this.flex, this.center = false});

  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.left,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.4,
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  final Map<String, dynamic> response;
  final bool isLast;
  final void Function(
    int responseId,
    String surveySlug,
    String clientSlug,
    String projectSlug,
  )?
  onDeleteResponse;
  const _Row({
    required this.response,
    required this.isLast,
    this.onDeleteResponse,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MonitoringProvider>();
    final clientSlug = provider.clientSlug;
    final projectSlug = provider.projectSlug;

    final user = response['user'] as Map<String, dynamic>?;
    final biodata = user?['biodata'] as Map<String, dynamic>?;

    final waktu = _fmtDate(response['created_at'] ?? '');
    final nama = user?['name'] ?? '-';
    final token = user?['email'] ?? '';
    final provinsi = _provinsi(biodata);
    final role = _role(user);

    return Container(
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              waktu,
              style: const TextStyle(fontSize: 9.5, color: Color(0xFF374151)),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 11,
                        color: Color(0xFF2D9E6B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        nama,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (token.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 1, left: 22),
                    child: Text(
                      token,
                      style: const TextStyle(
                        fontSize: 8.5,
                        color: Color(0xFF9CA3AF),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              provinsi,
              style: const TextStyle(fontSize: 9.5, color: Color(0xFF374151)),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                role,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF059669),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionBtn(
                  icon: Icons.visibility_outlined,
                  label: 'Lihat',
                  color: const Color(0xFF2D9E6B),
                  onTap: () {
                    final responseId =
                        int.tryParse(
                          (response['id'] ?? response['response_id'] ?? 0)
                              .toString(),
                        ) ??
                        0;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: RouteSettings(
                          name: '/lihat_monitor',
                          arguments: {
                            'surveySlug': provider.surveySlug,
                            'clientSlug': clientSlug,
                            'projectSlug': projectSlug,
                            'responseId': responseId,
                          },
                        ),
                        builder: (_) => LihatMonitorPage(
                          responseId: responseId,
                          surveySlug: provider.surveySlug,
                          clientSlug: clientSlug,
                          projectSlug: projectSlug,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
                _ActionBtn(
                  icon: Icons.delete_outline,
                  label: 'Hapus',
                  color: Colors.red,
                  onTap: () {
                    final responseId =
                        int.tryParse(
                          (response['id'] ?? response['response_id'] ?? 0)
                              .toString(),
                        ) ??
                        0;
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Hapus Data'),
                        content: const Text(
                          'Apakah Anda yakin ingin menghapus data ini?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              final provider = context
                                  .read<MonitoringProvider>();
                              if (onDeleteResponse != null) {
                                onDeleteResponse!(
                                  responseId,
                                  provider.surveySlug,
                                  clientSlug,
                                  projectSlug,
                                );
                              }
                            },
                            child: const Text(
                              'Hapus',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: _StatusBadge(
              // Prioritaskan nilai yang bukan boolean, atau petakan boolean ke PENDING/APPROVE
              status: _getModerationStatus(response),
            ),
          ),
        ],
      ),
    );
  }

  String _getModerationStatus(Map<String, dynamic> r) {
    final dynamic s =
        r['supervision_status'] ??
        r['moderation_status'] ??
        r['status_review'] ??
        r['review_status'] ??
        r['status_moderasi'] ??
        r['status'];

    if (s == null) return 'PENDING';

    final str = s.toString().toLowerCase();

    if (str == 'pending' || str.isEmpty) return 'PENDING';
    if (str == 'revision_needed' || str == 'revision') return 'REVISION';
    if (str == 'approve' || str == 'approved') return 'APPROVE';
    if (str == 'decline' || str == 'declined') return 'DECLINE';

    if (s is int) {
      switch (s) {
        case 0:
          return 'PENDING';
        case 1:
          return 'REVISION';
        case 2:
          return 'APPROVE';
        case 3:
          return 'DECLINE';
        default:
          return 'PENDING';
      }
    }

    if (s is bool) {
      if (r['is_approved'] == true) return 'APPROVE';
      if (r['is_revision'] == true) return 'REVISION';
      return (s == true) ? 'PENDING' : 'DRAFT';
    }

    return 'PENDING';
  }

  String _fmtDate(String raw) {
    if (raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final m = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${dt.day.toString().padLeft(2, '0')} ${m[dt.month]} ${dt.year}\n'
          '${dt.hour.toString().padLeft(2, '0')}.'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  String _provinsi(Map<String, dynamic>? b) {
    if (b == null) return 'Tidak ada';
    final name = b['province_name'];
    if (name != null && name.toString().isNotEmpty) return name.toString();
    final id = b['province_id'];
    if (id == null) return 'Tidak ada';
    return 'Prov. $id';
  }

  String _role(Map<String, dynamic>? u) {
    if (u == null) return 'Lainnya';
    switch ((u['usertype'] as String? ?? '').toLowerCase()) {
      case 'superadmin':
        return 'S.Admin';
      case 'admin':
        return 'Admin';
      case 'enumerator':
        return 'Enum.';
      default:
        return 'Lainnya';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String s = status.toUpperCase();

    // Map unexpected values like "TRUE", "false", "0", "1" to human readable labels
    if (s == 'TRUE' || s == '1') {
      // Jika true/1 dari database, asumsikan PENDING review jika belum ada label lain
      s = 'PENDING';
    } else if (s == 'FALSE' || s == '0' || s == 'NULL' || s.isEmpty) {
      s = 'PENDING';
    }

    // Default PENDING (Gray)
    Color bgColor = const Color(0xFFF3F4F6); // Light Gray
    Color textColor = const Color(0xFF6B7280); // Dark Gray

    if (s.contains('REVISION')) {
      s = 'REVISION';
      bgColor = const Color(0xFFFEF3C7); // Light Amber/Orange
      textColor = const Color(0xFFD97706); // Dark Orange
    } else if (s.contains('APPROVE')) {
      s = 'APPROVE';
      bgColor = const Color(0xFFD1FAE5); // Light Green
      textColor = const Color(0xFF059669); // Dark Green
    } else if (s.contains('DECLINE')) {
      s = 'DECLINE';
      bgColor = const Color(0xFFFEE2E2); // Light Red
      textColor = const Color(0xFFDC2626); // Dark Red
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          s,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

class _Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  const _Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  List<int> get _pages {
    if (totalPages <= 5) return List.generate(totalPages, (i) => i + 1);
    final r = <int>[1];
    if (currentPage > 3) r.add(-1);
    for (var i = currentPage - 1; i <= currentPage + 1; i++) {
      if (i > 1 && i < totalPages) r.add(i);
    }
    if (currentPage < totalPages - 2) r.add(-1);
    r.add(totalPages);
    return r;
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _PBtn(
        child: const Icon(
          Icons.chevron_left,
          size: 13,
          color: Color(0xFF6B7280),
        ),
        onTap: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
      ),
      const SizedBox(width: 3),
      ..._pages.map((p) {
        if (p == -1) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              '…',
              style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
            ),
          );
        }
        final active = p == currentPage;
        return Padding(
          padding: const EdgeInsets.only(right: 3),
          child: _PBtn(
            isActive: active,
            onTap: () => onPageChanged(p),
            child: Text(
              '$p',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ),
        );
      }),
      _PBtn(
        child: const Icon(
          Icons.chevron_right,
          size: 13,
          color: Color(0xFF6B7280),
        ),
        onTap: currentPage < totalPages
            ? () => onPageChanged(currentPage + 1)
            : null,
      ),
    ],
  );
}

class _PBtn extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final VoidCallback? onTap;
  const _PBtn({required this.child, this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2D9E6B) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isActive ? const Color(0xFF2D9E6B) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Center(child: child),
    ),
  );
}
