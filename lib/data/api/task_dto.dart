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

class TaskDto {
  TaskDto({
    this.id,
    this.title,
    this.description,
    this.status,
    this.priority,
    this.type,
    this.assignedTo,
    this.createdBy,
    this.leadId,
    this.customerId,
    this.projectId,
    this.siteVisitId,
    this.dueDate,
    this.createdAt,
  });

  final String? id;
  final String? title;
  final String? description;
  final String? status;
  final String? priority;
  final String? type;
  final String? assignedTo;
  final String? createdBy;
  final String? leadId;
  final String? customerId;
  final String? projectId;
  final String? siteVisitId;
  final DateTime? dueDate;
  final DateTime? createdAt;

  factory TaskDto.fromJson(Map<String, dynamic> json) => TaskDto(
    id: json['id']?.toString(),
    title: json['title'] as String?,
    description: json['description'] as String?,
    status: json['status'] as String?,
    priority: json['priority'] as String?,
    type: json['type'] as String?,
    assignedTo: json['assignedTo']?.toString(),
    createdBy: json['createdBy']?.toString(),
    leadId: json['leadId']?.toString(),
    customerId: json['customerId']?.toString(),
    projectId: json['projectId']?.toString(),
    siteVisitId: json['siteVisitId']?.toString(),
    dueDate: _parseDate(json['dueDate']),
    createdAt: _parseDate(json['createdAt']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (id != null) 'id': id,
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (status != null) 'status': status,
    if (priority != null) 'priority': priority,
    if (type != null) 'type': type,
    if (assignedTo != null) 'assignedTo': assignedTo,
    if (createdBy != null) 'createdBy': createdBy,
    if (leadId != null) 'leadId': leadId,
    if (customerId != null) 'customerId': customerId,
    if (projectId != null) 'projectId': projectId,
    if (siteVisitId != null) 'siteVisitId': siteVisitId,
    if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };
}
