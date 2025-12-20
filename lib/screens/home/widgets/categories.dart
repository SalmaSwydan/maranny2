import 'package:flutter/material.dart';

class Categories extends StatelessWidget {
  
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ["All Sports", "Football", "Basketball", "Tennis","Paddel", "Volleyball"];
    return SizedBox(
    height: 50,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(left: 6),
          child: Chip(
            label: Text(categories[index]),
            backgroundColor:
                index == 0 ? Colors.blue : Colors.grey[200],
          ),
        );
      },
    ),
  );
  }
}