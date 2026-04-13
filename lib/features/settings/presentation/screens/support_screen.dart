import 'package:flutter/material.dart';

/// Usage:
///   SupportScreen(userType: 'client')   ← from client side menu
///   SupportScreen(userType: 'coach')    ← from coach side menu
class SupportScreen extends StatefulWidget {
  final String userType;
  const SupportScreen({super.key, required this.userType});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  static const _blue1 = Color(0xFF1F3A93);
  static const _blue2 = Color(0xFF6FD3F5);

  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  int? _expandedFaq;

  bool get _isCoach => widget.userType == 'coach';

  // ─── CLIENT FAQs ──────────────────────────────────────────
  static const _clientFaqs = [
    {
      'q': 'How do I book a session with a coach?',
      'a':
      'Go to the Home tab and browse available coaches. Tap on a coach to view their profile, then tap "Book Session" to pick a time slot and confirm your booking.',
    },
    {
      'q': 'How do I cancel or reschedule a booking?',
      'a':
      'Open the Bookings tab, find your upcoming session, and tap "Manage". You can cancel or request a reschedule up to 24 hours before the session starts.',
    },
    {
      'q': 'How do payments work?',
      'a':
      'Payments are processed securely when you confirm a booking. Refunds for cancellations are processed within 3–5 business days.',
    },
    {
      'q': 'How do I become a coach on Maranny?',
      'a':
      'Log out of your current account and go back to the Welcome screen. Tap "I am a Coach", then tap Register. You will complete 4 steps: your basic info, your specialties, your available days, and optional certifications. Our team reviews your profile within 24–48 hours before it goes live.',
    },
    {
      'q': 'How do I report a coach?',
      'a':
      'Open the side menu and tap "Report". Search for the coach by name or email, select a reason, and add a description. Our moderation team reviews all reports within 24 hours.',
    },
    {
      'q': 'My payment failed — what should I do?',
      'a':
      'Check that your payment method is valid and has sufficient funds. If the issue persists, remove and re-add your payment method in Settings, then try again or contact us.',
    },
    {
      'q': 'How do I update my profile?',
      'a':
      'Go to the Profile tab and tap "Edit Profile". You can update your name, photo, bio, and contact details at any time.',
    },
    {
      'q': 'How do I find coaches near me?',
      'a':
      'On the Home screen, use the Nearby Facilities section or the search bar to filter coaches by location, sport, or price.',
    },
  ];

  // ─── COACH FAQs ───────────────────────────────────────────
  static const _coachFaqs = [
    {
      'q': 'How do I set or update my availability?',
      'a':
      'Go to your Profile tab and tap "Edit Profile". Update the days and time slots you are available. Changes take effect immediately for new bookings.',
    },
    {
      'q': 'How do I accept or decline a booking request?',
      'a':
      'Open the Bookings tab to see all pending requests. Tap any request to confirm or decline it. You will also receive a push notification for every new booking.',
    },
    {
      'q': 'How and when do I get paid?',
      'a':
      'Payments are released to your linked payout account after a session is completed and confirmed. Processing takes 3–5 business days. Manage your payout method in Settings → Payment Settings.',
    },
    {
      'q': 'How do I update my specialties or session price?',
      'a':
      'Go to the Profile tab and tap "Edit Profile". You can update your sports specialties, session price, location, bio, and profile photo at any time.',
    },
    {
      'q': 'How do I upload or update my certifications?',
      'a':
      'Go to Profile → Edit Profile and scroll to Certifications. Upload PDF files up to 10 MB each. New certifications are reviewed before appearing on your public profile.',
    },
    {
      'q': 'A client did not show up — what do I do?',
      'a':
      'Open the Bookings tab, find the session, and mark it as a no-show. Our team will review the case. Clients with repeated no-shows may face account restrictions.',
    },
    {
      'q': 'How do I message my clients?',
      'a':
      'Use the Messages tab to chat directly with your clients. You can send reminders, session notes, or follow-up messages after a session.',
    },
    {
      'q': 'My profile is under review — how long does it take?',
      'a':
      'Coach profile reviews typically take 24–48 hours. You will receive a notification once your profile is approved and visible to clients.',
    },
  ];

  List<Map<String, String>> get _faqs =>
      List<Map<String, String>>.from(_isCoach ? _coachFaqs : _clientFaqs);

  void _sendMessage() {
    if (_emailController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields.')),
      );
      return;
    }
    _emailController.clear();
    _messageController.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('Message Sent'),
        ]),
        content: const Text(
            'Thanks for reaching out! Our support team will respond within 24 hours.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:
              const Text('OK', style: TextStyle(color: _blue1))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildContactCards(),
                if (_isCoach) ...[
                  const SizedBox(height: 12),
                  _buildCoachResourcesBanner(),
                ],
                const SizedBox(height: 20),
                _buildSectionLabel('Frequently Asked Questions'),
                const SizedBox(height: 10),
                ..._buildFaqItems(),
                const SizedBox(height: 20),
                _buildSectionLabel("Didn't find what you need?"),
                const SizedBox(height: 10),
                _buildMessageForm(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [_blue1, _blue2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text('Support',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ]),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  _isCoach
                      ? 'Coach support centre'
                      : 'How can we help you?',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Contact cards ────────────────────────────────────────
  Widget _buildContactCards() {
    return Row(
      children: [
        Expanded(
          child: _ContactCard(
            icon: Icons.email_outlined,
            label: 'Email Us',
            value: _isCoach
                ? 'coaches@maranny.com'
                : 'support@maranny.com',
            color: _blue1,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ContactCard(
            icon: Icons.chat_bubble_outline,
            label: 'Live Chat',
            value: 'Available 9am–6pm',
            color: Colors.teal,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Live chat coming soon')),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Coach-only resources banner ──────────────────────────
  Widget _buildCoachResourcesBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(12),
        border:
        Border.all(color: _blue2.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _blue1.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.menu_book_outlined,
                color: _blue1, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Coach Resources',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _blue1)),
                SizedBox(height: 2),
                Text(
                    'Tips, guides and best practices for coaches',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  // ─── FAQ accordion ────────────────────────────────────────
  List<Widget> _buildFaqItems() {
    return _faqs.asMap().entries.map((entry) {
      final i = entry.key;
      final faq = entry.value;
      final isOpen = _expandedFaq == i;
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () =>
              setState(() => _expandedFaq = isOpen ? null : i),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: Text(faq['q']!,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87))),
                  Icon(
                      isOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                      size: 20),
                ]),
                if (isOpen) ...[
                  const SizedBox(height: 10),
                  Divider(height: 1, color: Colors.grey.shade100),
                  const SizedBox(height: 10),
                  Text(faq['a']!,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.5)),
                ],
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // ─── Send message form ────────────────────────────────────
  Widget _buildMessageForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Send Us a Message',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("We'll get back to you within 24 hours.",
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          _label('Your Email'),
          const SizedBox(height: 6),
          _inputField(
            controller: _emailController,
            hint: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _label('Message'),
          const SizedBox(height: 6),
          _inputField(
            controller: _messageController,
            hint: _isCoach
                ? 'Describe your issue as a coach…'
                : 'Describe your issue in detail…',
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send, size: 16),
              label: const Text('Send Message',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue1,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5));

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600));

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        const TextStyle(fontSize: 12, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _blue1)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CONTACT CARD
// ─────────────────────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;
  const _ContactCard(
      {required this.icon,
        required this.label,
        required this.value,
        required this.color,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}