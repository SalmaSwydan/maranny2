import 'package:flutter/material.dart';
import 'chat_screen.dart';

// FILE: messages_screen.dart → CLASS: MessagesScreen (client side)
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final conversations = [
      _Conversation(
        name: 'Sarah Ahmed',
        lastMessage: "Don't forget tomorrow's session 👍",
        time: '2:30 PM',
        unread: 1,
        color: const Color(0xFF1565C0),
        emoji: '🏊',
      ),
      _Conversation(
        name: 'Ahmed Mohamed',
        lastMessage: 'See you next week',
        time: '1:10 PM',
        unread: 0,
        color: const Color(0xFF1F3A93),
        emoji: '⚽',
      ),
      _Conversation(
        name: 'Nancy Ali',
        lastMessage: 'Thanks for the review!',
        time: 'Yesterday',
        unread: 0,
        color: const Color(0xFF6A1B9A),
        emoji: '🧘',
      ),
      _Conversation(
        name: 'Ziad Marwan',
        lastMessage: 'Your booking is confirmed',
        time: 'Yesterday',
        unread: 1,
        color: const Color(0xFF00695C),
        emoji: '🎾',
      ),
      _Conversation(
        name: 'Omar Hassan',
        lastMessage: 'Let me know if you need anything',
        time: 'Mon',
        unread: 0,
        color: const Color(0xFFE65100),
        emoji: '🏋️',
      ),
      _Conversation(
        name: 'Mona Adel',
        lastMessage: 'Session moved to 3 PM',
        time: 'Mon',
        unread: 1,
        color: const Color(0xFFC62828),
        emoji: '🤸',
      ),
      _Conversation(
        name: 'Karim Samy',
        lastMessage: 'Great progress today!',
        time: 'Sun',
        unread: 0,
        color: const Color(0xFF880E4F),
        emoji: '🥊',
      ),
      _Conversation(
        name: 'Hala Youssef',
        lastMessage: 'Warm up before coming',
        time: 'Sun',
        unread: 0,
        color: const Color(0xFF1B5E20),
        emoji: '🧘',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // ── Header — NO back button (this is a tab screen) ──
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
              child: const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Messages',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Conversation list ──
          Expanded(
            child: ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, indent: 80, endIndent: 16),
              itemBuilder: (context, index) {
                final conv = conversations[index];
                return _ConversationTile(
                  conversation: conv,
                  onTap: () {
                    // ✅ Opens ChatScreen — file: chat_screen.dart
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          coachName: conv.name,
                          coachColor: conv.color,
                          coachEmoji: conv.emoji,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tile widget ──
class _ConversationTile extends StatelessWidget {
  final _Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: conversation.color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  conversation.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Time + unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  conversation.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: conversation.unread > 0
                        ? const Color(0xFF1F3A93)
                        : Colors.grey,
                    fontWeight: conversation.unread > 0
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 6),
                if (conversation.unread > 0)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1F3A93),
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data models ──
class _Conversation {
  final String name;
  final String lastMessage;
  final String time;
  final int unread;
  final Color color;
  final String emoji;

  const _Conversation({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.color,
    required this.emoji,
  });
}
