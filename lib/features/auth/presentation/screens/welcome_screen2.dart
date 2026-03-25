import 'package:flutter/material.dart';
import 'package:maranny_two/features/auth/presentation/screens/register_screen.dart';
import 'package:maranny_two/features/auth/presentation/screens/login_screen.dart';
import '../../../become_coach/presentation/screens/coach_info_screen.dart';
import '../../../home/presentation/screens/guest_homescreen.dart';

class WelcomeScreen2 extends StatefulWidget {
  final String userType;

  const WelcomeScreen2({Key? key, required this.userType}) : super(key: key);

  @override
  State<WelcomeScreen2> createState() => _WelcomeScreenState2();
}

class _WelcomeScreenState2 extends State<WelcomeScreen2> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage("assets/images/background_screen.png"),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo and meditation icon
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/maranny_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // App name
              const Text(
                'MARANNY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 8),

              // Welcome text
              const Text(
                'welcome',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              const Spacer(flex: 2),

              const Text(
                'Find your perfect coach',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Selection card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // login button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedRole = 'login';
                          });
                          // Use the userType for login
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(userType: widget.userType),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: selectedRole == 'login'
                              ? Colors.white
                              : const Color(0xFF303F9F),
                          backgroundColor: selectedRole == 'login'
                              ? const Color(0xFF303F9F)
                              : Colors.white,
                          side: BorderSide(
                            color: selectedRole == 'login'
                                ? Colors.white
                                : const Color(0xFF303F9F),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Column(
                          children: const [
                            Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Don\'t have your account yet?',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // register button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedRole = 'register';
                          });
                          // ✅ FIXED: Check userType and navigate accordingly
                          if (widget.userType == 'coach') {
                            // Navigate to Become a Coach screens
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CoachInfoScreen(),
                              ),
                            );
                          } else {
                            // Navigate to regular RegisterScreen for trainee
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: selectedRole == 'register'
                              ? Colors.white
                              : const Color(0xFF303F9F),
                          backgroundColor: selectedRole == 'register'
                              ? const Color(0xFF303F9F)
                              : Colors.white,
                          side: BorderSide(
                            color: selectedRole == 'register'
                                ? Colors.white
                                : const Color(0xFF303F9F),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Column(
                          children: const [
                            Text(
                              'REGISTER',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Continue as guest
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GuestHomeScreen(
                              onAuthRequired: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoginScreen(userType: 'trainee'),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Continue as a guest',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
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