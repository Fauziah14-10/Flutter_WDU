import 'package:flutter/material.dart';

// ── Palette (top-level constants) ────────────────────────────
const Color _bgColor      = Color(0xFFEDF5EC);
const Color _green50      = Color(0xFFE8F5E9);
const Color _green100     = Color(0xFFC8E6C9);
const Color _green600     = Color(0xFF388E3C);
const Color _green700     = Color(0xFF2E7D32);
const Color _iconBg       = Color(0xFF4CAF50);
const Color _textSub      = Color(0xFF6A9E6C);
const Color _inputBorder  = Color(0xFFCEE5CF);

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
  final _descController  = TextEditingController();

  bool publicToken  = false;
  bool surveyTarget = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Back Button ──────────────────────────────
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _green600,
                  side: const BorderSide(color: _green100, width: 1.5),
                  backgroundColor: Colors.white60,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Page Title ───────────────────────────────
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Create New Survey',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: _green700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Set up your survey with target locations and response goals',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: _textSub,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Form Card ────────────────────────────────
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 760),
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 800
                      ? (MediaQuery.of(context).size.width - 760) / 2 - 24
                      : 0,
                ),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Survey Title Field ───────────────
                    const _FieldLabel(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Survey Title',
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'Enter survey title',
                      maxLines: 1,
                    ),

                    const SizedBox(height: 22),

                    // ── Description Field ─────────────────
                    const _FieldLabel(
                      icon: Icons.description_outlined,
                      label: 'Description',
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _descController,
                      hint: 'Enter survey description',
                      maxLines: 5,
                    ),

                    const SizedBox(height: 28),

                    // ── Public Token Toggle ───────────────
                    _ToggleRow(
                      icon: Icons.language_rounded,
                      title: 'Public Token',
                      subtitle: 'Enable public survey access',
                      value: publicToken,
                      onChanged: (v) => setState(() => publicToken = v),
                    ),

                    const SizedBox(height: 4),
                    const Divider(color: _green50, thickness: 1.5),
                    const SizedBox(height: 4),

                    // ── Survey Target Toggle ──────────────
                    _ToggleRow(
                      icon: Icons.location_on_rounded,
                      title: 'Survey Target',
                      subtitle: 'Set a response target for this survey',
                      value: surveyTarget,
                      onChanged: (v) => setState(() => surveyTarget = v),
                    ),

                    const SizedBox(height: 28),
                    const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                    const SizedBox(height: 20),

                    // ── Action Buttons ────────────────────
                    Row(
                      children: [
                        _buildCancelBtn(),
                        const SizedBox(width: 10),
                        _buildClearBtn(),
                        const Spacer(),
                        _buildCreateBtn(),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── TextField ──────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1B5E20)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAACFAB), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFFAFDFA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _inputBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _green600, width: 1.8),
        ),
      ),
    );
  }

  // ── Cancel Button ──────────────────────────────────────────
  Widget _buildCancelBtn() {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF607D8B),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.arrow_back_rounded, size: 16),
      label: const Text(
        'Cancel',
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── Clear Form Button ──────────────────────────────────────
  Widget _buildClearBtn() {
    return ElevatedButton.icon(
      onPressed: () {
        _titleController.clear();
        _descController.clear();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFB8C00),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.delete_outline_rounded, size: 16),
      label: const Text(
        'Clear Form',
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── Create Survey Button ───────────────────────────────────
  Widget _buildCreateBtn() {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: CALL API CREATE SURVEY
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _green600,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.check_rounded, size: 16),
      label: const Text(
        'Create Survey',
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Field Label with Icon ─────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FieldLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFDEF2DF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: _green600),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _green600,
          ),
        ),
      ],
    );
  }
}

// ── Toggle Row ────────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _green600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8AAB8F),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Text(
              value ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: value ? _green600 : const Color(0xFFAAAAAA),
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: _iconBg,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFCCCCCC),
            ),
          ],
        ),
      ],
    );
  }
}