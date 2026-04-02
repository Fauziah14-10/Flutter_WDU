import 'package:flutter/material.dart';
import '../../models/survey_model.dart';
import '../../pages/monitor_survey_page.dart';
import '../../pages/province_target_page.dart';
import '../../pages/cek_edit_survey_page.dart';
import '../../service/edit_answer_service.dart';

class ViewSurveyCard extends StatefulWidget {
  final SurveyModel survey;
  final String clientSlug;
  final String projectSlug;
  final int userId;
  final VoidCallback onRefresh;
  final VoidCallback onDelete;
  final VoidCallback onTapResponden;
  final VoidCallback onCekEdit;

  const ViewSurveyCard({
    super.key,
    required this.survey,
    required this.clientSlug,
    required this.projectSlug,
    required this.userId,
    required this.onRefresh,
    required this.onDelete,
    required this.onTapResponden,
    required this.onCekEdit,
  });

  @override
  State<ViewSurveyCard> createState() => _ViewSurveyCardState();
}

class _ViewSurveyCardState extends State<ViewSurveyCard> {
  final EditAnswerService _editService = EditAnswerService();
  bool _hasResponded = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkUserResponse();
  }

  Future<void> _checkUserResponse() async {
    if (widget.userId == 0) {
      setState(() => _isChecking = false);
      return;
    }

    try {
      final hasResponded = await _editService.checkUserHasResponded(
        clientSlug: widget.clientSlug,
        projectSlug: widget.projectSlug,
        surveySlug: widget.survey.slug,
        userId: widget.userId,
      );
      if (mounted) {
        setState(() {
          _hasResponded = hasResponded;
          _isChecking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOpen = widget.survey.isOpen;

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.survey.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: widget.onTapResponden,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bar_chart_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.survey.responseCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (widget.survey.desc != null && widget.survey.desc!.isNotEmpty)
              Text(
                widget.survey.desc!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF777777),
                  height: 1.4,
                ),
              ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Color(0xFFAAAAAA),
                ),
                const SizedBox(width: 4),
                if (widget.survey.provinceTargets.isEmpty)
                  Expanded(
                    child: Text(
                      widget.survey.targetLocation,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        : const Color(0xFFEF5350).withOpacity(0.1),
                    border: Border.all(
                      color: isOpen
                          ? const Color(0xFF4CAF50).withOpacity(0.4)
                          : const Color(0xFFEF5350).withOpacity(0.4),
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
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
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isOpen
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFB71C1C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (widget.survey.provinceTargets.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(Icons.location_on, color: Color(0xFF4CAF50), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'TARGET PROVINCES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: RouteSettings(
                      name: '/province_target',
                      arguments: {
                        'surveyName': widget.survey.title,
                        'provinces': widget.survey.provinceTargets
                            .map((p) => p.toJson())
                            .toList(),
                      },
                    ),
                    builder: (_) => ProvinceTargetPage(
                      surveyName: widget.survey.title,
                      provinces: widget.survey.provinceTargets,
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'All Provinces',
                        style: TextStyle(fontSize: 13),
                      ),
                      const Spacer(),
                      Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _isChecking
                      ? Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : _ActionBtn(
                          label: _hasResponded
                              ? 'Cek / Edit Kuisioner'
                              : 'Isi Kuisioner',
                          color: const Color(0xFF4CAF50),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                settings: RouteSettings(
                                  name: '/cek_edit_survey',
                                  arguments: {
                                    'surveySlug': widget.survey.slug,
                                    'clientSlug': widget.clientSlug,
                                    'projectSlug': widget.projectSlug,
                                    'responseId': 0,
                                  },
                                ),
                                builder: (_) => CekEditSurveyPage(
                                  surveySlug: widget.survey.slug,
                                  clientSlug: widget.clientSlug,
                                  projectSlug: widget.projectSlug,
                                  responseId: 0,
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _ActionBtn(
                    label: 'Monitor',
                    color: const Color(0xFF5C6BC0),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: RouteSettings(
                          name: '/monitoring',
                          arguments: {
                            'surveyName': widget.survey.title,
                            'clientSlug': widget.clientSlug,
                            'projectSlug': widget.projectSlug,
                            'surveySlug': widget.survey.slug,
                            'totalRespon': widget.survey.responseCount,
                            'targetLocation': widget.survey.targetLocation,
                            'isOpen': widget.survey.isOpen,
                          },
                        ),
                        builder: (_) => MonitoringSurveyPage(
                          surveyName: widget.survey.title,
                          clientSlug: widget.clientSlug,
                          projectSlug: widget.projectSlug,
                          surveySlug: widget.survey.slug,
                          totalRespon: widget.survey.responseCount,
                          targetLocation: widget.survey.targetLocation,
                          isOpen: widget.survey.isOpen,
                        ),
                      ),
                    ),
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

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 38,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    ),
  );
}
