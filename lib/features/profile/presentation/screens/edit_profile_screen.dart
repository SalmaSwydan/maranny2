import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../utils/coach_profile_manager.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _priceController = TextEditingController();

  String? _profileImagePath;
  int _yearsOfExperience = 3;
  final List<Map<String, String>> _pendingCertificates = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = CoachProfileManager.fullName;
    _emailController.text = CoachProfileManager.email;
    _locationController.text = CoachProfileManager.location;
    _phoneController.text = CoachProfileManager.phone;
    _bioController.text = CoachProfileManager.bio;
    _priceController.text = CoachProfileManager.sessionPrice;
    _profileImagePath = CoachProfileManager.profileImagePath;
    _yearsOfExperience = CoachProfileManager.yearsOfExperience;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      setState(() => _profileImagePath = xFile.path);
    }
  }

  Future<void> _pickCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        for (final f in result.files) {
          if (f.path != null && f.name.isNotEmpty) {
            _pendingCertificates.add({'path': f.path!, 'name': f.name});
          }
        }
      });
    }
  }

  void _saveEdit() {
    CoachProfileManager.saveProfile(
      imagePath: _profileImagePath,
      name: _nameController.text.trim(),
      emailVal: _emailController.text.trim(),
      locationVal: _locationController.text.trim(),
      phoneVal: _phoneController.text.trim(),
      bioVal: _bioController.text.trim(),
      years: _yearsOfExperience,
      price: _priceController.text.trim().isNotEmpty
          ? _priceController.text.trim()
          : null,
    );
    for (final c in _pendingCertificates) {
      CoachProfileManager.addCertificate(c['path']!, c['name']!);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved')),
    );
    Navigator.of(context).pop(true);
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
                    _buildProfilePicture(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Personal Information'),
                    _buildTextField(_nameController, 'Full Name'),
                    const SizedBox(height: 12),
                    _buildTextField(_emailController, 'Email'),
                    const SizedBox(height: 12),
                    _buildTextField(_locationController, 'Location / City'),
                    const SizedBox(height: 12),
                    _buildTextField(_phoneController, 'Phone Number'),
                    const SizedBox(height: 12),
                    _buildBioField(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Professional Information'),
                    _buildYearsDropdown(),
                    const SizedBox(height: 12),
                    _buildTextField(_priceController, 'Session Price (\$)'),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Upload More Certification'),
                    _buildCertificationUpload(),
                    if (_pendingCertificates.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ..._pendingCertificates.map(
                            (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf,
                                  color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  c['name'] ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 22),
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

  Widget _buildProfilePicture() {
    return Center(
      child: GestureDetector(
        onTap: _pickProfileImage,
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
                  : CoachProfileManager.profileImagePath != null
                  ? ClipOval(
                child: Image.file(
                  File(CoachProfileManager.profileImagePath!),
                  width: 112,
                  height: 112,
                  fit: BoxFit.cover,
                ),
              )
                  : const Icon(Icons.person,
                  size: 56, color: AppColors.primaryBlue),
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
                child:
                const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
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
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildYearsDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _yearsOfExperience,
          isExpanded: true,
          items: List.generate(20, (i) => i + 1)
              .map((v) =>
              DropdownMenuItem(value: v, child: Text('$v years experience')))
              .toList(),
          onChanged: (v) => setState(() => _yearsOfExperience = v ?? 3),
        ),
      ),
    );
  }

  Widget _buildCertificationUpload() {
    return GestureDetector(
      onTap: _pickCertificate,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.primaryBlue, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(Icons.upload_file, size: 48, color: AppColors.primaryBlue),
            const SizedBox(height: 12),
            const Text('Upload certifications',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('PDF Files up to 10MB',
                style:
                TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Choose File',
                  style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600)),
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
        onPressed: _saveEdit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Save Edit',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
