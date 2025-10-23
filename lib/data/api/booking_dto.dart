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

class BookingDto {
  BookingDto({
    this.id,
    this.customerId,
    this.projectId,
    this.unitId,
    this.amount,
    this.status,
    this.bookedAt,
  });

  final String? id;
  final String? customerId;
  final String? projectId;
  final String? unitId;
  final double? amount;
  final String? status;
  final DateTime? bookedAt;

  factory BookingDto.fromJson(Map<String, dynamic> json) => BookingDto(
    id: json['id']?.toString(),
    customerId: json['customerId']?.toString(),
    projectId: json['projectId']?.toString(),
    unitId: json['unitId']?.toString(),
    amount: (json['amount'] as num?)?.toDouble(),
    status: json['status'] as String?,
    bookedAt: _parseDate(json['bookedAt']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (id != null) 'id': id,
    if (customerId != null) 'customerId': customerId,
    if (projectId != null) 'projectId': projectId,
    if (unitId != null) 'unitId': unitId,
    if (amount != null) 'amount': amount,
    if (status != null) 'status': status,
    if (bookedAt != null) 'bookedAt': bookedAt!.toIso8601String(),
  };
}
