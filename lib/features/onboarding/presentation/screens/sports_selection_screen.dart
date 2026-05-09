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
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => ClientPreferencesScreen(
          selectedSports: _selected.toList(),
          pendingEmail: widget.pendingEmail,
          returnToLoginAfterSave: widget.returnToLoginAfterSave,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.06, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
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
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _StepProgressHeader(
                    step: 2,
                    totalSteps: 3,
                    title: 'Choose your sports',
                    subtitle:
                        'Pick at least one sport you care about. We will tune coach matches around it.',
                  ),
                ),
                const SizedBox(height: 18),
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
                        _selected.isEmpty
                            ? 'Select at least one sport to unlock recommendations'
                            : '${_selected.length} sport${_selected.length == 1 ? '' : 's'} selected',
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
                                ? 'Continue to preferences ->'
                                : 'Choose a sport to continue',
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

class _StepProgressHeader extends StatelessWidget {
  final int step;
  final int totalSteps;
  final String title;
  final String subtitle;

  const _StepProgressHeader({
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STEP $step OF $totalSteps',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(totalSteps, (index) {
            final active = index < step;
            return Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 7),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.82),
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
