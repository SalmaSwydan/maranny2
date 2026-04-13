import 'package:flutter/material.dart';
import 'booking_confirmed_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String day;
  final String time;
  // ✅ Coach info — customized per coach
  final String coachName;
  final String coachSport;
  final String coachImage;
  final int coachPrice;

  const PaymentScreen({
    super.key,
    required this.day,
    required this.time,
    this.coachName = 'Ahmed Mohamed',
    this.coachSport = 'Football Coach',
    this.coachImage = 'assets/images/coach_ahmed_mohamed.png',
    this.coachPrice = 500,
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
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Booking Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Booking Summary',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),

                  // ✅ Dynamic coach info
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: widget.coachImage.isNotEmpty
                            ? Image.asset(
                          widget.coachImage,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _avatarCircle(),
                        )
                            : _avatarCircle(),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.coachName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            widget.coachSport,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 10),

                  _summaryRow('Date & Time', '${widget.day}, ${widget.time}'),
                  const SizedBox(height: 8),
                  _summaryRow('Session Price', '${widget.coachPrice} LE'),
                  const SizedBox(height: 8),
                  _summaryRow('Total Amount', '${widget.coachPrice} LE', valueColor: Colors.blue),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Payment Method
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Payment Method',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),

            const SizedBox(height: 10),

            _paymentOption(0, 'Credit Card', Icons.credit_card),
            _paymentOption(1, 'Digital Wallet', Icons.account_balance_wallet_outlined),
            _paymentOption(2, 'Pay on Arrival', Icons.store_outlined),

            const Spacer(),

            // Pay button
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF303F9F),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Pay ${widget.coachPrice} LE',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarCircle() {
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFF303F9F),
      child: Text(
        widget.coachName.isNotEmpty ? widget.coachName[0].toUpperCase() : 'C',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87)),
      ],
    );
  }

  Widget _paymentOption(int value, String label, IconData icon) {
    return RadioListTile<int>(
      value: value,
      groupValue: selectedMethod,
      onChanged: (v) => setState(() => selectedMethod = v!),
      title: Row(
        children: [
          Icon(icon, color: const Color(0xFF303F9F), size: 20),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }
}
