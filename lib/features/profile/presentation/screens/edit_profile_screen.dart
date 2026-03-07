import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {

  final String name;
  final String email;
  final String city;
  final String phone;
  final String bio;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.city,
    required this.phone,
    required this.bio,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController cityController;
  late TextEditingController phoneController;
  late TextEditingController bioController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
    cityController = TextEditingController(text: widget.city);
    phoneController = TextEditingController(text: widget.phone);
    bioController = TextEditingController(text: widget.bio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: AppColors.primaryBlue,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            CircleAvatar(
              radius: 55,
              backgroundImage:
              const AssetImage('assets/images/AhmedAli_pp.png'),
            ),

            const SizedBox(height: 30),

            _buildField("Full Name", nameController),

            _buildField("Email", emailController),

            _buildField("City", cityController),

            _buildField("Phone", phoneController),

            _buildField("Bio", bioController, maxLines: 3),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),

                onPressed: () {

                  Navigator.pop(context,{
                    "name": nameController.text,
                    "email": emailController.text,
                    "city": cityController.text,
                    "phone": phoneController.text,
                    "bio": bioController.text,
                  });

                },

                child: const Text("Save Changes"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,{int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}