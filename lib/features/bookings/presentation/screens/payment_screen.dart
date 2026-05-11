import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../../data/models/bookings_models.dart';
import '../../data/repositories/bookings_repository.dart';
import 'booking_confirmed_screen.dart';
import '../utils/bookings_refresh_notifier.dart';

class PaymentScreen extends StatefulWidget {
  final int? sessionID;
  final int? coachID;
  final int? sportID;
  final String? sessionDate;
  final String? startTime;
  final String? location;
  final String day;
  final String time;
  final String coachName;
  final String coachSport;
  final String coachImage;
  final int coachPrice;

  const PaymentScreen({
    super.key,
    this.sessionID,
    this.coachID,
    this.sportID,
    this.sessionDate,
    this.startTime,
    this.location,
    required this.day,
    required this.time,
    this.coachName = 'Coach',
    this.coachSport = 'Coach',
    this.coachImage = '',
    this.coachPrice = 500,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final BookingsRepository _repo = BookingsRepository();

  static const int _payOnArrivalMethod = 2;
  int selectedMethod = _payOnArrivalMethod;
  bool _isBooking = false;

  String get _paymentMethodLabel => 'PayOnArrival';

  String get _selectedLocation {
    final value = widget.location?.trim() ?? '';
    return value.isEmpty ? 'Coach location' : value;
  }

  Future<void> _confirmBooking() async {
    if (_isBooking) return;

    final hasRealSession = widget.sessionID != null;
    final hasAvailabilityPayload =
        widget.coachID != null &&
        widget.sportID != null &&
        widget.sessionDate != null &&
        widget.startTime != null &&
        widget.sessionDate!.trim().isNotEmpty &&
        widget.startTime!.trim().isNotEmpty;

    if (!hasRealSession && !hasAvailabilityPayload) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not book this session. Please choose another time.',
          ),
        ),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      final finalScheduledAt = combineSessionDateAndTime(
        sessionDate: widget.sessionDate,
        startTime: widget.startTime,
      );
      final request = widget.sessionID != null
          ? BookSessionRequest(
              sessionID: widget.sessionID,
              notes: 'Booked from mobile app',
            )
          : BookSessionRequest(
              coachID: widget.coachID,
              sportID: widget.sportID,
              sessionDate: widget.sessionDate,
              startTime: widget.startTime,
              location: widget.location,
              notes: 'Booked from mobile app',
            );

      developer.log(
        'PaymentScreen booking submit -> '
        'coachId=${widget.coachID} '
        'sportId=${widget.sportID} '
        'sessionId=${widget.sessionID} '
        'selectedDate=${widget.sessionDate} '
        'selectedDay=${widget.day} '
        'selectedTime=${widget.startTime ?? widget.time} '
        'location=${widget.location ?? ''} '
        'requestBody=${request.toJson()} '
        'finalSessionDateTime=${finalScheduledAt?.toIso8601String() ?? ''} '
        'paymentMethod=$_paymentMethodLabel',
        name: 'PaymentScreen',
      );
      print(
        '[PaymentScreen] booking submit -> '
        'coachId=${widget.coachID} '
        'sportId=${widget.sportID} '
        'sessionId=${widget.sessionID} '
        'selectedDate=${widget.sessionDate} '
        'selectedDay=${widget.day} '
        'selectedTime=${widget.startTime ?? widget.time} '
        'location=${widget.location ?? ''} '
        'requestBody=${request.toJson()} '
        'finalSessionDateTime=${finalScheduledAt?.toIso8601String() ?? ''} '
        'paymentMethod=$_paymentMethodLabel',
      );

      await _repo.bookSession(request);
      BookingsRefreshNotifier.notifyUpdated();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BookingConfirmedScreen()),
        (route) => false,
      );
    } on DioException catch (error) {
      developer.log(
        'PaymentScreen booking failed -> '
        'status=${error.response?.statusCode} '
        'response=${error.response?.data} '
        'message=${error.message}',
        name: 'PaymentScreen',
        error: error,
      );
      print(
        '[PaymentScreen] booking failed -> '
        'status=${error.response?.statusCode} '
        'response=${error.response?.data} '
        'message=${error.message}',
      );
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_friendlyBookingError(error))));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not book this session. Please choose another time.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  bool get _isNetworkImage {
    return widget.coachImage.startsWith('http://') ||
        widget.coachImage.startsWith('https://');
  }

  String _friendlyBookingError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    final backendMessage = _extractBackendMessage(data);
    if (backendMessage != null) {
      return backendMessage;
    }
    if (statusCode == 401) {
      return 'Your session expired. Please sign in again and retry.';
    }
    if (statusCode == 403) {
      return 'You are not allowed to book this session.';
    }
    if (statusCode == 404) {
      return 'This session is no longer available.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server error while booking this session. Please try again.';
    }
    return 'Could not book this session. Please choose another time.';
  }

  String? _extractBackendMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final direct = data['message'] ?? data['error'] ?? data['title'];
      if (direct is String && direct.trim().isNotEmpty) {
        return direct.trim();
      }

      final errors = data['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            final first = value.first;
            if (first is String && first.trim().isNotEmpty) {
              return first.trim();
            }
          }
          if (value is String && value.trim().isNotEmpty) {
            return value.trim();
          }
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F7FF),
        elevation: 0,
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Color(0xFF101B3F),
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDDE5F4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Summary',
                    style: TextStyle(
                      color: Color(0xFF101B3F),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: widget.coachImage.isNotEmpty
                            ? _isNetworkImage
                                  ? Image.network(
                                      widget.coachImage,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _avatarCircle(),
                                    )
                                  : Image.asset(
                                      widget.coachImage,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _avatarCircle(),
                                    )
                            : _avatarCircle(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.coachName,
                              style: const TextStyle(
                                color: Color(0xFF101B3F),
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              widget.coachSport,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 10),
                  _summaryRow('Date & Time', '${widget.day}, ${widget.time}'),
                  const SizedBox(height: 8),
                  _summaryRow('Place', _selectedLocation),
                  const SizedBox(height: 8),
                  _summaryRow('Session Price', '${widget.coachPrice} LE'),
                  const SizedBox(height: 8),
                  _summaryRow(
                    'Total Amount',
                    '${widget.coachPrice} LE',
                    valueColor: Colors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Payment Method',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            _paymentOption(
              _payOnArrivalMethod,
              'Pay on Arrival',
              Icons.store_outlined,
            ),
            const SizedBox(height: 20),
            const _BookingPolicyNotice(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isBooking ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF304FFE),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 7,
                  shadowColor: const Color(0xFF304FFE).withValues(alpha: 0.32),
                ),
                child: _isBooking
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Confirm Booking',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _paymentOption(int value, String label, IconData icon) {
    final selected = selectedMethod == value;

    return GestureDetector(
      onTap: () => setState(() => selectedMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF303F9F) : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF303F9F), size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(label)),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? const Color(0xFF303F9F) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingPolicyNotice extends StatelessWidget {
  const _BookingPolicyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB9E6FE)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF1570EF), size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Before confirming',
                  style: TextStyle(
                    color: Color(0xFF175CD3),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _PolicyBullet(
            text:
                'By tapping Confirm Booking, you agree to Maranny’s booking terms and conditions.',
          ),
          SizedBox(height: 8),
          _PolicyBullet(
            text:
                'If you need to cancel, please contact your coach at least 24 hours before the session starts.',
          ),
          SizedBox(height: 8),
          _PolicyBullet(
            text:
                'Late cancellation or not attending without notice may result in an account warning.',
          ),
        ],
      ),
    );
  }
}

class _PolicyBullet extends StatelessWidget {
  final String text;

  const _PolicyBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(
            color: Color(0xFF1570EF),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF175CD3),
              fontSize: 12.5,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
