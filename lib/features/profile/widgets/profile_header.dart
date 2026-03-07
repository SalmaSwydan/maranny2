import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [

        /// Gradient Header
        Container(
          height: 180,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          padding: const EdgeInsets.only(left: 140, top: 70),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Ahmed Ali",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 6),

              Row(
                children: [
                  Icon(Icons.emoji_events,
                      color: Colors.white70, size: 18),
                  SizedBox(width: 6),
                  Text(
                    "Football, Swimming, Tennis",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              )
            ],
          ),
        ),

        /// Profile Image
        Positioned(
          bottom: -50,
          left: 20,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: const ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              child: Image(
                image: AssetImage("assets/images/AhmedAli_pp.png"),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}