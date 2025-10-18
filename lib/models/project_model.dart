enum ProjectStatus { planning, underConstruction, completed, onHold, cancelled }

enum ProjectType { residential, commercial, industrial, mixed }

class Project {
  final String id;
  final String name;
  final String? description;
  final String developerId;
  final String developerName;
  final ProjectType type;
  final ProjectStatus status;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;
  final double? totalArea;
  final int? totalUnits;
  final int? availableUnits;
  final double? startingPrice;
  final double? maxPrice;
  final String? priceUnit; // per sq ft, per unit, etc.
  final List<String>? amenities;
  final List<String>? propertyTypes; // 1BHK, 2BHK, 3BHK, etc.
  final String? reraNumber;
  final DateTime? launchDate;
  final DateTime? possessionDate;
  final String? projectManager;
  final String? projectManagerId;
  final List<String>? images;
  final String? brochureUrl;
  final String? floorPlanUrl;
  final String? locationMapUrl;
  final bool isActive;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? customFields;

  const Project({
    required this.id,
    required this.name,
    this.description,
    required this.developerId,
    required this.developerName,
    required this.type,
    required this.status,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.country = 'India',
    this.totalArea,
    this.totalUnits,
    this.availableUnits,
    this.startingPrice,
    this.maxPrice,
    this.priceUnit,
    this.amenities,
    this.propertyTypes,
    this.reraNumber,
    this.launchDate,
    this.possessionDate,
    this.projectManager,
    this.projectManagerId,
    this.images,
    this.brochureUrl,
    this.floorPlanUrl,
    this.locationMapUrl,
    required this.isActive,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    this.customFields,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    String? s(String a, String b) =>
        (json[a] as String?) ?? (json[b] as String?);
    T enumVal<T>(List<T> values, String a, String b, T fallback) {
      final String? v = s(a, b);
      if (v == null) return fallback;
      return values.firstWhere((e) {
        final String enumName = e.toString().split('.').last;
        return enumName == v;
      }, orElse: () => fallback);
    }

    num? n(String a, String b) => (json[a] as num?) ?? (json[b] as num?);
    bool b(String a, String b, bool d) =>
        (json[a] as bool?) ?? (json[b] as bool?) ?? d;

    return Project(
      id: s('id', 'id') ?? '',
      name: s('name', 'name') ?? '',
      description: s('description', 'description'),
      developerId: s('developerId', 'developer_id') ?? '',
      developerName: s('developerName', 'developer_name') ?? '',
      type: enumVal<ProjectType>(
        ProjectType.values,
        'type',
        'type',
        ProjectType.residential,
      ),
      status: enumVal<ProjectStatus>(
        ProjectStatus.values,
        'status',
        'status',
        ProjectStatus.planning,
      ),
      address: s('address', 'address'),
      city: s('city', 'city'),
      state: s('state', 'state'),
      pincode: s('pincode', 'pincode'),
      country: s('country', 'country') ?? 'India',
      totalArea: n('totalArea', 'total_area')?.toDouble(),
      totalUnits: (json['totalUnits'] as int?) ?? (json['total_units'] as int?),
      availableUnits:
          (json['availableUnits'] as int?) ?? (json['available_units'] as int?),
      startingPrice: n('startingPrice', 'starting_price')?.toDouble(),
      maxPrice: n('maxPrice', 'max_price')?.toDouble(),
      priceUnit: s('priceUnit', 'price_unit'),
      amenities: (json['amenities'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      propertyTypes: (json['propertyTypes'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      reraNumber: s('reraNumber', 'rera_number'),
      launchDate: s('launchDate', 'launch_date') != null
          ? DateTime.parse(s('launchDate', 'launch_date')!)
          : null,
      possessionDate: s('possessionDate', 'possession_date') != null
          ? DateTime.parse(s('possessionDate', 'possession_date')!)
          : null,
      projectManager: s('projectManager', 'project_manager'),
      projectManagerId: s('projectManagerId', 'project_manager_id'),
      images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
      brochureUrl: s('brochureUrl', 'brochure_url'),
      floorPlanUrl: s('floorPlanUrl', 'floor_plan_url'),
      locationMapUrl: s('locationMapUrl', 'location_map_url'),
      isActive: b('isActive', 'is_active', true),
      createdBy: s('createdBy', 'created_by') ?? '',
      createdByName: s('createdByName', 'created_by_name') ?? '',
      createdAt: DateTime.parse(
        s('createdAt', 'created_at') ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        s('updatedAt', 'updated_at') ?? DateTime.now().toIso8601String(),
      ),
      customFields:
          (json['customFields'] as Map<String, dynamic>?) ??
          json['custom_fields'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'developerId': developerId,
      'developerName': developerName,
      'type': type.name,
      'status': status.name,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
      'totalArea': totalArea,
      'totalUnits': totalUnits,
      'availableUnits': availableUnits,
      'startingPrice': startingPrice,
      'maxPrice': maxPrice,
      'priceUnit': priceUnit,
      'amenities': amenities,
      'propertyTypes': propertyTypes,
      'reraNumber': reraNumber,
      'launchDate': launchDate?.toIso8601String(),
      'possessionDate': possessionDate?.toIso8601String(),
      'projectManager': projectManager,
      'projectManagerId': projectManagerId,
      'images': images,
      'brochureUrl': brochureUrl,
      'floorPlanUrl': floorPlanUrl,
      'locationMapUrl': locationMapUrl,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'customFields': customFields,
    };
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? developerId,
    String? developerName,
    ProjectType? type,
    ProjectStatus? status,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? country,
    double? totalArea,
    int? totalUnits,
    int? availableUnits,
    double? startingPrice,
    double? maxPrice,
    String? priceUnit,
    List<String>? amenities,
    List<String>? propertyTypes,
    String? reraNumber,
    DateTime? launchDate,
    DateTime? possessionDate,
    String? projectManager,
    String? projectManagerId,
    List<String>? images,
    String? brochureUrl,
    String? floorPlanUrl,
    String? locationMapUrl,
    bool? isActive,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? customFields,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      developerId: developerId ?? this.developerId,
      developerName: developerName ?? this.developerName,
      type: type ?? this.type,
      status: status ?? this.status,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
      totalArea: totalArea ?? this.totalArea,
      totalUnits: totalUnits ?? this.totalUnits,
      availableUnits: availableUnits ?? this.availableUnits,
      startingPrice: startingPrice ?? this.startingPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      priceUnit: priceUnit ?? this.priceUnit,
      amenities: amenities ?? this.amenities,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      reraNumber: reraNumber ?? this.reraNumber,
      launchDate: launchDate ?? this.launchDate,
      possessionDate: possessionDate ?? this.possessionDate,
      projectManager: projectManager ?? this.projectManager,
      projectManagerId: projectManagerId ?? this.projectManagerId,
      images: images ?? this.images,
      brochureUrl: brochureUrl ?? this.brochureUrl,
      floorPlanUrl: floorPlanUrl ?? this.floorPlanUrl,
      locationMapUrl: locationMapUrl ?? this.locationMapUrl,
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
    return 'Project(id: $id, name: $name, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
