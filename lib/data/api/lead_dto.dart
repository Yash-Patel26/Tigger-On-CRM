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

class LeadDto {
  LeadDto({
    this.id,
    this.name,
    this.primaryPhone,
    this.alternatePhones,
    this.status,
    this.assignedTo,
    this.createdAt,
  });

  final String? id;
  final String? name;
  final String? primaryPhone;
  final List<String>? alternatePhones;
  final String? status;
  final String? assignedTo;
  final DateTime? createdAt;

  factory LeadDto.fromJson(Map<String, dynamic> json) => LeadDto(
    id: json['id']?.toString(),
    name: json['name'] as String?,
    primaryPhone: json['primaryPhone'] as String? ?? json['phone'] as String?,
    alternatePhones: (json['alternatePhones'] as List<dynamic>?)
        ?.map((dynamic e) => e.toString())
        .toList(),
    status: json['status'] as String?,
    assignedTo: json['assignedTo'] as String?,
    createdAt: _parseDate(json['createdAt']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (primaryPhone != null) 'primaryPhone': primaryPhone,
    if (alternatePhones != null) 'alternatePhones': alternatePhones,
    if (status != null) 'status': status,
    if (assignedTo != null) 'assignedTo': assignedTo,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };
}
