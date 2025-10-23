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
