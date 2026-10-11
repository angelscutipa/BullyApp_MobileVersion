import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  static Future<void> checkPermissions() async {
    await [
      Permission.camera,
      Permission.photos, // Para iOS/Android 13+
      Permission.storage, // Para Android 12 e inferiores
      Permission.videos,
    ].request();
  }
}
