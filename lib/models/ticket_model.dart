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
  inquiry;

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
    return Ticket(
      id: json['id'] as String,
      ticketNumber: json['ticketNumber'] as String,
      leadId: json['leadId'] as String?,
      customerId: json['customerId'] as String?,
      projectId: json['projectId'] as String?,
      unitNumber: json['unitNumber'] as String?,
      contactName: json['contactName'] as String,
      contactMobile: json['contactMobile'] as String,
      alternateNumber: json['alternateNumber'] as String?,
      issueTitle: json['issueTitle'] as String,
      issueDescription: json['issueDescription'] as String,
      ticketType: TicketType.values.firstWhere(
        (e) => e.name == json['ticketType'],
        orElse: () => TicketType.issue,
      ),
      serviceType: ServiceType.values.firstWhere(
        (e) => e.name == json['serviceType'],
        orElse: () => ServiceType.other,
      ),
      priority: TicketPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TicketPriority.medium,
      ),
      status: TicketStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TicketStatus.open,
      ),
      assignedTo: json['assignedTo'] as String?,
      assignedToName: json['assignedToName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      closedAt: json['closedAt'] != null
          ? DateTime.parse(json['closedAt'] as String)
          : null,
      resolution: json['resolution'] as String?,
      notes: json['notes'] as String?,
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      metadata: json['metadata'] as Map<String, dynamic>?,
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
