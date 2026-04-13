import 'package:flutter/material.dart';
import 'package:maranny_two/features/auth/presentation/screens/register_screen.dart';
import 'package:maranny_two/features/auth/presentation/screens/login_screen.dart';
import '../../../become_coach/presentation/screens/coach_info_screen.dart';
import '../../../home/presentation/screens/guest_homescreen.dart';

class WelcomeScreen2 extends StatelessWidget {
  final String userType;
  const WelcomeScreen2({Key? key, required this.userType}) : super(key: key);

  // Consistent blue used everywhere in app
  static const Color _blue = Color(0xFF1F3A93);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage("assets/images/background_screen.png"),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/maranny_logo.png',
                  width: 140, height: 140, fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 20),

              const Text('MARANNY',
                  style: TextStyle(
                      color: Colors.white, fontSize: 36,
                      fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 6),
              const Text('Welcome',
                  style: TextStyle(
                      color: Colors.white, fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Find your perfect coach',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),

              const Spacer(flex: 2),

              // Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // LOGIN button
                    _PrimaryButton(
                      label: 'LOGIN',
                      color: _blue,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                              LoginScreen(userType: userType))),
                    ),

                    const SizedBox(height: 12),

                    const Text("Don't have an account yet?",
                        style: TextStyle(color: Color(0xFF888888), fontSize: 13)),

                    const SizedBox(height: 12),

                    // REGISTER button
                    _OutlineButton(
                      label: 'REGISTER',
                      color: _blue,
                      onTap: () {
                        if (userType == 'coach') {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (_) => CoachInfoScreen()));
                        } else {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const RegisterScreen()));
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // OR divider
                    Row(children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or', style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13)),
                      ),
                      const Expanded(child: Divider()),
                    ]),

                    const SizedBox(height: 16),

                    // Sign up with Google
                    _GoogleButton(
                      label: 'Sign up with Google',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Google sign-in coming soon')),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // Continue as guest
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => GuestHomeScreen(
                            onAuthRequired: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) =>
                                    LoginScreen(userType: 'trainee'))),
                          ))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Continue as a guest',
                              style: TextStyle(
                                  color: Color(0xFF666666), fontSize: 13)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward,
                              size: 14, color: Color(0xFF666666)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared button widgets ─────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                letterSpacing: 1)),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                letterSpacing: 1)),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GoogleButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: BorderSide(color: Colors.grey.shade300),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google G logo colors
            const Text('G',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold,
                    color: Color(0xFF4285F4))),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500,
                    color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
