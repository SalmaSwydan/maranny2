import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/client_home_header.dart';
import '../widgets/upcoming_sessions.dart';
import '../widgets/coaches_for_you.dart';
import '../widgets/nearby_facilities.dart';
import '../../../../../core/widgets/app_side_menu.dart';
import '../../../auth/presentation/screens/welcome_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  // ✅ callback from MainLayout to switch to Bookings tab
  final VoidCallback? onGoToBookings;

  const ClientHomeScreen({super.key, this.onGoToBookings});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String get _userName {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? user?.email?.split('@').first ?? 'Ahmed';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppSideMenu(
        userName: _userName,
        onLogout: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
          );
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HomeHeaderTwo(
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: UpcomingSessionsSection(
                // ✅ "view more" switches to Bookings tab
                onViewMore: widget.onGoToBookings,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CoachesForYouSection(),
            ),

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
