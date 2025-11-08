enum TicketStatus {
  open,
  inProgress,
  pending,
  resolved,
  closed,
  cancelled;

  String get displayName {
    switch (this) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.pending:
        return 'Pending';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
      case TicketStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum TicketPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.urgent:
        return 'Urgent';
    }
  }
}

enum TicketType {
  issue,
  request,
  complaint,
  inquiry,
  generalQuery;

  String get displayName {
    switch (this) {
      case TicketType.issue:
        return 'Issue';
      case TicketType.request:
        return 'Request';
      case TicketType.complaint:
        return 'Complaint';
      case TicketType.inquiry:
        return 'Inquiry';
      case TicketType.generalQuery:
        return 'General Query';
    }
  }
}

enum ServiceType {
  maintenance,
  repair,
  cleaning,
  plumbing,
  electrical,
  hvac,
  security,
  gasSupply,
  parkingSpace,
  securitySpace,
  waterSupplySpace,
  wifi,
  other;

  String get displayName {
    switch (this) {
      case ServiceType.maintenance:
        return 'Maintenance';
      case ServiceType.repair:
        return 'Repair';
      case ServiceType.cleaning:
        return 'Cleaning';
      case ServiceType.plumbing:
        return 'Plumbing';
      case ServiceType.electrical:
        return 'Electrical';
      case ServiceType.hvac:
        return 'HVAC';
      case ServiceType.security:
        return 'Security';
      case ServiceType.gasSupply:
        return 'Gas Supply';
      case ServiceType.parkingSpace:
        return 'Parking Space';
      case ServiceType.securitySpace:
        return 'Security Space';
      case ServiceType.waterSupplySpace:
        return 'Water Supply Space';
      case ServiceType.wifi:
        return 'WiFi';
      case ServiceType.other:
        return 'Other';
    }
  }
}

class Ticket {
  final String id;
  final String ticketNumber;
  final String? leadId;
  final String? customerId;
  final String? projectId;
  final String? unitNumber;
  final String contactName;
  final String contactMobile;
  final String? alternateNumber;
  final String issueTitle;
  final String issueDescription;
  final String? ticketCategory;
  final TicketType ticketType;
  final ServiceType serviceType;
  final TicketPriority priority;
  final TicketStatus status;
  final String? assignedTo;
  final String? assignedToName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final String? resolution;
  final String? notes;
  final List<String> attachments;
  final Map<String, dynamic>? metadata;

  const Ticket({
    required this.id,
    required this.ticketNumber,
    this.leadId,
    this.customerId,
    this.projectId,
    this.unitNumber,
    required this.contactName,
    required this.contactMobile,
    this.alternateNumber,
    required this.issueTitle,
    required this.issueDescription,
    this.ticketCategory,
    required this.ticketType,
    required this.serviceType,
    required this.priority,
    required this.status,
    this.assignedTo,
    this.assignedToName,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.closedAt,
    this.resolution,
    this.notes,
    this.attachments = const [],
    this.metadata,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
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

    return Ticket(
      id: s('id', 'id') ?? '',
      ticketNumber: s('ticketNumber', 'ticket_number') ?? '',
      leadId: s('leadId', 'lead_id'),
      customerId: s('customerId', 'customer_id'),
      projectId: s('projectId', 'project_id'),
      unitNumber: s('unitNumber', 'unit_number'),
      contactName: s('contactName', 'contact_name') ?? '-',
      contactMobile: s('contactMobile', 'contact_mobile') ?? '-',
      alternateNumber: s('alternateNumber', 'alternate_number'),
      issueTitle: s('issueTitle', 'issue_title') ?? '-',
      issueDescription: s('issueDescription', 'issue_description') ?? '-',
      ticketCategory: s('ticketCategory', 'ticket_category'),
      ticketType: enumVal<TicketType>(
        TicketType.values,
        'ticketType',
        'ticket_type',
        TicketType.issue,
      ),
      serviceType: enumVal<ServiceType>(
        ServiceType.values,
        'serviceType',
        'service_type',
        ServiceType.other,
      ),
      priority: enumVal<TicketPriority>(
        TicketPriority.values,
        'priority',
        'priority',
        TicketPriority.medium,
      ),
      status: enumVal<TicketStatus>(
        TicketStatus.values,
        'status',
        'status',
        TicketStatus.open,
      ),
      assignedTo: s('assignedTo', 'assigned_to'),
      assignedToName: s('assignedToName', 'assigned_to_name'),
      createdAt: d('createdAt', 'created_at') ?? DateTime.now(),
      updatedAt: d('updatedAt', 'updated_at'),
      resolvedAt: d('resolvedAt', 'resolved_at'),
      closedAt: d('closedAt', 'closed_at'),
      resolution: s('resolution', 'resolution'),
      notes: s('notes', 'notes'),
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      metadata:
          (json['metadata'] as Map<String, dynamic>?) ??
          json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketNumber': ticketNumber,
      'leadId': leadId,
      'customerId': customerId,
      'projectId': projectId,
      'unitNumber': unitNumber,
      'contactName': contactName,
      'contactMobile': contactMobile,
      'alternateNumber': alternateNumber,
      'issueTitle': issueTitle,
      'issueDescription': issueDescription,
      'ticketCategory': ticketCategory,
      'ticketType': ticketType.name,
      'serviceType': serviceType.name,
      'priority': priority.name,
      'status': status.name,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'resolution': resolution,
      'notes': notes,
      'attachments': attachments,
      'metadata': metadata,
    };
  }

  Ticket copyWith({
    String? id,
    String? ticketNumber,
    String? leadId,
    String? customerId,
    String? projectId,
    String? unitNumber,
    String? contactName,
    String? contactMobile,
    String? alternateNumber,
    String? issueTitle,
    String? issueDescription,
    String? ticketCategory,
    TicketType? ticketType,
    ServiceType? serviceType,
    TicketPriority? priority,
    TicketStatus? status,
    String? assignedTo,
    String? assignedToName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    DateTime? closedAt,
    String? resolution,
    String? notes,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return Ticket(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      leadId: leadId ?? this.leadId,
      customerId: customerId ?? this.customerId,
      projectId: projectId ?? this.projectId,
      unitNumber: unitNumber ?? this.unitNumber,
      contactName: contactName ?? this.contactName,
      contactMobile: contactMobile ?? this.contactMobile,
      alternateNumber: alternateNumber ?? this.alternateNumber,
      issueTitle: issueTitle ?? this.issueTitle,
      issueDescription: issueDescription ?? this.issueDescription,
      ticketCategory: ticketCategory ?? this.ticketCategory,
      ticketType: ticketType ?? this.ticketType,
      serviceType: serviceType ?? this.serviceType,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      closedAt: closedAt ?? this.closedAt,
      resolution: resolution ?? this.resolution,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ticket && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Ticket(id: $id, ticketNumber: $ticketNumber, status: $status, priority: $priority)';
  }
}
