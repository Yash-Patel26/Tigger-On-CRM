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

class TicketDto {
  TicketDto({
    this.id,
    this.title,
    this.description,
    this.status,
    this.priority,
    this.assignedTo,
    this.createdBy,
    this.relatedLeadId,
    this.relatedCustomerId,
    this.createdAt,
  });

  final String? id;
  final String? title;
  final String? description;
  final String? status;
  final String? priority;
  final String? assignedTo;
  final String? createdBy;
  final String? relatedLeadId;
  final String? relatedCustomerId;
  final DateTime? createdAt;

  factory TicketDto.fromJson(Map<String, dynamic> json) => TicketDto(
    id: json['id']?.toString(),
    title: json['title'] as String?,
    description: json['description'] as String?,
    status: json['status'] as String?,
    priority: json['priority'] as String?,
    assignedTo: json['assignedTo']?.toString(),
    createdBy: json['createdBy']?.toString(),
    relatedLeadId: json['relatedLeadId']?.toString(),
    relatedCustomerId: json['relatedCustomerId']?.toString(),
    createdAt: _parseDate(json['createdAt']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (id != null) 'id': id,
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (status != null) 'status': status,
    if (priority != null) 'priority': priority,
    if (assignedTo != null) 'assignedTo': assignedTo,
    if (createdBy != null) 'createdBy': createdBy,
    if (relatedLeadId != null) 'relatedLeadId': relatedLeadId,
    if (relatedCustomerId != null) 'relatedCustomerId': relatedCustomerId,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };
}
