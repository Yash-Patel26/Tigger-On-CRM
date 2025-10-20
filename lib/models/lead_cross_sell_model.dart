class LeadCrossSell {
  final String id;
  final String leadId;
  final String? category;
  final String? propertyType;
  final String? projectId;
  final String? projectName;
  final String? assignedToName;
  final String? assignedTo;
  final String? description;
  final String? linkedLeadId;
  final DateTime createdAt;

  const LeadCrossSell({
    required this.id,
    required this.leadId,
    this.category,
    this.propertyType,
    this.projectId,
    this.projectName,
    this.assignedToName,
    this.assignedTo,
    this.description,
    this.linkedLeadId,
    required this.createdAt,
  });

  factory LeadCrossSell.fromJson(Map<String, dynamic> json) {
    return LeadCrossSell(
      id: json['id'] as String,
      leadId: json['lead_id'] as String,
      category: json['category'] as String?,
      propertyType: json['property_type'] as String?,
      projectId: json['project_id'] as String?,
      projectName: json['project_name'] as String?,
      assignedToName: json['assigned_to_name'] as String?,
      assignedTo: json['assigned_to'] as String?,
      description: json['description'] as String?,
      linkedLeadId: json['linked_lead_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead_id': leadId,
      'category': category,
      'property_type': propertyType,
      'project_id': projectId,
      'project_name': projectName,
      'assigned_to_name': assignedToName,
      'assigned_to': assignedTo,
      'description': description,
      'linked_lead_id': linkedLeadId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  LeadCrossSell copyWith({
    String? id,
    String? leadId,
    String? category,
    String? propertyType,
    String? projectId,
    String? projectName,
    String? assignedToName,
    String? assignedTo,
    String? description,
    String? linkedLeadId,
    DateTime? createdAt,
  }) {
    return LeadCrossSell(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      category: category ?? this.category,
      propertyType: propertyType ?? this.propertyType,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      assignedToName: assignedToName ?? this.assignedToName,
      assignedTo: assignedTo ?? this.assignedTo,
      description: description ?? this.description,
      linkedLeadId: linkedLeadId ?? this.linkedLeadId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
