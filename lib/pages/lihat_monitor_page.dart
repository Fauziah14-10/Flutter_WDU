import 'package:flutter/material.dart';
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

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
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
                    child: CircularProgressIndicator(color: AppTheme.monGreenMid),
                  )
                : _errorMessage != null
                    ? _buildErrorUI()
                    : FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
          ElevatedButton(
            onPressed: _fetchData,
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

  Widget _buildRespondentInfo() {
    // Cari info dari survey/client? Endpoint report biasanya tidak eksplisit kasih biodata responden di top level
    // tapi kita bisa coba ambil dari data yang ada di _detail atau asumsikan context dari navigation
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.monGreenMid, size: 18),
              const SizedBox(width: 8),
              const Text(
                "Informasi Respon",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const Divider(height: 24),
          _infoRow("Survey", _detail?.survey?.title ?? widget.surveySlug),
          _infoRow("Waktu Edit", _detail?.editedAt?.toString() ?? "-"),
          _infoRow("Response ID", widget.responseId.toString()),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildQuestionsList() {
    if (_detail == null) return [];

    final answersMap = {
      for (var a in _detail!.answers) a.questionId: a.answer
    };

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
