enum BankAccountType {
  savings,
  current,
  fixedDeposit,
  recurringDeposit;

  String get displayName {
    switch (this) {
      case BankAccountType.savings:
        return 'Savings';
      case BankAccountType.current:
        return 'Current';
      case BankAccountType.fixedDeposit:
        return 'Fixed Deposit';
      case BankAccountType.recurringDeposit:
        return 'Recurring Deposit';
    }
  }
}

enum BankCategory {
  savings,
  current,
  fixedDeposit,
  recurringDeposit;

  String get displayName {
    switch (this) {
      case BankCategory.savings:
        return 'Savings';
      case BankCategory.current:
        return 'Current';
      case BankCategory.fixedDeposit:
        return 'Fixed Deposit';
      case BankCategory.recurringDeposit:
        return 'Recurring Deposit';
    }
  }
}

class BankDetails {
  final String id;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final String ifscCode;
  final String branchName;
  final BankAccountType accountType;
  final BankCategory bankCategory;
  final String? micrCode;
  final String? swiftCode;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final bool isPrimary;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const BankDetails({
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
    this.updatedAt,
    this.metadata,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      id: json['id'] as String,
      bankName: json['bankName'] as String,
      accountNumber: json['accountNumber'] as String,
      accountHolderName: json['accountHolderName'] as String,
      ifscCode: json['ifscCode'] as String,
      branchName: json['branchName'] as String,
      accountType: BankAccountType.values.firstWhere(
        (e) => e.name == json['accountType'],
        orElse: () => BankAccountType.savings,
      ),
      bankCategory: BankCategory.values.firstWhere(
        (e) => e.name == json['bankCategory'],
        orElse: () => BankCategory.savings,
      ),
      micrCode: json['micrCode'] as String?,
      swiftCode: json['swiftCode'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'ifscCode': ifscCode,
      'branchName': branchName,
      'accountType': accountType.name,
      'bankCategory': bankCategory.name,
      'micrCode': micrCode,
      'swiftCode': swiftCode,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'isPrimary': isPrimary,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  BankDetails copyWith({
    String? id,
    String? bankName,
    String? accountNumber,
    String? accountHolderName,
    String? ifscCode,
    String? branchName,
    BankAccountType? accountType,
    BankCategory? bankCategory,
    String? micrCode,
    String? swiftCode,
    String? address,
    String? city,
    String? state,
    String? pincode,
    bool? isPrimary,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return BankDetails(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      ifscCode: ifscCode ?? this.ifscCode,
      branchName: branchName ?? this.branchName,
      accountType: accountType ?? this.accountType,
      bankCategory: bankCategory ?? this.bankCategory,
      micrCode: micrCode ?? this.micrCode,
      swiftCode: swiftCode ?? this.swiftCode,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      isPrimary: isPrimary ?? this.isPrimary,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BankDetails && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BankDetails(id: $id, bankName: $bankName, accountNumber: $accountNumber)';
  }
}
