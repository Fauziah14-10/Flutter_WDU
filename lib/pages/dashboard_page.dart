import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import 'list_survey_bpk.dart';
import 'list_survey_transjakarta.dart';
import 'project_tj_page.dart';

// ── Palette (top-level constants) ────────────────────────────
const Color sage50 = Color(0xFFF0FAF1);
const Color sage100 = Color(0xFFDDF2E0);
const Color sage200 = Color(0xFFB2E0BA);
const Color sage500 = Color(0xFF4CAF50);
const Color textDark = Color(0xFF1A2E1C);
const Color textMid = Color(0xFF4A6350);
const Color textLight = Color(0xFF8AAB8F);

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  final AuthService authService = AuthService();
  Map<String, dynamic>? user;
  bool loading = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  String _clientSearch = '';

  final List<Map<String, dynamic>> projects = [
    {
      'index': 1,
      'title': 'BPK 2026',
      'client': 'Badan Pemeriksa Keuangan',
      'description': 'Proyek BPK di tahun 2026',
      'time': '1 minggu yang lalu',
      'surveyCount': 4,
      'slug': 'bpk-20262026-01-19-145857',
      'client_slug': 'badan-pemeriksa-keuangan2026-01-19-145527',
    },
    {
      'index': 2,
      'title': 'Survei Pengukuran Capaian SPM',
      'client': 'TransJakarta',
      'description':
          'Survei Pengukuran Capaian SPM Penyelenggaraan PT Transportasi Jakarta Tahun 2026',
      'time': '2 minggu yang lalu',
      'surveyCount': 3,
      'slug':
          'survei-pengukuran-capaian-spm-penyelenggaraan-pt-transportasi-jakarta-tahun-20262026-01-05-140637',
      'client_slug': 'transjakarta2026-01-05-135904',
    },
  ];

  final List<Map<String, dynamic>> clients = [
    {
      'name': 'TransJakarta',
      'location':
          'Jalan Mayjen Sutoyo No. 1, Cawang, Kecamatan Makasar, Jakarta Timur, 13650',
      'description': 'PT Transportasi Jakarta',
      'image': 'assets/images/TJ.jpg',
      'slug': 'transjakarta2026-01-05-135904',
    },
    {
      'name': 'Badan Pemeriksa Keuangan',
      'location': 'Jl. Jenderal Gatot Subroto Kav. 31 Jakarta Pusat 10210',
      'description':
          'Badan Pemeriksa Keuangan (BPK) adalah lembaga negara yang bebas dan mandiri, bertugas memeriksa pengelolaan dan tanggung jawab keuangan negara.',
      'image': 'assets/images/BPK.jpg',
      'slug': 'badan-pemeriksa-keuangan2026-01-19-145527',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    loadUser();
  }

  void loadUser() async {
    user = await authService.getUser();
    setState(() => loading = false);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredClients {
    if (_clientSearch.isEmpty) return clients;
    return clients
        .where(
          (c) => c['name'].toString().toLowerCase().contains(
            _clientSearch.toLowerCase(),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: sage50,
        body: Center(child: CircularProgressIndicator(color: sage500)),
      );
    }

    return Scaffold(
      backgroundColor: sage50,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            slivers: [
              // ── App Bar ──────────────────────────────────────
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                pinned: true,
                expandedHeight: 0,
                leadingWidth: 200,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Image.asset(
                    'assets/images/SIS-WDU-logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        color: sage500,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'SIS',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                actions: const [],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(height: 1, color: sage100),
                ),
              ),

              // ── Body ─────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const _SectionHeader(
                      icon: Icons.folder_open_rounded,
                      title: 'Active Projects',
                      subtitle: 'Overview of latest projects',
                    ),
                    const SizedBox(height: 14),

                    ...projects.asMap().entries.map((entry) {
                      final i = entry.key;
                      final project = entry.value;
                      return _ProjectCard(
                        project: project,
                        animDelay: Duration(milliseconds: 100 + i * 150),
                        onViewSurveys: () {
                          if (project['client'] == 'Badan Pemeriksa Keuangan') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ListSurveyBPK(
                                  clientSlug: project['client_slug'],
                                  projectSlug: project['slug'],
                                  projectTitle: project['title'],
                                ),
                              ),
                            );
                          } else if (project['client'] == 'TransJakarta') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ListSurveyTransjakarta(
                                  clientSlug: project['client_slug'],
                                  projectSlug: project['slug'],
                                  projectTitle: project['title'],
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }),

                    const SizedBox(height: 6),

                    _ClientsSection(
                      clients: _filteredClients,
                      searchQuery: _clientSearch,
                      onSearchChanged: (val) =>
                          setState(() => _clientSearch = val),
                    ),

                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: sage100),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: sage500,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: textLight),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── Clients Section ──────────────────────────────────────────────────────────

class _ClientsSection extends StatelessWidget {
  final List<Map<String, dynamic>> clients;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const _ClientsSection({
    required this.clients,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: sage100),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: sage500,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clients',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Manage your client portfolio',
                          style: TextStyle(fontSize: 12, color: textLight),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: sage100,
                      foregroundColor: sage500,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: sage200),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text(
                      'Create',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: onSearchChanged,
                style: const TextStyle(fontSize: 13, color: textDark),
                decoration: InputDecoration(
                  hintText: 'Search clients...',
                  hintStyle: const TextStyle(color: sage200, fontSize: 13),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: textLight,
                    size: 18,
                  ),
                  filled: true,
                  fillColor: sage50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(color: sage100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(color: sage500, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (clients.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: sage100),
            ),
            child: const Column(
              children: [
                Icon(Icons.search_off_rounded, size: 36, color: sage200),
                SizedBox(height: 10),
                Text(
                  'No clients found',
                  style: TextStyle(fontSize: 13, color: textLight),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 4),
              itemCount: clients.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _ClientCard(client: clients[index]),
            ),
          ),
      ],
    );
  }
}

// ── Client Card ───────────────────────────────────────────────────────────────

class _ClientCard extends StatelessWidget {
  final Map<String, dynamic> client;

  const _ClientCard({required this.client});

  static const double cardWidth = 220;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardWidth,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sage100),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 96,
              width: double.infinity,
              child: client['image'] != null
                  ? Image.asset(
                      client['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _imagePlaceholder(client['name']),
                    )
                  : _imagePlaceholder(client['name']),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: sage500,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: textLight,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            client['location'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: textLight,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      client['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: textLight,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(height: 1, color: sage100),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionBtn(label: 'Profile', onTap: () {}),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _ActionBtn(
                      label: 'Projects',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ClientDetailPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  // ── More Button (fix: Material + InkWell) ──
                  Material(
                    color: sage50,
                    borderRadius: BorderRadius.circular(7),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(7),
                      onTap: () => _showClientOptions(context, client),
                      splashColor: sage200.withValues(alpha: 0.4),
                      highlightColor: sage100.withValues(alpha: 0.4),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: sage100),
                        ),
                        child: const Icon(
                          Icons.more_vert_rounded,
                          size: 16,
                          color: textLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(String name) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [sage100, sage200],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.business_rounded,
                size: 20,
                color: sage500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: const TextStyle(
                fontSize: 10,
                color: sage500,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showClientOptions(BuildContext context, Map<String, dynamic> client) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: sage100,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: sage500),
              title: const Text('Edit Client'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFE53935),
              ),
              title: const Text(
                'Delete Client',
                style: TextStyle(color: Color(0xFFE53935)),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Action Button (fix: Material + InkWell) ───────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: sage500,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Project Card ──────────────────────────────────────────────────────────────

class _ProjectCard extends StatefulWidget {
  final Map<String, dynamic> project;
  final Duration animDelay;
  final VoidCallback onViewSurveys;

  const _ProjectCard({
    required this.project,
    required this.animDelay,
    required this.onViewSurveys,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    Future.delayed(widget.animDelay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: sage100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['title'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: sage500,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  p['client'],
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: textMid,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: sage500,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${p['index']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                  child: Text(
                    p['description'],
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: textLight,
                      height: 1.5,
                    ),
                  ),
                ),
                Container(height: 1, color: sage100),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: sage200,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        p['time'],
                        style: const TextStyle(fontSize: 11.5, color: sage200),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sage100,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: sage200),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.assignment_outlined,
                              size: 12,
                              color: sage500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${p['surveyCount']} survei',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: sage500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.onViewSurveys,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sage500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text(
                        'View Surveys',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}