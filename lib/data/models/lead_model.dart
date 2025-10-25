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
    int? inti(Map<String, dynamic> j, String a, String b) {
      // Try to get the value from either field
      dynamic value = j[a] ?? j[b];

      // Handle null values
      if (value == null) return null;

      // If it's already an int, return it
      if (value is int) return value;

      // If it's a string, try to parse it as int
      if (value is String) {
        if (value.isEmpty) return null;
        return int.tryParse(value);
      }

      // If it's a double, convert to int
      if (value is double) return value.toInt();

      // For any other type, return null
      return null;
    }

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
    final Map<String, dynamic> json = {};

    // Only include id if it's not empty (for updates)
    if (id.isNotEmpty) {
      json['id'] = id;
    }

    // Only include lead_id if it's not empty (for updates)
    if (leadId.isNotEmpty) {
      json['lead_id'] = leadId;
    }

    json['customer_name'] = customerName;
    json['email'] = email;
    json['phone'] = phone;
    json['alternate_phone'] = alternatePhone;
    json['address'] = address;
    json['city'] = city;
    json['state'] = state;
    json['pincode'] = pincode;

    // Personal Information
    json['name'] = name;
    json['dob'] = dob?.toIso8601String();
    json['age'] = age;
    json['gender'] = gender;
    json['marital_status'] = maritalStatus;
    json['employment_type'] = employmentType;
    json['itr_filing_status'] = itrFilingStatus;
    json['occupation'] = occupation;
    json['country'] = country;
    json['state_name'] = stateName;
    json['location'] = location;
    json['status'] = status.toString().split('.').last;
    json['sub_status'] = subStatus.toString().split('.').last;
    json['source'] = source.toString().split('.').last;
    json['property_type'] = propertyType.toString().split('.').last;
    json['category_type'] = categoryType.toString().split('.').last;
    json['project_id'] = projectId;
    json['project_name'] = projectName;
    json['budget_range'] = budgetRange;
    json['requirements'] = requirements;
    json['notes'] = notes;

    // Only include assigned_to if it's not empty
    if (assignedTo.isNotEmpty) {
      json['assigned_to'] = assignedTo;
    } else {
      json['assigned_to'] = null;
    }

    // Only include assigned_to_name if it's not empty
    if (assignedToName.isNotEmpty) {
      json['assigned_to_name'] = assignedToName;
    } else {
      json['assigned_to_name'] = null;
    }

    // Only include created_by if it's not empty
    if (createdBy.isNotEmpty) {
      json['created_by'] = createdBy;
    } else {
      json['created_by'] = null;
    }

    // Only include created_by_name if it's not empty
    if (createdByName.isNotEmpty) {
      json['created_by_name'] = createdByName;
    } else {
      json['created_by_name'] = null;
    }
    json['created_at'] = createdAt.toIso8601String();
    json['updated_at'] = updatedAt.toIso8601String();
    json['last_follow_up_date'] = lastFollowUpDate?.toIso8601String();
    json['next_follow_up_date'] = nextFollowUpDate?.toIso8601String();
    json['has_site_visit'] = hasSiteVisit;
    json['follow_up_count'] = followUpCount;
    json['site_visit_count'] = siteVisitCount;
    json['is_duplicate'] = isDuplicate;
    json['custom_fields'] = customFields;

    return json;
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
