import 'package:flutter/material.dart';
import '../../../theme/app_color.dart';

class SearchBarr extends StatelessWidget {
  const SearchBarr({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Browse coaches by name",
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),

        // 👇 تثبيت حجم زر Search
        suffixIcon: Padding(
          padding: const EdgeInsets.all(6),
          child: SizedBox(
            width: 90, // 👈 مهم
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {},
                child: const Center(
                  child: Text(
                    "Search",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}