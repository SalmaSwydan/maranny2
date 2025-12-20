import 'package:flutter/material.dart';

class CategoriesTitle extends StatelessWidget {
  const CategoriesTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Sports Categories",
      style: TextStyle(
        color: Colors.white,
        fontSize: 21,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    );
  }
}