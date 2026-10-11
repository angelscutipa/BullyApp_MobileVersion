// lib/features/nfc/data/models/link_chip_response_model.dart

class LinkChipResponseModel {
  final String status;
  final String message;
  final Map<String, dynamic>? data;

  LinkChipResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory LinkChipResponseModel.fromJson(Map<String, dynamic> json) {
    return LinkChipResponseModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}