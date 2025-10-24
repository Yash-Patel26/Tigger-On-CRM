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
  final String propertyTypeId;
  final String? unitNumber;
  final double? price;
  final String? priceUnit;
  final bool isAvailable;
  final bool isActive;

  const Inventory({
    required this.id,
    required this.name,
    required this.projectId,
    required this.propertyTypeId,
    this.unitNumber,
    this.price,
    this.priceUnit,
    required this.isAvailable,
    required this.isActive,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'] as String,
      name: json['name'] as String,
      projectId: json['project_id'] as String,
      propertyTypeId: json['property_type_id'] as String,
      unitNumber: json['unit_number'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      priceUnit: json['price_unit'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'project_id': projectId,
      'property_type_id': propertyTypeId,
      'unit_number': unitNumber,
      'price': price,
      'price_unit': priceUnit,
      'is_available': isAvailable,
      'is_active': isActive,
    };
  }
}
