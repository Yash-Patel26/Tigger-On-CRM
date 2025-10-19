class LeadCrossSell {
  final String id;
  final String leadId;
  final String? category;
  final String? propertyType;
  final String? projectId;
  final String? projectName;
  final String? allocatedToName;
  final String? allocatedTo;
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
    this.allocatedToName,
    this.allocatedTo,
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
      allocatedToName: json['allocated_to_name'] as String?,
      allocatedTo: json['allocated_to'] as String?,
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
      'allocated_to_name': allocatedToName,
      'allocated_to': allocatedTo,
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
    String? allocatedToName,
    String? allocatedTo,
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
      allocatedToName: allocatedToName ?? this.allocatedToName,
      allocatedTo: allocatedTo ?? this.allocatedTo,
      description: description ?? this.description,
      linkedLeadId: linkedLeadId ?? this.linkedLeadId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
