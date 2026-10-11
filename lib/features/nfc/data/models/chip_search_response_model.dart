// lib/features/nfc/data/models/chip_search_response_model.dart

class ChipData {
  final int id;
  final String correlativo;
  final String code;
  final String codeHex;
  final String codeDecimal;
  final String status;
  final int? animalId;
  final Map<String, dynamic>? animal;

  ChipData({
    required this.id,
    required this.correlativo,
    required this.code,
    required this.codeHex,
    required this.codeDecimal,
    required this.status,
    this.animalId,
    this.animal,
  });

  factory ChipData.fromJson(Map<String, dynamic> json) {
    return ChipData(
      id: json['id'] as int,
      correlativo: json['correlativo'] ?? '',
      code: json['code'] ?? '',
      codeHex: json['code_hex'] ?? '',
      codeDecimal: json['code_decimal'] ?? '',
      status: json['status'] ?? '',
      animalId: json['animal_id'] as int?,
      animal: json['animal'] as Map<String, dynamic>?,
    );
  }
}

class ChipSearchResponseModel {
  final String status;
  final String message;
  final ChipData? chip;

  ChipSearchResponseModel({
    required this.status,
    required this.message,
    this.chip,
  });

  factory ChipSearchResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    
    return ChipSearchResponseModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      chip: data?['chip'] != null 
          ? ChipData.fromJson(data!['chip'] as Map<String, dynamic>) 
          : null,
    );
  }
}