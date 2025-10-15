enum CompanyType { pvtLtd, llp, partnership, proprietorship }

class DeveloperContact {
  final String id;
  final String name;
  final String mobile;
  final String designation;
  final String email;
  final bool isPrimary;

  const DeveloperContact({
    required this.id,
    required this.name,
    required this.mobile,
    required this.designation,
    required this.email,
    this.isPrimary = false,
  });

  factory DeveloperContact.fromJson(Map<String, dynamic> json) {
    return DeveloperContact(
      id: json['id'] as String,
      name: json['name'] as String,
      mobile: json['mobile'] as String,
      designation: json['designation'] as String,
      email: json['email'] as String,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'designation': designation,
      'email': email,
      'isPrimary': isPrimary,
    };
  }

  DeveloperContact copyWith({
    String? id,
    String? name,
    String? mobile,
    String? designation,
    String? email,
    bool? isPrimary,
  }) {
    return DeveloperContact(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      designation: designation ?? this.designation,
      email: email ?? this.email,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  @override
  String toString() {
    return 'DeveloperContact(id: $id, name: $name, designation: $designation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeveloperContact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Developer {
  final String id;
  final String name;
  final String? website;
  final String? logoUrl;
  final String address;
  final String state;
  final String district;
  final String city;
  final String pincode;
  final String country;
  final List<DeveloperContact> contacts;
  final CompanyType companyType;
  final bool isReraRegistered;
  final String? reraNumber;
  final String gstin;
  final String? gstinFilePath;
  final String pan;
  final String? panFilePath;
  final String? aadhar;
  final String? aadharFilePath;
  final bool isActive;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? customFields;

  const Developer({
    required this.id,
    required this.name,
    this.website,
    this.logoUrl,
    required this.address,
    required this.state,
    required this.district,
    required this.city,
    required this.pincode,
    this.country = 'India',
    required this.contacts,
    required this.companyType,
    required this.isReraRegistered,
    this.reraNumber,
    required this.gstin,
    this.gstinFilePath,
    required this.pan,
    this.panFilePath,
    this.aadhar,
    this.aadharFilePath,
    required this.isActive,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    this.customFields,
  });

  factory Developer.fromJson(Map<String, dynamic> json) {
    return Developer(
      id: json['id'] as String,
      name: json['name'] as String,
      website: json['website'] as String?,
      logoUrl: json['logoUrl'] as String?,
      address: json['address'] as String,
      state: json['state'] as String,
      district: json['district'] as String,
      city: json['city'] as String,
      pincode: json['pincode'] as String,
      country: json['country'] as String? ?? 'India',
      contacts: (json['contacts'] as List)
          .map((e) => DeveloperContact.fromJson(e as Map<String, dynamic>))
          .toList(),
      companyType: CompanyType.values.firstWhere(
        (e) => e.name == json['companyType'],
        orElse: () => CompanyType.pvtLtd,
      ),
      isReraRegistered: json['isReraRegistered'] as bool,
      reraNumber: json['reraNumber'] as String?,
      gstin: json['gstin'] as String,
      gstinFilePath: json['gstinFilePath'] as String?,
      pan: json['pan'] as String,
      panFilePath: json['panFilePath'] as String?,
      aadhar: json['aadhar'] as String?,
      aadharFilePath: json['aadharFilePath'] as String?,
      isActive: json['isActive'] as bool,
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
      'name': name,
      'website': website,
      'logoUrl': logoUrl,
      'address': address,
      'state': state,
      'district': district,
      'city': city,
      'pincode': pincode,
      'country': country,
      'contacts': contacts.map((e) => e.toJson()).toList(),
      'companyType': companyType.name,
      'isReraRegistered': isReraRegistered,
      'reraNumber': reraNumber,
      'gstin': gstin,
      'gstinFilePath': gstinFilePath,
      'pan': pan,
      'panFilePath': panFilePath,
      'aadhar': aadhar,
      'aadharFilePath': aadharFilePath,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'customFields': customFields,
    };
  }

  Developer copyWith({
    String? id,
    String? name,
    String? website,
    String? logoUrl,
    String? address,
    String? state,
    String? district,
    String? city,
    String? pincode,
    String? country,
    List<DeveloperContact>? contacts,
    CompanyType? companyType,
    bool? isReraRegistered,
    String? reraNumber,
    String? gstin,
    String? gstinFilePath,
    String? pan,
    String? panFilePath,
    String? aadhar,
    String? aadharFilePath,
    bool? isActive,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? customFields,
  }) {
    return Developer(
      id: id ?? this.id,
      name: name ?? this.name,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      address: address ?? this.address,
      state: state ?? this.state,
      district: district ?? this.district,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
      contacts: contacts ?? this.contacts,
      companyType: companyType ?? this.companyType,
      isReraRegistered: isReraRegistered ?? this.isReraRegistered,
      reraNumber: reraNumber ?? this.reraNumber,
      gstin: gstin ?? this.gstin,
      gstinFilePath: gstinFilePath ?? this.gstinFilePath,
      pan: pan ?? this.pan,
      panFilePath: panFilePath ?? this.panFilePath,
      aadhar: aadhar ?? this.aadhar,
      aadharFilePath: aadharFilePath ?? this.aadharFilePath,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customFields: customFields ?? this.customFields,
    );
  }

  @override
  String toString() {
    return 'Developer(id: $id, name: $name, city: $city, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Developer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
