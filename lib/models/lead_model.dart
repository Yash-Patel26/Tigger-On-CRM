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
  // Personal Information
  final String? name;
  final DateTime? dob;
  final int? age;
  final String? gender;
  final String? maritalStatus;
  final String? employmentType;
  final String? itrFilingStatus;
  final String? occupation;
  final String? country;
  final String? stateName;
  final String? location;
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
    // Personal Information
    this.name,
    this.dob,
    this.age,
    this.gender,
    this.maritalStatus,
    this.employmentType,
    this.itrFilingStatus,
    this.occupation,
    this.country,
    this.stateName,
    this.location,
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
    String? s(Map<String, dynamic> j, String a, String b) =>
        (j[a] as String?) ?? (j[b] as String?);
    String sr(Map<String, dynamic> j, String a, String b, String fallback) =>
        s(j, a, b) ?? fallback;
    String? opt(Map<String, dynamic> j, String a, String b) =>
        j[a] as String? ?? j[b] as String?;
    int? inti(Map<String, dynamic> j, String a, String b) =>
        (j[a] as int?) ?? (j[b] as int?);
    bool b(Map<String, dynamic> j, String a, String b, bool d) =>
        (j[a] as bool?) ?? (j[b] as bool?) ?? d;
    DateTime dt(Map<String, dynamic> j, String a, String b) =>
        DateTime.parse(sr(j, a, b, DateTime.now().toIso8601String()));
    DateTime? dtOpt(Map<String, dynamic> j, String a, String b) {
      final v = s(j, a, b);
      return v != null ? DateTime.parse(v) : null;
    }

    return Lead(
      id: sr(json, 'id', 'id', ''),
      leadId: sr(json, 'leadId', 'lead_id', ''),
      customerName: sr(json, 'customerName', 'customer_name', ''),
      email: sr(json, 'email', 'email', ''),
      phone: sr(json, 'phone', 'phone', ''),
      alternatePhone: opt(json, 'alternatePhone', 'alternate_phone'),
      address: opt(json, 'address', 'address'),
      city: opt(json, 'city', 'city'),
      state: opt(json, 'state', 'state'),
      pincode: opt(json, 'pincode', 'pincode'),
      // Personal Information
      name: opt(json, 'name', 'name'),
      dob: dtOpt(json, 'dob', 'dob'),
      age: inti(json, 'age', 'age'),
      gender: opt(json, 'gender', 'gender'),
      maritalStatus: opt(json, 'maritalStatus', 'marital_status'),
      employmentType: opt(json, 'employmentType', 'employment_type'),
      itrFilingStatus: opt(json, 'itrFilingStatus', 'itr_filing_status'),
      occupation: opt(json, 'occupation', 'occupation'),
      country: opt(json, 'country', 'country'),
      stateName: opt(json, 'stateName', 'state_name'),
      location: opt(json, 'location', 'location'),
      status: LeadStatus.values.firstWhere(
        (e) => e.name == (s(json, 'status', 'status') ?? 'warm'),
        orElse: () => LeadStatus.warm,
      ),
      subStatus: LeadSubStatus.values.firstWhere(
        (e) => e.name == (s(json, 'subStatus', 'sub_status') ?? 'newLead'),
        orElse: () => LeadSubStatus.newLead,
      ),
      source: LeadSource.values.firstWhere(
        (e) => e.name == (s(json, 'source', 'source') ?? 'website'),
        orElse: () => LeadSource.website,
      ),
      propertyType: PropertyType.values.firstWhere(
        (e) =>
            e.name ==
            (s(json, 'propertyType', 'property_type') ?? 'residential'),
        orElse: () => PropertyType.residential,
      ),
      categoryType: CategoryType.values.firstWhere(
        (e) => e.name == (s(json, 'categoryType', 'category_type') ?? 'b'),
        orElse: () => CategoryType.b,
      ),
      projectId: opt(json, 'projectId', 'project_id'),
      projectName: opt(json, 'projectName', 'project_name'),
      budgetRange: opt(json, 'budgetRange', 'budget_range'),
      requirements: opt(json, 'requirements', 'requirements'),
      notes: opt(json, 'notes', 'notes'),
      assignedTo: sr(json, 'assignedTo', 'assigned_to', ''),
      assignedToName: sr(json, 'assignedToName', 'assigned_to_name', ''),
      createdBy: sr(json, 'createdBy', 'created_by', ''),
      createdByName: sr(json, 'createdByName', 'created_by_name', ''),
      createdAt: dt(json, 'createdAt', 'created_at'),
      updatedAt: dt(json, 'updatedAt', 'updated_at'),
      lastFollowUpDate: dtOpt(json, 'lastFollowUpDate', 'last_follow_up_date'),
      nextFollowUpDate: dtOpt(json, 'nextFollowUpDate', 'next_follow_up_date'),
      hasSiteVisit: b(json, 'hasSiteVisit', 'has_site_visit', false),
      followUpCount: inti(json, 'followUpCount', 'follow_up_count') ?? 0,
      siteVisitCount: inti(json, 'siteVisitCount', 'site_visit_count') ?? 0,
      isDuplicate: b(json, 'isDuplicate', 'is_duplicate', false),
      customFields:
          (json['customFields'] as Map<String, dynamic>?) ??
          json['custom_fields'] as Map<String, dynamic>?,
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
      // Personal Information
      'name': name,
      'dob': dob?.toIso8601String(),
      'age': age,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'employmentType': employmentType,
      'itrFilingStatus': itrFilingStatus,
      'occupation': occupation,
      'country': country,
      'stateName': stateName,
      'location': location,
      'status': status.toString().split('.').last,
      'subStatus': subStatus.toString().split('.').last,
      'source': source.toString().split('.').last,
      'propertyType': propertyType.toString().split('.').last,
      'categoryType': categoryType.toString().split('.').last,
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
    // Personal Information
    String? name,
    DateTime? dob,
    int? age,
    String? gender,
    String? maritalStatus,
    String? employmentType,
    String? itrFilingStatus,
    String? occupation,
    String? country,
    String? stateName,
    String? location,
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
      // Personal Information
      name: name ?? this.name,
      dob: dob ?? this.dob,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      employmentType: employmentType ?? this.employmentType,
      itrFilingStatus: itrFilingStatus ?? this.itrFilingStatus,
      occupation: occupation ?? this.occupation,
      country: country ?? this.country,
      stateName: stateName ?? this.stateName,
      location: location ?? this.location,
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
