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

class SiteVisitDto {
  SiteVisitDto({
    this.id,
    this.leadId,
    this.customerId,
    this.projectId,
    this.visitMode,
    this.visitType,
    this.status,
    this.telecallerId,
    this.attenderId,
    this.meetingFrom,
    this.meetingTo,
    this.minutes,
    this.feedback,
    this.createdAt,
  });

  final String? id;
  final String? leadId;
  final String? customerId;
  final String? projectId;
  final String? visitMode;
  final String? visitType;
  final String? status;
  final String? telecallerId;
  final String? attenderId;
  final DateTime? meetingFrom;
  final DateTime? meetingTo;
  final String? minutes;
  final String? feedback;
  final DateTime? createdAt;

  factory SiteVisitDto.fromJson(Map<String, dynamic> json) => SiteVisitDto(
    id: json['id']?.toString(),
    leadId: json['leadId']?.toString(),
    customerId: json['customerId']?.toString(),
    projectId: json['projectId']?.toString(),
    visitMode: json['visitMode'] as String?,
    visitType: json['visitType'] as String?,
    status: json['status'] as String?,
    telecallerId: json['telecallerId']?.toString(),
    attenderId: json['attenderId']?.toString(),
    meetingFrom: _parseDate(json['meetingFrom']),
    meetingTo: _parseDate(json['meetingTo']),
    minutes: json['minutes']?.toString(),
    feedback: json['feedback'] as String?,
    createdAt: _parseDate(json['createdAt']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (id != null) 'id': id,
    if (leadId != null) 'leadId': leadId,
    if (customerId != null) 'customerId': customerId,
    if (projectId != null) 'projectId': projectId,
    if (visitMode != null) 'visitMode': visitMode,
    if (visitType != null) 'visitType': visitType,
    if (status != null) 'status': status,
    if (telecallerId != null) 'telecallerId': telecallerId,
    if (attenderId != null) 'attenderId': attenderId,
    if (meetingFrom != null) 'meetingFrom': meetingFrom!.toIso8601String(),
    if (meetingTo != null) 'meetingTo': meetingTo!.toIso8601String(),
    if (minutes != null) 'minutes': minutes,
    if (feedback != null) 'feedback': feedback,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };
}
