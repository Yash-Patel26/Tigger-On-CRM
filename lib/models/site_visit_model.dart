enum SiteVisitStatus { scheduled, completed, cancelled, rescheduled }

enum VisitMode { physical, video, phone, office }

enum VisitType { propertyInspection, siteSurvey, clientMeeting, followUp }

class SiteVisit {
  final String id;
  final String srNo; // Serial number like SV-1001
  final String leadId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String projectId;
  final String projectName;
  final String? unitNo;
  final VisitMode visitMode;
  final VisitType visitType;
  final SiteVisitStatus status;
  final String? telecallerId;
  final String? telecallerName;
  final DateTime? allocatedAt;
  final String? allocatedBy;
  final String? source;
  final DateTime? meetingFrom;
  final DateTime? meetingTo;
  final String? purpose;
  final String? address;
  final String? minutes;
  final String? attenderId;
  final String? attenderName;
  final DateTime? officeMeetingDateTime;
  final String? feedback;
  final String? notes;
  final List<String>? attachments;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? customFields;

  const SiteVisit({
    required this.id,
    required this.srNo,
    required this.leadId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.projectId,
    required this.projectName,
    this.unitNo,
    required this.visitMode,
    required this.visitType,
    required this.status,
    this.telecallerId,
    this.telecallerName,
    this.allocatedAt,
    this.allocatedBy,
    this.source,
    this.meetingFrom,
    this.meetingTo,
    this.purpose,
    this.address,
    this.minutes,
    this.attenderId,
    this.attenderName,
    this.officeMeetingDateTime,
    this.feedback,
    this.notes,
    this.attachments,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    this.customFields,
  });

  factory SiteVisit.fromJson(Map<String, dynamic> json) {
    return SiteVisit(
      id: json['id'] as String,
      srNo: json['srNo'] as String,
      leadId: json['leadId'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      projectId: json['projectId'] as String,
      projectName: json['projectName'] as String,
      unitNo: json['unitNo'] as String?,
      visitMode: VisitMode.values.firstWhere(
        (e) => e.name == json['visitMode'],
        orElse: () => VisitMode.physical,
      ),
      visitType: VisitType.values.firstWhere(
        (e) => e.name == json['visitType'],
        orElse: () => VisitType.propertyInspection,
      ),
      status: SiteVisitStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SiteVisitStatus.scheduled,
      ),
      telecallerId: json['telecallerId'] as String?,
      telecallerName: json['telecallerName'] as String?,
      allocatedAt: json['allocatedAt'] != null
          ? DateTime.parse(json['allocatedAt'] as String)
          : null,
      allocatedBy: json['allocatedBy'] as String?,
      source: json['source'] as String?,
      meetingFrom: json['meetingFrom'] != null
          ? DateTime.parse(json['meetingFrom'] as String)
          : null,
      meetingTo: json['meetingTo'] != null
          ? DateTime.parse(json['meetingTo'] as String)
          : null,
      purpose: json['purpose'] as String?,
      address: json['address'] as String?,
      minutes: json['minutes'] as String?,
      attenderId: json['attenderId'] as String?,
      attenderName: json['attenderName'] as String?,
      officeMeetingDateTime: json['officeMeetingDateTime'] != null
          ? DateTime.parse(json['officeMeetingDateTime'] as String)
          : null,
      feedback: json['feedback'] as String?,
      notes: json['notes'] as String?,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'] as List)
          : null,
      createdBy: json['createdBy'] as String,
      createdByName: json['createdByName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      customFields: json['customFields'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'srNo': srNo,
      'leadId': leadId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'projectId': projectId,
      'projectName': projectName,
      'unitNo': unitNo,
      'visitMode': visitMode.name,
      'visitType': visitType.name,
      'status': status.name,
      'telecallerId': telecallerId,
      'telecallerName': telecallerName,
      'allocatedAt': allocatedAt?.toIso8601String(),
      'allocatedBy': allocatedBy,
      'source': source,
      'meetingFrom': meetingFrom?.toIso8601String(),
      'meetingTo': meetingTo?.toIso8601String(),
      'purpose': purpose,
      'address': address,
      'minutes': minutes,
      'attenderId': attenderId,
      'attenderName': attenderName,
      'officeMeetingDateTime': officeMeetingDateTime?.toIso8601String(),
      'feedback': feedback,
      'notes': notes,
      'attachments': attachments,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'customFields': customFields,
    };
  }

  SiteVisit copyWith({
    String? id,
    String? srNo,
    String? leadId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? projectId,
    String? projectName,
    String? unitNo,
    VisitMode? visitMode,
    VisitType? visitType,
    SiteVisitStatus? status,
    String? telecallerId,
    String? telecallerName,
    DateTime? allocatedAt,
    String? allocatedBy,
    String? source,
    DateTime? meetingFrom,
    DateTime? meetingTo,
    String? purpose,
    String? address,
    String? minutes,
    String? attenderId,
    String? attenderName,
    DateTime? officeMeetingDateTime,
    String? feedback,
    String? notes,
    List<String>? attachments,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? customFields,
  }) {
    return SiteVisit(
      id: id ?? this.id,
      srNo: srNo ?? this.srNo,
      leadId: leadId ?? this.leadId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      unitNo: unitNo ?? this.unitNo,
      visitMode: visitMode ?? this.visitMode,
      visitType: visitType ?? this.visitType,
      status: status ?? this.status,
      telecallerId: telecallerId ?? this.telecallerId,
      telecallerName: telecallerName ?? this.telecallerName,
      allocatedAt: allocatedAt ?? this.allocatedAt,
      allocatedBy: allocatedBy ?? this.allocatedBy,
      source: source ?? this.source,
      meetingFrom: meetingFrom ?? this.meetingFrom,
      meetingTo: meetingTo ?? this.meetingTo,
      purpose: purpose ?? this.purpose,
      address: address ?? this.address,
      minutes: minutes ?? this.minutes,
      attenderId: attenderId ?? this.attenderId,
      attenderName: attenderName ?? this.attenderName,
      officeMeetingDateTime:
          officeMeetingDateTime ?? this.officeMeetingDateTime,
      feedback: feedback ?? this.feedback,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customFields: customFields ?? this.customFields,
    );
  }

  @override
  String toString() {
    return 'SiteVisit(id: $id, srNo: $srNo, customerName: $customerName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SiteVisit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
