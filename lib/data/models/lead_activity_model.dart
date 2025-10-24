enum ActivityType {
  created,
  updated,
  assigned,
  statusChanged,
  siteVisitScheduled,
  siteVisitCompleted,
  taskCreated,
  taskCompleted,
  noteAdded,
  followUpScheduled,
  converted,
  closed,
  callInitiated,
  emailInitiated,
  messageInitiated,
  whatsappInitiated,
  offlineWhatsappInitiated,
}

class LeadActivity {
  final String id;
  final String leadId;
  final ActivityType type;
  final String action;
  final String description;
  final String performedBy;
  final String performedByName;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const LeadActivity({
    required this.id,
    required this.leadId,
    required this.type,
    required this.action,
    required this.description,
    required this.performedBy,
    required this.performedByName,
    required this.createdAt,
    this.metadata,
  });

  factory LeadActivity.fromJson(Map<String, dynamic> json) {
    return LeadActivity(
      id: json['id'] as String,
      leadId: json['lead_id'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ActivityType.updated,
      ),
      action: json['action'] as String,
      description: json['description'] as String,
      performedBy: json['performed_by'] as String,
      performedByName: json['performed_by_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead_id': leadId,
      'type': type.toString().split('.').last,
      'action': action,
      'description': description,
      'performed_by': performedBy,
      'performed_by_name': performedByName,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'LeadActivity(id: $id, leadId: $leadId, type: $type, action: $action)';
  }
}
