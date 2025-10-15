DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
  return null;
}

class NotificationDto {
  NotificationDto({
    this.id,
    this.title,
    this.body,
    this.type,
    this.read,
    this.createdAt,
  });

  final String? id;
  final String? title;
  final String? body;
  final String? type;
  final bool? read;
  final DateTime? createdAt;

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      NotificationDto(
        id: json['id']?.toString(),
        title: json['title'] as String?,
        body: json['body'] as String?,
        type: json['type'] as String?,
        read: json['read'] as bool?,
        createdAt: _parseDate(json['createdAt']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (id != null) 'id': id,
    if (title != null) 'title': title,
    if (body != null) 'body': body,
    if (type != null) 'type': type,
    if (read != null) 'read': read,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };
}
