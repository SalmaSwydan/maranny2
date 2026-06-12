import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/settings_repository.dart';

class SupportScreen extends StatefulWidget {
  final String userType;

  const SupportScreen({super.key, required this.userType});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final SettingsRepository _repository = SettingsRepository();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  int? _expandedFaq;
  bool _isSending = false;

  bool get _isCoach => widget.userType.toLowerCase() == 'coach';

  List<_FaqItem> get _faqs => _isCoach ? _coachFaqs : _clientFaqs;

  static const List<_FaqItem> _clientFaqs = [
    _FaqItem(
      'How do I book a session?',
      'Open Home, choose a coach, select one of the available times, then confirm your booking from the payment screen.',
    ),
    _FaqItem(
      'Where can I see my bookings?',
      'Go to Bookings. Upcoming, pending, and past sessions are separated so you can track each request clearly.',
    ),
    _FaqItem(
      'Can I message a coach?',
      'Yes. Open the coach profile or a booking card and use Messages to contact the coach directly.',
    ),
    _FaqItem(
      'How do reviews work?',
      'After a completed session, you can rate the coach and write feedback. The review appears on the coach profile.',
    ),
  ];

  static const List<_FaqItem> _coachFaqs = [
    _FaqItem(
      'How do I manage booking requests?',
      'Open Bookings to accept or decline pending requests. Confirmed sessions appear in your upcoming schedule.',
    ),
    _FaqItem(
      'Why is my coach account under review?',
      'New coach accounts are reviewed by the admin team. Verification usually takes 24 to 48 hours.',
    ),
    _FaqItem(
      'How do I update my availability?',
      'Open Profile, tap Edit Profile, and update your locations, days, times, price, and sports.',
    ),
    _FaqItem(
      'How do client reviews appear?',
      'Reviews submitted after completed sessions are loaded from the backend and shown on your coach profile.',
    ),
  ];

  Future<void> _sendMessage() async {
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(email)) {
      _showSnack('Please enter a valid email address.');
      return;
    }
    if (message.length < 10) {
      _showSnack('Please describe the issue in at least 10 characters.');
      return;
    }

    setState(() => _isSending = true);
    try {
      final responseMessage = await _repository.contactSupport(
        email: email,
        message: message,
      );
      if (!mounted) return;
      _emailController.clear();
      _messageController.clear();
      _showSuccess(responseMessage);
    } on DioException catch (error) {
      _showSnack(_friendlyError(error));
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  String _friendlyError(DioException error) {
    final status = error.response?.statusCode;
    if (status == 401) {
      return 'Please log in again to contact support.';
    }
    if (status == 400) {
      return 'Please check your message and try again.';
    }
    return 'Could not send your message right now. Please try again.';
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Color(0xFFDFF8EF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Color(0xFF10A66B)),
        ),
        title: const Text(
          'Message sent',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontFamily: 'Poppins',
            color: AppColors.deepBlue,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [
            _buildTopBar(),
            const SizedBox(height: 22),
            _buildHero(),
            const SizedBox(height: 20),
            _buildQuickHelp(),
            const SizedBox(height: 24),
            _sectionLabel('Common questions'),
            const SizedBox(height: 10),
            ..._faqs.asMap().entries.map(_faqCard),
            const SizedBox(height: 24),
            _sectionLabel('Need more help?'),
            const SizedBox(height: 10),
            _buildMessageCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        _circleButton(
          Icons.arrow_back_ios_new_rounded,
          () => Navigator.pop(context),
        ),
        const Spacer(),
        _circleButton(Icons.support_agent_rounded, () {}),
      ],
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SUPPORT CENTER',
          style: TextStyle(
            color: Color(0xFF91A0C0),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.4,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isCoach ? 'Coach support.' : 'How can we help?',
          style: const TextStyle(
            color: AppColors.deepBlue,
            fontSize: 34,
            height: 1,
            fontWeight: FontWeight.w900,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isCoach
              ? 'Manage requests, profile, reviews, and account verification.'
              : 'Find answers for bookings, payments, coaches, and your account.',
          style: const TextStyle(
            color: Color(0xFF657392),
            fontSize: 13,
            height: 1.45,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickHelp() {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            icon: Icons.mail_outline_rounded,
            title: 'Email',
            subtitle: _isCoach ? 'coaches@maranny.com' : 'support@maranny.com',
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _InfoCard(
            icon: Icons.schedule_rounded,
            title: 'Response',
            subtitle: 'Within 24 hours',
          ),
        ),
      ],
    );
  }

  Widget _faqCard(MapEntry<int, _FaqItem> entry) {
    final isOpen = _expandedFaq == entry.key;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE7FA)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => setState(() => _expandedFaq = isOpen ? null : entry.key),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.value.question,
                      style: const TextStyle(
                        color: AppColors.deepBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF8A96B5),
                  ),
                ],
              ),
              if (isOpen) ...[
                const SizedBox(height: 10),
                Text(
                  entry.value.answer,
                  style: const TextStyle(
                    color: Color(0xFF657392),
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFDDE7FA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send us a message',
            style: TextStyle(
              color: AppColors.deepBlue,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tell us what happened and our team will follow up.',
            style: TextStyle(
              color: Color(0xFF7A86A5),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          _input(
            controller: _emailController,
            hint: 'Your email address',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _input(
            controller: _messageController,
            hint: _isCoach
                ? 'Describe your coach account issue...'
                : 'Describe your issue...',
            icon: Icons.edit_note_rounded,
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _isSending ? null : _sendMessage,
              icon: _isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(_isSending ? 'Sending...' : 'Send message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        color: AppColors.deepBlue,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF8A96B5), size: 20),
        filled: true,
        fillColor: const Color(0xFFF3F7FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDDE7FA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.lightBlue, width: 1.4),
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppColors.deepBlue, size: 18),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF91A0C0),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.2,
        fontFamily: 'Inter',
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE7FA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.deepBlue, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.deepBlue,
              fontWeight: FontWeight.w900,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF7A86A5),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem(this.question, this.answer);
}
