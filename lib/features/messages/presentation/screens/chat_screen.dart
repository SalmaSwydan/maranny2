import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_config.dart';
import '../../data/models/messages_models.dart';
import '../../data/repositories/messages_repository.dart';

class ChatScreen extends StatefulWidget {
  final int otherUserId;
  final String name;
  final bool isOnline;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.name,
    required this.isOnline,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessagesRepository _repo = MessagesRepository();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = true;
  bool _isSending = false;
  String? _error;
  List<MessageModel> _messages = [];
  final Map<int, String> _reactions = <int, String>{};

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _repo.getConversation(widget.otherUserId);
      await _repo.markAsRead(widget.otherUserId);

      if (!mounted) return;
      setState(() {
        _messages = data;
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load messages right now.';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _controller.clear();

    try {
      await _repo.sendMessage(
        SendMessageRequest(receiverId: widget.otherUserId, content: text),
      );

      await _loadMessages();
    } on DioException catch (e) {
      final data = e.response?.data;
      final errorText = data is Map<String, dynamic>
          ? (data['error'] ?? data['message'] ?? '').toString().trim()
          : '';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorText.isNotEmpty ? errorText : 'Failed to send message',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to send message')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _shouldShowDateDivider(int index) {
    if (index == 0) return true;
    final current = DateTime.tryParse(_messages[index].sentAt);
    final previous = DateTime.tryParse(_messages[index - 1].sentAt);
    if (current == null || previous == null) return false;
    return current.year != previous.year ||
        current.month != previous.month ||
        current.day != previous.day;
  }

  String _formatDateDivider(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return '';

    const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${weekdays[date.weekday - 1]}  ${date.day}  ${months[date.month - 1]}';
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FD),
      body: Column(
        children: [
          _ChatHeader(
            name: widget.name,
            isOnline: widget.isOnline,
            onBack: () => Navigator.pop(context),
            onRefresh: _loadMessages,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _ChatState(title: _error!, onRetry: _loadMessages)
                : _messages.isEmpty
                ? const _ChatState(title: 'No messages yet')
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(10, 16, 10, 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return Column(
                        children: [
                          if (_shouldShowDateDivider(index))
                            _DateDivider(label: _formatDateDivider(msg.sentAt)),
                          _MessageBubble(
                            messageId: msg.messageID,
                            text: msg.content,
                            messageType: msg.messageType,
                            attachmentUrl: msg.attachmentUrl,
                            latitude: msg.latitude,
                            longitude: msg.longitude,
                            isMine: msg.isMine,
                            isRead: msg.isRead || msg.readAt != null,
                            reaction: _reactions[msg.messageID],
                            onReact: _showReactionPicker,
                          ),
                        ],
                      );
                    },
                  ),
          ),
          _MessageComposer(
            controller: _controller,
            isSending: _isSending,
            onSend: _sendMessage,
            onAttach: _showAttachmentOptions,
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              _AttachmentOption(
                icon: Icons.photo_outlined,
                label: 'Photo',
                onTap: () => _sendPhotoAttachment(context),
              ),
              const SizedBox(width: 14),
              _AttachmentOption(
                icon: Icons.location_on_outlined,
                label: 'Location',
                onTap: () => _sendLocationAttachment(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendPhotoAttachment(BuildContext sheetContext) async {
    Navigator.of(sheetContext).pop();
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null || _isSending) return;

    setState(() => _isSending = true);
    try {
      await _repo.sendAttachment(
        receiverId: widget.otherUserId,
        messageType: 'image',
        content: 'Photo attachment',
        file: File(image.path),
      );
      await _loadMessages();
    } on DioException catch (e) {
      _showSendError(e);
    } catch (_) {
      _showGenericSendError();
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendLocationAttachment(BuildContext sheetContext) async {
    Navigator.of(sheetContext).pop();
    if (_isSending) return;

    final position = await _getCurrentPosition();
    if (position == null) return;

    setState(() => _isSending = true);
    try {
      await _repo.sendAttachment(
        receiverId: widget.otherUserId,
        messageType: 'location',
        content: 'Location shared',
        latitude: position.latitude,
        longitude: position.longitude,
      );
      await _loadMessages();
    } on DioException catch (e) {
      _showSendError(e);
    } catch (_) {
      _showGenericSendError();
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<Position?> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnack('Please enable location services first.');
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showSnack('Location permission is required to share your location.');
      return null;
    }

    return Geolocator.getCurrentPosition();
  }

  void _showSendError(DioException e) {
    final data = e.response?.data;
    final errorText = data is Map<String, dynamic>
        ? (data['error'] ?? data['message'] ?? '').toString().trim()
        : '';
    _showSnack(errorText.isNotEmpty ? errorText : 'Failed to send attachment');
  }

  void _showGenericSendError() {
    _showSnack('Failed to send attachment');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showReactionPicker(int messageId) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ['❤️', '👍', '😂', '🔥', '👏'].map((emoji) {
              return ActionChip(
                label: Text(emoji, style: const TextStyle(fontSize: 22)),
                onPressed: () {
                  setState(() => _reactions[messageId] = emoji);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final String name;
  final bool isOnline;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  const _ChatHeader({
    required this.name,
    required this.isOnline,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F7FD),
        border: Border(bottom: BorderSide(color: Color(0xFFDCE4F2))),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _CircleIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack,
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFDCE7F7),
              child: Text(
                firstLetter,
                style: const TextStyle(
                  color: Color(0xFF233B7A),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF243B85),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isOnline
                              ? const Color(0xFF65D98F)
                              : const Color(0xFF9BA8C4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isOnline ? 'Online' : 'Last seen recently',
                        style: TextStyle(
                          color: isOnline
                              ? const Color(0xFF55C982)
                              : const Color(0xFF8B98B5),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _CircleIconButton(icon: Icons.refresh_rounded, onTap: onRefresh),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF0FB),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD5DEEE)),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF243B85)),
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  final String label;

  const _DateDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF8B98B5),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final int messageId;
  final String text;
  final String messageType;
  final String? attachmentUrl;
  final double? latitude;
  final double? longitude;
  final bool isMine;
  final bool isRead;
  final String? reaction;
  final ValueChanged<int> onReact;

  const _MessageBubble({
    required this.messageId,
    required this.text,
    required this.messageType,
    required this.attachmentUrl,
    required this.latitude,
    required this.longitude,
    required this.isMine,
    required this.isRead,
    required this.reaction,
    required this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => onReact(messageId),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.74,
          ),
          child: Column(
            crossAxisAlignment: isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isMine ? const Color(0xFF60D9EF) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMine ? 16 : 6),
                    bottomRight: Radius.circular(isMine ? 6 : 16),
                  ),
                  border: isMine
                      ? null
                      : Border.all(color: const Color(0xFFD9E2F1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.025),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _MessageContent(
                  text: text,
                  messageType: messageType,
                  attachmentUrl: attachmentUrl,
                  latitude: latitude,
                  longitude: longitude,
                ),
              ),
              if (isMine) ...[
                const SizedBox(height: 4),
                Icon(
                  Icons.done_all_rounded,
                  size: 15,
                  color: isRead
                      ? const Color(0xFF60D9EF)
                      : const Color(0xFF9BA8C4),
                ),
              ],
              if (reaction != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFDCE4F2)),
                  ),
                  child: Text(
                    reaction!,
                    style: const TextStyle(
                      color: Color(0xFF243B85),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageContent extends StatelessWidget {
  final String text;
  final String messageType;
  final String? attachmentUrl;
  final double? latitude;
  final double? longitude;

  const _MessageContent({
    required this.text,
    required this.messageType,
    required this.attachmentUrl,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    if (messageType == 'image' && attachmentUrl != null) {
      final imageUrl = ApiConfig.resolveMediaUrl(attachmentUrl);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 220,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 220,
                height: 140,
                color: const Color(0xFFEAF0FB),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Color(0xFF7080A4),
                ),
              ),
            ),
          ),
          if (text.trim().isNotEmpty && text.trim() != 'Photo attachment') ...[
            const SizedBox(height: 8),
            _MessageText(text: text),
          ],
        ],
      );
    }

    if (messageType == 'location' && latitude != null && longitude != null) {
      return InkWell(
        onTap: () => _openLocation(latitude!, longitude!),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF0FB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Color(0xFF243B85),
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Shared location',
                    style: TextStyle(
                      color: Color(0xFF233154),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tap to open in Maps',
                    style: TextStyle(
                      color: Color(0xFF7080A4),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return _MessageText(text: text);
  }

  Future<void> _openLocation(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _MessageText extends StatelessWidget {
  final String text;

  const _MessageText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF233154),
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  const _MessageComposer({
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F7FD),
        border: Border(top: BorderSide(color: Color(0xFFDCE4F2))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _ComposerCircleButton(icon: Icons.add_rounded, onTap: onAttach),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Message...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8A98B8),
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(color: Color(0xFFD8E1F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(color: Color(0xFFD8E1F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(
                      color: Color(0xFF65D6F4),
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: isSending ? null : onSend,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF60D9EF),
                  shape: BoxShape.circle,
                ),
                child: isSending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.near_me_rounded,
                        color: Color(0xFF14326D),
                        size: 22,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ComposerCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF0FB),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD5DEEE)),
        ),
        child: Icon(icon, color: const Color(0xFF243B85), size: 24),
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7FD),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDCE4F2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF243B85)),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF243B85),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatState extends StatelessWidget {
  final String title;
  final VoidCallback? onRetry;

  const _ChatState({required this.title, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF7080A4),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ],
      ),
    );
  }
}
