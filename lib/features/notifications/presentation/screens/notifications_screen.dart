import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/notifications_models.dart';
import '../../data/repository/notifications_repository.dart';
import '../widgets/notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsRepository _repository = NotificationsRepository();

  bool _isLoading = true;
  bool _isClearing = false;
  String? _error;
  List<NotificationModel> _notifications = const <NotificationModel>[];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications = await _repository.getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load notifications right now.';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      await _repository.markAsRead(notification.notificationID);
      if (!mounted) return;
      setState(() {
        _notifications = _notifications
            .map(
              (item) => item.notificationID == notification.notificationID
                  ? NotificationModel(
                      notificationID: item.notificationID,
                      title: item.title,
                      message: item.message,
                      type: item.type,
                      isRead: true,
                      createdAt: item.createdAt,
                    )
                  : item,
            )
            .toList(growable: false);
      });
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    final unread = _notifications.where((item) => !item.isRead).toList();
    if (unread.isEmpty) return;

    setState(() {
      _isClearing = true;
    });

    for (final notification in unread) {
      try {
        await _repository.markAsRead(notification.notificationID);
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _notifications = _notifications
          .map(
            (item) => NotificationModel(
              notificationID: item.notificationID,
              title: item.title,
              message: item.message,
              type: item.type,
              isRead: true,
              createdAt: item.createdAt,
            ),
          )
          .toList(growable: false);
      _isClearing = false;
    });
  }

  IconData _iconFor(NotificationModel notification) {
    final type = notification.type.toLowerCase();
    final text =
        '${notification.title} ${notification.message}'.toLowerCase();

    if (type.contains('booking') || text.contains('booking')) {
      return Icons.calendar_today;
    }
    if (type.contains('message') || text.contains('message')) {
      return Icons.chat_bubble_outline;
    }
    if (type.contains('review') || text.contains('review')) {
      return Icons.star;
    }
    if (type.contains('cancel') || text.contains('cancel')) {
      return Icons.cancel;
    }
    if (type.contains('reminder') || text.contains('reminder')) {
      return Icons.access_time;
    }
    if (type.contains('approve') || text.contains('approve')) {
      return Icons.check_circle;
    }
    return Icons.notifications_outlined;
  }

  Color _iconColorFor(NotificationModel notification) {
    final type = notification.type.toLowerCase();
    final text =
        '${notification.title} ${notification.message}'.toLowerCase();

    if (type.contains('cancel') || text.contains('cancel')) {
      return Colors.red;
    }
    if (type.contains('review') || text.contains('review')) {
      return Colors.amber;
    }
    if (type.contains('approve') ||
        text.contains('approve') ||
        text.contains('confirmed')) {
      return Colors.green;
    }
    return AppColors.primaryBlue;
  }

  String _formatTimestamp(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;

    final local = parsed.isUtc ? parsed.toLocal() : parsed;
    final difference = DateTime.now().difference(local);

    if (difference.inDays >= 1) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
    if (difference.inHours >= 1) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    }
    if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    }
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final newNotifications = _notifications.where((item) => !item.isRead).toList();
    final earlierNotifications = _notifications.where((item) => item.isRead).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF6FD3F5),
                  Color(0xFF1F3A93),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (!_isLoading && _notifications.isNotEmpty)
                      TextButton(
                        onPressed: _isClearing ? null : _markAllAsRead,
                        child: Text(
                          _isClearing ? 'Updating...' : 'Mark All Read',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: TextButton(
                          onPressed: _loadNotifications,
                          child: Text(_error!),
                        ),
                      )
                    : _notifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No notifications',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'You\'re all caught up!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadNotifications,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (newNotifications.isNotEmpty) ...[
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                                      child: Text(
                                        'New',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins',
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    ...newNotifications.map(
                                      (notification) => NotificationItem(
                                        icon: _iconFor(notification),
                                        iconColor: _iconColorFor(notification),
                                        title: notification.title,
                                        description: notification.message,
                                        timestamp: _formatTimestamp(
                                          notification.createdAt,
                                        ),
                                        isNew: true,
                                        onTap: () => _markAsRead(notification),
                                      ),
                                    ),
                                  ],
                                  if (earlierNotifications.isNotEmpty) ...[
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                                      child: Text(
                                        'Earlier',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins',
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    ...earlierNotifications.map(
                                      (notification) => NotificationItem(
                                        icon: _iconFor(notification),
                                        iconColor: _iconColorFor(notification),
                                        title: notification.title,
                                        description: notification.message,
                                        timestamp: _formatTimestamp(
                                          notification.createdAt,
                                        ),
                                        isNew: false,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
