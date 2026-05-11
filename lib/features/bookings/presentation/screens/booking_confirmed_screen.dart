import 'package:flutter/material.dart';
import 'package:maranny_two/layout/main_layout.dart';

class BookingConfirmedScreen extends StatelessWidget {
  final String coachName;
  final String coachSport;
  final String when;
  final String location;

  const BookingConfirmedScreen({
    super.key,
    this.coachName = 'Coach',
    this.coachSport = 'Session',
    this.when = 'Pending schedule',
    this.location = 'Coach location',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(
                  color: Color(0xFF5EDAF0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF101B3F),
                  size: 46,
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                "You're\nbooked.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF142A78),
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  height: 0.92,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '$coachName will confirm shortly. We’ll ping you the moment they do.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF7A88A8),
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFD7E0F2)),
                ),
                child: Column(
                  children: [
                    _SummaryLine(label: 'Coach', value: coachName),
                    const SizedBox(height: 9),
                    _SummaryLine(label: 'Sport', value: coachSport),
                    const SizedBox(height: 9),
                    _SummaryLine(label: 'When', value: when),
                    const SizedBox(height: 9),
                    _SummaryLine(label: 'Location', value: location),
                  ],
                ),
              ),
              const SizedBox(height: 0),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Home',
                      filled: false,
                      onTap: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainLayout()),
                        (route) => false,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      label: 'View bookings',
                      filled: true,
                      onTap: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainLayout(initialIndex: 1),
                        ),
                        (route) => false,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7A88A8),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF142A78),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: filled ? const Color(0xFF5EDAF0) : Colors.white,
          side: BorderSide(
            color: filled ? const Color(0xFF5EDAF0) : const Color(0xFFD7E0F2),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF101B3F),
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
