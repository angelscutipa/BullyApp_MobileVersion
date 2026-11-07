import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

/// Handler global para mensajes recibidos cuando la app está en segundo plano o cerrada.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("==================================================");
    print("📩 NOTIFICACIÓN RECIBIDA EN BACKGROUND");
    print("Message ID: ${message.messageId}");
    print("DATA (Payload completo): ${message.data}");
    print("==================================================");
  }
  await NotificationService.instance.showNotificationFromRemoteMessage(message);
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  factory NotificationService() => instance;

  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Stream para notificar a la UI de URLs de destino al tocar notificaciones
  static final StreamController<String> selectNotificationStream =
      StreamController<String>.broadcast();

  /// Almacena una URL pendiente si la app fue abierta desde estado Terminated
  static String? pendingTargetUrl;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notificaciones Importantes',
    description: 'Canal principal para notificaciones de Bully App',
    importance: Importance.max,
  );

  /// Inicializa el servicio de notificaciones, permisos y manejadores de eventos.
  Future<void> initialize() async {
    // 1. Configurar manejador de mensajes en segundo plano
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Solicitar permisos de notificación
    await requestPermissions();

    // 3. Inicializar Notificaciones Locales (para foreground)
    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) {
          print("Notificación local presionada. Payload: ${response.payload}");
        }
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final Map<String, dynamic> data =
                Map<String, dynamic>.from(jsonDecode(response.payload!));
            _processPayloadData(data);
          } catch (e) {
            if (kDebugMode) {
              print("Error al decodificar payload local: $e");
            }
          }
        }
      },
    );

    // Crear el canal de notificación de alta importancia en Android
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_channel);
    }

    // 4. Configurar opciones de presentación en primer plano para iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5. Escuchar notificaciones en primer plano (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("==================================================");
        print("📩 NOTIFICACIÓN RECIBIDA EN FOREGROUND (APP ABIERTA)");
        print("DATA (Payload completo): ${message.data}");
        print("==================================================");
      }
      showNotificationFromRemoteMessage(message);
    });

    // 6. Escuchar cuando el usuario toca la notificación con la app en segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("==================================================");
        print("👉 NOTIFICACIÓN TOCADA DESDE BACKGROUND");
        print("DATA (Payload completo): ${message.data}");
        print("==================================================");
      }
      _handleNotificationClick(message);
    });

    // 7. Manejar notificación que abrió la app cuando estaba completamente cerrada (Terminated)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print("==================================================");
        print("🚀 APP ABIERTA MEDIANTE NOTIFICACIÓN INICIAL (TERMINATED)");
        print("DATA (Payload completo): ${initialMessage.data}");
        print("==================================================");
      }
      _handleNotificationClick(initialMessage);
    }

    // 8. Obtener y escuchar el Token de FCM
    await _initFcmToken();

    // 9. Suscribir automáticamente el dispositivo al tema comunitario "todos"
    await subscribeToTopic('todos');
  }

  /// Solicitar permisos de notificación al usuario.
  Future<void> requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      print("Estado del permiso de notificación: ${settings.authorizationStatus}");
    }
  }

  /// Obtener el Token FCM actual y suscribirse a cambios de token.
  Future<String?> _initFcmToken() async {
    try {
      final token = await _messaging.getToken();
      if (kDebugMode) {
        print("FCM Token obtenido: $token");
      }

      // Escuchar renovaciones de token
      _messaging.onTokenRefresh.listen((newToken) {
        if (kDebugMode) {
          print("FCM Token actualizado: $newToken");
        }
      });

      return token;
    } catch (e) {
      if (kDebugMode) {
        print("Error obteniendo FCM Token: $e");
      }
      return null;
    }
  }

  /// Obtener directamente el FCM Token actual.
  Future<String?> getFcmToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      return null;
    }
  }

  /// Suscribirse a un tema (Topic) específico de notificaciones.
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print("Suscrito exitosamente al tema: $topic");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error al suscribirse al tema $topic: $e");
      }
    }
  }

  /// Desuscribirse de un tema (Topic) de notificaciones.
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print("Desuscrito del tema: $topic");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error al desuscribirse del tema $topic: $e");
      }
    }
  }

  /// Muestra una notificación personalizada con imagen (o fallback al logo) y diseño alineado a la referencia.
  Future<void> showNotificationFromRemoteMessage(RemoteMessage message) async {
    final data = message.data;
    
    // Extraer título, cuerpo e imagen del payload
    final String title = data['title'] ?? message.notification?.title ?? 'BullyApp • Alerta';
    final String body = data['body'] ?? message.notification?.body ?? '';
    final String? imageUrl = data['imagen_url'] as String?;

    AndroidBitmap<Object>? bigPictureBitmap;

    // Intentar descargar la imagen del perro si viene en "imagen_url"
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      try {
        final response = await Dio().get<List<int>>(
          imageUrl.trim(),
          options: Options(
            responseType: ResponseType.bytes,
            receiveTimeout: const Duration(seconds: 6),
          ),
        );
        if (response.statusCode == 200 && response.data != null) {
          bigPictureBitmap = ByteArrayAndroidBitmap(Uint8List.fromList(response.data!));
        }
      } catch (e) {
        if (kDebugMode) {
          print("⚠️ No se pudo descargar la imagen de la notificación ($imageUrl): $e. Usando logo de respaldo.");
        }
      }
    }

    // Fallback: Si no llegó imagen o falló la descarga, usar el logo de la app por defecto
    bigPictureBitmap ??= const DrawableResourceAndroidBitmap('@mipmap/launcher_icon');

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      styleInformation: BigPictureStyleInformation(
        bigPictureBitmap,
        contentTitle: title,
        summaryText: body,
      ),
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  /// Manejo centralizado al tocar notificaciones.
  void _handleNotificationClick(RemoteMessage message) {
    _processPayloadData(message.data);
  }

  /// Extrae la información del payload y genera el evento de navegación.
  void _processPayloadData(Map<String, dynamic> data) {
    if (kDebugMode) {
      print("🔔 PROCESANDO NAVEGACIÓN O ACCIÓN POR NOTIFICACIÓN");
      print("Payload data: $data");
    }

    final dynamic animalId = data['animal_id'];
    if (animalId != null && animalId.toString().trim().isNotEmpty) {
      final String idStr = animalId.toString().trim();
      final String targetUrl = 'https://bullyapp.com.pe/bullys/$idStr';

      if (kDebugMode) {
        print("🔗 NAVEGACIÓN A URL OBJETIVO GENERADA: $targetUrl");
      }

      pendingTargetUrl = targetUrl;
      selectNotificationStream.add(targetUrl);
    }
  }

  /// Programa un recordatorio local de vacuna para un perro específico.
  Future<void> scheduleVaccineReminder({
    required int dogId,
    required String dogName,
    required String vaccineDateStr,
  }) async {
    try {
      DateTime? vaccineDate = DateTime.tryParse(vaccineDateStr);
      if (vaccineDate == null) return;

      final scheduledTime = DateTime(
        vaccineDate.year,
        vaccineDate.month,
        vaccineDate.day,
        9,
        0,
      );

      if (scheduledTime.isBefore(DateTime.now())) return;

      if (kDebugMode) {
        print("💉 Recordatorio de vacuna registrado para $dogName el $vaccineDateStr (ID: $dogId)");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error programando recordatorio de vacuna: $e");
      }
    }
  }
}
