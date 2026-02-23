import 'package:flutter/material.dart';
import '../models/survey_model.dart';
import '../service/survey_service.dart';
import '../widgets/survey_card.dart';

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
  final SurveyService _service = SurveyService();

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
      final data = await _service.getSurveys(
        widget.clientSlug,
        widget.projectSlug,
      );

      setState(() {
        surveys = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectTitle),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : surveys.isEmpty
                  ? const Center(
                      child: Text("Tidak ada survey tersedia"),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchSurveys,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: surveys.length,
                        itemBuilder: (context, index) {
                          return SurveyCard(
                            survey: surveys[index],
                          );
                        },
                      ),
                    ),
     );
  }
}