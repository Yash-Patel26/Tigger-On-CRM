enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled,
  onHold;

  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
      case TaskStatus.onHold:
        return 'On Hold';
    }
  }
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }
}

enum TaskType {
  followUp,
  siteVisit,
  call,
  meeting,
  documentation,
  review,
  other;

  String get displayName {
    switch (this) {
      case TaskType.followUp:
        return 'Follow Up';
      case TaskType.siteVisit:
        return 'Site Visit';
      case TaskType.call:
        return 'Call';
      case TaskType.meeting:
        return 'Meeting';
      case TaskType.documentation:
        return 'Documentation';
      case TaskType.review:
        return 'Review';
      case TaskType.other:
        return 'Other';
    }
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskType type;
  final TaskPriority priority;
  final TaskStatus status;
  final String? assignedTo;
  final String? assignedToName;
  final String? createdBy;
  final String? createdByName;
  final String? leadId;
  final String? customerId;
  final String? projectId;
  final String? siteVisitId;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final List<String> attachments;
  final Map<String, dynamic>? metadata;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.status,
    this.assignedTo,
    this.assignedToName,
    this.createdBy,
    this.createdByName,
    this.leadId,
    this.customerId,
    this.projectId,
    this.siteVisitId,
    this.dueDate,
    this.completedAt,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.attachments = const [],
    this.metadata,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: TaskType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TaskType.other,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      assignedTo: json['assignedTo'] as String?,
      assignedToName: json['assignedToName'] as String?,
      createdBy: json['createdBy'] as String?,
      createdByName: json['createdByName'] as String?,
      leadId: json['leadId'] as String?,
      customerId: json['customerId'] as String?,
      projectId: json['projectId'] as String?,
      siteVisitId: json['siteVisitId'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      notes: json['notes'] as String?,
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'priority': priority.name,
      'status': status.name,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'leadId': leadId,
      'customerId': customerId,
      'projectId': projectId,
      'siteVisitId': siteVisitId,
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notes': notes,
      'attachments': attachments,
      'metadata': metadata,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? type,
    TaskPriority? priority,
    TaskStatus? status,
    String? assignedTo,
    String? assignedToName,
    String? createdBy,
    String? createdByName,
    String? leadId,
    String? customerId,
    String? projectId,
    String? siteVisitId,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      leadId: leadId ?? this.leadId,
      customerId: customerId ?? this.customerId,
      projectId: projectId ?? this.projectId,
      siteVisitId: siteVisitId ?? this.siteVisitId,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status, priority: $priority)';
  }
}
