class NfcResponseModel {
  final String? status;
  final DogData? data;
  final String? message;

  NfcResponseModel({
    this.status,
    this.data,
    this.message,
  });

  factory NfcResponseModel.fromJson(Map<String, dynamic> json) {
    return NfcResponseModel(
      status: json['status'] as String?,
      data: json['data'] != null ? DogData.fromJson(json['data'] as Map<String, dynamic>) : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.toJson(),
      'message': message,
    };
  }
}

class DogData {
  final int? id;
  final String? name;
  final String? breed;
  final String? color;
  final String? gender;
  final String? birthDateFormatted;
  final String? registrationNumber;
  final String? registrySource;
  final String? sex;
  final String? microchip;
  final String? chipCorrelativo;
  final bool? isVerified;
  final bool? isHomologated;
  final String? photo;
  final String? status;
  final KennelModel? kennel;
  final OwnerModel? owner;
  final ChipModel? chip;

  DogData({
    this.id,
    this.name,
    this.breed,
    this.color,
    this.gender,
    this.birthDateFormatted,
    this.registrationNumber,
    this.registrySource,
    this.sex,
    this.microchip,
    this.chipCorrelativo,
    this.isVerified,
    this.isHomologated,
    this.photo,
    this.status,
    this.kennel,
    this.owner,
    this.chip,
  });

  factory DogData.fromJson(Map<String, dynamic> json) {
    // Extraemos la fecha formateada directamente para no complicarnos con todo el objeto anidado de fecha
    final birthDateMap = json['birth_date'] as Map<String, dynamic>?;
    final formattedDate = birthDateMap?['formatted'] as String?;

    return DogData(
      id: json['id'] as int?,
      name: json['name'] as String?,
      breed: json['breed'] as String?,
      color: json['color'] as String?,
      gender: json['gender'] as String?,
      birthDateFormatted: formattedDate,
      registrationNumber: json['registration_number'] as String?,
      registrySource: json['registry_source'] as String?,
      sex: json['sex'] as String?,
      microchip: json['microchip'] as String?,
      chipCorrelativo: json['chip_correlativo'] as String?,
      isVerified: json['is_verified'] as bool?,
      isHomologated: json['is_homologated'] as bool?,
      photo: json['photo'] as String?,
      status: json['status'] as String?,
      kennel: json['kennel'] != null ? KennelModel.fromJson(json['kennel'] as Map<String, dynamic>) : null,
      owner: json['owner'] != null ? OwnerModel.fromJson(json['owner'] as Map<String, dynamic>) : null,
      chip: json['chip'] != null ? ChipModel.fromJson(json['chip'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'color': color,
      'gender': gender,
      'registration_number': registrationNumber,
      'registry_source': registrySource,
      'sex': sex,
      'microchip': microchip,
      'chip_correlativo': chipCorrelativo,
      'is_verified': isVerified,
      'is_homologated': isHomologated,
      'photo': photo,
      'status': status,
      'kennel': kennel?.toJson(),
      'owner': owner?.toJson(),
      'chip': chip?.toJson(),
    };
  }
}

class KennelModel {
  final int? id;
  final String? name;
  final String? affix;

  KennelModel({this.id, this.name, this.affix});

  factory KennelModel.fromJson(Map<String, dynamic> json) {
    return KennelModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      affix: json['affix'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'affix': affix};
}

class OwnerModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? city;
  final String? profilePhoto;
  final bool? isVerified;

  OwnerModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.city,
    this.profilePhoto,
    this.isVerified,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      isVerified: json['is_verified'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'profile_photo': profilePhoto,
      'is_verified': isVerified,
    };
  }
}

class ChipModel {
  final int? id;
  final String? code;
  final String? codeHex;
  final String? correlativo;
  final String? status;

  ChipModel({
    this.id,
    this.code,
    this.codeHex,
    this.correlativo,
    this.status,
  });

  factory ChipModel.fromJson(Map<String, dynamic> json) {
    return ChipModel(
      id: json['id'] as int?,
      code: json['code'] as String?,
      codeHex: json['code_hex'] as String?,
      correlativo: json['correlativo'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'code_hex': codeHex,
      'correlativo': correlativo,
      'status': status,
    };
  }
}