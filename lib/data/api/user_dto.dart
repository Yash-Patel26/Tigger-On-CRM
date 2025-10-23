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

class UserDto {
  UserDto({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.avatarUrl,
    this.isActive,
    this.createdAt,
  });

  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? avatarUrl;
  final bool? isActive;
  final DateTime? createdAt;

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    id: json['id']?.toString(),
    name: json['name'] as String?,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    role: json['role'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    isActive: json['isActive'] as bool?,
    createdAt: _parseDate(json['createdAt']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (email != null) 'email': email,
    if (phone != null) 'phone': phone,
    if (role != null) 'role': role,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
    if (isActive != null) 'isActive': isActive,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };
}
