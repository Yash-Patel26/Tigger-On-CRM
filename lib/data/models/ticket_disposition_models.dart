class TicketDispositionMain {
  final String id;
  final String name;
  final bool isActive;
  final DateTime createdAt;

  const TicketDispositionMain({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
  });

  factory TicketDispositionMain.fromJson(Map<String, dynamic> json) {
    return TicketDispositionMain(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TicketDispositionMain copyWith({
    String? id,
    String? name,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return TicketDispositionMain(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TicketDispositionSub {
  final String id;
  final String mainId;
  final String name;
  final bool isActive;
  final DateTime createdAt;

  const TicketDispositionSub({
    required this.id,
    required this.mainId,
    required this.name,
    required this.isActive,
    required this.createdAt,
  });

  factory TicketDispositionSub.fromJson(Map<String, dynamic> json) {
    return TicketDispositionSub(
      id: json['id'] as String,
      mainId: json['main_id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'main_id': mainId,
      'name': name,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TicketDispositionSub copyWith({
    String? id,
    String? mainId,
    String? name,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return TicketDispositionSub(
      id: id ?? this.id,
      mainId: mainId ?? this.mainId,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
