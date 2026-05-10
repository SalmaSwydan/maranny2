import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const tabs = ['All', 'Equipment', 'Clothing', 'Accessories'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final tab = tabs[i];
          final isSelected = tab == selected;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(tab),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : const Color(0xFFEAF0FB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : const Color(0xFFD5DEEE),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(
                              alpha: 0.20,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF4E5D7E),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
