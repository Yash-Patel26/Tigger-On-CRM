enum LeadStatus { hot, warm, cold }

enum LeadSubStatus { newLead, inProgress, closed }

enum LeadSource { portal, walkIn, referral, website, socialMedia, other }

enum PropertyType { residential, commercial, industrial, land }

enum CategoryType { a, b, c }

class Lead {
  final String id;
  final String leadId; // Display ID like LD-1001
  final String customerName;
  final String email;
  final String phone;
  final String? alternatePhone;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final LeadStatus status;
  final LeadSubStatus subStatus;
  final LeadSource source;
  final PropertyType propertyType;
  final CategoryType categoryType;
  final String? projectId;
  final String? projectName;
  final String? budgetRange;
  final String? requirements;
  final String? notes;
  final String assignedTo;
  final String assignedToName;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastFollowUpDate;
  final DateTime? nextFollowUpDate;
  final bool hasSiteVisit;
  final int followUpCount;
  final int siteVisitCount;
  final bool isDuplicate;
  final Map<String, dynamic>? customFields;

  const Lead({
    required this.id,
    required this.leadId,
    required this.customerName,
    required this.email,
    required this.phone,
    this.alternatePhone,
    this.address,
    this.city,
    this.state,
    this.pincode,
    required this.status,
    required this.subStatus,
    required this.source,
    required this.propertyType,
    required this.categoryType,
    this.projectId,
    this.projectName,
    this.budgetRange,
    this.requirements,
    this.notes,
    required this.assignedTo,
    required this.assignedToName,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    this.lastFollowUpDate,
    this.nextFollowUpDate,
    this.hasSiteVisit = false,
    this.followUpCount = 0,
    this.siteVisitCount = 0,
    this.isDuplicate = false,
    this.customFields,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] as String,
      leadId: json['leadId'] as String,
      customerName: json['customerName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      alternatePhone: json['alternatePhone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      status: LeadStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LeadStatus.warm,
      ),
      subStatus: LeadSubStatus.values.firstWhere(
        (e) => e.name == json['subStatus'],
        orElse: () => LeadSubStatus.newLead,
      ),
      source: LeadSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => LeadSource.website,
      ),
      propertyType: PropertyType.values.firstWhere(
        (e) => e.name == json['propertyType'],
        orElse: () => PropertyType.residential,
      ),
      categoryType: CategoryType.values.firstWhere(
        (e) => e.name == json['categoryType'],
        orElse: () => CategoryType.b,
      ),
      projectId: json['projectId'] as String?,
      projectName: json['projectName'] as String?,
      budgetRange: json['budgetRange'] as String?,
      requirements: json['requirements'] as String?,
      notes: json['notes'] as String?,
      assignedTo: json['assignedTo'] as String,
      assignedToName: json['assignedToName'] as String,
      createdBy: json['createdBy'] as String,
      createdByName: json['createdByName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastFollowUpDate: json['lastFollowUpDate'] != null
          ? DateTime.parse(json['lastFollowUpDate'] as String)
          : null,
      nextFollowUpDate: json['nextFollowUpDate'] != null
          ? DateTime.parse(json['nextFollowUpDate'] as String)
          : null,
      hasSiteVisit: json['hasSiteVisit'] as bool? ?? false,
      followUpCount: json['followUpCount'] as int? ?? 0,
      siteVisitCount: json['siteVisitCount'] as int? ?? 0,
      isDuplicate: json['isDuplicate'] as bool? ?? false,
      customFields: json['customFields'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leadId': leadId,
      'customerName': customerName,
      'email': email,
      'phone': phone,
      'alternatePhone': alternatePhone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'status': status.name,
      'subStatus': subStatus.name,
      'source': source.name,
      'propertyType': propertyType.name,
      'categoryType': categoryType.name,
      'projectId': projectId,
      'projectName': projectName,
      'budgetRange': budgetRange,
      'requirements': requirements,
      'notes': notes,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastFollowUpDate': lastFollowUpDate?.toIso8601String(),
      'nextFollowUpDate': nextFollowUpDate?.toIso8601String(),
      'hasSiteVisit': hasSiteVisit,
      'followUpCount': followUpCount,
      'siteVisitCount': siteVisitCount,
      'isDuplicate': isDuplicate,
      'customFields': customFields,
    };
  }

  Lead copyWith({
    String? id,
    String? leadId,
    String? customerName,
    String? email,
    String? phone,
    String? alternatePhone,
    String? address,
    String? city,
    String? state,
    String? pincode,
    LeadStatus? status,
    LeadSubStatus? subStatus,
    LeadSource? source,
    PropertyType? propertyType,
    CategoryType? categoryType,
    String? projectId,
    String? projectName,
    String? budgetRange,
    String? requirements,
    String? notes,
    String? assignedTo,
    String? assignedToName,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastFollowUpDate,
    DateTime? nextFollowUpDate,
    bool? hasSiteVisit,
    int? followUpCount,
    int? siteVisitCount,
    bool? isDuplicate,
    Map<String, dynamic>? customFields,
  }) {
    return Lead(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      customerName: customerName ?? this.customerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      status: status ?? this.status,
      subStatus: subStatus ?? this.subStatus,
      source: source ?? this.source,
      propertyType: propertyType ?? this.propertyType,
      categoryType: categoryType ?? this.categoryType,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      budgetRange: budgetRange ?? this.budgetRange,
      requirements: requirements ?? this.requirements,
      notes: notes ?? this.notes,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastFollowUpDate: lastFollowUpDate ?? this.lastFollowUpDate,
      nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
      hasSiteVisit: hasSiteVisit ?? this.hasSiteVisit,
      followUpCount: followUpCount ?? this.followUpCount,
      siteVisitCount: siteVisitCount ?? this.siteVisitCount,
      isDuplicate: isDuplicate ?? this.isDuplicate,
      customFields: customFields ?? this.customFields,
    );
  }

  @override
  String toString() {
    return 'Lead(id: $id, leadId: $leadId, customerName: $customerName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Lead && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
