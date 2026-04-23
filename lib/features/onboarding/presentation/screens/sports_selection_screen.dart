import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'client_preferences_screen.dart';

class SportsSelectionScreen extends StatefulWidget {
  const SportsSelectionScreen({super.key});

  @override
  State<SportsSelectionScreen> createState() => _SportsSelectionScreenState();
}

class _SportsSelectionScreenState extends State<SportsSelectionScreen> {
  final Set<String> _selected = {};

  static const int _minimum = 3;

  static const List<Map<String, String>> _sports = [
    {'name': 'Fitness', 'emoji': '🏋️'},
    {'name': 'Wrestling', 'emoji': '🤼'},
    {'name': 'Weightlifting', 'emoji': '🏋️'},
    {'name': 'Martial Arts', 'emoji': '🥋'},
    {'name': 'Boxing', 'emoji': '🥊'},
    {'name': 'Swimming', 'emoji': '🏊'},
    {'name': 'Diving', 'emoji': '🤿'},
    {'name': 'Football', 'emoji': '⚽'},
    {'name': 'Basketball', 'emoji': '🏀'},
    {'name': 'Volleyball', 'emoji': '🏐'},
    {'name': 'Handball', 'emoji': '🤾'},
    {'name': 'Gymnastics', 'emoji': '🤸'},
    {'name': 'Ballet', 'emoji': '🩰'},
    {'name': 'Pilates', 'emoji': '🧘'},
    {'name': 'Lifestyle', 'emoji': '🌿'},
    {'name': 'Dancing', 'emoji': '💃'},
    {'name': 'Skating', 'emoji': '⛸️'},
    {'name': 'Padel', 'emoji': '🎾'},
    {'name': 'Squash', 'emoji': '🎾'},
    {'name': 'Tennis', 'emoji': '🎾'},
    {'name': 'Badminton', 'emoji': '🏸'},
    {'name': 'Equestrian', 'emoji': '🐎'},
    {'name': 'Track and Field', 'emoji': '🏃'},
    {'name': 'Strength & Conditioning', 'emoji': '💪'},
    {'name': 'Archery', 'emoji': '🏹'},
    {'name': 'Fencing', 'emoji': '🤺'},
    {'name': 'Nutrition', 'emoji': '🥗'},
    {'name': 'Yoga', 'emoji': '🧘'},
    {'name': 'CrossFit', 'emoji': '🏋️'},
    {'name': 'MMA', 'emoji': '🥋'},
    {'name': 'Karate', 'emoji': '🥋'},
    {'name': 'Judo', 'emoji': '🥋'},
    {'name': 'Taekwondo', 'emoji': '🥋'},
    {'name': 'Kickboxing', 'emoji': '🥊'},
    {'name': 'Kung Fu', 'emoji': '🥋'},
    {'name': 'Calisthenics', 'emoji': '🤸'},
    {'name': 'Rehabilitation', 'emoji': '🏥'},
    {'name': 'Horse Riding', 'emoji': '🐎'},
  ];

  bool get _canContinue => _selected.length >= _minimum;

  void _toggle(String sport) {
    setState(() {
      if (_selected.contains(sport)) {
        _selected.remove(sport);
      } else {
        _selected.add(sport);
      }
    });
  }

  void _continue() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ClientPreferencesScreen(
          selectedSports: _selected.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Text(
                '100+ sports profiles',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pick your favorite sports and start your journey.',
                style: TextStyle(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: _sports.map((sport) {
                        final name = sport['name']!;
                        final emoji = sport['emoji']!;
                        final selected = _selected.contains(name);

                        return GestureDetector(
                          onTap: () => _toggle(name),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: selected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.4),
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              '$name $emoji',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: selected
                                    ? AppColors.primaryBlue
                                    : Colors.white,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  children: [
                    Text(
                      'Selected: ${_selected.length} / Minimum: $_minimum',
                      style: TextStyle(
                        color: _canContinue ? Colors.white : Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _canContinue ? _continue : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          _canContinue ? Colors.white : Colors.white30,
                          foregroundColor: AppColors.primaryBlue,
                          disabledBackgroundColor: Colors.white30,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _canContinue
                              ? 'Continue →'
                              : 'Select $_minimum sports to continue',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}