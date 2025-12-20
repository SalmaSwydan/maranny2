import 'package:flutter/material.dart';
import 'package:maranny_two/screens/home/widgets/search_bar.dart';

import '../../../theme/app_color.dart';
import 'categories.dart';
import 'categories_title.dart';
import 'header_top.dart';


class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          HeaderTop(),
          SizedBox(height: 8),
          SearchBarr(),
          SizedBox(height: 3),
          CategoriesTitle(),
          SizedBox(height: 5),
          Categories(),
        ],
      ),
    );
  }
}
