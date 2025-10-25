// Master data models for various lookup tables

class PropertyCategory {
  final String id;
  final String name;
  final bool isActive;

  const PropertyCategory({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory PropertyCategory.fromJson(Map<String, dynamic> json) {
    return PropertyCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'is_active': isActive};
  }
}

class PropertyTypeMaster {
  final String id;
  final String name;
  final bool isActive;

  const PropertyTypeMaster({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory PropertyTypeMaster.fromJson(Map<String, dynamic> json) {
    return PropertyTypeMaster(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'is_active': isActive};
  }
}

class VisitModeMaster {
  final String id;
  final String name;
  final bool isActive;

  const VisitModeMaster({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory VisitModeMaster.fromJson(Map<String, dynamic> json) {
    return VisitModeMaster(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'is_active': isActive};
  }
}

class LeadStatusMaster {
  final String id;
  final String name;
  final bool isActive;

  const LeadStatusMaster({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory LeadStatusMaster.fromJson(Map<String, dynamic> json) {
    return LeadStatusMaster(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'is_active': isActive};
  }
}

class LeadSubStatusMaster {
  final String id;
  final String statusId;
  final String name;
  final bool isActive;

  const LeadSubStatusMaster({
    required this.id,
    required this.statusId,
    required this.name,
    required this.isActive,
  });

  factory LeadSubStatusMaster.fromJson(Map<String, dynamic> json) {
    return LeadSubStatusMaster(
      id: json['id'] as String,
      statusId: json['status_id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status_id': statusId,
      'name': name,
      'is_active': isActive,
    };
  }
}

class InventoryType {
  final String id;
  final String name;
  final bool isActive;

  const InventoryType({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory InventoryType.fromJson(Map<String, dynamic> json) {
    return InventoryType(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'is_active': isActive};
  }
}

class OptionType {
  final String id;
  final String name;
  final bool isActive;

  const OptionType({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory OptionType.fromJson(Map<String, dynamic> json) {
    return OptionType(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'is_active': isActive};
  }
}

class StateMaster {
  final String id;
  final String name;
  final String countryId;
  final bool isActive;

  const StateMaster({
    required this.id,
    required this.name,
    required this.countryId,
    required this.isActive,
  });

  factory StateMaster.fromJson(Map<String, dynamic> json) {
    return StateMaster(
      id: json['id'] as String,
      name: json['name'] as String,
      countryId: json['country_id'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country_id': countryId,
      'is_active': isActive,
    };
  }
}

class City {
  final String id;
  final String name;
  final String stateId;
  final bool isActive;

  const City({
    required this.id,
    required this.name,
    required this.stateId,
    required this.isActive,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as String,
      name: json['name'] as String,
      stateId: json['state_id'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'state_id': stateId, 'is_active': isActive};
  }
}

class Location {
  final String id;
  final String name;
  final String cityId;
  final bool isActive;

  const Location({
    required this.id,
    required this.name,
    required this.cityId,
    required this.isActive,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as String,
      name: json['name'] as String,
      cityId: json['city_id'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'city_id': cityId, 'is_active': isActive};
  }
}

class Inventory {
  final String id;
  final String name;
  final String projectId;
  final String? unitType;
  final double? price;
  final double? area;
  final int? floorNumber;
  final String? availabilityStatus;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Inventory({
    required this.id,
    required this.name,
    required this.projectId,
    this.unitType,
    this.price,
    this.area,
    this.floorNumber,
    this.availabilityStatus,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'] as String,
      name: json['name'] as String,
      projectId: json['project_id'] as String,
      unitType: json['unit_type'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      area: (json['area'] as num?)?.toDouble(),
      floorNumber: json['floor_number'] as int?,
      availabilityStatus: json['availability_status'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'project_id': projectId,
      'unit_type': unitType,
      'price': price,
      'area': area,
      'floor_number': floorNumber,
      'availability_status': availabilityStatus,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// New models for lead creation form
class LeadSourceMaster {
  final String id;
  final String name;
  final bool isActive;

  const LeadSourceMaster({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory LeadSourceMaster.fromJson(Map<String, dynamic> json) {
    return LeadSourceMaster(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'is_active': isActive};
  }
}

class ProjectMaster {
  final String id;
  final String name;
  final String? category;
  final String? state;
  final String? city;
  final String? location;
  final bool isActive;

  const ProjectMaster({
    required this.id,
    required this.name,
    this.category,
    this.state,
    this.city,
    this.location,
    required this.isActive,
  });

  factory ProjectMaster.fromJson(Map<String, dynamic> json) {
    return ProjectMaster(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      location: json['location'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'state': state,
      'city': city,
      'location': location,
      'is_active': isActive,
    };
  }
}

class BudgetMaster {
  final String id;
  final String name;
  final bool isActive;

  const BudgetMaster({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory BudgetMaster.fromJson(Map<String, dynamic> json) {
    return BudgetMaster(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'is_active': isActive};
  }
}

class PurchasePlanYear {
  final String id;
  final String name;
  final bool isActive;

  const PurchasePlanYear({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory PurchasePlanYear.fromJson(Map<String, dynamic> json) {
    return PurchasePlanYear(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'is_active': isActive};
  }
}

class PurchasePlanMonth {
  final String id;
  final String name;
  final bool isActive;

  const PurchasePlanMonth({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory PurchasePlanMonth.fromJson(Map<String, dynamic> json) {
    return PurchasePlanMonth(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'is_active': isActive};
  }
}

class UserMaster {
  final String id;
  final String name;
  final String? email;
  final bool isActive;

  const UserMaster({
    required this.id,
    required this.name,
    this.email,
    required this.isActive,
  });

  factory UserMaster.fromJson(Map<String, dynamic> json) {
    return UserMaster(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'is_active': isActive};
  }
}

class GenderMaster {
  final String id;
  final String name;
  final bool isActive;

  const GenderMaster({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory GenderMaster.fromJson(Map<String, dynamic> json) {
    return GenderMaster(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'is_active': isActive};
  }
}

class MaritalStatusMaster {
  final String id;
  final String name;
  final bool isActive;

  const MaritalStatusMaster({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory MaritalStatusMaster.fromJson(Map<String, dynamic> json) {
    return MaritalStatusMaster(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'is_active': isActive};
  }
}

class EmploymentTypeMaster {
  final String id;
  final String name;
  final bool isActive;

  const EmploymentTypeMaster({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory EmploymentTypeMaster.fromJson(Map<String, dynamic> json) {
    return EmploymentTypeMaster(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'is_active': isActive};
  }
}

class ItrFilingStatusMaster {
  final String id;
  final String name;
  final bool isActive;

  const ItrFilingStatusMaster({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory ItrFilingStatusMaster.fromJson(Map<String, dynamic> json) {
    return ItrFilingStatusMaster(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'is_active': isActive};
  }
}
