import 'package:flutter/material.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key});

  Widget _review(String name, String comment) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text(comment),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (_) => const Icon(Icons.star, size: 16, color: Colors.amber),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Recent Reviews"),
          _review("Ahmed Yasser",
              "Excellent coaching! Really improved my skills"),
          _review("Maria K.", "Very patient and professional."),
        ],
      ),
    );
  }

  Widget _title(String t) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(t,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("View All →",
              style: TextStyle(color: Colors.blue[700])),
        ],
      );
}