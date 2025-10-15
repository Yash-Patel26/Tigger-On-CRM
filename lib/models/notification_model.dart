enum NotificationType {
  lead,
  booking,
  siteVisit,
  ticket,
  system,
  reminder,
  alert;

  String get displayName {
    switch (this) {
      case NotificationType.lead:
        return 'Lead';
      case NotificationType.booking:
        return 'Booking';
      case NotificationType.siteVisit:
        return 'Site Visit';
      case NotificationType.ticket:
        return 'Ticket';
      case NotificationType.system:
        return 'System';
      case NotificationType.reminder:
        return 'Reminder';
      case NotificationType.alert:
        return 'Alert';
    }
  }
}

enum NotificationPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.medium:
        return 'Medium';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }
}

enum NotificationStatus {
  unread,
  read,
  archived;

  String get displayName {
    switch (this) {
      case NotificationStatus.unread:
        return 'Unread';
      case NotificationStatus.read:
        return 'Read';
      case NotificationStatus.archived:
        return 'Archived';
    }
  }
}

class Notification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final NotificationStatus status;
  final String? userId;
  final String? relatedId; // ID of related entity (lead, booking, etc.)
  final String? relatedType; // Type of related entity
  final String? actionUrl; // Deep link or action URL
  final Map<String, dynamic>? data; // Additional data
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? archivedAt;
  final bool isRead;
  final bool isArchived;

  const Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.status,
    this.userId,
    this.relatedId,
    this.relatedType,
    this.actionUrl,
    this.data,
    required this.createdAt,
    this.readAt,
    this.archivedAt,
    this.isRead = false,
    this.isArchived = false,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.medium,
      ),
      status: NotificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NotificationStatus.unread,
      ),
      userId: json['userId'] as String?,
      relatedId: json['relatedId'] as String?,
      relatedType: json['relatedType'] as String?,
      actionUrl: json['actionUrl'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      archivedAt: json['archivedAt'] != null
          ? DateTime.parse(json['archivedAt'] as String)
          : null,
      isRead: json['isRead'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'priority': priority.name,
      'status': status.name,
      'userId': userId,
      'relatedId': relatedId,
      'relatedType': relatedType,
      'actionUrl': actionUrl,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'archivedAt': archivedAt?.toIso8601String(),
      'isRead': isRead,
      'isArchived': isArchived,
    };
  }

  Notification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    NotificationStatus? status,
    String? userId,
    String? relatedId,
    String? relatedType,
    String? actionUrl,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? archivedAt,
    bool? isRead,
    bool? isArchived,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      actionUrl: actionUrl ?? this.actionUrl,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      archivedAt: archivedAt ?? this.archivedAt,
      isRead: isRead ?? this.isRead,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Notification(id: $id, title: $title, type: $type, status: $status)';
  }
}
