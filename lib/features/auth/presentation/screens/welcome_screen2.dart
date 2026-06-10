import 'package:flutter/material.dart';
import 'package:maranny_two/features/auth/presentation/screens/register_screen.dart';
import 'package:maranny_two/features/auth/presentation/screens/login_screen.dart';
import '../../../home/presentation/screens/guest_homescreen.dart';

class WelcomeScreen2 extends StatefulWidget {
  final String userType;
  const WelcomeScreen2({Key? key, required this.userType}) : super(key: key);

  @override
  State<WelcomeScreen2> createState() => _WelcomeScreen2State();
}

class _WelcomeScreen2State extends State<WelcomeScreen2> {
  static const Color _blue = Color(0xFF1F3A93);

  String? _activeButton;

  @override
  Widget build(BuildContext context) {
    // ✅ Subtitle changes based on userType
    final subtitle = widget.userType == 'coach'
        ? 'Manage your sessions & grow your clients'
        : 'Find your perfect coach';

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

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/maranny_logo.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'MARANNY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Welcome',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              // ✅ Dynamic subtitle
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const Spacer(flex: 2),

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
                    _ToggleButton(
                      label: 'LOGIN',
                      isActive: _activeButton == 'login',
                      activeColor: _blue,
                      onTap: () async {
                        setState(() => _activeButton = 'login');
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LoginScreen(userType: widget.userType),
                          ),
                        );
                        if (mounted) setState(() => _activeButton = null);
                      },
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Don't have an account yet?",
                      style: TextStyle(color: Color(0xFF888888), fontSize: 13),
                    ),

                    const SizedBox(height: 12),

                    _ToggleButton(
                      label: 'REGISTER',
                      isActive: _activeButton == 'register',
                      activeColor: _blue,
                      onTap: () async {
                        setState(() => _activeButton = 'register');
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RegisterScreen(userType: widget.userType),
                          ),
                        );
                        if (mounted) setState(() => _activeButton = null);
                      },
                    ),

                    const SizedBox(height: 14),

                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GuestHomeScreen(
                            onAuthRequired: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    LoginScreen(userType: 'trainee'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue as a guest',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Color(0xFF666666),
                          ),
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

// ── Toggle button ─────────────────────────────────────────────

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: isActive
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: activeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
    );
  }
}
