class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? alternatePhone;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;
  final String assignedTo;
  final String assignedToName;
  final String createdBy;
  final String createdByName;
  final String? projectType;
  final String? projectId;
  final String? projectName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastContactDate;
  final int leadCount;
  final int bookingCount;
  final int siteVisitCount;
  final bool isActive;
  final Map<String, dynamic>? customFields;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.alternatePhone,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.country,
    required this.assignedTo,
    required this.assignedToName,
    required this.createdBy,
    required this.createdByName,
    this.projectType,
    this.projectId,
    this.projectName,
    required this.createdAt,
    required this.updatedAt,
    this.lastContactDate,
    this.leadCount = 0,
    this.bookingCount = 0,
    this.siteVisitCount = 0,
    this.isActive = true,
    this.customFields,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    String s(String camel, String snake, [String fallback = '']) {
      final dynamic v = json[camel] ?? json[snake] ?? fallback;
      return (v is String) ? v : fallback;
    }

    String? sOpt(String camel, String snake) {
      final dynamic v = json[camel] ?? json[snake];
      return (v is String) ? v : null;
    }

    DateTime d(String camel, String snake, {DateTime? def}) {
      final dynamic v = json[camel] ?? json[snake];
      if (v is String && v.isNotEmpty) {
        return DateTime.tryParse(v) ?? (def ?? DateTime.now());
      }
      return def ?? DateTime.now();
    }

    DateTime? dOpt(String camel, String snake) {
      final dynamic v = json[camel] ?? json[snake];
      if (v is String && v.isNotEmpty) {
        return DateTime.tryParse(v);
      }
      return null;
    }

    int i(String camel, String snake, [int fallback = 0]) {
      final dynamic v = json[camel] ?? json[snake];
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    bool b(String camel, String snake, [bool fallback = true]) {
      final dynamic v = json[camel] ?? json[snake];
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true';
      return fallback;
    }

    return Customer(
      id: s('id', 'id'),
      name: s('name', 'name'),
      email: s('email', 'email'),
      phone: s('phone', 'phone'),
      alternatePhone: sOpt('alternatePhone', 'alternate_phone'),
      address: sOpt('address', 'address'),
      city: sOpt('city', 'city'),
      state: sOpt('state', 'state'),
      pincode: sOpt('pincode', 'pincode'),
      country: sOpt('country', 'country'),
      assignedTo: s('assignedTo', 'assigned_to'),
      assignedToName: s('assignedToName', 'assigned_to_name'),
      createdBy: s('createdBy', 'created_by'),
      createdByName: s('createdByName', 'created_by_name'),
      projectType: sOpt('projectType', 'project_type'),
      projectId: sOpt('projectId', 'project_id'),
      projectName: sOpt('projectName', 'project_name'),
      createdAt: d('createdAt', 'created_at'),
      updatedAt: d('updatedAt', 'updated_at', def: DateTime.now()),
      lastContactDate: dOpt('lastContactDate', 'last_contact_date'),
      leadCount: i('leadCount', 'lead_count', 0),
      bookingCount: i('bookingCount', 'booking_count', 0),
      siteVisitCount: i('siteVisitCount', 'site_visit_count', 0),
      isActive: b('isActive', 'is_active', true),
      customFields:
          (json['customFields'] as Map<String, dynamic>?) ??
          (json['custom_fields'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'alternatePhone': alternatePhone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'projectType': projectType,
      'projectId': projectId,
      'projectName': projectName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastContactDate': lastContactDate?.toIso8601String(),
      'leadCount': leadCount,
      'bookingCount': bookingCount,
      'siteVisitCount': siteVisitCount,
      'isActive': isActive,
      'customFields': customFields,
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? alternatePhone,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? country,
    String? assignedTo,
    String? assignedToName,
    String? createdBy,
    String? createdByName,
    String? projectType,
    String? projectId,
    String? projectName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastContactDate,
    int? leadCount,
    int? bookingCount,
    int? siteVisitCount,
    bool? isActive,
    Map<String, dynamic>? customFields,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      projectType: projectType ?? this.projectType,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastContactDate: lastContactDate ?? this.lastContactDate,
      leadCount: leadCount ?? this.leadCount,
      bookingCount: bookingCount ?? this.bookingCount,
      siteVisitCount: siteVisitCount ?? this.siteVisitCount,
      isActive: isActive ?? this.isActive,
      customFields: customFields ?? this.customFields,
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, email: $email, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
