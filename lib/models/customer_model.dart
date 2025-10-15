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
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      alternatePhone: json['alternatePhone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      country: json['country'] as String?,
      assignedTo: json['assignedTo'] as String,
      assignedToName: json['assignedToName'] as String,
      createdBy: json['createdBy'] as String,
      createdByName: json['createdByName'] as String,
      projectType: json['projectType'] as String?,
      projectId: json['projectId'] as String?,
      projectName: json['projectName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastContactDate: json['lastContactDate'] != null
          ? DateTime.parse(json['lastContactDate'] as String)
          : null,
      leadCount: json['leadCount'] as int? ?? 0,
      bookingCount: json['bookingCount'] as int? ?? 0,
      siteVisitCount: json['siteVisitCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      customFields: json['customFields'] as Map<String, dynamic>?,
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
