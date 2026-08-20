import 'package:nfc_manager/nfc_manager.dart';

class NFCScanResult {
  final NfcTag tag;
  final DateTime timestamp;
  String tagType;
  String uid;
  final Map<String, dynamic> data;

  NFCScanResult({
    required this.tag,
    required this.timestamp,
    required this.tagType,
    required this.uid,
    required this.data,
  });
}