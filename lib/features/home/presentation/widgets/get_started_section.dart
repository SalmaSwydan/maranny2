import 'package:flutter/material.dart';

class ReadyToGetStartedSheet extends StatelessWidget {
  final VoidCallback onTap;

  const ReadyToGetStartedSheet({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1F3A93);
    const lightBlue = Color(0xFF6FD3F5);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          const Text(
            'Ready to get started?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          const Text(
            'Create an account or login to book your first coaching session',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: Ink(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue, lightBlue],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(28),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
