import 'package:flutter/material.dart';

class MonitoringSurveyPage extends StatefulWidget {
  final String surveyName;
  final String clientSlug;
  final String projectSlug;
  final String surveySlug;
  final int totalRespon;
  final String targetLocation;
  final bool isOpen;

  const MonitoringSurveyPage({
    super.key,
    required this.surveyName,
    required this.clientSlug,
    required this.projectSlug,
    required this.surveySlug,
    this.totalRespon = 0,
    this.targetLocation = '-',
    this.isOpen = true,
  });

  @override
  State<MonitoringSurveyPage> createState() => _MonitoringSurveyPageState();
}

class _MonitoringSurveyPageState extends State<MonitoringSurveyPage>
    with SingleTickerProviderStateMixin {
  //int _selectedNavIndex = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color greenDark   = Color(0xFF2D7A3A);
  static const Color greenMid    = Color(0xFF3A9E4F);
  static const Color greenLight  = Color(0xFF5DBB6E);
  static const Color greenPale   = Color(0xFFE8F5EA);
  static const Color bgColor     = Color(0xFFF0F4F1);
  static const Color textDark    = Color(0xFF1A2E1C);
  static const Color textMid     = Color(0xFF4A6350);
  static const Color textLight   = Color(0xFF8AAB8F);
  static const Color borderColor = Color(0xFFD4E8D7);

  // progress tidak bisa dihitung karena target angka tidak tersedia di model

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildStatsRow(),
                      const SizedBox(height: 12),
                      _buildProgressCard(),
                      const SizedBox(height: 12),
                      _buildWilayahCard(),
                      const SizedBox(height: 18),
                      _buildListResponSection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [greenDark, greenMid, greenLight],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: -30, right: -30,
              child: Container(
                width: 150, height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -40, left: -20,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // ← Tombol back
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: _circleIconBtn(Icons.arrow_back_ios_new_rounded),
                      ),
                      const Spacer(),
                      _statusBadge(),
                      const Spacer(),
                      _circleIconBtn(Icons.more_vert_rounded),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'MONITORING SURVEY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white60,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.surveyName.isNotEmpty
                        ? widget.surveyName
                        : 'Monitoring Survey',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.35,
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

  Widget _circleIconBtn(IconData icon) {
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.18),
      ),
      child: Icon(icon, color: Colors.white, size: 17),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseDot(active: widget.isOpen),
          const SizedBox(width: 6),
          Text(
            widget.isOpen ? 'DIBUKA' : 'DITUTUP',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── STATS ROW ────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.bar_chart_rounded,
              iconBg: greenPale,
              iconColor: greenMid,
              label: 'Total Respon',
              value: '${widget.totalRespon}',
              sub: 'Responden masuk',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.location_on_rounded,
              iconBg: const Color(0xFFE8F0FF),
              iconColor: const Color(0xFF4A6FD4),
              label: 'Lokasi Target',
              value: '📍',
              sub: widget.targetLocation.isNotEmpty
                  ? widget.targetLocation
                  : 'Tidak ada lokasi',
            ),
          ),
        ],
      ),
    );
  }

  // ─── PROGRESS CARD ────────────────────────────────────────
  Widget _buildProgressCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: greenMid.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progress Respon',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: greenPale,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '0%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: greenMid,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 0,
                minHeight: 8,
                backgroundColor: greenPale,
                valueColor: const AlwaysStoppedAnimation<Color>(greenMid),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.totalRespon} respon masuk',
                  style: const TextStyle(fontSize: 11, color: textLight),
                ),
                const Text(
                  'Target belum diset',
                  style: TextStyle(fontSize: 11, color: textLight),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── CAKUPAN WILAYAH ──────────────────────────────────────
  Widget _buildWilayahCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to Cakupan Wilayah page
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: greenMid.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: greenPale,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on_rounded,
                    color: greenMid, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cakupan Wilayah',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Lihat distribusi wilayah',
                      style: TextStyle(fontSize: 11, color: textLight),
                    ),
                  ],
                ),
              ),
              Container(
                width: 30, height: 30,
                decoration: const BoxDecoration(
                  color: greenPale,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_right_rounded,
                    color: greenMid, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── LIST RESPON ──────────────────────────────────────────
  Widget _buildListResponSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.list_alt_rounded, color: greenMid, size: 18),
                  SizedBox(width: 7),
                  Text(
                    'List Respon',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: const Text(
                  '0 data',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: 68, height: 68,
            decoration: const BoxDecoration(
              color: greenPale,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_rounded, color: greenMid, size: 32),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum Ada Data',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textMid,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Data respon akan muncul di sini\nsetelah terhubung ke database',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: textLight, height: 1.5),
          ),
        ],
      ),
    );
  }
    }

 

// ─── STAT CARD ────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final String sub;

  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4E8D7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A9E4F).withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8AAB8F),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2E1C),
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            sub,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF8AAB8F),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PULSE DOT ────────────────────────────────────────────────
class _PulseDot extends StatefulWidget {
  final bool active;
  const _PulseDot({this.active = true});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 1.0, end: 0.3).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7, height: 7,
        decoration: BoxDecoration(
          color: widget.active
              ? const Color(0xFF7EFFA0)
              : const Color(0xFFFF7E7E),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}