import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../utils/notifications_manager.dart';
import '../widgets/notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<Map<String, dynamic>> _newNotifications;
  late List<Map<String, dynamic>> _earlierNotifications;

  @override
  void initState() {
    super.initState();
    _loadFromManager();
  }

  void _loadFromManager() {
    _newNotifications = NotificationsManager.getNewNotifications();
    _earlierNotifications = NotificationsManager.getEarlierNotifications();
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Notifications'),
          content: const Text('Are you sure you want to clear all notifications?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                NotificationsManager.clearAll();
                setState(() {
                  _loadFromManager();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications cleared'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Clear All', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
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
                    if (_newNotifications.isNotEmpty || _earlierNotifications.isNotEmpty)
                      TextButton(
                        onPressed: _clearAllNotifications,
                        child: const Text(
                          'Clear All',
                          style: TextStyle(
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
          // Notifications list
          Expanded(
            child: _newNotifications.isEmpty && _earlierNotifications.isEmpty
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
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // New notifications section
                        if (_newNotifications.isNotEmpty) ...[
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
                          ..._newNotifications.map((notification) {
                            return NotificationItem(
                              icon: notification['icon'] as IconData,
                              iconColor: notification['iconColor'] as Color,
                              title: notification['title'] as String,
                              description: notification['description'] as String,
                              timestamp: notification['timestamp'] as String,
                              isNew: true,
                            );
                          }),
                        ],
                        // Earlier notifications section
                        if (_earlierNotifications.isNotEmpty) ...[
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
                          ..._earlierNotifications.map((notification) {
                            return NotificationItem(
                              icon: notification['icon'] as IconData,
                              iconColor: notification['iconColor'] as Color,
                              title: notification['title'] as String,
                              description: notification['description'] as String,
                              timestamp: notification['timestamp'] as String,
                              isNew: false,
                            );
                          }),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

