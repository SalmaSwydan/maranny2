import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Single source of truth for notifications. Clear All persists across navigation.
class NotificationsManager {
  NotificationsManager._();

  static bool _seeded = false;
  static final List<Map<String, dynamic>> _newNotifications = [];
  static final List<Map<String, dynamic>> _earlierNotifications = [];

  static void _seedIfNeeded() {
    if (_seeded) return;
    _seeded = true;
    _newNotifications.addAll([
      {
        'icon': Icons.calendar_today,
        'iconColor': AppColors.primaryBlue,
        'title': 'New Booking Request',
        'description': 'Ahmed Khaled wants to book a session on Dec 25 at 10:00 pm',
        'timestamp': '2 hours ago',
      },
      {
        'icon': Icons.check_circle,
        'iconColor': Colors.green,
        'title': 'Booking Confirmed',
        'description': 'Ahmed Mohamed confirmed his session for tomorrow at 10:00 AM',
        'timestamp': '3 hours ago',
      },
      {
        'icon': Icons.chat_bubble_outline,
        'iconColor': AppColors.primaryBlue,
        'title': 'New Message from Client',
        'description': 'Ahmed Mohamed: Can we reschedule tomorrow\'s session?',
        'timestamp': '4 hours ago',
      },
      {
        'icon': Icons.access_time,
        'iconColor': AppColors.primaryBlue,
        'title': 'Session Reminder',
        'description': 'Your session with Ahmed Mohamed starts in 24 hours',
        'timestamp': '21 hours ago',
      },
    ]);
    _earlierNotifications.addAll([
      {
        'icon': Icons.star,
        'iconColor': Colors.amber,
        'title': 'New 5-star Review',
        'description': 'Ahmed Yasser left you a review: "Excellent coaching! Really improved My skills."',
        'timestamp': '2 days ago',
      },
      {
        'icon': Icons.cancel,
        'iconColor': Colors.red,
        'title': 'Session Canceled',
        'description': 'Ali Ahmed Canceled his session scheduled for Dec 20',
        'timestamp': '7 days ago',
      },
      {
        'icon': Icons.check_circle,
        'iconColor': Colors.green,
        'title': 'Coach Profile Approved',
        'description': 'Your coach profile has been verified and is now live!',
        'timestamp': '4 months ago',
      },
    ]);
  }

  static List<Map<String, dynamic>> getNewNotifications() {
    _seedIfNeeded();
    return List<Map<String, dynamic>>.from(_newNotifications);
  }

  static List<Map<String, dynamic>> getEarlierNotifications() {
    _seedIfNeeded();
    return List<Map<String, dynamic>>.from(_earlierNotifications);
  }

  static void clearAll() {
    _newNotifications.clear();
    _earlierNotifications.clear();
  }

  static bool get hasAny => _newNotifications.isNotEmpty || _earlierNotifications.isNotEmpty;
}
