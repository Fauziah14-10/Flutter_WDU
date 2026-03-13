import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../models/project_model.dart';
import '../core/theme/app_theme.dart';
import '../widgets/project_list/project_client_card.dart';
import '../widgets/project_list/projects_section.dart';

class ProjectListPage extends StatefulWidget {
  final Client client;

  const ProjectListPage({super.key, required this.client});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Project> get _projects => widget.client.projects ?? [];

  List<Project> get _filtered => _projects
      .where(
        (p) => p.projectName.toLowerCase().contains(_searchQuery.toLowerCase()),
      )
      .toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: AppTheme.textDark),
        title: const Text(
          'Detail Klien',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          ClientCard(client: widget.client),
          const SizedBox(height: 24),
          ProjectsSection(
            searchController: _searchController,
            searchQuery:      _searchQuery,
            onSearch:         (v) => setState(() => _searchQuery = v),
            projects:         _filtered,
            client:           widget.client,
          ),
        ],
      ),
    );
  }
}