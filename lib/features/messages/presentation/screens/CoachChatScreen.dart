import 'package:flutter/material.dart';

import 'chat_screen.dart';

class CoachChatScreen extends StatelessWidget {
  final int otherUserId;
  final String name;
  final bool isOnline;
  final int sessions;

  const CoachChatScreen({
    super.key,
    required this.otherUserId,
    required this.name,
    required this.isOnline,
    this.sessions = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ChatScreen(otherUserId: otherUserId, name: name, isOnline: isOnline);
  }
}
