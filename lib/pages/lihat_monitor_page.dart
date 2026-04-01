import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_theme.dart';
import '../service/survey_service.dart';
import '../models/survey_response_detail_model.dart';

class LihatMonitorPage extends StatefulWidget {
  final int responseId;
  final String surveySlug;
  final String clientSlug;
  final String projectSlug;

  const LihatMonitorPage({
    super.key,
    required this.responseId,
    required this.surveySlug,
    required this.clientSlug,
    required this.projectSlug,
  });

  @override
  State<LihatMonitorPage> createState() => _LihatMonitorPageState();
}

class _LihatMonitorPageState extends State<LihatMonitorPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  SurveyResponseDetail? _detail;

  late String _timelineStart;
  late String _timelineFinish;
  late String _timelineDuration;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _timelineStart = '-';
    _timelineFinish = '-';
    _timelineDuration = '-';
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await SurveyService().getSurveyResponseDetail(
        widget.clientSlug,
        widget.projectSlug,
        widget.surveySlug,
        widget.responseId,
      );

      if (detail != null) {
        _calculateTimeline(detail);
        setState(() {
          _detail = detail;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Data tidak ditemukan.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal memuat data: $e";
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.monBgColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.monGreenMid,
                    ),
                  )
                : _errorMessage != null
                ? _buildErrorUI()
                : FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRespondentInfo(),
                            const SizedBox(height: 24),
                            ..._buildQuestionsList(),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.monGreenDark, AppTheme.monGreenMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const Text(
                'Monitor Detail',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 34), // For balance
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Detail Responden Survey",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Analisis data responden terdaftar, campaign, dan guest",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(_errorMessage ?? "Terjadi kesalahan"),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchData, child: const Text("Coba Lagi")),
        ],
      ),
    );
  }

  Widget _buildRespondentInfo() {
    final responses = _detail?.responses;
    final location = _detail?.location;
    final userData = responses?['user'] as Map<String, dynamic>?;
    final biodata = _detail?.biodata;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: INFORMASI DASAR & LOKASI
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.monBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: AppTheme.monGreenMid,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "INFORMASI DASAR & LOKASI",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: AppTheme.monTextMid,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT COLUMN
                    Expanded(
                      flex: 1,
                      child: _buildLeftInfoColumn(
                        userData,
                        biodata,
                        _timelineStart,
                        _timelineFinish,
                        _timelineDuration,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 400,
                      color: const Color(0xFFF0F0F0),
                    ),
                    // RIGHT COLUMN
                    Expanded(
                      flex: 1,
                      child: _buildRightGeotaggingColumn(location),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildLeftInfoColumn(
                      userData,
                      biodata,
                      _timelineStart,
                      _timelineFinish,
                      _timelineDuration,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF0F0F0),
                    ),
                    _buildRightGeotaggingColumn(location),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeftInfoColumn(
    Map<String, dynamic>? userData,
    Map<String, dynamic>? biodata,
    dynamic start,
    dynamic finish,
    dynamic duration,
  ) {
    final name = userData?['name'] ?? _detail?.responses?['email'] ?? 'Guest';
    final province = _getProvinsi(biodata);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Profile Info
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF3F51B5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    name.toString().isNotEmpty
                        ? name.toString()[0].toUpperCase()
                        : 'G',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.monTextDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Instansi tidak tersedia",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.monTextLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Province Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBEDFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.public,
                            size: 14,
                            color: Color(0xFF3F51B5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            province == '-' ? "Tidak ada provinsi" : province,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3F51B5),
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

        const Divider(height: 1, thickness: 1, color: Color(0xFFF8F8F8)),

        // Address Section
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "ALAMAT",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.monTextLight,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.home_outlined,
                      size: 20,
                      color: AppTheme.monTextMid,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "Alamat tidak tersedia",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.monTextDark,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        _buildTimelineFooter(
          _timelineStart,
          _timelineFinish,
          _timelineDuration,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String label,
    String value,
    Color color, {
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppTheme.monTextLight,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (icon != null)
              Icon(icon, size: 14, color: color)
            else
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            const SizedBox(width: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineFooter(String start, String finish, String durasi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimelineItem("MULAI", start, Colors.green),
          _buildTimelineItem("SELESAI", finish, Colors.blue),
          _buildTimelineItem(
            "DURASI",
            durasi,
            Colors.orange,
            icon: Icons.access_time_rounded,
          ),
        ],
      ),
    );
  }

  void _calculateTimeline(SurveyResponseDetail detail) {
    final responses = detail.responses;
    final startRaw =
        responses?['started_at'] ??
        responses?['created_at'] ??
        detail.editedAt?.toString();
    final finishRaw =
        responses?['finished_at'] ??
        responses?['updated_at'] ??
        detail.editedAt?.toString();

    String formatTime(String? raw) {
      if (raw == null || raw.isEmpty) return '-';
      try {
        final dt = DateTime.parse(raw);
        final monthNames = [
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
        return '${dt.day.toString().padLeft(2, '0')} ${monthNames[dt.month]} ${dt.year}\n${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        return '-';
      }
    }

    String calcDuration(String? start, String? finish) {
      if (start == null || finish == null || start.isEmpty || finish.isEmpty)
        return '-';
      try {
        final s = DateTime.parse(start);
        final f = DateTime.parse(finish);
        final diff = f.difference(s);
        final h = diff.inHours;
        final m = diff.inMinutes.remainder(60);
        if (h > 0) return '${h}j ${m}m';
        return '${m}m';
      } catch (_) {
        return '-';
      }
    }

    _timelineStart = formatTime(startRaw);
    _timelineFinish = formatTime(finishRaw);
    _timelineDuration = calcDuration(startRaw, finishRaw);
  }

  Widget _buildRightGeotaggingColumn(Map<String, dynamic>? location) {
    final ip = location?['ip']?.toString() ?? '-';
    final wilayah = _getWilayah(location);
    final lat = location?['latitude']?.toString() ?? '-';
    final lng = location?['longitude']?.toString() ?? '-';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Geotagging Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppTheme.monGreenMid,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Geotagging",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.monTextDark,
                    ),
                  ),
                ],
              ),
              // GPS Aktif Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "GPS Aktif",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Detail Rows
          LayoutBuilder(
            builder: (context, constraints) {
              final isVeryWide = constraints.maxWidth > 350;
              if (isVeryWide) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildGeoItem(
                            "IP ADDRESS",
                            ip,
                            Icons.language_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildGeoItem(
                            "KOTA / WILAYAH",
                            wilayah,
                            Icons.location_city_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildCoordinateRow(lat, lng),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildGeoItem("IP ADDRESS", ip, Icons.language_rounded),
                    const SizedBox(height: 16),
                    _buildGeoItem(
                      "KOTA / WILAYAH",
                      wilayah,
                      Icons.location_city_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildCoordinateRow(lat, lng),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 24),
          _buildEnhancedMapPreview(location),
        ],
      ),
    );
  }

  Widget _buildGeoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppTheme.monTextLight,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 14, color: AppTheme.monTextLight),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.monTextDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoordinateRow(String lat, String lng) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "KOORDINAT",
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppTheme.monTextLight,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.map_outlined,
                size: 16,
                color: AppTheme.monTextLight,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "$lat, $lng",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.monTextDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final url = 'https://www.google.com/maps?q=$lat,$lng';
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 12,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Maps",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedMapPreview(Map<String, dynamic>? location) {
    final lat = double.tryParse(location?['latitude']?.toString() ?? '');
    final lng = double.tryParse(location?['longitude']?.toString() ?? '');

    if (lat == null || lng == null) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off_outlined,
                color: AppTheme.monTextLight,
                size: 32,
              ),
              SizedBox(height: 12),
              Text(
                "Peta tidak tersedia",
                style: TextStyle(color: AppTheme.monTextLight, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(lat, lng),
            initialZoom: 14,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flutter_application_wdu',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(lat, lng),
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getWilayah(Map<String, dynamic>? location) {
    if (location == null) return '-';
    final city = location['city'];
    final region = location['region'];
    if (city != null &&
        city.toString().isNotEmpty &&
        region != null &&
        region.toString().isNotEmpty) {
      return '$city, $region';
    }
    if (city != null && city.toString().isNotEmpty) return city.toString();
    if (region != null && region.toString().isNotEmpty)
      return region.toString();
    return 'Unknown';
  }

  String _getProvinsi(Map<String, dynamic>? biodata) {
    if (biodata == null) return '-';
    final id = biodata['province_id'];
    final name = biodata['province_name'];
    if (name != null && name.toString().isNotEmpty) return name.toString();
    if (id != null) return 'Prov. $id';
    return '-';
  }

  List<Widget> _buildQuestionsList() {
    if (_detail == null) return [];

    final answersMap = {for (var a in _detail!.answers) a.questionId: a.answer};

    List<Widget> list = [];

    for (var page in _detail!.pages) {
      list.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Text(
            page.pageName.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );

      for (var q in page.questions) {
        final answer = answersMap[q.id] ?? "-";
        list.add(_buildQuestionCard(q, answer));
        list.add(const SizedBox(height: 12));
      }
    }

    return list;
  }

  Widget _buildQuestionCard(SurveyQuestionData q, String answer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q.plainText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.monBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.reply, size: 14, color: AppTheme.monGreenMid),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    answer.isEmpty ? "-" : answer,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.monGreenDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
