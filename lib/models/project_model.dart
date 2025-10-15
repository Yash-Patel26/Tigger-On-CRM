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
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      developerId: json['developerId'] as String,
      developerName: json['developerName'] as String,
      type: ProjectType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProjectType.residential,
      ),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProjectStatus.planning,
      ),
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      country: json['country'] as String? ?? 'India',
      totalArea: json['totalArea'] != null
          ? (json['totalArea'] as num).toDouble()
          : null,
      totalUnits: json['totalUnits'] as int?,
      availableUnits: json['availableUnits'] as int?,
      startingPrice: json['startingPrice'] != null
          ? (json['startingPrice'] as num).toDouble()
          : null,
      maxPrice: json['maxPrice'] != null
          ? (json['maxPrice'] as num).toDouble()
          : null,
      priceUnit: json['priceUnit'] as String?,
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'] as List)
          : null,
      propertyTypes: json['propertyTypes'] != null
          ? List<String>.from(json['propertyTypes'] as List)
          : null,
      reraNumber: json['reraNumber'] as String?,
      launchDate: json['launchDate'] != null
          ? DateTime.parse(json['launchDate'] as String)
          : null,
      possessionDate: json['possessionDate'] != null
          ? DateTime.parse(json['possessionDate'] as String)
          : null,
      projectManager: json['projectManager'] as String?,
      projectManagerId: json['projectManagerId'] as String?,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : null,
      brochureUrl: json['brochureUrl'] as String?,
      floorPlanUrl: json['floorPlanUrl'] as String?,
      locationMapUrl: json['locationMapUrl'] as String?,
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
