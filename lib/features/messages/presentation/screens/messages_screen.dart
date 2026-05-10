import 'package:flutter/material.dart';

import '../../../../core/network/api_config.dart';
import '../../data/models/messages_models.dart';
import '../../data/repositories/messages_repository.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MessagesRepository _repo = MessagesRepository();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<ConversationModel> _conversations = [];
  String _query = '';

  List<ConversationModel> get _filteredConversations {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _conversations;
    return _conversations
        .where((conversation) {
          return conversation.name.toLowerCase().contains(query) ||
              conversation.lastMessage.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  int get _unreadTotal => _conversations.fold<int>(
    0,
    (total, conversation) => total + conversation.unreadCount,
  );

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        _error = 'Could not load messages right now.';
        _isLoading = false;
      });
    }
  }

  String _formatTime(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(messageDay).inDays;

    if (difference == 0) {
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    if (difference == 1) return 'Yest.';
    if (difference < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    }
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    final conversations = _filteredConversations;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FD),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
              child: IconButton(
                tooltip: 'Refresh',
                onPressed: _loadConversations,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF233B7A),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                '${_unreadTotal.clamp(0, 99)} UNREAD',
                style: const TextStyle(
                  color: Color(0xFF8B98B5),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.4,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: Text(
                'Messages.',
                style: TextStyle(
                  color: Color(0xFF13296B),
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: -1.1,
                ),
              ),
            ),
            _buildSearchBar(),
            const SizedBox(height: 18),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? _MessageState(
                      title: _error!,
                      actionLabel: 'Try again',
                      onPressed: _loadConversations,
                    )
                  : conversations.isEmpty
                  ? _MessageState(
                      title: _query.isEmpty
                          ? 'No conversations yet'
                          : 'No matching messages',
                      actionLabel: _query.isEmpty ? null : 'Clear search',
                      onPressed: _query.isEmpty
                          ? null
                          : () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                    )
                  : RefreshIndicator(
                      onRefresh: _loadConversations,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: conversations.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Color(0xFFDCE4F2)),
                        itemBuilder: (context, index) {
                          final conversation = conversations[index];
                          return _ConversationTile(
                            conversation: conversation,
                            time: _formatTime(conversation.lastMessageTime),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    otherUserId: conversation.userId,
                                    name: conversation.name,
                                    isOnline: conversation.isOnline,
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
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'Search messages',
          hintStyle: const TextStyle(
            color: Color(0xFF8A98B8),
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF8A98B8),
          ),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD8E1F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD8E1F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF65D6F4), width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final String time;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = conversation.name.isNotEmpty
        ? conversation.name[0].toUpperCase()
        : '?';
    final imageUrl = ApiConfig.resolveMediaUrl(conversation.imageUrl);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFDCE7F7),
                  backgroundImage: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : null,
                  child: imageUrl.isEmpty
                      ? Text(
                          firstLetter,
                          style: const TextStyle(
                            color: Color(0xFF243B85),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : null,
                ),
                if (conversation.isOnline)
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF39D98A),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF243B85),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    conversation.lastMessage.isEmpty
                        ? 'No messages yet'
                        : conversation.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF7080A4),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF8A98B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 13),
                if (conversation.unreadCount > 0)
                  Container(
                    constraints: const BoxConstraints(minWidth: 20),
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF67D7EF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Center(
                      child: Text(
                        conversation.unreadCount > 99
                            ? '99+'
                            : '${conversation.unreadCount}',
                        style: const TextStyle(
                          color: Color(0xFF14326D),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onPressed;

  const _MessageState({required this.title, this.actionLabel, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF7080A4),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (actionLabel != null && onPressed != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onPressed, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
