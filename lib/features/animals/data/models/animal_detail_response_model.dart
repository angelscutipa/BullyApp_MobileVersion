class ChipInfo {
  final int id;
  final String code;
  final int? animalId;
  final String status;
  final String? correlativo;

  ChipInfo({
    required this.id,
    required this.code,
    this.animalId,
    required this.status,
    this.correlativo,
  });

  factory ChipInfo.fromJson(Map<String, dynamic> json) {
    return ChipInfo(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      animalId: json['animal_id'],
      status: json['status'] ?? '',
      correlativo: json['correlativo'],
    );
  }
}

class TrophyInfo {
  final String? photo;
  final String? championship;
  final String? position;
  final String? date;
  final bool verified;
  final String? breed;
  final String? ageCategory;
  final String? sex;
  final String? category;

  TrophyInfo({
    this.photo,
    this.championship,
    this.position,
    this.date,
    this.verified = false,
    this.breed,
    this.ageCategory,
    this.sex,
    this.category,
  });

  factory TrophyInfo.fromJson(Map<String, dynamic> json) {
    return TrophyInfo(
      photo: json['photo'],
      championship: json['championship'],
      position: json['position']?.toString(),
      date: json['date'],
      verified: json['verified'] ?? false,
      breed: json['breed'],
      ageCategory: json['age_category'],
      sex: json['sex'],
      category: json['category'],
    );
  }
}

class UserOwnerInfo {
  final int? id;
  final int? userId;
  final String? firstName;
  final String? lastName;
  final String? documentType;
  final String? documentNumber;
  final String? birthdate;
  final String? phone;
  final String? country;
  final String? city;
  final String? department;
  final String? address;
  final String? addressMaps;
  final String? profilePhoto;
  final List<String> banner;
  final bool isVerified;
  final bool isActive;
  final String? bio;

  UserOwnerInfo({
    this.id,
    this.userId,
    this.firstName,
    this.lastName,
    this.documentType,
    this.documentNumber,
    this.birthdate,
    this.phone,
    this.country,
    this.city,
    this.department,
    this.address,
    this.addressMaps,
    this.profilePhoto,
    this.banner = const [],
    this.isVerified = false,
    this.isActive = true,
    this.bio,
  });

  factory UserOwnerInfo.fromJson(Map<String, dynamic> json) {
    return UserOwnerInfo(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      documentType: json['document_type'] as String?,
      documentNumber: json['document_number'] as String?,
      birthdate: json['birthdate'] as String?,
      phone: json['phone'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      department: json['department'] as String?,
      address: json['address'] as String?,
      addressMaps: json['address_maps'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      banner: json['banner'] != null
          ? (json['banner'] as List).map((e) => e.toString()).toList()
          : [],
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      bio: json['bio'] as String?,
    );
  }
}

class UserInfo {
  final int? id;
  final String? name;
  final String? email;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? avatar;
  final bool isActive;
  final UserOwnerInfo? owner;

  UserInfo({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.avatar,
    this.isActive = true,
    this.owner,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      avatar: json['avatar'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      owner: json['owner'] != null
          ? UserOwnerInfo.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AnimalData {
  final int id;
  final String name;
  final String? microchip;
  final String? profilePhoto;
  final ChipInfo? chip;
  final List<TrophyInfo> trophies;
  final UserInfo? user;

  AnimalData({
    required this.id,
    required this.name,
    this.microchip,
    this.profilePhoto,
    this.chip,
    this.trophies = const [],
    this.user,
  });

  factory AnimalData.fromJson(Map<String, dynamic> json) {
    return AnimalData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      microchip: json['microchip'],
      profilePhoto: json['profile_photo'],
      chip: json['chip'] != null ? ChipInfo.fromJson(json['chip'] as Map<String, dynamic>) : null,
      trophies: json['trophies'] != null
          ? (json['trophies'] as List)
              .map((e) => TrophyInfo.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      user: json['user'] != null ? UserInfo.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }
}

class AnimalDetailResponseModel {
  final String status;
  final String message;
  final AnimalData? animal;

  AnimalDetailResponseModel({
    required this.status,
    required this.message,
    this.animal,
  });

  factory AnimalDetailResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return AnimalDetailResponseModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      animal: data?['animal'] != null ? AnimalData.fromJson(data!['animal'] as Map<String, dynamic>) : null,
    );
  }
}
