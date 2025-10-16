class AuthUser {
  final String id;
  final String email;
  final String? phone;
  final String? fullName;
  final String? avatarUrl;
  final bool emailConfirmed;
  final bool phoneConfirmed;
  final DateTime createdAt;
  final DateTime? lastSignInAt;
  final Map<String, dynamic>? metadata;

  const AuthUser({
    required this.id,
    required this.email,
    this.phone,
    this.fullName,
    this.avatarUrl,
    this.emailConfirmed = false,
    this.phoneConfirmed = false,
    required this.createdAt,
    this.lastSignInAt,
    this.metadata,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      emailConfirmed: json['email_confirmed_at'] != null,
      phoneConfirmed: json['phone_confirmed_at'] != null,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastSignInAt: json['last_sign_in_at'] != null
          ? DateTime.parse(json['last_sign_in_at'] as String)
          : null,
      metadata: json['user_metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'email_confirmed_at': emailConfirmed
          ? DateTime.now().toIso8601String()
          : null,
      'phone_confirmed_at': phoneConfirmed
          ? DateTime.now().toIso8601String()
          : null,
      'created_at': createdAt.toIso8601String(),
      'last_sign_in_at': lastSignInAt?.toIso8601String(),
      'user_metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'AuthUser(id: $id, email: $email, fullName: $fullName)';
  }
}

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime expiresAt;
  final AuthUser user;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.expiresAt,
    required this.user,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'expires_at': expiresAt.toIso8601String(),
      'user': user.toJson(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  String toString() {
    return 'AuthSession(accessToken: ${accessToken.substring(0, 10)}..., expiresAt: $expiresAt)';
  }
}

class SignInRequest {
  final String email;
  final String password;

  const SignInRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class SignUpRequest {
  final String email;
  final String password;
  final String? fullName;
  final String? phone;
  final Map<String, dynamic>? metadata;

  const SignUpRequest({
    required this.email,
    required this.password,
    this.fullName,
    this.phone,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'data': {'full_name': fullName, 'phone': phone, ...?metadata},
    };
  }
}

class PasswordResetRequest {
  final String email;

  const PasswordResetRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class PasswordUpdateRequest {
  final String newPassword;

  const PasswordUpdateRequest({required this.newPassword});

  Map<String, dynamic> toJson() {
    return {'password': newPassword};
  }
}
