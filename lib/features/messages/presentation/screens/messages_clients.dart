import 'package:flutter/material.dart';
import '../../data/models/messages_models.dart';
import '../../data/repositories/messages_repository.dart';
import '../widgets/message_item.dart';
import 'CoachChatScreen.dart';

class MessagesClientsScreen extends StatefulWidget {
  const MessagesClientsScreen({super.key});

  @override
  State<MessagesClientsScreen> createState() => _MessagesClientsScreenState();
}

class _MessagesClientsScreenState extends State<MessagesClientsScreen> {
  final MessagesRepository _repo = MessagesRepository();

  bool _isLoading = true;
  String? _error;
  List<ConversationModel> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _repo.getConversations();

      if (!mounted) return;
      setState(() {
        _conversations = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load messages';
        _isLoading = false;
      });
    }
  }

  String _formatTime(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;

    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header — نفس الديزاين
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF6FD3F5), Color(0xFF1F3A93)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Messages',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _loadConversations,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Messages list — نفس الشكل باستخدام MessageItem
          Expanded(
            child: Container(
              color: Colors.white,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                child: TextButton(
                  onPressed: _loadConversations,
                  child: Text(_error!),
                ),
              )
                  : _conversations.isEmpty
                  ? const Center(child: Text('No messages yet'))
                  : RefreshIndicator(
                onRefresh: _loadConversations,
                child: ListView.builder(
                  itemCount: _conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = _conversations[index];

                    return MessageItem(
                      name: conversation.name,
                      message: conversation.lastMessage,
                      time: _formatTime(
                        conversation.lastMessageTime,
                      ),
                      unreadCount:
                      conversation.unreadCount > 0
                          ? conversation.unreadCount
                          : null,
                      isOnline: conversation.isOnline,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                CoachChatScreen(
                                  otherUserId:
                                  conversation.userId,
                                  name: conversation.name,
                                  isOnline:
                                  conversation.isOnline,
                                  sessions: 0,
                                ),
                          ),
                        );

                        _loadConversations();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}