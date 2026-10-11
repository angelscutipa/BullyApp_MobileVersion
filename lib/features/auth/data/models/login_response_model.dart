// lib/features/auth/data/models/login_response_model.dart

class LoginResponseModel {
  final String status;
  final String message;
  final String? token;
  final String? tokenType;
  final Map<String, dynamic>? user;

  LoginResponseModel({
    required this.status,
    required this.message,
    this.token,
    this.tokenType,
    this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    return LoginResponseModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      token: data?['token'] as String?,
      tokenType: data?['token_type'] as String?,
      user: data?['user'] as Map<String, dynamic>?,
    );
  }
}