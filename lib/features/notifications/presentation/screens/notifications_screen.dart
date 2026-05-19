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
    final text = '${notification.title} ${notification.message}'.toLowerCase();

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
    final text = '${notification.title} ${notification.message}'.toLowerCase();

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
    final newNotifications = _notifications
        .where((item) => !item.isRead)
        .toList();
    final earlierNotifications = _notifications
        .where((item) => item.isRead)
        .toList();
    final unreadCount = newNotifications.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
              child: _NotificationsHeader(
                unreadCount: unreadCount,
                showMarkAll: !_isLoading && _notifications.isNotEmpty,
                isClearing: _isClearing,
                onBack: () => Navigator.of(context).pop(),
                onMarkAllRead: _markAllAsRead,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _ErrorState(message: _error!, onRetry: _loadNotifications)
                : _notifications.isEmpty
                ? const _EmptyNotificationsState()
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (newNotifications.isNotEmpty) ...[
                            _NotificationSectionHeader(
                              title: 'New',
                              count: newNotifications.length,
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
                            _NotificationSectionHeader(
                              title: 'Earlier',
                              count: earlierNotifications.length,
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

class _NotificationsHeader extends StatelessWidget {
  final int unreadCount;
  final bool showMarkAll;
  final bool isClearing;
  final VoidCallback onBack;
  final VoidCallback onMarkAllRead;

  const _NotificationsHeader({
    required this.unreadCount,
    required this.showMarkAll,
    required this.isClearing,
    required this.onBack,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD7E0F2)),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.deepBlue,
                  size: 18,
                ),
              ),
            ),
            const Spacer(),
            if (showMarkAll)
              TextButton(
                onPressed: isClearing ? null : onMarkAllRead,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.deepBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                child: Text(
                  isClearing ? 'Updating...' : 'Mark all read',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          unreadCount == 0 ? 'ALL CAUGHT UP' : '$unreadCount UNREAD',
          style: const TextStyle(
            color: Color(0xFF9AA9C6),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.4,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Notifications.',
          style: TextStyle(
            color: AppColors.deepBlue,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          unreadCount == 0
              ? 'You are up to date with bookings, messages, and account alerts.'
              : 'Review your latest bookings, messages, and account updates.',
          style: const TextStyle(
            color: Color(0xFF6C7897),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.35,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

class _NotificationSectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _NotificationSectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'Poppins',
              color: AppColors.deepBlue,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FB),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.deepBlue,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotificationsState extends StatelessWidget {
  const _EmptyNotificationsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFD7E0F2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF0FB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  size: 38,
                  color: AppColors.deepBlue,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'No notifications yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                  color: AppColors.deepBlue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Important bookings, chat updates, and account alerts will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  color: Color(0xFF6C7897),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFD7E0F2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.deepBlue,
                size: 34,
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.deepBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
