class UserLoginLocation {
  final String id;
  final String userId;
  final DateTime loginTimestamp;
  final String? ipAddress;
  final String? country;
  final String? countryCode;
  final String? state;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? timezone;
  final String? deviceType;
  final String? deviceOs;
  final String? browser;
  final String? userAgent;
  final bool isSuccessful;
  final String? failureReason;
  final String? sessionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserLoginLocation({
    required this.id,
    required this.userId,
    required this.loginTimestamp,
    this.ipAddress,
    this.country,
    this.countryCode,
    this.state,
    this.city,
    this.latitude,
    this.longitude,
    this.timezone,
    this.deviceType,
    this.deviceOs,
    this.browser,
    this.userAgent,
    this.isSuccessful = true,
    this.failureReason,
    this.sessionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserLoginLocation.fromJson(Map<String, dynamic> json) {
    return UserLoginLocation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      loginTimestamp: DateTime.parse(json['login_timestamp'] as String),
      ipAddress: json['ip_address'] as String?,
      country: json['country'] as String?,
      countryCode: json['country_code'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      timezone: json['timezone'] as String?,
      deviceType: json['device_type'] as String?,
      deviceOs: json['device_os'] as String?,
      browser: json['browser'] as String?,
      userAgent: json['user_agent'] as String?,
      isSuccessful: json['is_successful'] as bool? ?? true,
      failureReason: json['failure_reason'] as String?,
      sessionId: json['session_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'login_timestamp': loginTimestamp.toIso8601String(),
      'ip_address': ipAddress,
      'country': country,
      'country_code': countryCode,
      'state': state,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'device_type': deviceType,
      'device_os': deviceOs,
      'browser': browser,
      'user_agent': userAgent,
      'is_successful': isSuccessful,
      'failure_reason': failureReason,
      'session_id': sessionId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserLoginLocation copyWith({
    String? id,
    String? userId,
    DateTime? loginTimestamp,
    String? ipAddress,
    String? country,
    String? countryCode,
    String? state,
    String? city,
    double? latitude,
    double? longitude,
    String? timezone,
    String? deviceType,
    String? deviceOs,
    String? browser,
    String? userAgent,
    bool? isSuccessful,
    String? failureReason,
    String? sessionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserLoginLocation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      loginTimestamp: loginTimestamp ?? this.loginTimestamp,
      ipAddress: ipAddress ?? this.ipAddress,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      state: state ?? this.state,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
      deviceType: deviceType ?? this.deviceType,
      deviceOs: deviceOs ?? this.deviceOs,
      browser: browser ?? this.browser,
      userAgent: userAgent ?? this.userAgent,
      isSuccessful: isSuccessful ?? this.isSuccessful,
      failureReason: failureReason ?? this.failureReason,
      sessionId: sessionId ?? this.sessionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserLoginLocation(id: $id, userId: $userId, loginTimestamp: $loginTimestamp, country: $country, city: $city, deviceType: $deviceType, isSuccessful: $isSuccessful)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserLoginLocation &&
        other.id == id &&
        other.userId == userId &&
        other.loginTimestamp == loginTimestamp &&
        other.ipAddress == ipAddress &&
        other.country == country &&
        other.countryCode == countryCode &&
        other.state == state &&
        other.city == city &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.timezone == timezone &&
        other.deviceType == deviceType &&
        other.deviceOs == deviceOs &&
        other.browser == browser &&
        other.userAgent == userAgent &&
        other.isSuccessful == isSuccessful &&
        other.failureReason == failureReason &&
        other.sessionId == sessionId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      loginTimestamp,
      ipAddress,
      country,
      countryCode,
      state,
      city,
      latitude,
      longitude,
      timezone,
      deviceType,
      deviceOs,
      browser,
      userAgent,
      isSuccessful,
      failureReason,
      sessionId,
      createdAt,
      updatedAt,
    );
  }
}
