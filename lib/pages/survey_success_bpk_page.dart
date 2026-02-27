import 'package:flutter/material.dart';


class SurveySuccessBpkPage extends StatelessWidget {
  const SurveySuccessBpkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              "Survey Berhasil Disubmit",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("Kembali ke Halaman Awal"),
            ),
          ],
        ),
      ),
    );
  }
}
