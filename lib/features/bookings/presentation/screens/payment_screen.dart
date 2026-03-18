import 'package:flutter/material.dart';
import 'booking_confirmed_screen.dart';

class PaymentScreen extends StatefulWidget {

  final String day;
  final String time;

  const PaymentScreen({
    super.key,
    required this.day,
    required this.time,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  int selectedMethod = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Payment"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Booking Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Booking Summary",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [

                      const CircleAvatar(
                        backgroundImage:
                        AssetImage("assets/images/coach_ahmed_mohamed.png"),
                      ),

                      const SizedBox(width: 10),

                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Ahmed Mohamed"),
                          Text(
                            "Football Coach",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Date & Time"),
                      Text("${widget.day}, ${widget.time}"),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Session Price"),
                      Text("\$25"),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Amount"),
                      Text(
                        "\$25",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Payment Method",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            RadioListTile(
              value: 0,
              groupValue: selectedMethod,
              title: const Text("Credit Card"),
              onChanged: (value) {
                setState(() {
                  selectedMethod = value!;
                });
              },
            ),

            RadioListTile(
              value: 1,
              groupValue: selectedMethod,
              title: const Text("Digital Wallet"),
              onChanged: (value) {
                setState(() {
                  selectedMethod = value!;
                });
              },
            ),

            RadioListTile(
              value: 2,
              groupValue: selectedMethod,
              title: const Text("Pay on Arrival"),
              onChanged: (value) {
                setState(() {
                  selectedMethod = value!;
                });
              },
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookingConfirmedScreen(),
                    ),
                  );

                },
                child: const Text("Pay \$25"),
              ),
            )
          ],
        ),
      ),
    );
  }
}