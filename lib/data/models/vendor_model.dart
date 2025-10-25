class VendorModel {
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
  final String companyType;
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

  VendorModel({
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
    required this.companyType,
    required this.isReraRegistered,
    this.reraNumber,
    required this.gstin,
    this.gstinFilePath,
    required this.pan,
    this.panFilePath,
    this.aadhar,
    this.aadharFilePath,
    this.isActive = true,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    this.customFields,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      website: json['website'] as String?,
      logoUrl: json['logo_url'] as String?,
      address: json['address'] as String,
      state: json['state'] as String,
      district: json['district'] as String,
      city: json['city'] as String,
      pincode: json['pincode'] as String,
      country: json['country'] as String? ?? 'India',
      companyType: json['company_type'] as String,
      isReraRegistered: json['is_rera_registered'] as bool,
      reraNumber: json['rera_number'] as String?,
      gstin: json['gstin'] as String,
      gstinFilePath: json['gstin_file_path'] as String?,
      pan: json['pan'] as String,
      panFilePath: json['pan_file_path'] as String?,
      aadhar: json['aadhar'] as String?,
      aadharFilePath: json['aadhar_file_path'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdBy: json['created_by'] as String,
      createdByName: json['created_by_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      customFields: json['custom_fields'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'website': website,
      'logo_url': logoUrl,
      'address': address,
      'state': state,
      'district': district,
      'city': city,
      'pincode': pincode,
      'country': country,
      'company_type': companyType,
      'is_rera_registered': isReraRegistered,
      'rera_number': reraNumber,
      'gstin': gstin,
      'gstin_file_path': gstinFilePath,
      'pan': pan,
      'pan_file_path': panFilePath,
      'aadhar': aadhar,
      'aadhar_file_path': aadharFilePath,
      'is_active': isActive,
      'created_by': createdBy,
      'created_by_name': createdByName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'custom_fields': customFields,
    };
  }

  VendorModel copyWith({
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
    String? companyType,
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
    return VendorModel(
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
}

class VendorContactModel {
  final String id;
  final String vendorId;
  final String name;
  final String mobile;
  final String designation;
  final String email;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  VendorContactModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.mobile,
    required this.designation,
    required this.email,
    this.isPrimary = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorContactModel.fromJson(Map<String, dynamic> json) {
    return VendorContactModel(
      id: json['id'] as String,
      vendorId:
          json['developer_id'] as String, // Using developer_id as vendor_id
      name: json['name'] as String,
      mobile: json['mobile'] as String,
      designation: json['designation'] as String,
      email: json['email'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'developer_id': vendorId, // Using developer_id as vendor_id
      'name': name,
      'mobile': mobile,
      'designation': designation,
      'email': email,
      'is_primary': isPrimary,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class VendorBankDetailsModel {
  final String id;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String ifscCode;
  final String branchName;
  final String accountType;
  final String bankCategory;
  final String? micrCode;
  final String? swiftCode;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final bool isPrimary;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  VendorBankDetailsModel({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.ifscCode,
    required this.branchName,
    required this.accountType,
    required this.bankCategory,
    this.micrCode,
    this.swiftCode,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.isPrimary = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  factory VendorBankDetailsModel.fromJson(Map<String, dynamic> json) {
    return VendorBankDetailsModel(
      id: json['id'] as String,
      bankName: json['bank_name'] as String,
      accountNumber: json['account_number'] as String,
      accountHolderName: json['account_holder_name'] as String,
      ifscCode: json['ifsc_code'] as String,
      branchName: json['branch_name'] as String,
      accountType: json['account_type'] as String,
      bankCategory: json['bank_category'] as String,
      micrCode: json['micr_code'] as String?,
      swiftCode: json['swift_code'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_holder_name': accountHolderName,
      'ifsc_code': ifscCode,
      'branch_name': branchName,
      'account_type': accountType,
      'bank_category': bankCategory,
      'micr_code': micrCode,
      'swift_code': swiftCode,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'is_primary': isPrimary,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}
