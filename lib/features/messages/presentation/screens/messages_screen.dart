import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final chat = messages[index];
          return MessageTile(chat: chat);
        },
      ),
    );
  }
}

/// Message Tile

class MessageTile extends StatelessWidget {
  final ChatModel chat;

  const MessageTile({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        //    chat details
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            /// Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primaryBlue,
              child: Text(
                chat.emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),

            const SizedBox(width: 12),

            /// Name + Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            /// Time + unread
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                if (chat.unread)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


/// Model

class ChatModel {
  final String name;
  final String lastMessage;
  final String time;
  final bool unread;
  final String emoji;

  ChatModel({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.emoji,
  });
}

/// Fake Data (10 chats)

final List<ChatModel> messages = [
  ChatModel(
    name: 'Sarah Ahmed',
    lastMessage: 'Don’t forget tomorrow’s session 👍',
    time: '2:30 PM',
    unread: true,
    emoji: '🏊‍♀️',
  ),
  ChatModel(
    name: 'Ahmed Mohamed',
    lastMessage: 'See you next week',
    time: '1:10 PM',
    unread: false,
    emoji: '⚽',
  ),
  ChatModel(
    name: 'Nancy Ali',
    lastMessage: 'Thanks for the review!',
    time: 'Yesterday',
    unread: false,
    emoji: '🧘‍♀️',
  ),
  ChatModel(
    name: 'Ziad Marwan',
    lastMessage: 'Your booking is confirmed',
    time: 'Yesterday',
    unread: true,
    emoji: '🎾',
  ),
  ChatModel(
    name: 'Omar Hassan',
    lastMessage: 'Let me know if you need anything',
    time: 'Mon',
    unread: false,
    emoji: '🏋️‍♂️',
  ),
  ChatModel(
    name: 'Mona Adel',
    lastMessage: 'Session moved to 3 PM',
    time: 'Mon',
    unread: true,
    emoji: '🤸‍♀️',
  ),
  ChatModel(
    name: 'Karim Samy',
    lastMessage: 'Great progress today!',
    time: 'Sun',
    unread: false,
    emoji: '🥊',
  ),
  ChatModel(
    name: 'Hala Youssef',
    lastMessage: 'Warm up before coming',
    time: 'Sun',
    unread: false,
    emoji: '🧘',
  ),
  ChatModel(
    name: 'Youssef Ali',
    lastMessage: 'Please confirm attendance',
    time: 'Sat',
    unread: true,
    emoji: '🏀',
  ),
  ChatModel(
    name: 'Nada Mahmoud',
    lastMessage: 'Nice session today 👏',
    time: 'Sat',
    unread: false,
    emoji: '🏃‍♀️',
  ),
];
