class AssignmentUser {
  final String id;
  final String name;
  final String? email;
  final String? role;
  final bool isActive;
  final DateTime createdAt;

  const AssignmentUser({
    required this.id,
    required this.name,
    this.email,
    this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory AssignmentUser.fromJson(Map<String, dynamic> json) {
    return AssignmentUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      role: json['role'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AssignmentUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AssignmentUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
