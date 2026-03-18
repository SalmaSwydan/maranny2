import 'package:flutter/material.dart';
import 'package:maranny_two/features/onboarding/presentation/screens/Firstscreen.dart';
import 'package:maranny_two/features/onboarding/presentation/screens/Fourthscreen.dart';
import 'package:maranny_two/features/onboarding/presentation/screens/Secondscreen.dart';
import 'package:maranny_two/features/onboarding/presentation/screens/Thirdscreen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // متغير لتعقب الصفحة الحالية
  int currentPage = 0;

  // PageController للتحكم في PageView
  PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose(); // ضروري تنظف الكونترولر
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // الصفحة اللي هتسحب فيها
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  currentPage = page;
                });
              },
              children: [
                // هنا تحط شاشاتك الأربعة
                Firstscreen(), // شاشة 1
                Secondscreen(), // شاشة 2
                Thirdscreen(), // شاشة 3
                Fourthscreen(), // شاشة 4
              ],
            ),
          ),
        ],
      ),
    );
  }
}
