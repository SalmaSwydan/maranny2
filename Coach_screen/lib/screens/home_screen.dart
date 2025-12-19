import 'package:flutter/material.dart';
import 'package:maranny32/widgets/bottom_navigation.dart';
import 'package:maranny32/widgets/header.dart';
import 'package:maranny32/widgets/pending_requests_section.dart';
import 'package:maranny32/widgets/rewiews.dart';
import 'package:maranny32/widgets/stats_cards.dart';
import 'package:maranny32/widgets/today_schedule.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffD9D9D9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: const [
              Header(),
              StatsCards(),
              TodaySchedule(),
              PendingRequestsSection(),
              ReviewsSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}