import 'package:flutter/material.dart';
import 'survey_success_bpk_page.dart';


class CekEditSurveyBpkPage extends StatefulWidget {
  final String surveyId;
  final String clientSlug;
  final String projectSlug;

  const CekEditSurveyBpkPage({
    super.key,
    required this.surveyId,
    required this.clientSlug,
    required this.projectSlug,
  });
    
  @override
  State<CekEditSurveyBpkPage> createState() => _CekEditSurveyPageState();
}

class _CekEditSurveyPageState extends State<CekEditSurveyBpkPage> {
  String? pilihanRadio1;
  String? pilihanRadio2;
  String? pilihanDropdown;
  List<String> checklist = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cek / Edit Survey"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Title1",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// RADIO BUTTON 1
            const Text("showing if choosing b"),

            RadioListTile<String>(
              value: "a",
              groupValue: pilihanRadio1,
              onChanged: (val) {
                setState(() {
                  pilihanRadio1 = val;
                });
              },
              title: const Text("a"),
            ),

            RadioListTile<String>(
              value: "b",
              groupValue: pilihanRadio1,
              onChanged: (val) {
                setState(() {
                  pilihanRadio1 = val;
                });
              },
              title: const Text("b"),
            ),

            const SizedBox(height: 16),

            /// DROPDOWN
            const Text("cinta"),
            const SizedBox(height: 6),

            DropdownButtonFormField<String>(
              value: pilihanDropdown,
              items: const [
                DropdownMenuItem(value: "1", child: Text("Option 1")),
                DropdownMenuItem(value: "2", child: Text("Option 2")),
              ],
              onChanged: (val) {
                setState(() {
                  pilihanDropdown = val;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// RADIO BUTTON 2
            const Text("numba"),

            RadioListTile<String>(
              value: "heehe",
              groupValue: pilihanRadio2,
              onChanged: (val) {
                setState(() {
                  pilihanRadio2 = val;
                });
              },
              title: const Text("heehe"),
            ),

            RadioListTile<String>(
              value: "heeee",
              groupValue: pilihanRadio2,
              onChanged: (val) {
                setState(() {
                  pilihanRadio2 = val;
                });
              },
              title: const Text("heeee"),
            ),

            const SizedBox(height: 16),

            /// CHECKBOX
            const Text("( Pilihlah Minimal 1 pilihan )"),

            CheckboxListTile(
              value: checklist.contains("fuuc"),
              onChanged: (val) {
                setState(() {
                  val == true
                      ? checklist.add("fuuc")
                      : checklist.remove("fuuc");
                });
              },
              title: const Text("fuuc"),
            ),

            CheckboxListTile(
              value: checklist.contains("ha"),
              onChanged: (val) {
                setState(() {
                  val == true
                      ? checklist.add("ha")
                      : checklist.remove("ha");
                });
              },
              title: const Text("ha"),
            ),

            const SizedBox(height: 30),

            /// SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SurveySuccessBpkPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
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