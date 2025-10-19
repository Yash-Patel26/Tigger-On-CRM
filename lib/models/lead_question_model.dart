class LeadQuestion {
  final String id;
  final String leadId;
  final String title;
  final String? notes;
  final DateTime createdAt;

  const LeadQuestion({
    required this.id,
    required this.leadId,
    required this.title,
    this.notes,
    required this.createdAt,
  });

  factory LeadQuestion.fromJson(Map<String, dynamic> json) {
    return LeadQuestion(
      id: json['id'] as String,
      leadId: json['lead_id'] as String,
      title: json['title'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead_id': leadId,
      'title': title,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  LeadQuestion copyWith({
    String? id,
    String? leadId,
    String? title,
    String? notes,
    DateTime? createdAt,
  }) {
    return LeadQuestion(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
