import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7E0F2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF8190AD), size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Search coaches, sports, areas...',
              style: TextStyle(
                color: Color(0xFF8190AD),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppColors.deepBlue,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
