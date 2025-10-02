enum NotificationType {
  appointmentReminder,
  appointmentConfirmed,
  appointmentCancelled,
  appointmentRescheduled,
  prescriptionReady,
  testResults,
  general,
  emergency,
  promotion,
}

enum NotificationPriority { low, medium, high, urgent }

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? data;
  final String? actionUrl;
  final String? imageUrl;
  final String? iconUrl;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.data,
    this.actionUrl,
    this.imageUrl,
    this.iconUrl,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${data['type']}',
        orElse: () => NotificationType.general,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == 'NotificationPriority.${data['priority']}',
        orElse: () => NotificationPriority.medium,
      ),
      isRead: data['isRead'] ?? false,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      readAt: data['readAt']?.toDate(),
      data: data['data'],
      actionUrl: data['actionUrl'],
      imageUrl: data['imageUrl'],
      iconUrl: data['iconUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'isRead': isRead,
      'createdAt': createdAt,
      'readAt': readAt,
      'data': data,
      'actionUrl': actionUrl,
      'imageUrl': imageUrl,
      'iconUrl': iconUrl,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? imageUrl,
    String? iconUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      data: data ?? this.data,
      actionUrl: actionUrl ?? this.actionUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      iconUrl: iconUrl ?? this.iconUrl,
    );
  }

  bool get isUrgent => priority == NotificationPriority.urgent;
  bool get isHigh => priority == NotificationPriority.high;
  bool get isRecent => DateTime.now().difference(createdAt).inHours < 24;
}


