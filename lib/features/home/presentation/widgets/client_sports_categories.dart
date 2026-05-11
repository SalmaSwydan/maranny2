import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SportsCategoriesTwo extends StatelessWidget {
  const SportsCategoriesTwo({super.key});

  @override
  Widget build(BuildContext context) {
    const categories = [
      'All sports',
      'Football',
      'Padel',
      'Swimming',
      'Basketball',
      'Gym',
      'Tennis',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < categories.length; i++)
                _Chip(categories[i], selected: i == 0),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.deepBlue : const Color(0xFFEAF0FB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected ? AppColors.deepBlue : const Color(0xFFD7E0F2),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.deepBlue,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
