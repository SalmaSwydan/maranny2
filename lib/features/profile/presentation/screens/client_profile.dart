import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/profile_header.dart';
import '../../widgets/profile_stats.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/client_profile_storage.dart';
import '../../../../core/utils/profile_validators.dart';
import '../../../../core/utils/user_preferences_storage.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/repositories/profile_repository.dart';
import 'client_edit_profile_screen.dart';
import 'dart:io';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  bool _isLoading = true;
  bool _isUploadingImage = false;
  String? _error;

  String name = 'User';
  String email = '';
  String city = '';
  String phone = '';
  String bio = '';
  String sports = 'No sports yet';
  String? profilePicture;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final UserModel user = await _authRepository.getCurrentUser();
      final savedPrefs = await UserPreferencesStorage.load();
      final profileCache = await ClientProfileStorage.load();

      if (!mounted) return;

      setState(() {
        name = user.fullName.trim().isNotEmpty ? user.fullName : 'User';
        email = user.email;
        profilePicture = (user.profilePicture?.trim().isNotEmpty ?? false)
            ? user.profilePicture
            : profileCache.imageUrl;
        city = _firstNonEmpty([user.city, user.street, profileCache.location]);
        phone = _firstNonEmpty([user.phoneNumber, profileCache.phone]);
        bio = _firstNonEmpty([user.bio, profileCache.bio]);
        sports = savedPrefs.sports.isNotEmpty
            ? savedPrefs.sports.join(', ')
            : 'No sports yet';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load profile';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadProfileImage() async {
    if (_isUploadingImage) return;

    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final imageUrl = await _profileRepository.uploadProfilePicture(
        File(xFile.path),
      );
      await ClientProfileStorage.save(imageUrl: imageUrl);
      if (!mounted) return;
      setState(() {
        profilePicture = imageUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated successfully.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not upload profile image right now. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xffF5F6FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xffF5F6FA),
        body: Center(
          child: TextButton(onPressed: _loadCurrentUser, child: Text(_error!)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(
              name: name,
              sports: sports,
              bio: bio,
              imageUrl: profilePicture,
              onImageTap: _pickAndUploadProfileImage,
              isUploadingImage: _isUploadingImage,
            ),
            const SizedBox(height: 18),
            const ProfileStats(),
            const SizedBox(height: 20),
            _ProfileCompletionCard(
              missing: ProfileValidators.missingClientProfileFields(
                phone: phone,
                location: city,
                sports: sports == 'No sports yet'
                    ? const []
                    : sports.split(','),
              ),
            ),
            _ProfileInfoCard(
              title: 'Personal Details',
              children: [
                _ProfileInfoRow(
                  icon: Icons.person_outline,
                  label: 'Full Name',
                  value: name,
                ),
                _ProfileInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: email,
                ),
                _ProfileInfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Location / City',
                  value: city.isNotEmpty ? city : 'Not added yet',
                ),
                _ProfileInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: phone.isNotEmpty ? phone : 'Not added yet',
                ),
              ],
            ),
            _ProfileInfoCard(
              title: 'About You',
              children: [
                _StackedInfoTile(
                  icon: Icons.notes_outlined,
                  label: 'Bio',
                  value: bio.isNotEmpty ? bio : 'Not added yet',
                ),
              ],
            ),
            _ProfileInfoCard(
              title: 'Preferred Sports',
              children: [
                _StackedInfoTile(
                  icon: Icons.sports_soccer_outlined,
                  label: 'Sports you like',
                  value: sports,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClientEditProfileScreen(
                          name: name,
                          email: email,
                          city: city,
                          phone: phone,
                          bio: bio,
                          imageUrl: profilePicture,
                          sports: sports == 'No sports yet'
                              ? const []
                              : sports
                                    .split(',')
                                    .map((sport) => sport.trim())
                                    .where((sport) => sport.isNotEmpty)
                                    .toList(growable: false),
                        ),
                      ),
                    );

                    if (result != null && result is Map) {
                      setState(() {
                        name = result['name'] ?? name;
                        email = result['email'] ?? email;
                        city = result['city'] ?? city;
                        phone = result['phone'] ?? phone;
                        bio = result['bio'] ?? bio;
                        final updatedSports = result['sports'];
                        if (updatedSports is List) {
                          sports = updatedSports.join(', ');
                        }
                        profilePicture = result['imageUrl'] ?? profilePicture;
                      });
                    } else {
                      _loadCurrentUser();
                    }
                  },
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }
}

class _ProfileCompletionCard extends StatelessWidget {
  final List<String> missing;

  const _ProfileCompletionCard({required this.missing});

  @override
  Widget build(BuildContext context) {
    if (missing.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.10),
            AppColors.lightBlue.withValues(alpha: 0.16),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Complete your profile to book',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add ${missing.join(', ')}.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileInfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StackedInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StackedInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
