import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/egypt_locations.dart';
import '../../../../core/utils/profile_validators.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../data/models/profile_models.dart';
import '../../data/repositories/profile_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  String? _profileImagePath;
  String? _profileImageUrl;
  String? _certificateImagePath;
  String? _certificateImageUrl;
  final Set<String> _selectedLocations = <String>{};

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final UserModel user = await _authRepository.getCurrentUser();

      if (!mounted) return;

      _nameController.text = user.fullName;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      _bioController.text = user.bio ?? '';
      _profileImageUrl = user.profilePicture;
      try {
        final setup = await _profileRepository.getMyCoachSetup();
        _certificateImageUrl = setup.certificateUrl;
        final locations = setup.locations.isNotEmpty
            ? setup.locations
            : (setup.city ?? '').split(',');
        _selectedLocations
          ..clear()
          ..addAll(
            locations
                .map((location) => location.trim())
                .where(EgyptLocations.isKnownPlace),
          );
        _locationController.text = _selectedLocations.join(', ');
      } catch (_) {
        final userCity = user.city ?? '';
        if (EgyptLocations.isKnownPlace(userCity)) {
          _selectedLocations.add(userCity);
          _locationController.text = userCity;
        }
      }

      setState(() => _isLoading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load profile')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
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

  Future<void> _pickCertificateImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);

    if (xFile != null) {
      setState(() => _certificateImagePath = xFile.path);
    }
  }

  Future<void> _saveEdit() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      if (_profileImagePath != null && _profileImagePath!.isNotEmpty) {
        _profileImageUrl = await _profileRepository.uploadProfilePicture(
          File(_profileImagePath!),
        );
      }

      if (_certificateImagePath != null && _certificateImagePath!.isNotEmpty) {
        _certificateImageUrl = await _profileRepository.uploadCoachCertificate(
          File(_certificateImagePath!),
        );
      }

      final fullName = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final bio = _bioController.text.trim();
      if (!ProfileValidators.isValidName(fullName)) {
        _showError('Enter your real full name using letters only');
        return;
      }
      if (phone.isNotEmpty && !ProfileValidators.isValidEgyptPhone(phone)) {
        _showError('Enter a valid Egyptian mobile number');
        return;
      }
      if (bio.isNotEmpty && !ProfileValidators.hasMinimumBioWords(bio)) {
        _showError(
          'Bio is optional, but if added it must contain at least 20 words.',
        );
        return;
      }
      if (_selectedLocations.length < 3) {
        _showError('Please choose at least 3 coaching areas');
        return;
      }
      final parts = fullName
          .split(' ')
          .where((e) => e.trim().isNotEmpty)
          .toList();

      final firstName = parts.isNotEmpty ? parts.first : fullName;
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      await _profileRepository.updateProfile(
        UpdateProfileRequest(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phone.isEmpty
              ? null
              : ProfileValidators.normalizeEgyptPhone(phone),
          city: _selectedLocations.isEmpty
              ? null
              : _selectedLocations.join(', '),
          bio: bio.isEmpty ? null : bio,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved')));

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF3F7FF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                    _buildProfilePicture(),
                    const SizedBox(height: 24),
                    _buildCertificateUploader(),
                    const SizedBox(height: 24),
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
                            enabled: false,
                          ),
                          const SizedBox(height: 12),
                          _buildLocationSelector(),
                          const SizedBox(height: 12),
                          _buildTextField(_phoneController, 'Phone Number'),
                          const SizedBox(height: 12),
                          _buildBioField(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
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
                  'COACH SETTINGS',
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

  Widget _buildProfilePicture() {
    return Center(
      child: GestureDetector(
        onTap: _pickProfileImage,
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
                  : _profileImageUrl != null &&
                        _profileImageUrl!.startsWith('http')
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

  Widget _buildCertificateUploader() {
    final hasLocalImage =
        _certificateImagePath != null && _certificateImagePath!.isNotEmpty;
    final hasRemoteImage =
        _certificateImageUrl != null &&
        _certificateImageUrl!.startsWith('http');

    return _FormPlate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle('Coach Certifications'),
          GestureDetector(
            onTap: _pickCertificateImage,
            child: Container(
              height: 132,
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD7E0F2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: hasLocalImage
                    ? Image.file(
                        File(_certificateImagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : hasRemoteImage
                    ? Image.network(
                        _certificateImageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => _certificatePlaceholder(),
                      )
                    : _certificatePlaceholder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: _isSaving ? null : _pickCertificateImage,
              icon: const Icon(Icons.upload_file_rounded, size: 20),
              label: Text(
                hasLocalImage || hasRemoteImage
                    ? 'Change certificate image'
                    : 'Upload certificate image',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.deepBlue,
                side: const BorderSide(color: Color(0xFFD7E0F2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
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

  Widget _certificatePlaceholder() {
    return Container(
      color: const Color(0xFFF7FAFF),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            color: AppColors.deepBlue,
            size: 34,
          ),
          SizedBox(height: 8),
          Text(
            'No certificate uploaded yet',
            style: TextStyle(
              color: Color(0xFF6C7897),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: enabled ? const Color(0xFFF7FAFF) : const Color(0xFFEAF0FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFFD7E0F2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFFD7E0F2)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.deepBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7E0F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coaching Areas',
            style: TextStyle(
              color: Color(0xFF6C7897),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EgyptLocations.allAreas.map((area) {
              final selected = _selectedLocations.contains(area);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedLocations.remove(area);
                    } else {
                      _selectedLocations.add(area);
                    }
                    _locationController.text = _selectedLocations.join(', ');
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.deepBlue
                        : const Color(0xFFF7FAFF),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected
                          ? AppColors.deepBlue
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    area,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.deepBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            '${_selectedLocations.length} selected. Minimum 3 areas.',
            style: const TextStyle(color: Color(0xFF6C7897), fontSize: 12),
          ),
        ],
      ),
    );
  }

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

  Widget _buildSaveButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveEdit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
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
