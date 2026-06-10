import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/client_profile_storage.dart';
import '../../../../core/utils/egypt_locations.dart';
import '../../../../core/utils/profile_validators.dart';
import '../../../../core/utils/user_preferences_storage.dart';
import '../../data/models/profile_models.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../sports/data/repositories/sports_repository.dart';

class ClientEditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String city;
  final String phone;
  final String bio;
  final String? imageUrl;
  final List<String> sports;

  const ClientEditProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.city,
    required this.phone,
    required this.bio,
    this.imageUrl,
    this.sports = const [],
  });

  @override
  State<ClientEditProfileScreen> createState() =>
      _ClientEditProfileScreenState();
}

class _ClientEditProfileScreenState extends State<ClientEditProfileScreen> {
  final ProfileRepository _profileRepository = ProfileRepository();
  final SportsRepository _sportsRepository = SportsRepository();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _cityController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;

  String? _profileImagePath;
  String? _profileImageUrl;
  bool _isSaving = false;
  List<String> _availableSports = const [
    'Football',
    'Basketball',
    'Swimming',
    'Tennis',
    'Gym Training',
    'Padel',
  ];
  late Set<String> _selectedSports;
  double _minPrice = 100;
  double _maxPrice = 500;
  String? _ratingPreference;
  String? _locationPreference;
  String? _selectedPreferenceCity;
  String? _selectedPreferenceArea;
  String? _coachGender;
  String? _coachAgeRange;
  bool _certifiedOnly = false;
  bool _preferencesExpanded = true;

  bool get _preferencesComplete =>
      _ratingPreference != null &&
      _locationPreference != null &&
      (_locationPreference != 'My city' || _selectedPreferenceCity != null) &&
      _coachGender != null &&
      _coachAgeRange != null;

  double? get _maxDistance {
    if (_locationPreference == 'Anywhere') return 100;
    if (_locationPreference == 'My city') return 25;
    return null;
  }

  List<String> get _preferenceAreas =>
      EgyptLocations.areasForCity(_selectedPreferenceCity);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _cityController = TextEditingController(text: widget.city);
    _phoneController = TextEditingController(text: widget.phone);
    _bioController = TextEditingController(text: widget.bio);
    _profileImageUrl = widget.imageUrl;
    _selectedSports = widget.sports.toSet();
    _loadSports();
    _loadPreferences();
  }

  Future<void> _loadSports() async {
    try {
      final sports = await _sportsRepository.getSports();
      final names = sports
          .map((sport) => sport.name.trim())
          .where((name) => name.isNotEmpty)
          .toList(growable: false);
      if (mounted && names.isNotEmpty) {
        setState(() => _availableSports = names);
      }
    } catch (_) {}
  }

  Future<void> _loadPreferences() async {
    UserPreferences prefs;
    try {
      prefs = await _profileRepository.getPreferences();
      await UserPreferencesStorage.saveSnapshot(prefs);
    } catch (_) {
      prefs = await UserPreferencesStorage.load();
    }
    if (!mounted) return;

    setState(() {
      if (_selectedSports.isEmpty && prefs.sports.isNotEmpty) {
        _selectedSports = prefs.sports.toSet();
      }
      _minPrice = prefs.budgetMin ?? _minPrice;
      _maxPrice = prefs.budgetMax ?? _maxPrice;
      _ratingPreference = prefs.ratingPreferenceLabel;
      _locationPreference = prefs.locationPreference;
      _selectedPreferenceCity = prefs.city;
      _selectedPreferenceArea = prefs.area;
      _coachGender = prefs.coachGender;
      _coachAgeRange = prefs.coachAgeRange;
      _certifiedOnly = prefs.certifiedOnly;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      setState(() => _profileImagePath = xFile.path);
    }
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final location = _cityController.text.trim();
    final phone = _phoneController.text.trim();
    final bio = _bioController.text.trim();

    if (!ProfileValidators.isValidName(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your real full name using letters only'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!ProfileValidators.isValidLocation(location)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a valid Cairo/Giza area'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!ProfileValidators.isValidEgyptPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid Egyptian number like 01012345678 or +201012345678',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
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
    if (_selectedSports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose at least one sport'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!_preferencesComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your recommendation preferences.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _preferencesExpanded = true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_profileImagePath != null && _profileImagePath!.isNotEmpty) {
        _profileImageUrl = await _profileRepository.uploadProfilePicture(
          File(_profileImagePath!),
        );
      }
      final nameParts = name.split(RegExp(r'\s+'));
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : nameParts.first;

      await _profileRepository.updateProfile(
        UpdateProfileRequest(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: ProfileValidators.normalizeEgyptPhone(phone),
          city: location,
          bio: bio,
        ),
      );
      await _profileRepository.updatePreferences(
        UpdatePreferencesRequest(
          sports: _selectedSports.toList(),
          budgetMin: _minPrice,
          budgetMax: _maxPrice,
          maxDistance: _maxDistance,
          city: _selectedPreferenceCity,
          area: _selectedPreferenceArea,
          locationPreference: _locationPreference,
          ratingPreference: _ratingPreference,
          coachGender: _coachGender,
          coachAgeRange: _coachAgeRange,
          certifiedOnly: _certifiedOnly,
        ),
      );
      await UserPreferencesStorage.saveSnapshot(
        UserPreferences(
          sports: _selectedSports.toList(),
          budgetMin: _minPrice,
          budgetMax: _maxPrice,
          city: _selectedPreferenceCity,
          area: _selectedPreferenceArea,
          locationPreference: _locationPreference,
          minRating: _ratingPreference == null
              ? null
              : double.tryParse(_ratingPreference!.replaceAll('+', '')),
          coachGender: _coachGender,
          coachAgeRange: _coachAgeRange,
          certifiedOnly: _certifiedOnly,
        ),
      );
      final normalizedPhone = ProfileValidators.normalizeEgyptPhone(phone);
      await ClientProfileStorage.save(
        phone: normalizedPhone,
        location: location,
        bio: bio,
        imageUrl: _profileImageUrl ?? widget.imageUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved')));

      Navigator.of(context).pop({
        'name': name,
        'email': email,
        'city': location,
        'phone': normalizedPhone,
        'bio': bio,
        'sports': _selectedSports.toList(),
        'imagePath': _profileImagePath ?? '',
        'imageUrl': _profileImageUrl ?? widget.imageUrl ?? '',
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save your profile right now. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Profile picture (same as coach) ──
                    _buildProfilePicture(),
                    const SizedBox(height: 24),

                    // ── Personal Information ──
                    _FormPlate(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionTitle('Personal Information'),
                          _buildTextField(_nameController, 'Full Name'),
                          const SizedBox(height: 12),
                          _buildTextField(
                            _emailController,
                            'Email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          _buildLocationDropdown(),
                          const SizedBox(height: 12),
                          _buildTextField(
                            _phoneController,
                            'Phone Number',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          _buildBioField(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Sports Background (matches coach "Professional Info") ──
                    _FormPlate(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionTitle('Sports Background'),
                          _buildSportsPicker(),
                          const SizedBox(height: 16),
                          _buildPreferencesSettingsCard(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Save button (same gradient style as coach) ──
                    _buildSaveButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Same app bar as coach ─────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD7E0F2)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.deepBlue,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROFILE SETTINGS',
                  style: TextStyle(
                    color: Color(0xFF9AA9C6),
                    fontSize: 11,
                    letterSpacing: 2.2,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Edit profile.',
                  style: TextStyle(
                    color: AppColors.deepBlue,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Same profile picture widget as coach ─────────
  Widget _buildProfilePicture() {
    return Center(
      child: GestureDetector(
        onTap: _isSaving ? null : _pickProfileImage,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 58,
              backgroundColor: const Color(0xFFE8ECF7),
              child: _profileImagePath != null
                  ? ClipOval(
                      child: Image.file(
                        File(_profileImagePath!),
                        width: 116,
                        height: 116,
                        fit: BoxFit.cover,
                      ),
                    )
                  : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                  ? ClipOval(
                      child: Image.network(
                        _profileImageUrl!,
                        width: 116,
                        height: 116,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person_rounded,
                          size: 56,
                          color: AppColors.deepBlue,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person_rounded,
                      size: 56,
                      color: AppColors.deepBlue,
                    ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.lightBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.deepBlue,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Same section title as coach ──────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w900,
          color: AppColors.deepBlue,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  // ── Same text field style as coach ───────────────
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF7FAFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFFD7E0F2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFFD7E0F2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.deepBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    final allAreas = EgyptLocations.allAreas;
    final currentValue = allAreas.contains(_cityController.text.trim())
        ? _cityController.text.trim()
        : null;

    return DropdownButtonFormField<String>(
      initialValue: currentValue,
      isExpanded: true,
      items: allAreas
          .map(
            (area) => DropdownMenuItem<String>(value: area, child: Text(area)),
          )
          .toList(growable: false),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _cityController.text = value);
      },
      decoration: InputDecoration(
        labelText: 'Location / City',
        filled: true,
        fillColor: const Color(0xFFF7FAFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFFD7E0F2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFFD7E0F2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.deepBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSportsPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableSports.map((sport) {
        final selected = _selectedSports.contains(sport);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (selected) {
                _selectedSports.remove(sport);
              } else {
                _selectedSports.add(sport);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? AppColors.deepBlue : const Color(0xFFF7FAFF),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? AppColors.deepBlue : const Color(0xFFD7E0F2),
              ),
            ),
            child: Text(
              sport,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.deepBlue,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Same bio field as coach ───────────────────────
  Widget _buildBioField() {
    return TextField(
      controller: _bioController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Bio / About You',
        alignLabelWithHint: true,
        filled: true,
        fillColor: const Color(0xFFF7FAFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFFD7E0F2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFFD7E0F2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.deepBlue, width: 1.5),
        ),
      ),
    );
  }

  // ── Years dropdown (same style as coach) ─────────
  Widget _buildPreferencesSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7E0F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () =>
                setState(() => _preferencesExpanded = !_preferencesExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFEAF0FB),
                  child: Icon(Icons.tune, color: AppColors.deepBlue, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommendation Preferences',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.deepBlue,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Budget, area, coach style, and certification filters.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C7897),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _preferencesExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.deepBlue,
                ),
              ],
            ),
          ),
          if (_preferencesExpanded) ...[
            const SizedBox(height: 16),
            _buildPreferenceNote(),
            const SizedBox(height: 16),
            _buildPreferenceTitle('Budget per session'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_minPrice.toInt()} LE',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepBlue,
                  ),
                ),
                Text(
                  '${_maxPrice.toInt()} LE',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepBlue,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: 50,
              max: 1000,
              divisions: 19,
              activeColor: AppColors.deepBlue,
              inactiveColor: AppColors.deepBlue.withValues(alpha: 0.14),
              labels: RangeLabels(
                '${_minPrice.toInt()} LE',
                '${_maxPrice.toInt()} LE',
              ),
              onChanged: _isSaving
                  ? null
                  : (values) => setState(() {
                      _minPrice = values.start;
                      _maxPrice = values.end;
                    }),
            ),
            const SizedBox(height: 14),
            _buildPreferenceTitle('Minimum coach rating'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['4.5+', '4.0+', '3.0+', "Doesn't Matter"].map((opt) {
                return _settingsChip(
                  opt,
                  _ratingPreference == opt,
                  () => setState(() => _ratingPreference = opt),
                  icon: opt == "Doesn't Matter" ? null : Icons.star,
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            _buildPreferenceTitle('Location preference'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Anywhere', 'My city'].map((opt) {
                return _settingsChip(opt, _locationPreference == opt, () {
                  setState(() {
                    _locationPreference = opt;
                    _selectedPreferenceCity = null;
                    _selectedPreferenceArea = null;
                  });
                });
              }).toList(),
            ),
            if (_locationPreference == 'My city') ...[
              const SizedBox(height: 14),
              _buildPreferenceTitle('City'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: EgyptLocations.cities.map((city) {
                  final selected = _selectedPreferenceCity == city;
                  return _settingsChip(city, selected, () {
                    setState(() {
                      _selectedPreferenceCity = selected ? null : city;
                      _selectedPreferenceArea = null;
                    });
                  });
                }).toList(),
              ),
              if (_selectedPreferenceCity != null &&
                  _preferenceAreas.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildPreferenceTitle('Area'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _preferenceAreas.map((area) {
                    final selected = _selectedPreferenceArea == area;
                    return _settingsChip(area, selected, () {
                      setState(
                        () => _selectedPreferenceArea = selected ? null : area,
                      );
                    });
                  }).toList(),
                ),
              ],
            ],
            const SizedBox(height: 18),
            _buildPreferenceTitle('Preferred coach gender'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Male', 'Female', 'No Preference'].map((opt) {
                return _settingsChip(
                  opt,
                  _coachGender == opt,
                  () => setState(() => _coachGender = opt),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            _buildPreferenceTitle('Preferred coach age range'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['20-30', '30-40', '40+', 'No Preference'].map((opt) {
                return _settingsChip(
                  opt,
                  _coachAgeRange == opt,
                  () => setState(() => _coachAgeRange = opt),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            _buildPreferenceTitle('Coach certification'),
            const SizedBox(height: 10),
            _settingsRadioTile(
              title: 'Any coaches',
              subtitle: 'Show both certified and non-certified coaches',
              selected: !_certifiedOnly,
              onTap: () => setState(() => _certifiedOnly = false),
            ),
            const SizedBox(height: 10),
            _settingsRadioTile(
              title: 'Certified coaches only',
              subtitle: 'Only show coaches with verified certifications',
              selected: _certifiedOnly,
              onTap: () => setState(() => _certifiedOnly = true),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreferenceNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDEEFF)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.deepBlue, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Fill these preferences so recommendations match your budget and location.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.deepBlue,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.deepBlue,
      ),
    );
  }

  Widget _settingsChip(
    String label,
    bool selected,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: _isSaving ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.deepBlue : const Color(0xFFF7FAFF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.deepBlue : const Color(0xFFD7E0F2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? Colors.white : Colors.amber,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.deepBlue,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsRadioTile({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isSaving ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.deepBlue.withValues(alpha: 0.08)
              : const Color(0xFFF7FAFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.deepBlue : const Color(0xFFD7E0F2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.deepBlue : Colors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6C7897),
                      height: 1.25,
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

  Widget _buildSaveButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Save Edit',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                ),
              ),
      ),
    );
  }
}

class _FormPlate extends StatelessWidget {
  const _FormPlate({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD7E0F2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
