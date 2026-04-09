import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/survey_model.dart';
import '../../pages/monitor_survey_page.dart';
import '../../pages/cek_edit_survey_page.dart';
import '../../pages/biodata_page.dart';
import '../../pages/camera_capture_page.dart';
import '../../pages/submission_page.dart';

class SurveyBentoCard extends StatelessWidget {
  final SurveyModel survey;
  final String clientSlug;
  final String projectSlug;
  final bool? hasAnswered;

  const SurveyBentoCard({
    super.key,
    required this.survey,
    required this.clientSlug,
    required this.projectSlug,
    this.hasAnswered,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.onSurface.withOpacity(0.08),
            blurRadius: 48,
            offset: const Offset(0, 24),
            spreadRadius: -12,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {}, // Optional: specific detail tap
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER: TITLE & BADGES ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            survey.title,
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.onSurface,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            survey.desc ??
                                'Evaluasi pemanfaatan infrastruktur digital nasional.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.onSurfaceVariant.withOpacity(0.7),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildResponseBadge(),
                        const SizedBox(height: 8),
                        _buildStatusBadge(),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── INFO ROW ──
                Row(
                  children: [
                    _infoEntry(
                      Icons.location_on_outlined,
                      survey.provinceTargets.isEmpty
                          ? 'Nasional'
                          : '${survey.provinceTargets.length} Provinsi',
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 16,
                      width: 1,
                      color: AppTheme.outlineVariant.withOpacity(0.2),
                    ),
                    const SizedBox(width: 12),
                    _infoEntry(Icons.calendar_today_rounded, 'Batch 1'),
                  ],
                ),
                const SizedBox(height: 24),

                // ── PROVINCES LIST ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TARGET PROVINCES',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'View all',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...survey.provinceTargets
                              .take(3)
                              .map((p) => _chip(p.name)),
                          if (survey.provinceTargets.length > 3)
                            _chip(
                              '+${survey.provinceTargets.length - 3} Others',
                            ),
                          if (survey.provinceTargets.isEmpty)
                            _chip('Nasional (All Provinces)', isSpecial: true),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 24),

                // ── ACTIONS ──
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        label: hasAnswered == true
                            ? 'Cek / Edit'
                            : 'Isi Kuisioner',
                        icon: Icons.edit_note_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF006A36), Color(0xFF71F69D)],
                        ),
                        onTap: () {
                          if (hasAnswered == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CekEditSurveyPage(
                                  surveySlug: survey.slug,
                                  clientSlug: clientSlug,
                                  projectSlug: projectSlug,
                                  responseId: 0,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BiodataPage(
                                  surveySlug: survey.slug,
                                  clientSlug: clientSlug,
                                  projectSlug: projectSlug,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionButton(
                        label: 'Monitor',
                        icon: Icons.analytics_rounded,
                        color: const Color(0xFF00656F),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MonitoringSurveyPage(
                                surveyName: survey.title,
                                clientSlug: clientSlug,
                                projectSlug: projectSlug,
                                surveySlug: survey.slug,
                                totalRespon: survey.responseCount,
                                targetLocation: survey.targetLocation,
                                isOpen: survey.isOpen,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponseBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.analytics_rounded,
            size: 14,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '${survey.responseCount}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final bool isActive = survey.isOpen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: (isActive ? AppTheme.primary : AppTheme.error).withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        isActive ? 'AKTIF' : 'DITUTUP',
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: isActive ? AppTheme.primary : AppTheme.error,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _infoEntry(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.onSurfaceVariant.withOpacity(0.6)),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceVariant.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, {bool isSpecial = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSpecial
            ? AppTheme.primary.withOpacity(0.05)
            : AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.outlineVariant.withOpacity(isSpecial ? 0.3 : 0.1),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: isSpecial ? FontWeight.w700 : FontWeight.w500,
          color: isSpecial ? AppTheme.primary : AppTheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    VoidCallback? onTap,
    Color? color,
    Gradient? gradient,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: (color ?? AppTheme.primary).withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
