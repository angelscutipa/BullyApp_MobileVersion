import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  static Future<void> checkPermissions() async {
    final permissions = <Permission>[
      Permission.camera,
      Permission.photos, // Para iOS/Android 13+
      if (defaultTargetPlatform == TargetPlatform.android) ...[
        Permission.storage, // Para Android 12 e inferiores
        Permission.videos,
        // En iOS el permiso de notificaciones lo gestiona exclusivamente FirebaseMessaging
        Permission.notification,
      ],
    ];

    await permissions.request();
  }
}
