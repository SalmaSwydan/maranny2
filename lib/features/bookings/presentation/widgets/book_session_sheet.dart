import 'package:flutter/material.dart';
import '../screens/payment_screen.dart';

class BookSessionSheet extends StatefulWidget {
  const BookSessionSheet({super.key});

  @override
  State<BookSessionSheet> createState() => _BookSessionSheetState();
}

class _BookSessionSheetState extends State<BookSessionSheet> {

  String? selectedDay;
  String? selectedTime;

  Widget timeButton(String day, String time) {

    bool isSelected = selectedTime == time;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDay = day;
          selectedTime = time;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget dayRow(String day, List<String> times) {
    return Column(
      children: [

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(
              width: 90,
              child: Text(
                day,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: Wrap(
                children: times
                    .map((time) => timeButton(day, time))
                    .toList(),
              ),
            ),
          ],
        ),

        const Divider(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Text(
            "Available days",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          dayRow("Saturday", ["9:00 AM", "11:00 AM"]),
          dayRow("Sunday", ["10:00 AM"]),
          dayRow("Monday", ["10:00 AM", "2:00 PM", "5:00 PM"]),
          dayRow("Tuesday", ["10:00 AM", "3:00 PM", "6:00 PM"]),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: selectedTime == null
                  ? null
                  : () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(
                      day: selectedDay!,
                      time: selectedTime!,
                    ),
                  ),
                );

              },
              child: const Text("Book Now"),
            ),
          ),
        ],
      ),
    );
  }
}