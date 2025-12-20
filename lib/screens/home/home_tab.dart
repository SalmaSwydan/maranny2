import 'package:flutter/material.dart';
import 'package:maranny_two/screens/home/widgets/_buildheader.dart';
import 'package:maranny_two/screens/home/widgets/coaches.dart';
import 'package:maranny_two/screens/home/widgets/coaches_title.dart';
import 'package:maranny_two/screens/home/widgets/coming_sessions.dart';
import 'package:maranny_two/screens/home/widgets/nearby_facilities_section.dart';
import 'package:maranny_two/screens/home/widgets/upcoming_title.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: const [
              HeaderSection(),
               UpcomingTitle(),
                ComingSessions(),
                CoachesTitle(),
                Coaches(),
                NearbyFacilitiesSection(),
            ],
          ),
        ),
      ),
    );
  }
}