class LeadReference {
  final String id;
  final String leadId;
  final String direction; // 'to' or 'by'
  final String firstName;
  final String? middleName;
  final String lastName;
  final String contact;
  final String email;
  final String? note;
  final String? linkedLeadId;
  final DateTime createdAt;

  const LeadReference({
    required this.id,
    required this.leadId,
    required this.direction,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.contact,
    required this.email,
    this.note,
    this.linkedLeadId,
    required this.createdAt,
  });

  factory LeadReference.fromJson(Map<String, dynamic> json) {
    return LeadReference(
      id: json['id'] as String,
      leadId: json['lead_id'] as String,
      direction: json['direction'] as String,
      firstName: json['first_name'] as String,
      middleName: json['middle_name'] as String?,
      lastName: json['last_name'] as String,
      contact: json['contact'] as String,
      email: json['email'] as String,
      note: json['note'] as String?,
      linkedLeadId: json['linked_lead_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead_id': leadId,
      'direction': direction,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'contact': contact,
      'email': email,
      'note': note,
      'linked_lead_id': linkedLeadId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }

  LeadReference copyWith({
    String? id,
    String? leadId,
    String? direction,
    String? firstName,
    String? middleName,
    String? lastName,
    String? contact,
    String? email,
    String? note,
    String? linkedLeadId,
    DateTime? createdAt,
  }) {
    return LeadReference(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      direction: direction ?? this.direction,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      contact: contact ?? this.contact,
      email: email ?? this.email,
      note: note ?? this.note,
      linkedLeadId: linkedLeadId ?? this.linkedLeadId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
