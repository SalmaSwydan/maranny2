import 'package:flutter/material.dart';
import '../../widgets/profile_header.dart';
import '../../widgets/profile_input_field.dart';
import '../../widgets/profile_stats.dart';
import '../../../../core/theme/app_colors.dart';
import 'edit_profile_screen.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {

  String name = "Ahmed Ali";
  String email = "ahmed.ali@example.com";
  String city = "Cairo";
  String phone = "+20 100 123 567";
  String bio = "Football player who loves training.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      body: SingleChildScrollView(
        child: Column(
          children: [

            const ProfileHeader(),

            const SizedBox(height: 70),

            const ProfileStats(),

            const SizedBox(height: 20),

            ProfileInputField(
              label: "Full Name",
              hint: name,
            ),

            ProfileInputField(
              label: "Email",
              hint: email,
            ),

            ProfileInputField(
              label: "Location / City",
              hint: city,
            ),

            ProfileInputField(
              label: "Phone Number",
              hint: phone,
            ),

            ProfileInputField(
              label: "Bio / About You",
              hint: bio,
              maxLines: 4,
            ),

            const ProfileInputField(
              label: "Sports",
              hint: "Football, Swimming",
            ),

            const SizedBox(height: 20),

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
                        builder: (context) => EditProfileScreen(
                          name: name,
                          email: email,
                          city: city,
                          phone: phone,
                          bio: bio,
                        ),
                      ),
                    );

                    if (result != null) {
                      setState(() {
                        name = result['name'];
                        email = result['email'];
                        city = result['city'];
                        phone = result['phone'];
                        bio = result['bio'];
                      });
                    }
                  },

                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(fontSize: 16),
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