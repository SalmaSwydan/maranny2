import 'package:flutter/material.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/settings/presentation/screens/safety_moderation_screen.dart';
import '../../features/settings/presentation/screens/support_screen.dart';
import '../theme/app_colors.dart';

class AppSideMenu extends StatelessWidget {
  final String userName;
  final String userType;
  final VoidCallback onLogout;

  const AppSideMenu({
    super.key,
    required this.userName,
    required this.userType,
    required this.onLogout,
  });

  bool get _isCoach => userType.toLowerCase() == 'coach';
  static final AuthRepository _authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.72,
      backgroundColor: const Color(0xFFF3F7FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(userName: userName, role: _isCoach ? 'Coach' : 'Trainee'),
            const SizedBox(height: 18),
            _MenuItem(
              icon: Icons.help_outline_rounded,
              iconColor: AppColors.deepBlue,
              iconBackground: const Color(0xFFEAF0FF),
              title: 'Support',
              subtitle: _isCoach
                  ? 'Coach help and account support'
                  : 'Get help with bookings and app issues',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SupportScreen(userType: userType),
                  ),
                );
              },
            ),
            _MenuItem(
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFFE89113),
              iconBackground: const Color(0xFFFFF3DE),
              title: 'Report',
              subtitle: _isCoach
                  ? 'Report a trainee or platform issue'
                  : 'Report a coach or platform issue',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SafetyModerationScreen(userType: userType),
                  ),
                );
              },
            ),
            _MenuItem(
              icon: Icons.logout_rounded,
              iconColor: const Color(0xFFFF4D4D),
              iconBackground: const Color(0xFFFFE8E8),
              title: 'Logout',
              subtitle: 'Sign out of your account',
              titleColor: const Color(0xFFFF3B30),
              onTap: () async {
                Navigator.pop(context);
                await _authRepository.logout();
                onLogout();
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              child: Text(
                'Maranny keeps your sports journey organized, safe, and simple.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.deepBlue.withValues(alpha: 0.45),
                  fontSize: 11,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String userName;
  final String role;

  const _Header({required this.userName, required this.role});

  @override
  Widget build(BuildContext context) {
    final initial = userName.trim().isEmpty ? 'M' : userName.trim()[0];
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF213A96), Color(0xFF5ED1F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            ),
            child: Center(
              child: Text(
                initial.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName.trim().isEmpty ? 'Maranny user' : userName.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final Color titleColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 23),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: titleColor,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7A86A5),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB7C2DA),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
