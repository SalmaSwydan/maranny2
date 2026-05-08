import 'package:flutter/material.dart';
import 'package:maranny_two/core/utils/app_assets.dart';
import 'package:maranny_two/features/auth/presentation/screens/welcome_screen2.dart';
import 'package:maranny_two/features/home/presentation/screens/guest_homescreen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? selectedRole;

  void _continue() {
    final role = selectedRole;
    if (role == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen2(userType: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage(AppAssets.backgroundScreen),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    AppAssets.marannyLogo,
                    width: 112,
                    height: 112,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'STEP 01 / 03',
                  style: TextStyle(
                    color: Color(0xFFE3F6FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'How do you\nplan to use\nMaranny?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 39,
                    height: 0.92,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.4,
                  ),
                ),
                const Spacer(),
                _RoleChoiceCard(
                  eyebrow: 'FOR ATHLETES',
                  title: 'Train with a coach',
                  subtitle: 'Find pros, book sessions, track your progress.',
                  isSelected: selectedRole == 'trainee',
                  onTap: () => setState(() => selectedRole = 'trainee'),
                ),
                const SizedBox(height: 14),
                _RoleChoiceCard(
                  eyebrow: 'FOR COACHES',
                  title: 'Coach & earn',
                  subtitle: 'Get discovered. Manage your calendar. Get paid.',
                  isSelected: selectedRole == 'coach',
                  onTap: () => setState(() => selectedRole = 'coach'),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: selectedRole == null ? null : _continue,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      backgroundColor: const Color(0xFFAEEFFA),
                      disabledBackgroundColor: const Color(
                        0xFFAEEFFA,
                      ).withValues(alpha: 0.72),
                      foregroundColor: const Color(0xFF17337C),
                      disabledForegroundColor: const Color(
                        0xFF17337C,
                      ).withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GuestHomeScreen(
                            onAuthRequired: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WelcomeScreen(),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Continue as a guest',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChoiceCard extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChoiceCard({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isSelected ? 0.98 : 0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1F3A93)
                  : Colors.white.withValues(alpha: 0.78),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0C276B).withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: const TextStyle(
                        color: Color(0xFF98A9C8),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF142450),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF66799E),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: isSelected ? 1 : 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F3A93),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
