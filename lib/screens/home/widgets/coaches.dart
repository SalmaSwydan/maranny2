import 'package:flutter/material.dart';

class Coaches extends StatelessWidget {
  const Coaches({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
      //  _sectiontitl("Coaches for you", "See more"),
        SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              return _coachCard();
            },
          ),
        ),
      ],
    ),
  );
}

Widget _coachCard() {
  return Container(
    width: 140,
    margin: EdgeInsets.only(right: 12),
    child: Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            CircleAvatar(radius: 30),
            SizedBox(height: 8),
            Text("Ahmed Mohamed",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Football"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, size: 14, color: Colors.orange),
                Text("4.9"),
              ],
            )
          ],
        ),
      ),
    ),
  );
  }
  
  
}