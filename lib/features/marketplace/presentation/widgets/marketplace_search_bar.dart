import 'package:flutter/material.dart';

class MarketplaceSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const MarketplaceSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(
          color: Color(0xFF24345D),
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF8D99B5),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF8D99B5),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFE8EEF9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.tune_rounded,
                size: 18,
                color: Color(0xFF536489),
              ),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFD7E0F1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFD7E0F1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF8DDFF3), width: 1.4),
          ),
        ),
      ),
    );
  }
}
