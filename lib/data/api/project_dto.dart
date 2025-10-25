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

class ProjectDto {
  ProjectDto({
    this.id,
    this.name,
    this.developerId,
    this.city,
    this.state,
    this.type,
    this.status,
    this.startingPrice,
    this.maxPrice,
    this.priceUnit,
    this.amenities,
    this.propertyTypes,
    this.isActive,
    this.createdAt,
  });

  final String? id;
  final String? name;
  final String? developerId;
  final String? city;
  final String? state;
  final String? type;
  final String? status;
  final double? startingPrice;
  final double? maxPrice;
  final String? priceUnit;
  final List<String>? amenities;
  final List<String>? propertyTypes;
  final bool? isActive;
  final DateTime? createdAt;

  factory ProjectDto.fromJson(Map<String, dynamic> json) => ProjectDto(
    id: json['id']?.toString(),
    name: json['name'] as String?,
    developerId: json['developerId']?.toString(),
    city: json['city'] as String?,
    state: json['state'] as String?,
    type: json['type'] as String?,
    status: json['status'] as String?,
    startingPrice: (json['startingPrice'] as num?)?.toDouble(),
    maxPrice: (json['maxPrice'] as num?)?.toDouble(),
    priceUnit: json['priceUnit'] as String?,
    amenities: (json['amenities'] as List<dynamic>?)
        ?.map((dynamic e) => e.toString())
        .toList(),
    propertyTypes: (json['propertyTypes'] as List<dynamic>?)
        ?.map((dynamic e) => e.toString())
        .toList(),
    isActive: json['isActive'] as bool?,
    createdAt: _parseDate(json['createdAt']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (developerId != null) 'developerId': developerId,
    if (city != null) 'city': city,
    if (state != null) 'state': state,
    if (type != null) 'type': type,
    if (status != null) 'status': status,
    if (startingPrice != null) 'startingPrice': startingPrice,
    if (maxPrice != null) 'maxPrice': maxPrice,
    if (priceUnit != null) 'priceUnit': priceUnit,
    if (amenities != null) 'amenities': amenities,
    if (propertyTypes != null) 'propertyTypes': propertyTypes,
    if (isActive != null) 'isActive': isActive,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };
}
