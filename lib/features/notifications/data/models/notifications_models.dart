// Notification models.

class NotificationModel {
  final int notificationID;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;

  const NotificationModel({
    required this.notificationID,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        notificationID: _asInt(
          json['notificationID'] ?? json['notificationId'] ?? json['id'],
        ),
        title: _asString(json['title'], fallback: 'Notification'),
        message: _asString(
          json['message'] ?? json['description'] ?? json['body'],
        ),
        type: _asString(json['type'], fallback: 'general'),
        isRead: _asBool(json['isRead'] ?? json['read'], fallback: false),
        createdAt: _asString(
          json['createdAt'] ?? json['createdOn'] ?? json['timestamp'],
        ),
      );
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return fallback;
}
