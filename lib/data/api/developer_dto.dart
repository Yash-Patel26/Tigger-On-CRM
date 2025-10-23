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

class DeveloperDto {
  DeveloperDto({
    this.id,
    this.name,
    this.logoUrl,
    this.city,
    this.state,
    this.isActive,
    this.createdAt,
  });

  final String? id;
  final String? name;
  final String? logoUrl;
  final String? city;
  final String? state;
  final bool? isActive;
  final DateTime? createdAt;

  factory DeveloperDto.fromJson(Map<String, dynamic> json) => DeveloperDto(
    id: json['id']?.toString(),
    name: json['name'] as String?,
    logoUrl: json['logoUrl'] as String?,
    city: json['city'] as String?,
    state: json['state'] as String?,
    isActive: json['isActive'] as bool?,
    createdAt: _parseDate(json['createdAt']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (logoUrl != null) 'logoUrl': logoUrl,
    if (city != null) 'city': city,
    if (state != null) 'state': state,
    if (isActive != null) 'isActive': isActive,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };
}
