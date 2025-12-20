import 'package:flutter/material.dart';

class ComingSessions extends StatelessWidget {
  const ComingSessions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       // _sessionCard("Sarah Ahmed", "Dec 15", "2:00 PM"),
        SizedBox(height: 8),
        Row(
          children: [
            _sessionCard("Ahmed Mohamed", "Tomorrow", "10:00 AM"),
            SizedBox(width: 8),
            _sessionCard("Ziad Marwan", "Dec 21", "2:00 PM"),
          ],
        )
      ],
    ),
  );
}

Widget _sessionCard(String name, String date, String time) {
  return Expanded(
    child: Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(date),
            Text(time),
          ],
        ),
      ),
    ),
  );
}
  }
