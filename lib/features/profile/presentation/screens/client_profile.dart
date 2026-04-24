import 'package:flutter/material.dart';
import '../../widgets/profile_header.dart';
import '../../widgets/profile_input_field.dart';
import '../../widgets/profile_stats.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/data/models/user_model.dart';
import 'client_edit_profile_screen.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = true;
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

      if (!mounted) return;

      setState(() {
        name = user.fullName.trim().isNotEmpty ? user.fullName : 'User';
        email = user.email;
        profilePicture = user.profilePicture;
        city = '';
        phone = '';
        bio = '';
        sports = 'No sports yet';
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
          child: TextButton(
            onPressed: _loadCurrentUser,
            child: Text(_error!),
          ),
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
              imageUrl: profilePicture,
            ),
            const SizedBox(height: 70),
            const ProfileStats(),
            const SizedBox(height: 20),
            ProfileInputField(
              label: 'Full Name',
              hint: name,
            ),
            ProfileInputField(
              label: 'Email',
              hint: email,
            ),
            ProfileInputField(
              label: 'Location / City',
              hint: city.isNotEmpty ? city : 'Not added yet',
            ),
            ProfileInputField(
              label: 'Phone Number',
              hint: phone.isNotEmpty ? phone : 'Not added yet',
            ),
            ProfileInputField(
              label: 'Bio / About You',
              hint: bio.isNotEmpty ? bio : 'Not added yet',
              maxLines: 4,
            ),
            ProfileInputField(
              label: 'Sports',
              hint: sports,
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
                      });
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
}