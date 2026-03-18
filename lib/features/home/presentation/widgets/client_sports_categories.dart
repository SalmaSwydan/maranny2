import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SportsCategoriesTwo extends StatelessWidget {
  const SportsCategoriesTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sports Categories',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              _Chip('All Sports', selected: true),
              _Chip('⚽ Football'),
              _Chip('🏀 Basketball'),
              _Chip('🎾 Tennis'),
            ],
          ),
        )
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool selected;

  const _Chip(this.text, {this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? AppColors.primaryBlue : Colors.white,
        ),
      ),
    );
  }
}
