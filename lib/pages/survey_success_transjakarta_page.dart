import 'package:flutter/material.dart';


class SurveySuccessTransjakartaPage extends StatelessWidget {
  const SurveySuccessTransjakartaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              SizedBox(height: 20),
              Text(
                "Survey Berhasil Dikirim!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Terima kasih sudah mengisi survey Transjakarta.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}