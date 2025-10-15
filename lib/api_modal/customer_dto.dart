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

class CustomerDto {
  CustomerDto({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.assignedTo,
    this.createdAt,
  });

  final String? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? assignedTo;
  final DateTime? createdAt;

  factory CustomerDto.fromJson(Map<String, dynamic> json) => CustomerDto(
    id: json['id']?.toString(),
    name: json['name'] as String?,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    address: json['address'] as String?,
    city: json['city'] as String?,
    state: json['state'] as String?,
    assignedTo: json['assignedTo'] as String?,
    createdAt: _parseDate(json['createdAt']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (phone != null) 'phone': phone,
    if (email != null) 'email': email,
    if (address != null) 'address': address,
    if (city != null) 'city': city,
    if (state != null) 'state': state,
    if (assignedTo != null) 'assignedTo': assignedTo,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };
}
