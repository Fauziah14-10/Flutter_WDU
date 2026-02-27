import 'package:flutter/material.dart';
import '/pages/survey_success_transjakarta_page.dart';

class CekEditTransjakartaPage extends StatefulWidget {
  final String surveyId;
  final String clientSlug;
  final String projectSlug;

  const CekEditTransjakartaPage({
    super.key,
    required this.surveyId,
    required this.clientSlug,
    required this.projectSlug,
  });

  @override
  State<CekEditTransjakartaPage> createState() =>
      _CekEditTransjakartaPageState();
}

class _CekEditTransjakartaPageState extends State<CekEditTransjakartaPage> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cek/Edit Survey Transjakarta"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "SURVEY KEPUASAN TRANSJAKARTA",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text("Where'd you find this?"),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Expanded(child: Center(child: Text("STS"))),
                      Expanded(child: Center(child: Text("TS"))),
                      Expanded(child: Center(child: Text("S"))),
                      Expanded(child: Center(child: Text("SS"))),
                    ],
                  ),

                  const Divider(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Radio<String>(
                          value: "STS",
                          groupValue: selectedValue,
                          onChanged: (value) =>
                              setState(() => selectedValue = value),
                        ),
                      ),
                      Expanded(
                        child: Radio<String>(
                          value: "TS",
                          groupValue: selectedValue,
                          onChanged: (value) =>
                              setState(() => selectedValue = value),
                        ),
                      ),
                      Expanded(
                        child: Radio<String>(
                          value: "S",
                          groupValue: selectedValue,
                          onChanged: (value) =>
                              setState(() => selectedValue = value),
                        ),
                      ),
                      Expanded(
                        child: Radio<String>(
                          value: "SS",
                          groupValue: selectedValue,
                          onChanged: (value) =>
                              setState(() => selectedValue = value),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (selectedValue == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Pilih salah satu jawaban dulu"),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SurveySuccessTransjakartaPage(),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Submit Survey",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}