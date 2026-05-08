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
  int _yearsOfExperience = 1;
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
        UpdatePreferencesRequest(sports: _selectedSports.toList()),
      );
      await UserPreferencesStorage.save(sports: _selectedSports.toList());
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Profile picture (same as coach) ──
                    _buildProfilePicture(),
                    const SizedBox(height: 24),

                    // ── Personal Information ──
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
                    const SizedBox(height: 20),

                    // ── Sports Background (matches coach "Professional Info") ──
                    _buildSectionTitle('Sports Background'),
                    _buildSportsPicker(),
                    const SizedBox(height: 12),
                    _buildYearsDropdown(),

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 22,
            ),
          ),
          const Expanded(
            child: Text(
              'Edit Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 48),
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
              radius: 56,
              backgroundColor: Colors.grey.shade200,
              child: _profileImagePath != null
                  ? ClipOval(
                      child: Image.file(
                        File(_profileImagePath!),
                        width: 112,
                        height: 112,
                        fit: BoxFit.cover,
                      ),
                    )
                  : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                  ? ClipOval(
                      child: Image.network(
                        _profileImageUrl!,
                        width: 112,
                        height: 112,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 56,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 56,
                      color: AppColors.primaryBlue,
                    ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
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
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
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
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primaryBlue.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primaryBlue.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
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
      value: currentValue,
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
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primaryBlue.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primaryBlue.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
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
              color: selected ? AppColors.primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? AppColors.primaryBlue
                    : AppColors.primaryBlue.withValues(alpha: 0.45),
              ),
            ),
            child: Text(
              sport,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
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
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primaryBlue.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primaryBlue.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ── Years dropdown (same style as coach) ─────────
  Widget _buildYearsDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _yearsOfExperience,
          isExpanded: true,
          items: List.generate(20, (i) => i + 1)
              .map(
                (v) => DropdownMenuItem(
                  value: v,
                  child: Text('$v year${v > 1 ? 's' : ''} experience'),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _yearsOfExperience = v ?? 1),
        ),
      ),
    );
  }

  // ── Same save button as coach ─────────────────────
  Widget _buildSaveButton() {
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }
}
