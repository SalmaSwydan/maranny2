import 'package:flutter/material.dart';
import 'package:maranny_two/features/auth/presentation/screens/welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<Map<String, String>> _pages = [
    {
      'icon': 'verified_user',
      'title': 'VERIFIED COACHES',
      'subtitle': 'Reserve training packages seamlessly with verified coaches',
    },
    {
      'icon': 'auto_awesome',
      'title': 'Smart Recommendation',
      'subtitle': 'AI-powered suggestions tailored to your sports interests',
    },
    {
      'icon': 'location_on',
      'title': 'Find Nearby',
      'subtitle': 'Discover sports facilities and coaches near you instantly',
    },
    {
      'icon': 'calendar_month',
      'title': 'Book Sessions',
      'subtitle': 'Reserve training packages seamlessly with verified coaches',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToWelcome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
    );
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToWelcome();
    }
  }

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
              const SizedBox(height: 20),

              // ── Logo ──
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/maranny_logo.png',
                  width: 130, height: 130, fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              const Text('Maranny',
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 4),
              const Text(
                'Your Gateway to Professional Sports Coaching',
                style: TextStyle(fontSize: 13, color: Colors.white70),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // ── Sliding card — matches Figma size ──
              SizedBox(
                // ✅ Fixed height matching Figma card proportions
                height: size.height * 0.28,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (page) =>
                      setState(() => _currentPage = page),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon with circle background like Figma
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _iconFromString(page['icon']!),
                                color: Colors.white, size: 30,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              page['title']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              page['subtitle']!,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ── Page indicator ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  final bool active = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: active ? 28 : 8,
                    height: active ? 4 : 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius:
                      BorderRadius.circular(active ? 2 : 4),
                    ),
                  );
                }),
              ),

              const Spacer(),

              // ── Buttons ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    // Next / Get Started button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton(
                        onPressed: _next,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                              color: Colors.white, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          // ✅ "Next" on pages 1-3, "Get Started" on last page
                          _isLastPage ? 'Get Started' : 'Next',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    // ✅ Skip button — hidden on last page
                    if (!_isLastPage)
                      TextButton(
                        onPressed: _goToWelcome,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    else
                      const SizedBox(height: 40),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFromString(String name) {
    switch (name) {
      case 'verified_user':
        return Icons.verified_user;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'location_on':
        return Icons.location_on;
      case 'calendar_month':
        return Icons.calendar_month;
      default:
        return Icons.star;
    }
  }
}