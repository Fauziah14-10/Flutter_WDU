import 'package:flutter/material.dart';

class CreateSurveyPage extends StatefulWidget {
  final String clientSlug;
  final String projectSlug;

  const CreateSurveyPage({
    super.key,
    required this.clientSlug,
    required this.projectSlug,
  });

  @override
  State<CreateSurveyPage> createState() => _CreateSurveyPageState();
}

class _CreateSurveyPageState extends State<CreateSurveyPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  bool publicToken = false;
  bool surveyTarget = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create Survey",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 700,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.grey.withOpacity(0.15),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ───── Survey Title ─────
                const Text(
                  "Survey Title",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: "Enter survey title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ───── Description ─────
                const Text(
                  "Description",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Enter survey description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ───── Public Token ─────
                SwitchListTile(
                  value: publicToken,
                  activeColor: Colors.green,
                  title: const Text(
                    "Public Token",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32)),
                  ),
                  subtitle: const Text("Enable public survey access"),
                  onChanged: (val) {
                    setState(() {
                      publicToken = val;
                    });
                  },
                ),

                const SizedBox(height: 10),

                // ───── Survey Target ─────
                SwitchListTile(
                  value: surveyTarget,
                  activeColor: Colors.green,
                  title: const Text(
                    "Survey Target",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32)),
                  ),
                  onChanged: (val) {
                    setState(() {
                      surveyTarget = val;
                    });
                  },
                ),

                const SizedBox(height: 30),

                // ───── Buttons ─────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          onPressed: () {
                            _titleController.clear();
                            _descController.clear();
                          },
                          child: const Text("Clear Form"),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 14),
                      ),
                      onPressed: () {
                        // TODO: CALL API CREATE SURVEY
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Create Survey",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}