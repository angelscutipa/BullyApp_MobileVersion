class UserModel {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String? googleId;
  final String? facebookId;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.googleId,
    this.facebookId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(
                json['id']?.toString() ?? '',
              ) ??
              0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      googleId: json['google_id']?.toString(),
      facebookId: json['facebook_id']?.toString(),
    );
  }
}