import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/list_survey_page.dart'; // sesuaikan dengan nama file halaman survey kamu

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {

          case '/dashboard':
            return MaterialPageRoute(
              builder: (context) => const DashboardPage(),
            );

          case '/surveys':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => SurveyListPage(
                clientSlug: args['clientSlug'],
                projectSlug: args['projectSlug'],
                projectTitle: args['projectTitle'] ?? '',
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (context) => LoginPage(),
            );
        }
      },
    );
  }
}