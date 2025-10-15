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

class VendorDto {
  VendorDto({
    this.id,
    this.name,
    this.contactNumber,
    this.type,
    this.createdBy,
    this.createdAt,
    this.status,
  });

  final String? id;
  final String? name;
  final String? contactNumber;
  final String? type;
  final String? createdBy;
  final DateTime? createdAt;
  final String? status;

  factory VendorDto.fromJson(Map<String, dynamic> json) => VendorDto(
    id: json['id']?.toString(),
    name: json['name'] as String?,
    contactNumber: json['contactNumber'] as String? ?? json['phone'] as String?,
    type: json['type'] as String?,
    createdBy: json['createdBy'] as String?,
    createdAt: _parseDate(json['createdAt']),
    status: json['status'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (contactNumber != null) 'contactNumber': contactNumber,
    if (type != null) 'type': type,
    if (createdBy != null) 'createdBy': createdBy,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (status != null) 'status': status,
  };
}
