import 'package:flutter/material.dart';
import '../widgets/message_item.dart';
import 'chat_screen.dart';

class MessagesClientsScreen extends StatelessWidget {
  const MessagesClientsScreen({super.key});

  // Sample messages data
  final List<Map<String, dynamic>> _messages = const [
    {
      'name': 'Ahmed Mohamed',
      'message': "Can we reschedule tomorrow's session?",
      'time': '2:30 PM',
      'unreadCount': 1,
      'isOnline': true,
      'sessions': 8,
    },
    {
      'name': 'Fatima Ali',
      'message': "Thanks for the feedback! I'll work on it",
      'time': '1:15 PM',
      'unreadCount': null,
      'isOnline': true,
      'sessions': 12,
    },
    {
      'name': 'Mohammed Hassan',
      'message': 'When should I increase my training intensity?',
      'time': '11:45 AM',
      'unreadCount': 2,
      'isOnline': false,
      'sessions': 5,
    },
    {
      'name': 'Sarah Omar',
      'message': 'You: Great session today!',
      'time': 'Yesterday',
      'unreadCount': null,
      'isOnline': false,
      'sessions': 15,
    },
  ];

  // Get unique chat messages for each client
  List<Map<String, dynamic>> _getChatMessages(String name) {
    switch (name) {
      case 'Ahmed Mohamed':
        return [
          {
            'text': "Hi! How's your training going?",
            'isSent': true, // Coach - blue
            'time': '10:30 AM',
          },
          {
            'text': "It's going great! Really enjoying it.",
            'isSent': false, // Client - grey
            'time': '10:35 AM',
          },
          {
            'text': "Can we reschedule tomorrow's session?",
            'isSent': false, // Client - grey
            'time': '2:30 PM',
          },
        ];
      case 'Fatima Ali':
        return [
          {
            'text': "How did the practice go today?",
            'isSent': true, // Coach - blue
            'time': '9:15 AM',
          },
          {
            'text': "It was good! But I'm still struggling with my serve.",
            'isSent': false, // Client - grey
            'time': '9:20 AM',
          },
          {
            'text': "Let's focus on that in the next session. Keep practicing!",
            'isSent': true, // Coach - blue
            'time': '9:25 AM',
          },
          {
            'text': "Thanks for the feedback! I'll work on it",
            'isSent': false, // Client - grey
            'time': '1:15 PM',
          },
        ];
      case 'Mohammed Hassan':
        return [
          {
            'text': "When should I increase my training intensity?",
            'isSent': false, // Client - grey
            'time': '11:45 AM',
          },
          {
            'text': "Let's discuss that in person. You're making great progress!",
            'isSent': true, // Coach - blue
            'time': '11:50 AM',
          },
        ];
      case 'Sarah Omar':
        return [
          {
            'text': "Great session today!",
            'isSent': true, // Coach - blue
            'time': 'Yesterday',
          },
          {
            'text': "Thank you! I felt really good today.",
            'isSent': false, // Client - grey
            'time': 'Yesterday',
          },
          {
            'text': "Keep up the excellent work! See you next week.",
            'isSent': true, // Coach - blue
            'time': 'Yesterday',
          },
        ];
      default:
        return [
          {
            'text': "Hi! How's your training going?",
            'isSent': true,
            'time': '10:30 AM',
          },
          {
            'text': "It's going great!",
            'isSent': false,
            'time': '10:35 AM',
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // ✅ NO bottomNavigationBar - handled by CoachMainLayout
      body: Column(
        children: [
          // Header with gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF6FD3F5), // light blue
                  Color(0xFF1F3A93), // deep blue
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
                    const Text(
                      'Messages',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Messages list
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return MessageItem(
                    name: message['name'],
                    message: message['message'],
                    time: message['time'],
                    unreadCount: message['unreadCount'],
                    isOnline: message['isOnline'],
                    onTap: () {
                      final chatMessages = _getChatMessages(message['name']);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            name: message['name'],
                            isOnline: message['isOnline'],
                            sessions: message['sessions'],
                            initialMessages: chatMessages,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}