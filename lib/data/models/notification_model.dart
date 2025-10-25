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

  String get iconPath {
    switch (this) {
      case NotificationType.lead:
        return 'assets/icons/lead_icon.png';
      case NotificationType.booking:
        return 'assets/icons/booking_icon.png';
      case NotificationType.siteVisit:
        return 'assets/icons/site_visit_icon.png';
      case NotificationType.ticket:
        return 'assets/icons/ticket_icon.png';
      case NotificationType.system:
        return 'assets/icons/system_icon.png';
      case NotificationType.reminder:
        return 'assets/icons/reminder_icon.png';
      case NotificationType.alert:
        return 'assets/icons/alert_icon.png';
    }
  }

  String get colorHex {
    switch (this) {
      case NotificationType.lead:
        return '#4CAF50'; // Green
      case NotificationType.booking:
        return '#2196F3'; // Blue
      case NotificationType.siteVisit:
        return '#FF9800'; // Orange
      case NotificationType.ticket:
        return '#F44336'; // Red
      case NotificationType.system:
        return '#9C27B0'; // Purple
      case NotificationType.reminder:
        return '#607D8B'; // Blue Grey
      case NotificationType.alert:
        return '#E91E63'; // Pink
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

  String get colorHex {
    switch (this) {
      case NotificationPriority.low:
        return '#4CAF50'; // Green
      case NotificationPriority.medium:
        return '#FF9800'; // Orange
      case NotificationPriority.high:
        return '#F44336'; // Red
      case NotificationPriority.urgent:
        return '#E91E63'; // Pink
    }
  }

  int get sortOrder {
    switch (this) {
      case NotificationPriority.urgent:
        return 1;
      case NotificationPriority.high:
        return 2;
      case NotificationPriority.medium:
        return 3;
      case NotificationPriority.low:
        return 4;
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

  String get colorHex {
    switch (this) {
      case NotificationStatus.unread:
        return '#2196F3'; // Blue
      case NotificationStatus.read:
        return '#9E9E9E'; // Grey
      case NotificationStatus.archived:
        return '#607D8B'; // Blue Grey
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
      userId: json['user_id'] as String?,
      relatedId: json['related_id'] as String?,
      relatedType: json['related_type'] as String?,
      actionUrl: json['action_url'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      archivedAt: json['archived_at'] != null
          ? DateTime.parse(json['archived_at'] as String)
          : null,
      isRead: json['is_read'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
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
      'user_id': userId,
      'related_id': relatedId,
      'related_type': relatedType,
      'action_url': actionUrl,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'archived_at': archivedAt?.toIso8601String(),
      'is_read': isRead,
      'is_archived': isArchived,
    };
  }

  // Method to create Supabase-compatible JSON for insertion
  Map<String, dynamic> toSupabaseJson() {
    return {
      'title': title,
      'message': message,
      'type': type.name,
      'priority': priority.name,
      'status': status.name,
      'user_id': userId,
      'related_id': relatedId,
      'related_type': relatedType,
      'action_url': actionUrl,
      'data': data,
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

  // Helper methods for common operations
  Notification markAsRead() {
    return copyWith(
      status: NotificationStatus.read,
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  Notification markAsUnread() {
    return copyWith(
      status: NotificationStatus.unread,
      isRead: false,
      readAt: null,
    );
  }

  Notification archive() {
    return copyWith(
      status: NotificationStatus.archived,
      isArchived: true,
      archivedAt: DateTime.now(),
    );
  }

  Notification unarchive() {
    return copyWith(
      status: NotificationStatus.unread,
      isArchived: false,
      archivedAt: null,
    );
  }

  // Utility methods
  bool get isUnread => status == NotificationStatus.unread;
  bool get isReadStatus => status == NotificationStatus.read;
  bool get isArchivedStatus => status == NotificationStatus.archived;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get formattedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
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
