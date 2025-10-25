class MeetingStatusOption {
  final String id;
  final String name;
  final String displayName;
  final String? description;
  final String? colorCode;
  final String? iconName;
  final int sortOrder;
  final bool isActive;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MeetingStatusOption({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    this.colorCode,
    this.iconName,
    required this.sortOrder,
    required this.isActive,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MeetingStatusOption.fromJson(Map<String, dynamic> json) {
    return MeetingStatusOption(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      description: json['description'] as String?,
      colorCode: json['color_code'] as String?,
      iconName: json['icon_name'] as String?,
      sortOrder: json['sort_order'] as int,
      isActive: json['is_active'] as bool,
      isDefault: json['is_default'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'description': description,
      'color_code': colorCode,
      'icon_name': iconName,
      'sort_order': sortOrder,
      'is_active': isActive,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'MeetingStatusOption(id: $id, name: $name, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MeetingStatusOption && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
