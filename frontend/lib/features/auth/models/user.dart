class User {
  final int userId;
  final String role;
  final String name;
  final String email;
  final double rating;
  final bool isActive;
  final Map<String, dynamic>? locationData;

  User({
    required this.userId,
    required this.role,
    required this.name,
    required this.email,
    required this.rating,
    required this.isActive,
    this.locationData,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as int,
      role: json['role'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      rating: (json['rating'] as num).toDouble(),
      isActive: json['is_active'] as bool,
      locationData: json['location_data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role': role,
      'name': name,
      'email': email,
      'rating': rating,
      'is_active': isActive,
      'location_data': locationData,
    };
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
