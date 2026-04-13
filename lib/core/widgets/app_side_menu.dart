import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../features/settings/presentation/screens/safety_moderation_screen.dart';
import '../../../features/settings/presentation/screens/support_screen.dart';

/// ─────────────────────────────────────────────────────────────
/// APP SIDE MENU
///
/// In client home screen:
///   AppSideMenu(userName: _userName, userType: 'client', onLogout: ...)
///
/// In coach home screen / coach layout:
///   AppSideMenu(userName: _userName, userType: 'coach', onLogout: ...)
/// ─────────────────────────────────────────────────────────────
class AppSideMenu extends StatelessWidget {
  final String userName;
  final String userType; // 'client' or 'coach'
  final VoidCallback onLogout;

  const AppSideMenu({
    super.key,
    required this.userName,
    required this.userType,
    required this.onLogout,
  });

  bool get _isCoach => userType == 'coach';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 24,
              20,
              24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1F3A93), Color(0xFF6FD3F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty
                          ? userName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withValues(alpha: 0.2),
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: Text(
                          _isCoach ? 'Coach' : 'Trainee',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Support ──
          _MenuItem(
            icon: Icons.help_outline,
            iconColor: const Color(0xFF1F3A93),
            title: 'Support',
            subtitle: _isCoach
                ? 'Coach support centre'
                : 'Get help with any issues',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  // ✅ passes the correct userType
                  builder: (_) => SupportScreen(userType: userType),
                ),
              );
            },
          ),

          // ── Report ──
          _MenuItem(
            icon: Icons.warning_amber_outlined,
            iconColor: Colors.orange,
            title: 'Report',
            subtitle: _isCoach
                ? 'Report a trainee or issue'
                : 'Report a coach or issue',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  // ✅ passes the correct userType
                  builder: (_) =>
                      SafetyModerationScreen(userType: userType),
                ),
              );
            },
          ),

          // ── Logout ──
          _MenuItem(
            icon: Icons.logout,
            iconColor: Colors.red,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            titleColor: Colors.red,
            onTap: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              onLogout();
            },
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color titleColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.titleColor = Colors.black87,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 14),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey)),
            ],
          ),
        ]),
      ),
    );
  }
}