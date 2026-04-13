import 'package:flutter/material.dart';

class ClientNotificationsScreen extends StatefulWidget {
  const ClientNotificationsScreen({super.key});

  @override
  State<ClientNotificationsScreen> createState() =>
      _ClientNotificationsScreenState();
}

class _ClientNotificationsScreenState
    extends State<ClientNotificationsScreen> {
  List<_NotifItem> _newNotifs = [
    _NotifItem(
      icon: Icons.check_circle,
      iconColor: const Color(0xFF1F3A93),
      title: 'Booking Confirmed',
      body: 'Your Session Sara Ahmed on Jan 13 at 2:00 pm is confirmed',
      time: '2 hours ago',
    ),
    _NotifItem(
      icon: Icons.chat_bubble_outline,
      iconColor: Colors.grey,
      title: 'New Message from Coach Ahmed',
      body: "Hey! I'm excited for our session. See you on Thursday!",
      time: '4 hours ago',
    ),
    _NotifItem(
      icon: Icons.timer_outlined,
      iconColor: Colors.grey,
      title: 'Session Reminder',
      body: 'Your football session with coach Ahmed starts in 24 hours',
      time: '21 hours ago',
    ),
  ];

  List<_NotifItem> _earlierNotifs = [
    _NotifItem(
      icon: Icons.star,
      iconColor: Colors.amber,
      title: 'Review Reminder',
      body: 'How is your session with coach Ahmed ? share your experience',
      time: '2 days ago',
    ),
    _NotifItem(
      icon: Icons.calendar_today,
      iconColor: const Color(0xFF1F3A93),
      title: 'Session Rescheduled',
      body: 'Coach Ahmed has rescheduled your session to Dec 20 at 7:00 PM',
      time: '3 days ago',
    ),
  ];

  void _clearAll() {
    setState(() {
      _newNotifs.clear();
      _earlierNotifs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // ── Header ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1F3A93), Color(0xFF6FD3F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                    ),
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ──
          Expanded(
            child: (_newNotifs.isEmpty && _earlierNotifs.isEmpty)
                ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No notifications',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
                : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Clear All
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _clearAll,
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        color: Color(0xFF1F3A93),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // New section
                if (_newNotifs.isNotEmpty) ...[
                  const Text('New',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 10),
                  ..._newNotifs.map((n) => _NotifCard(item: n)),
                  const SizedBox(height: 16),
                ],

                // Earlier section
                if (_earlierNotifs.isNotEmpty) ...[
                  const Text('Earlier',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 10),
                  ..._earlierNotifs.map((n) => _NotifCard(item: n)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final _NotifItem item;
  const _NotifCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: item.iconColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.icon, color: item.iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(item.body,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 6),
                  Text(item.time,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String time;

  const _NotifItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
  });
}
