import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../sports/data/models/sport_model.dart';
import '../../../sports/data/repositories/sports_repository.dart';
import 'client_preferences_screen.dart';

class SportsSelectionScreen extends StatefulWidget {
  final String? pendingEmail;
  final bool returnToLoginAfterSave;

  const SportsSelectionScreen({
    super.key,
    this.pendingEmail,
    this.returnToLoginAfterSave = false,
  });

  @override
  State<SportsSelectionScreen> createState() => _SportsSelectionScreenState();
}

class _SportsSelectionScreenState extends State<SportsSelectionScreen> {
  static const int _minimum = 1;

  final SportsRepository _sportsRepository = SportsRepository();
  final Set<String> _selected = {};
  late final Future<List<SportModel>> _sportsFuture;

  @override
  void initState() {
    super.initState();
    _sportsFuture = _sportsRepository.getSports();
  }

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
          pendingEmail: widget.pendingEmail,
          returnToLoginAfterSave: widget.returnToLoginAfterSave,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/background_screen.png'),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0C83D7).withValues(alpha: 0.50),
                const Color(0xFF101E8E).withValues(alpha: 0.72),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Image.asset(
                  'assets/images/maranny_logo.png',
                  width: 92,
                  height: 92,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Choose your sport',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pick at least one sport so we can personalize your recommendations.',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder<List<SportModel>>(
                    future: _sportsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      final sports = snapshot.data ?? const <SportModel>[];
                      if (sports.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'No sports are available right now.',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: sports.map((sport) {
                              final selected = _selected.contains(sport.name);
                              return GestureDetector(
                                onTap: () => _toggle(sport.name),
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
                                    sport.name,
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
                      );
                    },
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
                            backgroundColor: _canContinue
                                ? Colors.white
                                : Colors.white30,
                            foregroundColor: AppColors.primaryBlue,
                            disabledBackgroundColor: Colors.white30,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _canContinue
                                ? 'Continue ->'
                                : 'Select $_minimum sport to continue',
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
      ),
    );
  }
}
