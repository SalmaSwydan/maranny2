import 'package:flutter/material.dart';

import '../widgets/get_started_section.dart';
import '../widgets/guest_home_header.dart';
import '../widgets/create_account_card.dart';
import '../widgets/why_maranny_section.dart';
import '../widgets/featured_coaches_section.dart';

class GuestHomeScreen extends StatelessWidget {
  final VoidCallback onAuthRequired;

  const GuestHomeScreen({
    super.key,
    required this.onAuthRequired,
  });

  void _showReadyToGetStarted(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return ReadyToGetStartedSheet(
          onTap: () {
            Navigator.pop(context);
            onAuthRequired();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        body: SingleChildScrollView(
          child: Column(
            children: [
              /// -------- Home Header --------
              /// ✅ FIX: category taps now show the bottom sheet first
              /// instead of jumping straight to sign up
              HomeHeader(
                onCategoryTap: () => _showReadyToGetStarted(context),
              ),

              const SizedBox(height: 16),

              /// -------- Create Account Card --------
              CreateAccountCard(
                onTap: onAuthRequired,
              ),

              const SizedBox(height: 16),

              /// -------- Why Maranny --------
              const WhyMarannySection(),

              const SizedBox(height: 16),

              /// -------- Featured Coaches --------
              FeaturedCoachesSection(
                onSeeMore: () => _showReadyToGetStarted(context),
              ),

              const SizedBox(height: 24),
            ],
          ),
        )
    );
    }
}
