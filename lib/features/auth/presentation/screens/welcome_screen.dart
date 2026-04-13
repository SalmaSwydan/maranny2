import 'package:flutter/material.dart';
import 'package:maranny_two/features/auth/presentation/screens/welcome_screen2.dart';
import 'package:maranny_two/features/home/presentation/screens/guest_homescreen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? selectedRole;

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
                'How would you like to use MARANNY?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
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
                    // Trainee button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => selectedRole = 'trainee');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WelcomeScreen2(userType: 'trainee'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: selectedRole == 'trainee'
                              ? Colors.white
                              : const Color(0xFF303F9F),
                          backgroundColor: selectedRole == 'trainee'
                              ? const Color(0xFF303F9F)
                              : Colors.white,
                          side: BorderSide(
                            color: selectedRole == 'trainee'
                                ? Colors.white
                                : const Color(0xFF303F9F),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Column(
                          children: [
                            Text('I am a Trainee',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            SizedBox(height: 2),
                            Text('(Find a Coach)',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w300)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Coach button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => selectedRole = 'coach');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WelcomeScreen2(userType: 'coach'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: selectedRole == 'coach'
                              ? Colors.white
                              : const Color(0xFF303F9F),
                          backgroundColor: selectedRole == 'coach'
                              ? const Color(0xFF303F9F)
                              : Colors.white,
                          side: BorderSide(
                            color: selectedRole == 'coach'
                                ? Colors.white
                                : const Color(0xFF303F9F),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Column(
                          children: [
                            Text('I am a Coach',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            SizedBox(height: 2),
                            Text('(Manage Sessions)',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w300)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ✅ FIX: Continue as guest → GuestHomeScreen
                    TextButton(
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue as a guest',
                            style: TextStyle(
                                color: Color(0xFF666666), fontSize: 14),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward,
                              size: 16, color: Color(0xFF666666)),
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
