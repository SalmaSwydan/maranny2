import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/settings_repository.dart';

class SafetyModerationScreen extends StatefulWidget {
  final String userType;

  const SafetyModerationScreen({super.key, required this.userType});

  @override
  State<SafetyModerationScreen> createState() => _SafetyModerationScreenState();
}

class _SafetyModerationScreenState extends State<SafetyModerationScreen> {
  final SettingsRepository _repository = SettingsRepository();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedReason;
  bool _isSubmitting = false;

  bool get _isCoach => widget.userType.toLowerCase() == 'coach';

  List<String> get _reasons => _isCoach
      ? const [
          'No-show or repeated cancellations',
          'Inappropriate behavior',
          'Harassment',
          'Abusive language',
          'Fake booking or fraud',
          'Other',
        ]
      : const [
          'Fake or misleading profile',
          'Unprofessional conduct',
          'Inappropriate behavior',
          'Session not delivered',
          'Overcharging or payment issue',
          'Harassment',
          'Other',
        ];

  Future<void> _submitReport() async {
    final target = _targetController.text.trim();
    final details = _descriptionController.text.trim();
    if (target.isEmpty) {
      _showSnack(
        _isCoach
            ? 'Please enter the trainee name or email.'
            : 'Please enter the coach name, email, or listing.',
      );
      return;
    }
    if (_selectedReason == null) {
      _showSnack('Please choose a report reason.');
      return;
    }
    if (details.length < 10) {
      _showSnack('Please add at least 10 characters of details.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final message = await _repository.submitReport(
        target: target,
        reason: _selectedReason!,
        description: details,
        reportedType: _isCoach ? 'Client' : 'Coach',
      );
      if (!mounted) return;
      _targetController.clear();
      _descriptionController.clear();
      setState(() => _selectedReason = null);
      _showSuccess(message);
    } on DioException catch (error) {
      _showSnack(_friendlyError(error));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _friendlyError(DioException error) {
    final status = error.response?.statusCode;
    if (status == 401) {
      return 'Please log in again before submitting a report.';
    }
    if (status == 400) {
      return 'Please check the report details and try again.';
    }
    return 'Could not submit your report right now. Please try again.';
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF0FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.verified_user_rounded,
            color: AppColors.deepBlue,
          ),
        ),
        title: const Text(
          'Report submitted',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.deepBlue,
            fontWeight: FontWeight.w900,
            fontFamily: 'Poppins',
          ),
        ),
        content: Text(
          '$message\n\nOur moderation team will review it carefully.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _targetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [
            _buildTopBar(),
            const SizedBox(height: 22),
            _buildHero(),
            const SizedBox(height: 20),
            _buildInfoBanner(),
            const SizedBox(height: 18),
            _buildReportForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        _circleButton(
          Icons.arrow_back_ios_new_rounded,
          () => Navigator.pop(context),
        ),
        const Spacer(),
        _circleButton(Icons.shield_outlined, () {}),
      ],
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SAFETY CENTER',
          style: TextStyle(
            color: Color(0xFF91A0C0),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.4,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isCoach ? 'Report a concern.' : 'Keep sport safe.',
          style: const TextStyle(
            color: AppColors.deepBlue,
            fontSize: 34,
            height: 1,
            fontWeight: FontWeight.w900,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isCoach
              ? 'Tell us about trainee behavior, fake bookings, or platform issues.'
              : 'Report coaches, listings, sessions, or any unsafe experience.',
          style: const TextStyle(
            color: Color(0xFF657392),
            fontSize: 13,
            height: 1.45,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFDCA4)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFE89113)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Reports are confidential. Please include clear details so the moderation team can review the issue fairly.',
              style: TextStyle(
                color: Color(0xFF76501A),
                fontWeight: FontWeight.w700,
                height: 1.4,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFDDE7FA)),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isCoach ? 'Who are you reporting?' : 'What are you reporting?',
            style: const TextStyle(
              color: AppColors.deepBlue,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 14),
          _input(
            controller: _targetController,
            icon: Icons.person_search_rounded,
            hint: _isCoach
                ? 'Trainee name or email'
                : 'Coach name, email, or listing',
          ),
          const SizedBox(height: 18),
          const Text(
            'Reason',
            style: TextStyle(
              color: AppColors.deepBlue,
              fontWeight: FontWeight.w900,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _reasons.map(_reasonChip).toList(),
          ),
          const SizedBox(height: 18),
          _input(
            controller: _descriptionController,
            icon: Icons.edit_note_rounded,
            hint: 'Describe what happened, including dates or messages...',
            maxLines: 5,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitReport,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(_isSubmitting ? 'Submitting...' : 'Submit report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reasonChip(String reason) {
    final selected = _selectedReason == reason;
    return ChoiceChip(
      label: Text(reason),
      selected: selected,
      onSelected: (_) => setState(() => _selectedReason = reason),
      selectedColor: AppColors.deepBlue,
      backgroundColor: const Color(0xFFF3F7FF),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.deepBlue,
        fontWeight: FontWeight.w800,
        fontSize: 11,
        fontFamily: 'Inter',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: selected ? AppColors.deepBlue : const Color(0xFFDDE7FA),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        color: AppColors.deepBlue,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF8A96B5), size: 20),
        filled: true,
        fillColor: const Color(0xFFF3F7FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDDE7FA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.lightBlue, width: 1.4),
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppColors.deepBlue, size: 18),
        ),
      ),
    );
  }
}
