import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/profile_validators.dart';
import '../../../sports/data/models/sport_model.dart';
import '../../../sports/data/repositories/sports_repository.dart';
import '../../data/models/coach_onboarding_draft.dart';
import 'coach_days_screen.dart';

class CoachSpecialtiesScreen extends StatefulWidget {
  final CoachOnboardingDraft draft;

  const CoachSpecialtiesScreen({required this.draft, super.key});

  @override
  State<CoachSpecialtiesScreen> createState() => _CoachSpecialtiesScreenState();
}

class _CoachSpecialtiesScreenState extends State<CoachSpecialtiesScreen> {
  final SportsRepository _sportsRepository = SportsRepository();

  late final TextEditingController _bioController;
  late final Future<List<SportModel>> _sportsFuture;
  String? _selectedSpecialty;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.draft.bio ?? '');
    _sportsFuture = _sportsRepository.getSports();
    _selectedSpecialty = widget.draft.selectedSports.isNotEmpty
        ? widget.draft.selectedSports.first
        : null;
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _toggleSpecialty(String sport) {
    setState(() {
      _selectedSpecialty = _selectedSpecialty == sport ? null : sport;
    });
  }

  void _handleContinue() {
    if (_selectedSpecialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose your specified sport')),
      );
      return;
    }

    final bio = _bioController.text.trim();
    if (bio.isNotEmpty && !ProfileValidators.hasMinimumBioWords(bio)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bio is optional, but if added it must contain at least 20 words.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final nextDraft = widget.draft.copyWith(
      selectedSports: [_selectedSpecialty!],
      bio: bio,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CoachDaysScreen(draft: nextDraft),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressIndicator(currentStep: 2),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSpecialtiesSection(),
                    const SizedBox(height: 32),
                    _buildBioSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F3A93), Color(0xFF6FD3F5)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const Expanded(
              child: Text(
                'Become a coach',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator({required int currentStep}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index < currentStep;
          return Expanded(
            child: Container(
              height: 6,
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryBlue
                    : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSpecialtiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your specialties',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose your specified sport.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<SportModel>>(
          future: _sportsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final sports =
                snapshot.data?.map((sport) => sport.name).toList() ??
                <String>[];

            if (sports.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No sports are available right now.'),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: sports.length,
              itemBuilder: (context, index) {
                final sport = sports[index];
                return _buildSportButton(sport, _selectedSpecialty == sport);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSportButton(String sport, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleSpecialty(sport),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : AppColors.disabledGray,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              sport,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bio / About You',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: TextField(
            controller: _bioController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText:
                  'Tell clients about your coaching style and experience...',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
            ),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleContinue,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF1B2B83), Color(0xFF304CE9)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Center(
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
