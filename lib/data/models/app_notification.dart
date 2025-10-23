enum AppNotificationType { lead, calendar, booking, followUp }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.unread,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String time;
  final AppNotificationType type;
  final bool unread;
  final DateTime createdAt;

  AppNotification copyWith({bool? unread}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      time: time,
      type: type,
      unread: unread ?? this.unread,
      createdAt: createdAt,
    );
  }
}
