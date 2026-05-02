import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../providers/font_size_provider.dart';
import '../widgets/dashboard_surveys/client_card.dart';
import '../widgets/dashboard_surveys/project_card.dart';
import 'login_page.dart';
import 'settings_page.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/ringing_bell_icon.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider()..init(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    final provider = context.read<DashboardProvider>();

    if (!provider.loading) {
      _animController.forward();
    } else {
      provider.addListener(_onLoadingDone);
    }
  }

  void _onLoadingDone() {
    final provider = context.read<DashboardProvider>();
    if (!provider.loading) {
      _animController.forward();
      provider.removeListener(_onLoadingDone);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    if (provider.loading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: RefreshIndicator(
          onRefresh: () => provider.init(),
          color: AppTheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildAppBar(),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 12),

                    // 🔥 PROJECT LIST (FIX animDelay)
                    if (provider.filteredProjects.isNotEmpty)
                      ...provider.filteredProjects.asMap().entries.map((entry) {
                        final i = entry.key;
                        final project = entry.value;

                        return ProjectCard(
                          project: project,
                          animDelay: Duration(milliseconds: 100 + i * 150),
                        );
                      }),

                    /*
                    const SizedBox(height: 20),

                    // 🔥 CLIENT SECTION
                    _ClientsSection(provider: provider),
                    */
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppTheme.surface.withOpacity(0.8),
      automaticallyImplyLeading: false,
      pinned: true,
      expandedHeight: 80,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            title: Row(
              children: [
                Image.asset(
                  'assets/icon/SIS-WDU-app-logo.png',
                  height: 32,
                  errorBuilder: (_, __, ___) => const Text('SIS-WDU'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        _buildFontSizeButton(context),
        const RingingBellIcon(),
        _buildSettingsButton(context),
      ],
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.settings_rounded, color: AppTheme.primary),
      tooltip: 'Settings',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsPage()),
        );
      },
    );
  }

  Widget _buildFontSizeButton(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, provider, _) {
        return IconButton(
          icon: Icon(Icons.format_size_rounded, color: AppTheme.primary),
          tooltip: 'Ukuran Font',
          onPressed: () => _showFontSizeDialog(context),
        );
      },
    );
  }

  void _showFontSizeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer<FontSizeProvider>(
          builder: (context, provider, _) {
            return Container(
              decoration: const BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 20),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.format_size_rounded,
                            color: AppTheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ukuran Teks',
                                style: GoogleFonts.manrope(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sesuaikan kenyamanan membaca Anda',
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildFontSizeOption(context, provider, 'Kecil', 0.85, 'A', 14),
                        const SizedBox(height: 10),
                        _buildFontSizeOption(context, provider, 'Normal', 1.0, 'A', 18),
                        const SizedBox(height: 10),
                        _buildFontSizeOption(context, provider, 'Besar', 1.2, 'A', 22),
                        const SizedBox(height: 10),
                        _buildFontSizeOption(context, provider, 'Sangat Besar', 1.4, 'A', 26),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFontSizeOption(
    BuildContext context,
    FontSizeProvider provider,
    String label,
    double scale,
    String iconLabel,
    double iconSize,
  ) {
    final isSelected = provider.fontSizeScale == scale;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primary.withValues(alpha: 0.1)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppTheme.primary
              : AppTheme.outlineVariant.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            provider.setFontSizeScale(scale);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Text preview icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    iconLabel,
                    style: GoogleFonts.manrope(
                      fontSize: iconSize,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Label
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? AppTheme.primary : AppTheme.onSurface,
                    ),
                  ),
                ),
                // Checkmark
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.primary,
                    size: 26,
                  )
                else
                  const Icon(
                    Icons.circle_outlined,
                    color: AppTheme.outline,
                    size: 26,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= CLIENT SECTION =================

class _ClientsSection extends StatelessWidget {
  final DashboardProvider provider;

  const _ClientsSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clients',
          style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800),
        ),

        const SizedBox(height: 12),

        // 🔥 SEARCH BAR
        TextField(
          onChanged: provider.updateSearch,
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Search clients or projects...',
            hintStyle: GoogleFonts.inter(
              color: AppTheme.outline.withOpacity(0.8),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppTheme.outline,
              size: 20,
            ),
            filled: true,
            fillColor: AppTheme.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.outlineVariant.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.outlineVariant.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 🔥 GRID FIX OVERFLOW DI SINI
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.filteredClients.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 255,
          ),
          itemBuilder: (context, index) {
            return ClientCard(client: provider.filteredClients[index]);
          },
        ),
      ],
    );
  }
}
