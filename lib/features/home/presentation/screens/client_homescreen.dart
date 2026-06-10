import 'package:flutter/material.dart';
import '../../../../../core/network/token_storage.dart';
import '../widgets/client_home_header.dart';
import '../widgets/upcoming_sessions.dart';
import '../widgets/coaches_for_you.dart';
import '../widgets/nearby_facilities.dart';
import '../../../../../core/widgets/app_side_menu.dart';
import '../../../auth/presentation/screens/welcome_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  final VoidCallback? onGoToBookings;
  final int recommendationRefreshVersion;

  const ClientHomeScreen({
    super.key,
    this.onGoToBookings,
    this.recommendationRefreshVersion = 0,
  });

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final displayName = await TokenStorage.getDisplayName();

    if (!mounted) return;

    setState(() {
      _userName = displayName != null && displayName.trim().isNotEmpty
          ? displayName.trim()
          : 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF3F7FF),
      drawer: AppSideMenu(
        userName: _userName,
        userType: 'client',
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
              userName: _userName,
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: UpcomingSessionsSection(onViewMore: widget.onGoToBookings),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: CoachesForYouSection(
                key: ValueKey(widget.recommendationRefreshVersion),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: NearbySportsFacilitiesSection(),
            ),
          ],
        ),
      ),
    );
  }
}
