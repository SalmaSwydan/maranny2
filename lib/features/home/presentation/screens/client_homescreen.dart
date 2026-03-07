import 'package:flutter/material.dart';
import '../widgets/client_home_header.dart';
import '../widgets/upcoming_sessions.dart';
import '../widgets/coaches_for_you.dart';
import '../widgets/nearby_facilities.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// Header
            const HomeHeaderTwo(),

            /// Upcoming sessions
            const Padding(
              padding: EdgeInsets.all(16),
              child: UpcomingSessionsSection(),
            ),

            /// Coaches for you
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CoachesForYouSection(),
            ),

            /// Nearby facilities
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: NearbySportsFacilitiesSection(),
            ),
          ],
        ),
      ),
    );
  }
}