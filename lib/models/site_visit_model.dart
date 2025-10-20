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
  final String? assignedBy;
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
    this.assignedBy,
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
    String? s(String a, String b) =>
        (json[a] as String?) ?? (json[b] as String?);
    DateTime? d(String a, String b) {
      final String? v = s(a, b);
      return v == null ? null : DateTime.parse(v);
    }

    T enumVal<T>(List<T> values, String a, String b, T fallback) {
      final String? v = s(a, b);
      if (v == null) return fallback;
      return values.firstWhere(
        (e) => e.toString().split('.').last == v,
        orElse: () => fallback,
      );
    }

    return SiteVisit(
      id: s('id', 'id') ?? '',
      srNo: s('srNo', 'sr_no') ?? '',
      leadId: s('leadId', 'lead_id') ?? '',
      customerId: s('customerId', 'customer_id') ?? '',
      customerName: s('customerName', 'customer_name') ?? '',
      customerPhone: s('customerPhone', 'customer_phone') ?? '',
      projectId: s('projectId', 'project_id') ?? '',
      projectName: s('projectName', 'project_name') ?? '',
      unitNo: s('unitNo', 'unit_no'),
      visitMode: enumVal<VisitMode>(
        VisitMode.values,
        'visitMode',
        'visit_mode',
        VisitMode.physical,
      ),
      visitType: enumVal<VisitType>(
        VisitType.values,
        'visitType',
        'visit_type',
        VisitType.propertyInspection,
      ),
      status: enumVal<SiteVisitStatus>(
        SiteVisitStatus.values,
        'status',
        'status',
        SiteVisitStatus.scheduled,
      ),
      telecallerId: s('telecallerId', 'telecaller_id'),
      telecallerName: s('telecallerName', 'telecaller_name'),
      allocatedAt: d('allocatedAt', 'allocated_at'),
      assignedBy: s('assignedBy', 'assigned_by'),
      source: s('source', 'source'),
      meetingFrom: d('meetingFrom', 'meeting_from'),
      meetingTo: d('meetingTo', 'meeting_to'),
      purpose: s('purpose', 'purpose'),
      address: s('address', 'address'),
      minutes: s('minutes', 'minutes'),
      attenderId: s('attenderId', 'attender_id'),
      attenderName: s('attenderName', 'attender_name'),
      officeMeetingDateTime: d(
        'officeMeetingDateTime',
        'office_meeting_date_time',
      ),
      feedback: s('feedback', 'feedback'),
      notes: s('notes', 'notes'),
      attachments: (json['attachments'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      createdBy: s('createdBy', 'created_by') ?? '',
      createdByName: s('createdByName', 'created_by_name') ?? '',
      createdAt: d('createdAt', 'created_at') ?? DateTime.now(),
      updatedAt: d('updatedAt', 'updated_at') ?? DateTime.now(),
      customFields:
          (json['customFields'] as Map<String, dynamic>?) ??
          json['custom_fields'] as Map<String, dynamic>?,
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
      'visitMode': visitMode.toString().split('.').last,
      'visitType': visitType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'telecallerId': telecallerId,
      'telecallerName': telecallerName,
      'allocatedAt': allocatedAt?.toIso8601String(),
      'assignedBy': assignedBy,
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
    String? assignedBy,
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
      assignedBy: assignedBy ?? this.assignedBy,
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
