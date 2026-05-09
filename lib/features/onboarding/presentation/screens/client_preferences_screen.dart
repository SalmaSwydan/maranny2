import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/egypt_locations.dart';
import '../../../../core/utils/user_preferences_storage.dart';
import '../../../../layout/main_layout.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../profile/data/models/profile_models.dart';
import '../../../profile/data/repositories/profile_repository.dart';

class ClientPreferencesScreen extends StatefulWidget {
  final List<String> selectedSports;
  final String? pendingEmail;
  final bool returnToLoginAfterSave;

  const ClientPreferencesScreen({
    super.key,
    required this.selectedSports,
    this.pendingEmail,
    this.returnToLoginAfterSave = false,
  });

  @override
  State<ClientPreferencesScreen> createState() =>
      _ClientPreferencesScreenState();
}

class _ClientPreferencesScreenState extends State<ClientPreferencesScreen> {
  final ProfileRepository _profileRepository = ProfileRepository();

  double _minPrice = 100;
  double _maxPrice = 500;
  String? _ratingPreference;
  String? _locationPreference;
  String? _selectedCity;
  String? _selectedArea;
  String? _coachGender;
  String? _coachAgeRange;
  bool _certifiedOnly = false;
  bool _isSaving = false;

  bool get _hasPendingRegistration => widget.pendingEmail != null;

  bool get _canFinish =>
      widget.selectedSports.isNotEmpty &&
      _ratingPreference != null &&
      _locationPreference != null &&
      (_locationPreference != 'My city' || _selectedCity != null) &&
      _coachGender != null &&
      _coachAgeRange != null;

  List<String> get _areasForCity => EgyptLocations.areasForCity(_selectedCity);

  double? get _maxDistance {
    if (_locationPreference == 'Anywhere') return 100;
    if (_locationPreference == 'My city') return 25;
    return null;
  }

  Future<void> _finish() async {
    if (_isSaving) return;
    if (!_canFinish) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your preferences before continuing.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    String? remoteWarning;

    if (!_hasPendingRegistration) {
      try {
        await _profileRepository.updatePreferences(
          UpdatePreferencesRequest(
            sports: widget.selectedSports,
            budgetMin: _minPrice,
            budgetMax: _maxPrice,
            maxDistance: _maxDistance,
            city: _selectedCity,
            area: _selectedArea,
            locationPreference: _locationPreference,
            ratingPreference: _ratingPreference,
            coachGender: _coachGender,
            coachAgeRange: _coachAgeRange,
            certifiedOnly: _certifiedOnly,
          ),
        );
      } on DioException catch (e) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          remoteWarning = (data['error'] ?? data['message']) as String?;
        }
        remoteWarning ??= 'Preferences were saved on this device only.';
      } catch (_) {
        remoteWarning = 'Preferences were saved on this device only.';
      }
    }

    final pendingEmail = widget.pendingEmail;
    if (pendingEmail != null) {
      await UserPreferencesStorage.saveForEmail(
        email: pendingEmail,
        sports: widget.selectedSports,
        budgetMin: _minPrice,
        budgetMax: _maxPrice,
        city: _selectedCity,
        area: _selectedArea,
        locationPreference: _locationPreference,
        ratingPreference: _ratingPreference,
        coachGender: _coachGender,
        coachAgeRange: _coachAgeRange,
        certifiedOnly: _certifiedOnly,
      );
    } else {
      await UserPreferencesStorage.save(
        sports: widget.selectedSports,
        budgetMin: _minPrice,
        budgetMax: _maxPrice,
        city: _selectedCity,
        area: _selectedArea,
        locationPreference: _locationPreference,
        ratingPreference: _ratingPreference,
        coachGender: _coachGender,
        coachAgeRange: _coachAgeRange,
        certifiedOnly: _certifiedOnly,
      );
    }

    if (!mounted) return;

    if (remoteWarning != null && remoteWarning.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(remoteWarning)));
    }

    if (widget.returnToLoginAfterSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preferences saved. Please confirm your email, then log in.',
          ),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(userType: 'trainee'),
        ),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Preferences',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Help us find the best coaches for you.',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 17,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Please fill all preference sections before continuing.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.selectedSports
                          .map(
                            (s) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                s,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Budget per session'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_minPrice.toInt()} LE',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      Text(
                        '${_maxPrice.toInt()} LE',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: RangeValues(_minPrice, _maxPrice),
                    min: 50,
                    max: 1000,
                    divisions: 19,
                    activeColor: AppColors.primaryBlue,
                    inactiveColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                    labels: RangeLabels(
                      '${_minPrice.toInt()} LE',
                      '${_maxPrice.toInt()} LE',
                    ),
                    onChanged: (values) => setState(() {
                      _minPrice = values.start;
                      _maxPrice = values.end;
                    }),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Minimum coach rating'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['4.5+', '4.0+', '3.0+', "Doesn't Matter"].map((
                      opt,
                    ) {
                      final hasStars = opt != "Doesn't Matter";
                      final selected = _ratingPreference == opt;
                      return GestureDetector(
                        onTap: () => setState(() => _ratingPreference = opt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryBlue
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primaryBlue
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasStars) ...[
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: selected ? Colors.white : Colors.amber,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                opt,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: selected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Location preference'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Anywhere', 'My city']
                        .map(
                          (opt) => _chip(opt, _locationPreference == opt, () {
                            setState(() {
                              _locationPreference = opt;
                              _selectedCity = null;
                              _selectedArea = null;
                            });
                          }),
                        )
                        .toList(),
                  ),
                  if (_locationPreference == 'My city') ...[
                    const SizedBox(height: 16),
                    _sectionTitle('Select your city'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: EgyptLocations.cities.map((city) {
                        final selected = _selectedCity == city;
                        return _chip(city, selected, () {
                          setState(() {
                            _selectedCity = selected ? null : city;
                            _selectedArea = null;
                          });
                        });
                      }).toList(),
                    ),
                    if (_selectedCity != null && _areasForCity.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _sectionTitle('Select area in $_selectedCity'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _areasForCity.map((area) {
                          final selected = _selectedArea == area;
                          return _chip(area, selected, () {
                            setState(
                              () => _selectedArea = selected ? null : area,
                            );
                          });
                        }).toList(),
                      ),
                    ],
                  ],
                  const SizedBox(height: 20),
                  _sectionTitle('Preferred coach gender'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Male', 'Female', 'No Preference']
                        .map(
                          (opt) => _chip(
                            opt,
                            _coachGender == opt,
                            () => setState(() => _coachGender = opt),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Preferred coach age range'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['20-30', '30-40', '40+', 'No Preference']
                        .map(
                          (opt) => _chip(
                            opt,
                            _coachAgeRange == opt,
                            () => setState(() => _coachAgeRange = opt),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Coach certification'),
                  const SizedBox(height: 10),
                  _certificationOption(
                    title: 'Any coaches',
                    subtitle: 'Show both certified and non-certified coaches',
                    selected: !_certifiedOnly,
                    onTap: () => setState(() => _certifiedOnly = false),
                  ),
                  const SizedBox(height: 10),
                  _certificationOption(
                    title: 'Certified coaches only',
                    subtitle: 'Only show coaches with verified certifications',
                    selected: _certifiedOnly,
                    onTap: () => setState(() => _certifiedOnly = true),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSaving || !_canFinish ? null : _finish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.transparent,
                          disabledForegroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Start my journey ->',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
  );

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _certificationOption({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryBlue.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primaryBlue : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
